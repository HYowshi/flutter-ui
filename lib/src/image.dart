import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'adaptive.dart';

/// Responsive asset/network image with stable geometry, decode hints and fallbacks.
class UIImage extends StatefulWidget {
  const UIImage(
    this.source, {
    super.key,
    this.semanticLabel,
    this.fallbackSource,
    this.fallback,
    this.placeholder,
    this.errorBuilder,
    this.aspectRatio = 16 / 9,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.width,
    this.height,
    this.borderRadius = 16,
    this.variants = const {},
    this.optimizeDecode = true,
    this.allowRetry = true,
  }) : assert(aspectRatio > 0 && aspectRatio < double.infinity),
       assert(borderRadius >= 0 && borderRadius < double.infinity),
       assert(width == null || width > 0 && width < double.infinity),
       assert(height == null || height > 0 && height < double.infinity),
       _shape = 'image',
       provider = null;
  const UIImage.avatar(
    this.source, {
    super.key,
    double size = 48,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.variants = const {},
    this.optimizeDecode = true,
    this.allowRetry = false,
    this.semanticLabel,
    this.fallbackSource,
    this.fallback,
    this.placeholder,
    this.errorBuilder,
  }) : assert(size > 0 && size < double.infinity),
       width = size,
       height = size,
       aspectRatio = 1,
       borderRadius = 999,
       _shape = 'avatar',
       provider = null;
  const UIImage.thumbnail(
    this.source, {
    super.key,
    double size = 80,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.variants = const {},
    this.optimizeDecode = true,
    this.allowRetry = false,
    this.semanticLabel,
    this.fallbackSource,
    this.fallback,
    this.placeholder,
    this.errorBuilder,
  }) : assert(size > 0 && size < double.infinity),
       width = size,
       height = size,
       aspectRatio = 1,
       borderRadius = 12,
       _shape = 'thumbnail',
       provider = null;
  const UIImage.banner(
    this.source, {
    super.key,
    this.semanticLabel,
    this.fallbackSource,
    this.fallback,
    this.placeholder,
    this.errorBuilder,
    this.variants = const {},
    this.height,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.borderRadius = 16,
    this.optimizeDecode = true,
    this.allowRetry = true,
  }) : assert(height == null || height > 0 && height < double.infinity),
       assert(borderRadius >= 0 && borderRadius < double.infinity),
       width = null,
       aspectRatio = 16 / 9,
       _shape = 'banner',
       provider = null;
  const UIImage.provider(
    this.provider, {
    super.key,
    this.semanticLabel,
    this.fallbackSource,
    this.fallback,
    this.placeholder,
    this.errorBuilder,
    this.aspectRatio = 16 / 9,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.borderRadius = 16,
    this.optimizeDecode = true,
    this.allowRetry = false,
  }) : assert(provider != null),
       assert(aspectRatio > 0 && aspectRatio < double.infinity),
       assert(borderRadius >= 0 && borderRadius < double.infinity),
       assert(width == null || width > 0 && width < double.infinity),
       assert(height == null || height > 0 && height < double.infinity),
       source = null,
       variants = const {},
       _shape = 'image';

  /// Null/blank means unavailable; it does not initiate an asset request.
  final String? source;

  /// Asset or HTTP(S) source used once if the primary image is unavailable.
  final String? fallbackSource;

  /// Final fallback if both sources fail. Kept inside the original frame/clip.
  final Widget? fallback;

  /// Static loading content, shared by the main and fallback image.
  final Widget? placeholder;

  /// Full override of the error UI, with the primary error. Takes priority
  /// over fallbackSource/fallback. No automatic retry is inserted into it.
  final ImageErrorWidgetBuilder? errorBuilder;
  final ImageProvider? provider;
  final String? semanticLabel;
  final double aspectRatio, borderRadius;
  final double? width, height;
  final BoxFit fit;
  final AlignmentGeometry alignment;

  /// Optional original-width -> source variants; also reduces web download size.
  final Map<int, String> variants;
  final bool optimizeDecode, allowRetry;
  final String _shape;
  @override
  State<UIImage> createState() => _UIImageState();
}

class _UIImageState extends State<UIImage> {
  int _retry = 0;
  int _generation = 0;
  int? _retryGeneration;
  Object? _activeIdentity;

  ImageProvider? _sourceProvider(String? source) {
    // Reject control characters before trimming; never reinterpret these as assets.
    if (source != null && source.codeUnits.any((c) => c < 32 || c == 127)) {
      return null;
    }
    final value = source?.trim() ?? '';
    if (value.isEmpty) return null;
    final uri = Uri.tryParse(value);
    if (uri == null) return null;
    if (uri.scheme == 'https' || uri.scheme == 'http') {
      return uri.host.isEmpty || uri.userInfo.isNotEmpty
          ? null
          : NetworkImage(value);
    }
    // Other schemes need an explicit ImageProvider, not an accidental asset request.
    if (uri.hasScheme || value.startsWith('//')) return null;
    return AssetImage(value);
  }

  Future<void> _tryAgain(
    ImageProvider image,
    ImageProvider original,
    int generation,
  ) async {
    if (_retryGeneration == generation) return;
    _retryGeneration = generation;
    // Invalidate the actual resized key, not just the original provider key.
    try {
      await image.evict();
      if (image != original) await original.evict();
      if (mounted && _generation == generation) setState(() => _retry++);
    } catch (_) {
      // Custom providers may fail to obtain an eviction key. The current error
      // UI remains usable; never leak an unhandled asynchronous exception.
    } finally {
      if (_retryGeneration == generation) _retryGeneration = null;
    }
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => UIAdaptiveBuilder(
      builder: (context, ui) {
        final scheme = Theme.of(context).colorScheme;
        final ratio = widget._shape == 'banner' && !ui.compact
            ? 21 / 9
            : widget.aspectRatio;
        var width = math.min(widget.width ?? ui.width, ui.width);
        var height = widget.height ?? width / ratio;
        final square =
            widget._shape == 'avatar' || widget._shape == 'thumbnail';
        if (square) {
          if (constraints.hasBoundedHeight) {
            width = math.min(width, constraints.maxHeight);
          }
          height = width;
        } else if (constraints.hasBoundedHeight) {
          height = math.min(height, constraints.maxHeight);
        }
        if (width <= 0 || height <= 0) return const SizedBox.shrink();
        final physical = (width * MediaQuery.devicePixelRatioOf(context))
            .ceil();
        final bucket = ((physical / 128).ceil() * 128).clamp(128, 2048);
        ImageProvider decoded(ImageProvider original) =>
            widget.optimizeDecode && !kIsWeb
            ? ResizeImage.resizeIfNeeded(bucket, null, original)
            : original;
        var source = widget.source;
        if (widget.variants.isNotEmpty) {
          // One scan: no sorted lists allocated on every layout/resize.
          int? adequate, largest;
          for (final entry in widget.variants.entries) {
            final size = entry.key;
            if (size <= 0) {
              throw ArgumentError('Image variant widths must be positive.');
            }
            if (entry.value.trim().isEmpty) continue;
            if (largest == null || size > largest) largest = size;
            if (size >= physical && (adequate == null || size < adequate)) {
              adequate = size;
            }
          }
          final size = adequate ?? largest;
          if (size != null) source = widget.variants[size];
        }

        final original = widget.provider ?? _sourceProvider(source);
        Widget neutral(IconData icon) => ColoredBox(
          color: scheme.surfaceContainerHigh,
          child: Center(
            child: Icon(
              icon,
              color: scheme.onSurfaceVariant,
              size: math.min(32, math.min(width, height) * .45),
            ),
          ),
        );
        Widget loading() => widget.placeholder ?? neutral(Icons.image_outlined);
        Widget terminal() =>
            widget.fallback ?? neutral(Icons.broken_image_outlined);
        Widget fade(
          BuildContext context,
          Widget child,
          int? frame,
          bool sync,
        ) => Stack(
          fit: StackFit.expand,
          children: [
            if (frame == null) loading(),
            AnimatedOpacity(
              opacity: frame == null ? 0 : 1,
              duration: sync || MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero
                  : const Duration(milliseconds: 160),
              child: child,
            ),
          ],
        );
        Widget imageWidget(
          ImageProvider provider, {
          required Object identity,
          required ImageErrorWidgetBuilder errorBuilder,
        }) => Image(
          key: ValueKey((identity, _retry)),
          image: decoded(provider),
          width: width,
          height: height,
          fit: widget.fit,
          alignment: widget.alignment,
          filterQuality: FilterQuality.medium,
          excludeFromSemantics: true,
          gaplessPlayback: false,
          frameBuilder: fade,
          errorBuilder: errorBuilder,
        );
        final currentIdentity = (source, widget.provider, bucket);
        if (_activeIdentity != currentIdentity) {
          _activeIdentity = currentIdentity;
          _generation++;
        }
        final generation = _generation;
        Widget defaultError() {
          if (!widget.allowRetry ||
              original == null ||
              width < 48 ||
              height < 48) {
            return terminal();
          }
          final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
          void retry() {
            // A callback from an old source cannot refresh a different source.
            if (mounted && _generation == generation) {
              _tryAgain(decoded(original), original, generation);
            }
          }

          return ColoredBox(
            color: scheme.surfaceContainerHigh,
            child: Center(
              child: width >= 180 * scale && height >= 80 * scale
                  ? TextButton.icon(
                      onPressed: retry,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Thử lại ảnh'),
                    )
                  : IconButton(
                      onPressed: retry,
                      tooltip: 'Thử lại ảnh',
                      icon: const Icon(Icons.refresh_rounded),
                    ),
            ),
          );
        }

        Widget error(BuildContext context, Object error, StackTrace? stack) {
          if (widget.errorBuilder != null) {
            return widget.errorBuilder!(context, error, stack);
          }
          final backup = _sourceProvider(widget.fallbackSource);
          if (backup == null || backup == original) {
            return widget.fallback ?? defaultError();
          }
          return imageWidget(
            backup,
            identity: ('fallback', backup),
            errorBuilder: (context, error, stack) => terminal(),
          );
        }

        final visual = ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: SizedBox(
            width: width,
            height: height,
            child: original == null
                ? error(
                    context,
                    StateError('Image source is unavailable.'),
                    null,
                  )
                : imageWidget(
                    original,
                    identity: currentIdentity,
                    errorBuilder: error,
                  ),
          ),
        );
        return Semantics(
          label: widget.semanticLabel,
          image: widget.semanticLabel != null,
          container: true,
          child: Align(
            alignment: AlignmentDirectional.topStart,
            widthFactor: 1,
            heightFactor: 1,
            child: visual,
          ),
        );
      },
    ),
  );
}

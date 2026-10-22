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
    this.aspectRatio = 16 / 9,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.width,
    this.height,
    this.borderRadius = 16,
    this.variants = const {},
    this.optimizeDecode = true,
    this.allowRetry = true,
  }) : assert(aspectRatio > 0),
       assert(width == null || width > 0),
       assert(height == null || height > 0),
       _shape = 'image',
       provider = null;
  const UIImage.avatar(
    this.source, {
    super.key,
    double size = 48,
    this.semanticLabel,
  }) : assert(size > 0),
       width = size,
       height = size,
       aspectRatio = 1,
       fit = BoxFit.cover,
       alignment = Alignment.center,
       borderRadius = 999,
       variants = const {},
       optimizeDecode = true,
       allowRetry = false,
       _shape = 'avatar',
       provider = null;
  const UIImage.thumbnail(
    this.source, {
    super.key,
    double size = 80,
    this.semanticLabel,
  }) : assert(size > 0),
       width = size,
       height = size,
       aspectRatio = 1,
       fit = BoxFit.cover,
       alignment = Alignment.center,
       borderRadius = 12,
       variants = const {},
       optimizeDecode = true,
       allowRetry = false,
       _shape = 'thumbnail',
       provider = null;
  const UIImage.banner(
    this.source, {
    super.key,
    this.semanticLabel,
    this.variants = const {},
  }) : width = null,
       height = null,
       aspectRatio = 16 / 9,
       fit = BoxFit.cover,
       alignment = Alignment.center,
       borderRadius = 16,
       optimizeDecode = true,
       allowRetry = true,
       _shape = 'banner',
       provider = null;
  const UIImage.provider(
    this.provider, {
    super.key,
    this.semanticLabel,
    this.aspectRatio = 16 / 9,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.borderRadius = 16,
    this.optimizeDecode = true,
  }) : assert(provider != null),
       assert(aspectRatio > 0),
       assert(width == null || width > 0),
       assert(height == null || height > 0),
       source = '',
       variants = const {},
       allowRetry = false,
       _shape = 'image';

  final String source;
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
  @override
  Widget build(BuildContext context) => UIAdaptiveBuilder(
    builder: (context, ui) {
      final s = Theme.of(context).colorScheme;
      final ratio = widget._shape == 'banner' && !ui.compact
          ? 21 / 9
          : widget.aspectRatio;
      final width = math.min(widget.width ?? ui.width, ui.width);
      final height = widget.height ?? width / ratio;
      if (width <= 0 || height <= 0) return const SizedBox.shrink();
      final physical = (width * MediaQuery.devicePixelRatioOf(context)).ceil();
      final bucket = ((physical / 128).ceil() * 128).clamp(128, 2048);
      var source = widget.source;
      if (widget.variants.isNotEmpty) {
        final sizes = widget.variants.keys.toList()..sort();
        if (sizes.first <= 0) {
          throw ArgumentError('Image variant widths must be positive.');
        }
        final size = sizes.firstWhere(
          (s) => s >= physical,
          orElse: () => sizes.last,
        );
        source = widget.variants[size]!;
      }
      final uri = Uri.tryParse(source);
      final network = uri?.scheme == 'https' || uri?.scheme == 'http';
      final ImageProvider original =
          widget.provider ??
          (network ? NetworkImage(source) : AssetImage(source));
      // Width-only decode preserves source proportions. Web decode hints are ignored by the engine.
      final image = widget.optimizeDecode && !kIsWeb
          ? ResizeImage.resizeIfNeeded(bucket, null, original)
          : original;
      Widget placeholder(IconData icon) => ColoredBox(
        color: s.surfaceContainerHigh,
        child: Center(
          child: Icon(
            icon,
            color: s.onSurfaceVariant,
            size: math.min(32, height * .45),
          ),
        ),
      );
      final visual = SizedBox(
        width: width,
        height: height,
        child: _buildImage(
          context,
          image,
          original,
          network,
          source,
          width,
          height,
          placeholder,
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
  );

  Widget _buildImage(
    BuildContext context,
    ImageProvider image,
    ImageProvider original,
    bool network,
    String source,
    double width,
    double height,
    Widget Function(IconData) placeholder,
  ) {
    final s = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: Image(
        key: ValueKey((source, widget.provider, _retry)),
        image: image,
        width: width,
        height: height,
        fit: widget.fit,
        alignment: widget.alignment,
        filterQuality: FilterQuality.medium,
        excludeFromSemantics: true,
        gaplessPlayback: false,
        frameBuilder: (context, child, frame, sync) => Stack(
          fit: StackFit.expand,
          children: [
            if (frame == null) placeholder(Icons.image_outlined),
            AnimatedOpacity(
              opacity: frame == null ? 0 : 1,
              duration: sync || MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero
                  : const Duration(milliseconds: 160),
              child: child,
            ),
          ],
        ),
        errorBuilder: (context, error, stack) => ColoredBox(
          color: s.surfaceContainerHigh,
          child: Center(
            child: widget.allowRetry && network && width >= 160 && height >= 80
                ? TextButton.icon(
                    onPressed: () async {
                      await original.evict();
                      if (mounted) setState(() => _retry++);
                    },
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Thử lại ảnh'),
                  )
                : Icon(
                    Icons.broken_image_outlined,
                    color: s.onSurfaceVariant,
                    size: math.min(32, height * .45),
                  ),
          ),
        ),
      ),
    );
  }
}

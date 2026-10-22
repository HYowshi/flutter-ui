import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:youth_ui/youth_ui.dart';

class ControlledImage extends ImageProvider<ControlledImage> {
  final pending = Completer<ImageInfo>();
  Completer<bool>? eviction;
  int evictions = 0;
  @override
  Future<ControlledImage> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture(this);
  @override
  ImageStreamCompleter loadImage(
    ControlledImage key,
    ImageDecoderCallback decode,
  ) => OneFrameImageStreamCompleter(pending.future);
  @override
  Future<bool> evict({
    ImageCache? cache,
    ImageConfiguration configuration = ImageConfiguration.empty,
  }) {
    evictions++;
    return eviction?.future ??
        super.evict(cache: cache, configuration: configuration);
  }
}

class ImageBundle extends CachingAssetBundle {
  ImageBundle(this.bytes);
  final ByteData bytes;
  final requests = <String>[];
  @override
  Future<ByteData> load(String key) async {
    requests.add(key);
    if (key == 'AssetManifest.bin') {
      return const StandardMessageCodec().encodeMessage(<String, Object?>{})!;
    }
    if (key == 'backup.png') return bytes;
    throw StateError('Missing test asset');
  }
}

Future<ByteData> png() async {
  final recorder = ui.PictureRecorder();
  Canvas(recorder)
      .drawRect(const Rect.fromLTWH(0, 0, 4, 4), Paint()..color = Colors.green);
  final picture = recorder.endRecording();
  final image = picture.toImageSync(4, 4);
  picture.dispose();
  final bytes = (await image.toByteData(format: ui.ImageByteFormat.png))!;
  image.dispose();
  return bytes;
}

Widget host(
  Widget child, {
  AssetBundle? bundle,
  double width = 320,
  double height = 400,
  double scale = 1,
}) => MaterialApp(
  home: MediaQuery(
    data: MediaQueryData(textScaler: TextScaler.linear(scale)),
    child: Scaffold(
      body: DefaultAssetBundle(
        bundle: bundle ?? rootBundle,
        child: Center(
          child: SizedBox(width: width, height: height, child: child),
        ),
      ),
    ),
  ),
);

void main() {
  testWidgets('failed primary loads backup with the same fit and alignment', (
    tester,
  ) async {
    final bytes = await tester.runAsync(png);
    final bundle = ImageBundle(bytes!);
    final primary = ControlledImage();
    await tester.pumpWidget(
      host(
        UIImage.provider(
          primary,
          fallbackSource: 'backup.png',
          fit: BoxFit.contain,
          alignment: Alignment.bottomRight,
        ),
        bundle: bundle,
      ),
    );
    primary.pending.completeError(StateError('failed'));
    await tester.pumpAndSettle();
    final backup = tester.widgetList<Image>(find.byType(Image)).last;
    await tester.runAsync(
      () => precacheImage(backup.image, tester.element(find.byType(UIImage))),
    );
    await tester.pumpAndSettle();
    expect(backup.fit, BoxFit.contain);
    expect(backup.alignment, Alignment.bottomRight);
    expect(tester.widget<RawImage>(find.byType(RawImage)).image, isNotNull);
    expect(bundle.requests.where((r) => r == 'backup.png'), hasLength(1));
    expect(tester.takeException(), isNull);
  });
  testWidgets('avatar remains square with narrow width and unbounded height', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        const SingleChildScrollView(
          child: SizedBox(
            width: 32,
            child: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(width: 32, child: UIImage.avatar(null, size: 80)),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byType(ClipRRect)), const Size(32, 32));
    expect(tester.takeException(), isNull);
  });
  for (final source in <String?>[
    null,
    '',
    '  ',
    'https://',
    'data:image/png;base64,invalid',
    'file:///missing.png',
  ]) {
    testWidgets(
      'unavailable source $source skips requests and uses custom fallback',
      (tester) async {
        await tester.pumpWidget(
          host(UIImage(source, fallback: const Text('Unavailable'))),
        );
        await tester.pumpAndSettle();
        expect(find.text('Unavailable'), findsOneWidget);
        expect(find.byType(Image), findsNothing);
        expect(tester.getSize(find.byType(ClipRRect)), const Size(320, 180));
        expect(tester.takeException(), isNull);
      },
    );
  }
  testWidgets('blank main source can load a custom fallback asset', (
    tester,
  ) async {
    final bytes = await tester.runAsync(png);
    final bundle = ImageBundle(bytes!);
    await tester.pumpWidget(
      host(const UIImage(null, fallbackSource: 'backup.png'), bundle: bundle),
    );
    await tester.runAsync(
      () => precacheImage(
        tester.widget<Image>(find.byType(Image)).image,
        tester.element(find.byType(UIImage)),
      ),
    );
    await tester.pumpAndSettle();
    final image = tester.widget<Image>(find.byType(Image));
    expect((image.image as ResizeImage).imageProvider, isA<AssetImage>());
    expect(bundle.requests.where((r) => r == 'backup.png'), hasLength(1));
    expect(find.byIcon(Icons.broken_image_outlined), findsNothing);
    expect(tester.widget<RawImage>(find.byType(RawImage)).image, isNotNull);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'failed main and fallback asset stop at final widget, never loop',
    (tester) async {
      final primary = ControlledImage();
      await tester.pumpWidget(
        host(
          UIImage.provider(
            primary,
            fallbackSource: 'missing-backup.png',
            fallback: const Text('Final fallback'),
          ),
        ),
      );
      final initialSize = tester.getSize(find.byType(ClipRRect));
      primary.pending.completeError(StateError('Primary failed'));
      await tester.pumpAndSettle();
      expect(find.text('Final fallback'), findsOneWidget);
      expect(tester.getSize(find.byType(ClipRRect)), initialSize);
      expect(tester.binding.hasScheduledFrame, isFalse);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'custom errorBuilder takes precedence and gets the original error',
    (tester) async {
      final primary = ControlledImage();
      final failure = StateError('primary');
      Object? seen;
      await tester.pumpWidget(
        host(
          UIImage.provider(
            primary,
            fallbackSource: 'should-not-load.png',
            fallback: const Text('Unused'),
            errorBuilder: (context, error, stack) {
              seen = error;
              return const Text('Custom error');
            },
          ),
        ),
      );
      primary.pending.completeError(failure);
      await tester.pumpAndSettle();
      expect(seen, same(failure));
      expect(find.text('Custom error'), findsOneWidget);
      expect(find.text('Unused'), findsNothing);
      expect(
        find.byType(Image),
        findsOneWidget,
      ); // the failed primary, no fallback request
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'custom placeholder is static and replaced on first image frame',
    (tester) async {
      final primary = ControlledImage();
      await tester.pumpWidget(
        host(
          UIImage.provider(primary, placeholder: const Text('Loading image')),
        ),
      );
      expect(find.text('Loading image'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(tester.binding.hasScheduledFrame, isFalse);
      final recorder = ui.PictureRecorder();
      Canvas(recorder).drawRect(const Rect.fromLTWH(0, 0, 4, 4), Paint());
      final picture = recorder.endRecording();
      primary.pending.complete(ImageInfo(image: picture.toImageSync(4, 4)));
      picture.dispose();
      await tester.pumpAndSettle();
      expect(find.text('Loading image'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('retry deduplicates taps and cannot refresh a changed source', (
    tester,
  ) async {
    final old = ControlledImage()..eviction = Completer<bool>();
    await tester.pumpWidget(
      host(UIImage.provider(old, allowRetry: true, optimizeDecode: false)),
    );
    old.pending.completeError(StateError('old failed'));
    await tester.pumpAndSettle();
    final action = find.text('Thử lại ảnh');
    await tester.tap(action);
    await tester.tap(action);
    expect(old.evictions, 1);
    final current = ControlledImage();
    await tester.pumpWidget(
      host(UIImage.provider(current, optimizeDecode: false)),
    );
    final before = tester.widget<Image>(find.byType(Image)).key;
    old.eviction!.complete(true);
    await tester.pumpAndSettle();
    expect(tester.widget<Image>(find.byType(Image)).key, before);
    expect(tester.takeException(), isNull);
  });
  testWidgets('retry completion after disposal is safe', (tester) async {
    final primary = ControlledImage()..eviction = Completer<bool>();
    await tester.pumpWidget(
      host(UIImage.provider(primary, allowRetry: true, optimizeDecode: false)),
    );
    primary.pending.completeError(StateError('fail'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Thử lại ảnh'));
    await tester.pumpWidget(const SizedBox());
    primary.eviction!.complete(true);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
  testWidgets('retry falls back to an icon for narrow frames and large text', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(const UIImage('missing.png'), width: 80, height: 80, scale: 3),
    );
    await tester.pumpAndSettle();
    // 80x45 at 16:9 is too short for an accessible retry action.
    expect(find.byTooltip('Thử lại ảnh'), findsNothing);
    await tester.pumpWidget(
      host(
        const UIImage('missing.png', aspectRatio: 1),
        width: 80,
        height: 80,
        scale: 3,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byTooltip('Thử lại ảnh'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('small variants accept custom fallback and shrink uniformly', (
    tester,
  ) async {
    for (final widget in [
      const UIImage.avatar(null, size: 80, fallback: Text('A')),
      const UIImage.thumbnail(null, size: 80, fallback: Text('A')),
    ]) {
      await tester.pumpWidget(host(widget, width: 100, height: 32));
      await tester.pumpAndSettle();
      expect(tester.getSize(find.byType(ClipRRect)), const Size(32, 32));
      expect(find.text('A'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });
  testWidgets('empty variant does not override valid base source', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(const UIImage('base.png', variants: {320: ''}, allowRetry: false)),
    );
    await tester.pumpAndSettle();
    final actual =
        tester.widget<Image>(find.byType(Image)).image as ResizeImage;
    expect((actual.imageProvider as AssetImage).assetName, 'base.png');
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'replacing a failed source restores loading without stale fallback',
    (tester) async {
      await tester.pumpWidget(
        host(const UIImage(null, fallback: Text('Failed'))),
      );
      final next = ControlledImage();
      await tester.pumpWidget(
        host(UIImage.provider(next, fallback: const Text('Failed'))),
      );
      expect(find.text('Failed'), findsNothing);
      expect(find.byIcon(Icons.image_outlined), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}

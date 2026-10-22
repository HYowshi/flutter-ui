import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:youth_ui/youth_ui.dart';

class TestImage extends ImageProvider<TestImage> {
  TestImage(this.result);
  final Future<ImageInfo> result;
  @override
  Future<TestImage> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture(this);
  @override
  ImageStreamCompleter loadImage(TestImage key, ImageDecoderCallback decode) =>
      OneFrameImageStreamCompleter(result);
}

ui.Image tinyImage() {
  final recorder = ui.PictureRecorder();
  Canvas(recorder)
      .drawRect(const Rect.fromLTWH(0, 0, 4, 4), Paint()..color = Colors.blue);
  final picture = recorder.endRecording();
  final image = picture.toImageSync(4, 4);
  picture.dispose();
  return image;
}

Widget host(Widget child, {double width = 320}) => UIApp(
  primary: Colors.blue,
  reduceMotion: true,
  home: Scaffold(
    body: Center(
      child: SizedBox(width: width, height: 580, child: child),
    ),
  ),
);

void main() {
  testWidgets('theme fade preserves form state and reuses cached endpoints', (
    tester,
  ) async {
    final mode = UIThemeController(mode: ThemeMode.light);
    addTearDown(mode.dispose);
    late YouthColors before;
    await tester.pumpWidget(
      UIApp(
        primary: Colors.blue,
        controller: mode,
        home: Scaffold(
          body: Builder(
            builder: (context) {
              before = YouthColors.of(context);
              return const TextField();
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final light = before;
    await tester.enterText(find.byType(TextField), 'Keep my work');
    mode.mode = ThemeMode.dark;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));
    expect(find.byType(RawImage), findsOneWidget);
    await tester.pumpAndSettle();
    expect(before.scheme.brightness, Brightness.dark);
    expect(find.text('Keep my work'), findsOneWidget);
    expect(find.byType(RawImage), findsNothing);
    mode.mode = ThemeMode.light;
    await tester.pumpAndSettle();
    expect(identical(before, light), isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'rapid theme requests finish at the latest mode and dispose safely',
    (tester) async {
      final mode = UIThemeController(mode: ThemeMode.light);
      addTearDown(mode.dispose);
      late Brightness current;
      await tester.pumpWidget(
        UIApp(
          primary: Colors.green,
          controller: mode,
          home: Builder(
            builder: (context) {
              current = Theme.of(context).brightness;
              return const Scaffold(body: Text('Ready'));
            },
          ),
        ),
      );
      mode.mode = ThemeMode.dark;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 30));
      mode.mode = ThemeMode.light;
      await tester.pump(const Duration(milliseconds: 20));
      mode.mode = ThemeMode.dark;
      await tester.pumpAndSettle();
      expect(current, Brightness.dark);
      mode.mode = ThemeMode.light;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'reduced motion changes theme immediately and toggle needs no setup',
    (tester) async {
      late Brightness current;
      await tester.pumpWidget(
        UIApp(
          primary: Colors.indigo,
          initialThemeMode: ThemeMode.light,
          reduceMotion: true,
          home: Builder(
            builder: (context) {
              current = Theme.of(context).brightness;
              return const Scaffold(body: UIThemeToggle());
            },
          ),
        ),
      );
      await tester.tap(find.byTooltip('Đổi sáng / tối'));
      await tester.pumpAndSettle();
      expect(current, Brightness.dark);
      expect(find.byType(RawImage), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('pending images keep dimensions and use a static placeholder', (
    tester,
  ) async {
    final pending = Completer<ImageInfo>();
    await tester.pumpWidget(host(UIImage.provider(TestImage(pending.future))));
    final initial = tester.getSize(find.byType(ClipRRect));
    expect(initial.width, 320);
    expect(initial.height, 180);
    expect(find.byIcon(Icons.image_outlined), findsOneWidget);
    await tester.pumpAndSettle();
    expect(tester.binding.hasScheduledFrame, isFalse);
    pending.complete(ImageInfo(image: tinyImage()));
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byType(ClipRRect)), initial);
    expect(find.byIcon(Icons.image_outlined), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('failed provider stays bounded and exposes an error fallback', (
    tester,
  ) async {
    final failed = Completer<ImageInfo>();
    await tester.pumpWidget(host(UIImage.provider(TestImage(failed.future))));
    failed.completeError(StateError('image failed'));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.broken_image_outlined), findsOneWidget);
    expect(tester.getSize(find.byType(ClipRRect)), const Size(320, 180));
    expect(tester.takeException(), isNull);
  });

  testWidgets('avatar stays circular inside a stretched page', (tester) async {
    await tester.pumpWidget(
      host(const UIPage(children: [UIImage.avatar('missing-avatar.png')])),
    );
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byType(ClipRRect)), const Size(48, 48));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'decode hints are bucketed and reused within the same size range',
    (tester) async {
      final provider = TestImage(Completer<ImageInfo>().future);
      await tester.pumpWidget(host(UIImage.provider(provider), width: 300));
      final image = tester.widget<Image>(find.byType(Image));
      final physicalWidth = 300 * tester.view.devicePixelRatio;
      expect(
        (image.image as ResizeImage).width,
        ((physicalWidth / 128).ceil() * 128).clamp(128, 2048),
      );
      await tester.pumpWidget(host(UIImage.provider(provider), width: 310));
      expect(tester.widget<Image>(find.byType(Image)).image, image.image);
      expect(tester.takeException(), isNull);
    },
  );

  for (final preset in UIWireframeLayout.values) {
    testWidgets(
      'wireframe ${preset.name} adapts without animation or interactive controls',
      (tester) async {
        await tester.pumpWidget(
          host(UIPage(children: [UIWireframe.page(layout: preset)])),
        );
        await tester.pumpAndSettle();
        expect(find.byType(Image), findsNothing);
        expect(find.byType(ButtonStyleButton), findsNothing);
        expect(tester.binding.hasScheduledFrame, isFalse);
        expect(tester.takeException(), isNull);
      },
    );
  }

  test('button resolution reuses equivalent state sets', () {
    final colors = YouthUI.colors(primary: Colors.blue).light
        .extension<YouthColors>()!;
    final first = colors.button(UITone.primary, UIButtonVariant.outline, {
      WidgetState.hovered,
      WidgetState.focused,
    });
    final second = colors.button(UITone.primary, UIButtonVariant.outline, {
      WidgetState.focused,
      WidgetState.hovered,
    });
    expect(identical(first, second), isTrue);
  });
  testWidgets('system theme changes follow platform brightness', (
    tester,
  ) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    late Brightness current;
    await tester.pumpWidget(
      UIApp(
        primary: Colors.blue,
        reduceMotion: true,
        home: Builder(
          builder: (context) {
            current = Theme.of(context).brightness;
            return const Scaffold(body: Text('System mode'));
          },
        ),
      ),
    );
    expect(current, Brightness.light);
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    await tester.pumpAndSettle();
    expect(current, Brightness.dark);
    expect(tester.takeException(), isNull);
  });

  testWidgets('collapsed image does not start a provider', (tester) async {
    await tester.pumpWidget(
      host(
        UIImage.provider(TestImage(Completer<ImageInfo>().future)),
        width: 0,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(Image), findsNothing);
    expect(tester.takeException(), isNull);
  });
  testWidgets('source variants follow display width and device pixel ratio', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        const UIImage(
          'original.png',
          variants: {128: 'small.png', 1024: 'large.png'},
        ),
        width: 100,
      ),
    );
    await tester.pumpAndSettle();
    final provider =
        tester.widget<Image>(find.byType(Image)).image as ResizeImage;
    final physical = 100 * tester.view.devicePixelRatio;
    expect(
      (provider.imageProvider as AssetImage).assetName,
      physical <= 128 ? 'small.png' : 'large.png',
    );
    await tester.pumpWidget(
      host(
        const UIImage(
          'original.png',
          variants: {128: 'small.png', 1024: 'large.png'},
        ),
        width: 20,
      ),
    );
    await tester.pumpAndSettle();
    expect(
      ((tester.widget<Image>(find.byType(Image)).image as ResizeImage)
                  .imageProvider
              as AssetImage)
          .assetName,
      'small.png',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('platform reduced motion disables the theme overlay', (
    tester,
  ) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    final mode = UIThemeController(mode: ThemeMode.light);
    addTearDown(mode.dispose);
    await tester.pumpWidget(
      UIApp(
        primary: Colors.blue,
        controller: mode,
        home: const Scaffold(body: Text('Accessible')),
      ),
    );
    mode.mode = ThemeMode.dark;
    await tester.pumpAndSettle();
    expect(find.byType(RawImage), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

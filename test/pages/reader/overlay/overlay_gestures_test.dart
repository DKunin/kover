import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kover/models/read_direction.dart';
import 'package:kover/pages/reader/image_reader/zoomable_horizontal_page_image.dart';
import 'package:kover/pages/reader/overlay/overlay_gestures.dart';
import 'package:kover/pages/reader/overlay/overlay_gestures_provider.dart';
import 'package:material_ui/material_ui.dart';

const _seriesId = 7;
const _readerKey = ValueKey('reader');

void main() {
  testWidgets('passes pinch zoom in and out through to the comic page', (
    tester,
  ) async {
    var centerTaps = 0;
    final transformationController = TransformationController();
    addTearDown(transformationController.dispose);
    final pageController = PageController();
    addTearDown(pageController.dispose);

    await tester.pumpWidget(
      _host(
        onCenterTap: () => centerTaps++,
        child: ZoomableHorizontalPageImage(
          key: _readerKey,
          outerController: pageController,
          onZoomChanged: (_) {},
          transformationController: transformationController,
          child: const SizedBox.expand(),
        ),
      ),
    );
    await tester.pump();

    final firstPointer = await tester.startGesture(const Offset(120, 150));
    final secondPointer = await tester.startGesture(const Offset(180, 150));
    await firstPointer.moveBy(const Offset(-70, 0));
    await secondPointer.moveBy(const Offset(70, 0));
    await tester.pump();
    await firstPointer.up();
    await secondPointer.up();
    await tester.pumpAndSettle();

    final zoomedScale = transformationController.value.getMaxScaleOnAxis();
    expect(
      zoomedScale,
      greaterThan(1),
    );

    final thirdPointer = await tester.startGesture(const Offset(80, 150));
    final fourthPointer = await tester.startGesture(const Offset(220, 150));
    await thirdPointer.moveBy(const Offset(50, 0));
    await fourthPointer.moveBy(const Offset(-50, 0));
    await tester.pump();
    await thirdPointer.up();
    await fourthPointer.up();
    await tester.pumpAndSettle();

    expect(
      transformationController.value.getMaxScaleOnAxis(),
      lessThan(zoomedScale),
    );
    expect(centerTaps, 0);
  });

  testWidgets('preserves left, center, and right tap zones', (tester) async {
    final taps = <String>[];

    await tester.pumpWidget(
      _host(
        onLeftTap: () => taps.add('left'),
        onCenterTap: () => taps.add('center'),
        onRightTap: () => taps.add('right'),
        child: const ColoredBox(key: _readerKey, color: Colors.black),
      ),
    );
    await tester.pump();

    await tester.tapAt(const Offset(40, 150));
    await tester.tapAt(const Offset(150, 150));
    await tester.tapAt(const Offset(260, 150));

    expect(taps, ['left', 'center', 'right']);
  });

  testWidgets('opens controls when tapping selectable EPUB text', (
    tester,
  ) async {
    var centerTaps = 0;

    await tester.pumpWidget(
      _host(
        onCenterTap: () => centerTaps++,
        child: const SelectionArea(
          child: Center(
            child: SelectableText('Tap the middle of this EPUB page'),
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Tap the middle of this EPUB page'));

    expect(centerTaps, 1);
  });

  testWidgets('keeps long-press text selection from opening controls', (
    tester,
  ) async {
    var centerTaps = 0;

    await tester.pumpWidget(
      _host(
        onCenterTap: () => centerTaps++,
        child: const SelectionArea(
          child: Center(
            child: SelectableText('Select this EPUB text'),
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.longPress(find.text('Select this EPUB text'));

    expect(centerTaps, 0);
  });
}

Widget _host({
  required Widget child,
  VoidCallback? onLeftTap,
  VoidCallback? onCenterTap,
  VoidCallback? onRightTap,
}) {
  return ProviderScope(
    overrides: [
      overlayGesturesProvider(seriesId: _seriesId).overrideWith(
        (_) async => OverlayGesturesModel(
          navigationGestures: true,
          readDirection: ReadDirection.leftToRight,
        ),
      ),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 300,
            height: 300,
            child: OverlayGestures(
              seriesId: _seriesId,
              onLeftTap: onLeftTap,
              onCenterTap: onCenterTap,
              onRightTap: onRightTap,
              child: child,
            ),
          ),
        ),
      ),
    ),
  );
}

import 'package:flutter_test/flutter_test.dart';
import 'package:kover/pages/reader/epub_reader/zoomable_epub_page.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('single-finger scrolling stays with EPUB content at base scale', (
    tester,
  ) async {
    final scrollController = ScrollController();
    addTearDown(scrollController.dispose);

    await tester.pumpWidget(
      _TestHost(scrollController: scrollController),
    );

    await tester.drag(find.byType(ListView), const Offset(0, -160));
    await tester.pumpAndSettle();

    expect(scrollController.offset, greaterThan(0));
    expect(_scale(tester), 1);
  });

  testWidgets('two-finger pinch zooms EPUB content in and out', (tester) async {
    final scrollController = ScrollController();
    addTearDown(scrollController.dispose);

    await tester.pumpWidget(
      _TestHost(scrollController: scrollController),
    );

    final firstPointer = await tester.startGesture(const Offset(120, 150));
    final secondPointer = await tester.startGesture(const Offset(180, 150));
    await firstPointer.moveBy(const Offset(-70, 0));
    await secondPointer.moveBy(const Offset(70, 0));
    await tester.pump();

    final zoomedScale = _scale(tester);
    expect(zoomedScale, greaterThan(1));

    await firstPointer.up();
    await secondPointer.up();
    await tester.pump();

    final thirdPointer = await tester.startGesture(const Offset(80, 150));
    final fourthPointer = await tester.startGesture(const Offset(220, 150));
    await thirdPointer.moveBy(const Offset(50, 0));
    await fourthPointer.moveBy(const Offset(-50, 0));
    await tester.pump();

    expect(_scale(tester), lessThan(zoomedScale));

    await thirdPointer.up();
    await fourthPointer.up();
  });

  testWidgets('zoomed single-finger drag pans without scrolling the book', (
    tester,
  ) async {
    final scrollController = ScrollController();
    addTearDown(scrollController.dispose);

    await tester.pumpWidget(
      _TestHost(scrollController: scrollController),
    );

    final firstPointer = await tester.startGesture(const Offset(120, 150));
    final secondPointer = await tester.startGesture(const Offset(180, 150));
    await firstPointer.moveBy(const Offset(-70, -50));
    await secondPointer.moveBy(const Offset(70, 50));
    await tester.pump();
    await firstPointer.up();
    await secondPointer.up();
    await tester.pump();

    final initialTranslation = _translation(tester);
    final initialScrollOffset = scrollController.offset;
    await tester.drag(find.byType(ListView), const Offset(-40, -40));
    await tester.pump();

    expect(_translation(tester), isNot(initialTranslation));
    expect(scrollController.offset, initialScrollOffset);
  });
}

class _TestHost extends StatefulWidget {
  final ScrollController scrollController;

  const _TestHost({required this.scrollController});

  @override
  State<_TestHost> createState() => _TestHostState();
}

class _TestHostState extends State<_TestHost> {
  bool interactionLocked = false;
  bool zoomed = false;
  bool multiTouch = false;

  void updateInteractionLock() {
    final next = zoomed || multiTouch;
    if (interactionLocked != next) {
      setState(() => interactionLocked = next);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 300,
            height: 300,
            child: ZoomableEpubPage(
              resetKey: 0,
              onZoomChanged: (value) {
                zoomed = value;
                updateInteractionLock();
              },
              onMultiTouchChanged: (value) {
                multiTouch = value;
                updateInteractionLock();
              },
              child: ListView.builder(
                controller: widget.scrollController,
                physics: interactionLocked
                    ? const NeverScrollableScrollPhysics()
                    : const AlwaysScrollableScrollPhysics(),
                itemCount: 20,
                itemBuilder: (_, index) => SizedBox(
                  height: 80,
                  child: Text('Page row $index'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

double _scale(WidgetTester tester) => _matrix(tester).getMaxScaleOnAxis();

Offset _translation(WidgetTester tester) {
  final translation = _matrix(tester).getTranslation();
  return Offset(translation.x, translation.y);
}

Matrix4 _matrix(WidgetTester tester) => tester
    .widget<Transform>(find.byKey(ZoomableEpubPage.transformKey))
    .transform;

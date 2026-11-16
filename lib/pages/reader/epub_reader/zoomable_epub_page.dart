import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

/// Adds two-finger zoom and zoomed panning without taking single-finger
/// gestures away from EPUB scrolling and text selection at the base scale.
class ZoomableEpubPage extends StatefulWidget {
  static const transformKey = ValueKey('zoomable-epub-page-transform');

  final Widget child;
  final Object resetKey;
  final ValueChanged<bool> onZoomChanged;
  final ValueChanged<bool> onMultiTouchChanged;

  const ZoomableEpubPage({
    super.key,
    required this.child,
    required this.resetKey,
    required this.onZoomChanged,
    required this.onMultiTouchChanged,
  });

  @override
  State<ZoomableEpubPage> createState() => _ZoomableEpubPageState();
}

class _ZoomableEpubPageState extends State<ZoomableEpubPage> {
  static const _minScale = 1.0;
  static const _maxScale = 4.0;

  final Map<int, Offset> _pointers = {};

  Size _viewport = Size.zero;
  double _scale = _minScale;
  Offset _translation = Offset.zero;
  bool _multiTouch = false;

  double? _pinchStartDistance;
  double _pinchStartScale = _minScale;
  Offset _pinchContentPoint = Offset.zero;
  Offset? _lastPanPosition;

  @override
  void didUpdateWidget(covariant ZoomableEpubPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.resetKey == widget.resetKey) return;

    final wasZoomed = _isZoomed;
    final wasMultiTouch = _multiTouch;
    if (!wasZoomed && !wasMultiTouch) return;

    _pointers.clear();
    _scale = _minScale;
    _translation = Offset.zero;
    _multiTouch = false;
    _clearGestureState();

    if (wasZoomed || wasMultiTouch) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (wasZoomed) widget.onZoomChanged(false);
        if (wasMultiTouch) widget.onMultiTouchChanged(false);
      });
    }
  }

  bool get _isZoomed => _scale > _minScale + 1e-3;

  void _handlePointerDown(PointerDownEvent event) {
    _pointers[event.pointer] = event.localPosition;
    _lastPanPosition = event.localPosition;

    if (_pointers.length >= 2) {
      _setMultiTouch(true);
      _startPinch();
    }
  }

  void _handlePointerMove(PointerMoveEvent event) {
    if (!_pointers.containsKey(event.pointer)) return;
    _pointers[event.pointer] = event.localPosition;

    if (_pointers.length >= 2) {
      _updatePinch();
      return;
    }

    final previous = _lastPanPosition;
    _lastPanPosition = event.localPosition;
    if (!_isZoomed || previous == null) return;

    _setTransform(
      scale: _scale,
      translation: _translation + event.localPosition - previous,
    );
  }

  void _handlePointerEnd(PointerEvent event) {
    final hadMultiTouch = _pointers.length >= 2;
    _pointers.remove(event.pointer);

    if (hadMultiTouch && _pointers.length < 2) {
      _setMultiTouch(false);
    }

    if (_pointers.length >= 2) {
      _startPinch();
    } else {
      _pinchStartDistance = null;
      _lastPanPosition = _pointers.values.firstOrNull;
    }
  }

  void _startPinch() {
    final positions = _pointers.values.take(2).toList(growable: false);
    if (positions.length < 2) return;

    final distance = (positions[0] - positions[1]).distance;
    if (!distance.isFinite || distance <= 1e-3) return;

    final focalPoint = (positions[0] + positions[1]) / 2;
    _pinchStartDistance = distance;
    _pinchStartScale = _scale;
    _pinchContentPoint = (focalPoint - _translation) / _scale;
  }

  void _updatePinch() {
    final startDistance = _pinchStartDistance;
    final positions = _pointers.values.take(2).toList(growable: false);
    if (startDistance == null || positions.length < 2) return;

    final distance = (positions[0] - positions[1]).distance;
    if (!distance.isFinite) return;

    final focalPoint = (positions[0] + positions[1]) / 2;
    final nextScale = (_pinchStartScale * distance / startDistance)
        .clamp(_minScale, _maxScale)
        .toDouble();

    _setTransform(
      scale: nextScale,
      translation: focalPoint - _pinchContentPoint * nextScale,
    );
  }

  void _setTransform({required double scale, required Offset translation}) {
    final nextTranslation = _clampTranslation(translation, scale);
    if (scale == _scale && nextTranslation == _translation) return;

    final wasZoomed = _isZoomed;
    setState(() {
      _scale = scale;
      _translation = nextTranslation;
    });

    final zoomed = _isZoomed;
    if (wasZoomed != zoomed) {
      widget.onZoomChanged(zoomed);
    }
  }

  Offset _clampTranslation(Offset translation, double scale) {
    if (scale <= _minScale || _viewport.isEmpty) return Offset.zero;

    final minX = math.min(0.0, _viewport.width * (1 - scale));
    final minY = math.min(0.0, _viewport.height * (1 - scale));
    return Offset(
      translation.dx.clamp(minX, 0.0).toDouble(),
      translation.dy.clamp(minY, 0.0).toDouble(),
    );
  }

  void _setMultiTouch(bool value) {
    if (_multiTouch == value) return;
    _multiTouch = value;
    widget.onMultiTouchChanged(value);
  }

  void _clearGestureState() {
    _pinchStartDistance = null;
    _pinchStartScale = _minScale;
    _pinchContentPoint = Offset.zero;
    _lastPanPosition = null;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _viewport = constraints.biggest;
        final transform = Matrix4.identity()
          ..setEntry(0, 0, _scale)
          ..setEntry(1, 1, _scale)
          ..setTranslationRaw(_translation.dx, _translation.dy, 0);

        return Listener(
          behavior: HitTestBehavior.opaque,
          onPointerDown: _handlePointerDown,
          onPointerMove: _handlePointerMove,
          onPointerUp: _handlePointerEnd,
          onPointerCancel: _handlePointerEnd,
          child: ClipRect(
            child: Transform(
              key: ZoomableEpubPage.transformKey,
              transform: transform,
              alignment: Alignment.topLeft,
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}

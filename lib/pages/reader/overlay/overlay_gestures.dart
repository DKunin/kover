import 'dart:async';

import 'package:flutter/gestures.dart' show kLongPressTimeout, kTouchSlop;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kover/mapping/enums/read_direction.dart';
import 'package:kover/pages/reader/overlay/overlay_gestures_provider.dart';
import 'package:kover/widgets/util/async_value.dart';
import 'package:material_ui/material_ui.dart';

class OverlayGestures extends ConsumerWidget {
  final int seriesId;
  final Widget child;
  final VoidCallback? onCenterTap;
  final VoidCallback? onLeftTap;
  final VoidCallback? onRightTap;
  final bool disableGestures;

  const OverlayGestures({
    super.key,
    required this.seriesId,
    required this.child,
    this.onCenterTap,
    this.onLeftTap,
    this.onRightTap,
    this.disableGestures = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final model = ref.watch(overlayGesturesProvider(seriesId: seriesId));

    if (disableGestures) {
      return child;
    }

    return Async(
      asyncValue: model,
      loading: () => child,
      error: (_, _) => child,
      data: (data) => LayoutBuilder(
        builder: (context, constraints) {
          void handleTapUp(Offset localPosition) {
            if (!data.navigationGestures) {
              onCenterTap?.call();
              return;
            }

            final position = localPosition.dx / constraints.maxWidth;
            final isRightToLeft =
                data.readDirection.toTextDirection() == TextDirection.rtl;

            if (position < 0.25) {
              (isRightToLeft ? onRightTap : onLeftTap)?.call();
            } else if (position > 0.75) {
              (isRightToLeft ? onLeftTap : onRightTap)?.call();
            } else {
              onCenterTap?.call();
            }
          }

          return _PassthroughTapDetector(
            onTapUp: handleTapUp,
            child: child,
          );
        },
      ),
    );
  }
}

/// Observes taps without joining the gesture arena, so selectable EPUB text
/// and zoomable comic pages can keep handling their own gestures.
class _PassthroughTapDetector extends StatefulWidget {
  final Widget child;
  final ValueChanged<Offset> onTapUp;

  const _PassthroughTapDetector({
    required this.child,
    required this.onTapUp,
  });

  @override
  State<_PassthroughTapDetector> createState() =>
      _PassthroughTapDetectorState();
}

class _PassthroughTapDetectorState extends State<_PassthroughTapDetector> {
  final Set<int> _activePointers = {};

  int? _tapPointer;
  Offset? _tapOrigin;
  Timer? _longPressTimer;
  bool _tapEligible = false;

  void _handlePointerDown(PointerDownEvent event) {
    if (_activePointers.isEmpty) {
      _tapPointer = event.pointer;
      _tapOrigin = event.localPosition;
      _tapEligible = true;
      _longPressTimer = Timer(kLongPressTimeout, () {
        _tapEligible = false;
      });
    } else {
      _tapEligible = false;
      _longPressTimer?.cancel();
    }
    _activePointers.add(event.pointer);
  }

  void _handlePointerMove(PointerMoveEvent event) {
    if (event.pointer != _tapPointer || !_tapEligible) return;

    final origin = _tapOrigin;
    if (origin != null &&
        (event.localPosition - origin).distance > kTouchSlop) {
      _tapEligible = false;
      _longPressTimer?.cancel();
    }
  }

  void _handlePointerUp(PointerUpEvent event) {
    final isTap =
        event.pointer == _tapPointer &&
        _tapEligible &&
        _activePointers.length == 1;

    _activePointers.remove(event.pointer);
    if (_activePointers.isEmpty) _clearTap();

    if (isTap) widget.onTapUp(event.localPosition);
  }

  void _handlePointerCancel(PointerCancelEvent event) {
    _activePointers.remove(event.pointer);
    _tapEligible = false;
    if (_activePointers.isEmpty) _clearTap();
  }

  void _clearTap() {
    _longPressTimer?.cancel();
    _longPressTimer = null;
    _tapPointer = null;
    _tapOrigin = null;
    _tapEligible = false;
  }

  @override
  void dispose() {
    _longPressTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _handlePointerDown,
      onPointerMove: _handlePointerMove,
      onPointerUp: _handlePointerUp,
      onPointerCancel: _handlePointerCancel,
      child: widget.child,
    );
  }
}

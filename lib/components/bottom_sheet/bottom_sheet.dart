import 'package:flutter/gestures.dart';
import 'package:widget_app/generic.dart';

class BottomSheet extends StatefulWidget {
  const BottomSheet({super.key});

  @override
  State<BottomSheet> createState() => _BottomSheetState();
}

class _BottomSheetState extends State<BottomSheet>
    with SingleTickerProviderStateMixin {
  final _scrollController = ScrollController();
  late final AnimationController _animationController;

  Drag? _drag;
  DragStartDetails? _startDetails;

  Curve _curve = const SuspendedCurve(
    curve: Curves.fastEaseInToSlowEaseOut,
  );

  bool _isDragging = false;
  double _availableHeight = 0.0;

  double get _percentage {
    return _curve.transform(_animationController.value);
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      _availableHeight = constraints.maxHeight;
      return AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return CustomSingleChildLayout(
            delegate: _SheetLayoutDelegate(
              _percentage,
              true,
            ),
            child: Stack(
              children: [
                ListView.builder(
                  controller: _scrollController,
                  itemCount: 100,
                  itemBuilder: (context, index) {
                    return Button.custom(
                      backgroundColor: WidgetStateColor.resolveWith(
                        (states) {
                          var value = 1.0;
                          if (states.contains(WidgetState.hovered)) {
                            value = 0.9;
                          }

                          if (states.contains(WidgetState.pressed)) {
                            value = 0.8;
                          }
                          return HSVColor.fromAHSV(
                            1.0,
                            index.toDouble().wrap(0, 13).remap(0, 13, 0, 360),
                            0.7,
                            value,
                          ).toColor();
                        },
                      ),
                      borderColor: WidgetStateColor.resolveWith(
                        (states) {
                          return HSVColor.fromAHSV(
                            1.0,
                            (index + 100)
                                .toDouble()
                                .wrap(0, 13)
                                .remap(0, 13, 0, 360),
                            0.7,
                            1.0,
                          ).toColor();
                        },
                      ),
                      foregroundColor: WidgetStateColor.resolveWith(
                        (states) {
                          return HSVColor.fromAHSV(
                            1.0,
                            (index + 100)
                                .toDouble()
                                .wrap(0, 13)
                                .remap(0, 13, 0, 360),
                            0.7,
                            1.0,
                          ).toColor();
                        },
                      ),
                      borderRadius: 0,
                      onPressed: () {},
                      children: [Text("Item #${index + 1}")],
                    );
                  },
                ),
                Positioned.fill(
                  right: 6.0, // account for scroll bar
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onVerticalDragDown: (details) {},
                    onVerticalDragStart: (details) {
                      _startDetails = details;
                    },
                    onVerticalDragUpdate: (details) {
                      if (!_isDragging) {
                        _drag =
                            _scrollController.position.drag(_startDetails!, () {
                          _startDetails = null;
                          _drag = null;
                        });
                        _isDragging = true;
                      }

                      final canScrollDown =
                          _scrollController.offset > 0 && details.delta.dy > 0;
                      final canScrollUp = _animationController.value >= 1.0 &&
                          details.delta.dy < 0;

                      if (canScrollDown || canScrollUp) {
                        _drag?.update(details);
                      } else {
                        if (_animationController.value < 1.0 &&
                            _scrollController.offset > 0) {
                          _scrollController.jumpTo(0.0);
                        }
                        _curve = Curves.linear;
                        _animationController.value -=
                            details.delta.dy / _availableHeight;
                      }
                    },
                    onVerticalDragEnd: (details) {
                      _isDragging = false;
                      final velocity = _animationController.value < 1.0
                          ? 0.0
                          : details.velocity.pixelsPerSecond.dy;
                      _drag?.end(DragEndDetails(
                        primaryVelocity: velocity,
                        velocity: Velocity(
                          pixelsPerSecond: Offset(0, velocity),
                        ),
                        globalPosition: details.globalPosition,
                        localPosition: details.localPosition,
                      ));
                    },
                    onVerticalDragCancel: () {
                      _drag?.cancel();
                      _isDragging = false;
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
    });
  }
}

class _SheetLayoutDelegate extends SingleChildLayoutDelegate {
  _SheetLayoutDelegate(this.progress, this.expand);

  final double progress;
  final bool expand;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return BoxConstraints(
      minWidth: constraints.maxWidth,
      maxWidth: constraints.maxWidth,
      minHeight: expand ? constraints.maxHeight : 0,
      maxHeight: expand ? constraints.maxHeight : constraints.minHeight,
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    return Offset(0.0, size.height - childSize.height * progress);
  }

  @override
  bool shouldRelayout(_SheetLayoutDelegate oldDelegate) {
    return progress != oldDelegate.progress;
  }
}

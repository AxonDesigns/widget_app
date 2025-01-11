import 'package:flutter/gestures.dart';
import 'package:widget_app/components/bottom_sheet/bottom_sheet_layout.dart';
import 'package:widget_app/components/bottom_sheet/sheet_controller.dart';
import 'package:widget_app/generic.dart';

class BottomSheet extends StatefulWidget {
  const BottomSheet({
    super.key,
    required this.builder,
    this.maxHeightFactor = 0.9,
  });

  final double maxHeightFactor;
  final Widget Function(BuildContext context) builder;

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

  bool _isScrolling = false;
  double _availableHeight = 0.0;

  double get _progress {
    return _curve.transform(_animationController.value);
  }

  double get maxHeight {
    return _availableHeight * widget.maxHeightFactor;
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          final difference = (0.0 - _progress).abs();

          final duration = Duration(
            milliseconds: difference.remap(0.0, 1.0, 150, 600.0).toInt(),
          );
          _animationController.duration = duration;
          _curve = SuspendedCurve(
            curve: Curves.fastEaseInToSlowEaseOut,
            from: _progress,
            isReverse: true,
          );

          _animationController.reverse();
        }
      },
      child: SheetController(
        scrollController: _scrollController,
        child: LayoutBuilder(builder: (context, constraints) {
          _availableHeight = constraints.maxHeight;
          return AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return CustomSingleChildLayout(
                delegate: SheetLayoutDelegate(
                  progress: _progress,
                  maxHeight: maxHeight,
                ),
                child: child!,
              );
            },
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: context.theme.surfaceColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(18.0),
                ),
              ),
              child: Stack(
                fit: StackFit.passthrough,
                children: [
                  widget.builder(context),
                  Positioned.fill(
                    right: 6.0, // account for scroll bar
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onVerticalDragDown: (details) {},
                      onVerticalDragStart: (details) {
                        _startDetails = details;
                        if (_animationController.isAnimating) {
                          _animationController.stop();
                        }
                      },
                      onVerticalDragUpdate: (details) {
                        if (!_scrollController.hasClients) return;

                        if (!_isScrolling) {
                          _drag = _scrollController.position
                              .drag(_startDetails!, () {
                            _startDetails = null;
                            _drag = null;
                          });
                          _isScrolling = true;
                        }

                        final canScrollDown = _scrollController.offset > 0 &&
                            details.delta.dy > 0;
                        final canScrollUp = _animationController.value >= 1.0 &&
                            details.delta.dy < 0;

                        if (canScrollDown || canScrollUp) {
                          _drag?.update(details);
                        } else {
                          if (_scrollController.offset < 0 &&
                              details.delta.dy < 0) {
                            _scrollController.jumpTo(0.0);
                          }

                          _curve = Curves.linear;
                          _animationController.value -=
                              details.delta.dy / maxHeight;
                        }
                      },
                      onVerticalDragEnd: (details) {
                        if (_isScrolling) {
                          if (!_scrollController.hasClients) {
                            _isScrolling = false;
                            return;
                          }

                          final velocity = _animationController.value < 1.0
                              ? 0.0
                              : details.velocity.pixelsPerSecond.dy;

                          _drag?.end(
                            DragEndDetails(
                              primaryVelocity: velocity,
                              velocity: Velocity(
                                pixelsPerSecond: Offset(0, velocity),
                              ),
                              globalPosition: details.globalPosition,
                              localPosition: details.localPosition,
                            ),
                          );
                          _isScrolling = false;
                        }

                        final velocity = details.velocity.pixelsPerSecond.dy;
                        final canDismiss = _scrollController.hasClients
                            ? _scrollController.offset <= 0.0
                            : true;

                        bool dismiss = false;
                        if (velocity.abs() > 400.0) {
                          if (velocity > 0.0 && canDismiss) {
                            dismiss = true;
                          }
                        } else {
                          if (_progress < 0.5) {
                            dismiss = true;
                          }
                        }

                        var targetProgress = dismiss ? 0.0 : 1.0;

                        if (targetProgress != _progress) {
                          final difference = (targetProgress - _progress).abs();

                          final duration = Duration(
                            milliseconds:
                                difference.remap(0.0, 1.0, 150, 600.0).toInt(),
                          );
                          _animationController.duration = duration;
                          _curve = SuspendedCurve(
                            curve: Curves.fastEaseInToSlowEaseOut,
                            from: _progress,
                            isReverse: dismiss,
                          );

                          if (!dismiss) {
                            _animationController.forward();
                          } else {
                            _animationController.reverse();
                            Navigator.of(context).pop();
                          }
                        }
                      },
                      onVerticalDragCancel: () {
                        _drag?.cancel();
                        _isScrolling = false;
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Button _buildButton(int index) {
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
            index.toDouble().wrap(0, 14).remap(0, 14, 0, 360),
            0.7,
            value,
          ).toColor();
        },
      ),
      borderColor: WidgetStateColor.resolveWith(
        (states) {
          return Colors.transparent;
        },
      ),
      foregroundColor: WidgetStateColor.resolveWith(
        (states) {
          return HSVColor.fromAHSV(
            1.0,
            (index + 7).toDouble().wrap(0, 14).remap(0, 14, 0, 360),
            0.7,
            1.0,
          ).toColor();
        },
      ),
      borderRadius: 0,
      onPressed: () {},
      children: [Text("Item #${index + 1}")],
    );
  }
}

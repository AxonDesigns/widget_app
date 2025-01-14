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
    with SingleTickerProviderStateMixin, AfterLayoutMixin {
  final _scrollController = ScrollController();
  late final AnimationController _animationController;
  final _childKey = GlobalKey();

  Drag? _drag;
  DragStartDetails? _startDetails;

  final _curve = Curves.fastEaseInToSlowEaseOut;

  bool _isScrolling = false;
  bool _isDragging = false;
  double _availableHeight = 0.0;
  double _currentHeight = 0.0;
  double _lastHeight = 0.0;
  double _targetHeight = 0.0;

  double get _progress {
    return _currentHeight / maxHeight;
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
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  void afterLayout(Duration timeStamp) {
    super.afterLayout(timeStamp);
    open();
    /*WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final renderBox =
          _childKey.currentContext?.findRenderObject() as RenderBox?;
      print(renderBox?.size.height);
    });*/
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          close();
        }
      },
      child: SheetController(
        scrollController: _scrollController,
        child: LayoutBuilder(builder: (context, constraints) {
          _availableHeight = constraints.maxHeight;
          return AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              if (_animationController.isAnimating) {
                _currentHeight =
                    _curve.transform(_animationController.value).remap(
                          0.0,
                          1.0,
                          _lastHeight,
                          _targetHeight,
                        );
              }
              if (_animationController.isCompleted &&
                  _currentHeight != _targetHeight &&
                  !_isDragging) {
                _currentHeight = _targetHeight;
              }
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
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 64,
                    ),
                    child: KeyedSubtree(
                      key: _childKey,
                      child: widget.builder(context),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: SizedBox(
                      height: 64,
                      child: Center(
                        child: Container(
                          height: 6,
                          width: 100,
                          decoration: BoxDecoration(
                            color:
                                context.theme.foregroundColor.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(200),
                          ),
                        ),
                      ),
                    ),
                  ),
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
                        final canScrollUp =
                            _progress >= 1.0 && details.delta.dy < 0;
                        if (canScrollDown || canScrollUp) {
                          _isDragging = false;

                          _drag?.update(details);
                        } else {
                          _isDragging = true;
                          final newHeight = (_currentHeight - details.delta.dy)
                              .clamp(0.0, maxHeight);
                          if (_currentHeight != newHeight) {
                            /*if (_scrollController.offset < 0) {
                              _scrollController.
                            }*/
                            setState(() {
                              _currentHeight = newHeight;
                            });
                          }
                        }
                      },
                      onVerticalDragEnd: (details) {
                        if (_isScrolling) {
                          if (!_scrollController.hasClients) {
                            _isScrolling = false;
                            return;
                          }

                          final velocity = _isDragging
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

                        if (_isDragging) {
                          _isDragging = false;
                        }

                        final velocity = details.velocity.pixelsPerSecond.dy;
                        final canDismiss = _scrollController.hasClients
                            ? _scrollController.offset <= 0.0
                            : true;

                        if (velocity.abs() > 400.0) {
                          if (velocity > 0.0 && canDismiss) {
                            _targetHeight = 0.0;
                          } else {
                            _targetHeight = maxHeight;
                          }
                        } else {
                          if (_progress < 0.5) {
                            _targetHeight = 0.0;
                          } else {
                            _targetHeight = maxHeight;
                          }
                        }

                        _lastHeight = _currentHeight;
                        if (_lastHeight != _targetHeight) {
                          _startAnimation();
                        }
                        if (_targetHeight <= 0) {
                          Navigator.of(context).pop();
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

  void open() {
    if (_animationController.isAnimating) {
      _animationController.stop();
    }
    _lastHeight = _currentHeight;
    _targetHeight = maxHeight;
    _startAnimation();
  }

  void close() {
    if (_animationController.isAnimating) {
      _animationController.stop();
    }
    _lastHeight = _currentHeight;
    _targetHeight = 0.0;
    _startAnimation();
  }

  void _startAnimation() {
    final difference = (_targetHeight - _lastHeight).abs();
    final duration = Duration(
      milliseconds: difference.remap(0.0, maxHeight, 150, 600.0).toInt(),
    );
    _animationController.duration = duration;
    _animationController.forward(from: 0.0);
  }
}

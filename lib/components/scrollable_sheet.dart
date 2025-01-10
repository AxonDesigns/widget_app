import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:widget_app/components/components.dart';
import 'package:widget_app/extensions/extensions.dart';

class ScrollableSheet extends StatefulWidget {
  const ScrollableSheet({
    super.key,
    required this.child,
    required this.sheetBuilder,
    this.sheetController,
    this.relative = true,
    this.maxHeightFactor = 1.0,
    this.minHeightFactor = 0.0,
    this.startHeightFactor = 0.5,
    this.padding,
  });

  final Widget child;
  final Widget Function(BuildContext context, bool shrinkWrap) sheetBuilder;
  final ScrollController? sheetController;
  final bool relative;
  final double maxHeightFactor;
  final double startHeightFactor;
  final double minHeightFactor;
  final EdgeInsets? padding;

  @override
  State<ScrollableSheet> createState() => _ScrollableSheetState();
}

class _ScrollableSheetState extends State<ScrollableSheet>
    with SingleTickerProviderStateMixin, AfterLayoutMixin {
  late ScrollController _scrollController;
  late final AnimationController _animationController;
  final _contentKey = GlobalKey();
  bool _scrolling = false;
  Drag? _drag;
  DragStartDetails? _dragDetails;
  double _screenHeight = 0.0;
  double _currentHeight = 0.0;
  double _lastHeight = 0.0;
  double _targetHeight = 0.0;

  double? get contentHeight {
    final renderBox =
        _contentKey.currentContext?.findRenderObject() as RenderBox?;
    return renderBox?.size.height;
  }

  bool get shouldScroll {
    if (contentHeight == null) return false;
    return contentHeight! >= (_screenHeight * widget.maxHeightFactor);
  }

  double get maxHeight {
    if (!shouldScroll && contentHeight != null) {
      return contentHeight!;
    }

    return (_screenHeight * widget.maxHeightFactor);
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: 0.0,
    );
    _scrollController = widget.sheetController ?? ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void afterLayout(Duration timeStamp) {
    super.afterLayout(timeStamp);
    setState(() {});
  }

  @override
  void didUpdateWidget(covariant ScrollableSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.sheetController != oldWidget.sheetController) {
      _scrollController.removeListener(_onScroll);
      _scrollController.dispose();
      _scrollController = widget.sheetController ?? ScrollController();
      _scrollController.addListener(_onScroll);
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (!shouldScroll && _scrollController.offset > 0.0) {
      _scrollController.jumpTo(0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        statusBarColor: context.theme.backgroundColor,
        statusBarIconBrightness: context.invertedBrightness,
        systemNavigationBarColor: context.theme.backgroundColor,
      ),
      child: SafeArea(
        top: true,
        child: LayoutBuilder(
          builder: (context, constraints) {
            _screenHeight = constraints.maxHeight;
            return AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                if (_animationController.isAnimating) {
                  _currentHeight = Curves.fastEaseInToSlowEaseOut
                      .transform(
                        _animationController.value,
                      )
                      .remap(
                        0.0,
                        1.0,
                        _lastHeight,
                        _targetHeight,
                      );
                }
                return Stack(
                  children: [
                    // Content size calculation
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.0,
                        child: IgnorePointer(
                          child: Center(
                            child: SizedBox(
                              key: _contentKey,
                              child: Padding(
                                padding: EdgeInsets.only(
                                  left: widget.padding?.left ?? 0.0,
                                  right: widget.padding?.right ?? 0.0,
                                ),
                                child: widget.sheetBuilder(context, true),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    child!,
                    Positioned(
                      left: 0.0,
                      right: 0.0,
                      bottom: 0.0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: context.theme.surfaceColor,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(18.0),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              height: _currentHeight,
                            )
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0.0,
                      left: 0.0,
                      right: 0.0,
                      height: _currentHeight,
                      child: PrimaryScrollController(
                        controller: _scrollController,
                        child: widget.sheetBuilder(context, false),
                      ),
                    ),
                    Positioned(
                      bottom: 0.0,
                      left: 0.0,
                      right: 0.0,
                      height: _currentHeight + 70.0,
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onVerticalDragDown: (details) {},
                        onVerticalDragStart: (details) {
                          _dragDetails = details;
                        },
                        onVerticalDragUpdate: (details) {
                          final scrollingDown = details.delta.dy > 0.0;
                          final fullyExpanded = _currentHeight >= maxHeight;
                          final scrollAtTop = _scrollController.offset <= 0.0;
                          final canScrollDown = !scrollAtTop && scrollingDown;
                          final canScrollUp = fullyExpanded && !scrollingDown;

                          if (shouldScroll && (canScrollDown || canScrollUp)) {
                            if (!_scrolling) {
                              _drag = _scrollController.position
                                  .drag(_dragDetails!, () {
                                _drag = null;
                              });
                              setState(() => _scrolling = true);
                            } else {
                              _drag?.update(details);
                            }
                          } else {
                            if (_scrolling) {
                              _drag?.cancel();
                              setState(() => _scrolling = false);
                            }

                            if (_animationController.isAnimating) {
                              _animationController.stop();
                            }

                            _currentHeight -= details.delta.dy;
                            _currentHeight = _currentHeight.clamp(
                              0.0,
                              maxHeight,
                            );
                            setState(() {});
                          }
                        },
                        onVerticalDragEnd: (details) {
                          if (_scrolling) {
                            if (!_scrollController.hasClients) return;

                            _drag?.end(details);
                            setState(() => _scrolling = false);
                          }

                          _lastHeight = _currentHeight;

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
                            if (_lastHeight > (maxHeight * 0.5)) {
                              _targetHeight = maxHeight;
                            } else {
                              _targetHeight = 0.0;
                            }
                          }
                          if (_targetHeight != _currentHeight) {
                            final difference =
                                (_targetHeight - _currentHeight).abs();
                            final duration = Duration(
                              milliseconds: difference
                                  .remap(0.0, maxHeight, 150, 600.0)
                                  .toInt(),
                            );
                            _animationController.duration = duration;
                            _animationController.forward(from: 0.0);
                            //_animationController.fling(velocity: velocity);
                          }
                        },
                        onVerticalDragCancel: () {
                          if (!_scrollController.hasClients) return;
                          _drag?.cancel();
                          setState(() => _scrolling = false);
                        },
                      ),
                    ),
                  ],
                );
              },
              child: widget.child,
            );
          },
        ),
      ),
    );
  }
}

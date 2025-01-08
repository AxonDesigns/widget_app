import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:widget_app/components.dart';
import 'package:widget_app/extensions.dart';

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

  double? get contentHeight {
    final renderBox =
        _contentKey.currentContext?.findRenderObject() as RenderBox?;
    return renderBox?.size.height;
  }

  bool get shouldScroll {
    if (contentHeight == null) return false;
    return contentHeight! > MediaQuery.sizeOf(context).height;
  }

  double get maxHeight {
    if (!shouldScroll && contentHeight != null) {
      return contentHeight!;
    }

    return context.screenSize.height;
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
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
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
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
                        Center(
                          child: Container(
                            height: 5.0,
                            width: 90.0,
                            margin: const EdgeInsets.only(
                              top: 32.0,
                              bottom: 32.0,
                            ),
                            decoration: BoxDecoration(
                              color: context.theme.foregroundColor.withOpacity(
                                0.25,
                              ),
                              borderRadius: BorderRadius.circular(100.0),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: _animationController.value.remap(
                            0.0,
                            1.0,
                            0.0,
                            maxHeight,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0.0,
                  left: 0.0,
                  right: 0.0,
                  height: _animationController.value.remap(
                    0.0,
                    1.0,
                    0.0,
                    maxHeight,
                  ),
                  child: PrimaryScrollController(
                    controller: _scrollController,
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: widget.padding?.left ?? 0.0,
                        right: widget.padding?.right ?? 0.0,
                      ),
                      child: widget.sheetBuilder(context, false),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0.0,
                  left: 0.0,
                  right: 0.0,
                  height: _animationController.value.remap(
                        0.0,
                        1.0,
                        0.0,
                        maxHeight,
                      ) +
                      70.0,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onVerticalDragDown: (details) {},
                    onVerticalDragStart: (details) {
                      _dragDetails = details;
                    },
                    onVerticalDragUpdate: (details) {
                      if (shouldScroll) {
                        if (!_scrolling) {
                          _drag = _scrollController.position.drag(_dragDetails!,
                              () {
                            _drag = null;
                          });
                          setState(() => _scrolling = true);
                        } else {
                          _drag?.update(details);
                        }
                      } else {
                        if (_scrolling) {
                          _scrollController.jumpTo(0.0);
                          _drag?.cancel();
                          setState(() => _scrolling = false);
                        }

                        final delta = details.primaryDelta!.remap(
                          0.0,
                          maxHeight,
                          0.0,
                          1.0,
                        );

                        if ((_animationController.value - delta)
                            .isBetween(0.0, 1.0)) {
                          setState(() {
                            _animationController.value -= delta;
                          });
                        }
                      }
                    },
                    onVerticalDragEnd: (details) {
                      if (_scrolling) {
                        if (!_scrollController.hasClients) return;
                        _drag?.end(details);
                        setState(() => _scrolling = false);
                      }

                      final velocity = details.velocity.pixelsPerSecond.dy;
                      if (velocity.abs() > 400.0) {
                        if (velocity > 0.0) {
                          _animationController.reverse();
                        } else {
                          _animationController.forward();
                        }
                      } else {
                        if (_animationController.value > 0.5) {
                          _animationController.forward();
                        } else {
                          _animationController.reverse();
                        }
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
        ),
      ),
    );
  }
}

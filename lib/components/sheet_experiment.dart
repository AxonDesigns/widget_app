import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:widget_app/components/components.dart';
import 'package:widget_app/extensions/extensions.dart';

class SheetExperiment extends StatefulWidget {
  const SheetExperiment({
    super.key,
    required this.child,
    this.maxHeightFactor = 0.9,
    this.startHeightFactor = 0.5,
  });

  final Widget child;
  final double maxHeightFactor;
  final double startHeightFactor;

  @override
  State<SheetExperiment> createState() => _SheetExperimentState();
}

class _SheetExperimentState extends State<SheetExperiment>
    with SingleTickerProviderStateMixin {
  late final ScrollController _scrollController;
  late final AnimationController _animationController;
  double _minExtent = 50.0;
  double _maxExtent = 50.0;
  double _handleHeight = 50.0;
  Size _size = Size.zero;
  bool _isDragging = false;
  double _overscrollOffset = 0;
  double _dragOffset = 0;
  bool _draggable = true;
  bool _firstLayout = true;
  GlobalKey _key = GlobalKey();

  ScrollPhysics get inheritedPhysics =>
      ScrollConfiguration.of(context).getScrollPhysics(context);

  bool get isAtTop =>
      _scrollController.offset <= _scrollController.position.minScrollExtent;

  bool get contentTallerThanViewport =>
      _scrollController.position.maxScrollExtent > context.size!.height;

  double get contentHeight {
    final renderBox = _key.currentContext?.findRenderObject() as RenderBox?;
    return renderBox?.size.height ?? 100.0;
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant SheetExperiment oldWidget) {
    super.didUpdateWidget(oldWidget);
    /*final oldExtent = _maxExtent;
    _maxExtent = MediaQuery.sizeOf(context).height;
    _minExtent = ((1.0 - widget.maxHeightFactor) * _maxExtent) + _handleHeight;
    _dragOffset = _dragOffset.remap(
      _minExtent,
      oldExtent,
      _minExtent,
      _maxExtent,
    );*/
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    if (_scrollController.offset < _scrollController.position.minScrollExtent &&
        _dragOffset <= _handleHeight) {
      setState(() {
        _overscrollOffset = _scrollController.offset;
      });
    } else if (_overscrollOffset != 0.0) {
      setState(() {
        _overscrollOffset = 0.0;
      });
    }
  }

  Drag? _drag;
  ScrollHoldController? _hold;
  DragStartDetails? _dragDetails;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (_firstLayout) {
          _dragOffset = constraints.maxHeight * widget.startHeightFactor;
          _firstLayout = false;
        }

        if (constraints.biggest != _size &&
            !_firstLayout &&
            _scrollController.hasClients) {
          _size = constraints.biggest;
          final oldExtent = _maxExtent;
          _maxExtent = constraints.maxHeight;
          _draggable = contentHeight >= _maxExtent;

          _minExtent = ((1.0 - widget.maxHeightFactor) * _maxExtent) +
              _handleHeight +
              MediaQuery.of(context).viewPadding.top;

          if (_draggable) {
            _dragOffset = _dragOffset.remap(
              _minExtent,
              oldExtent,
              _minExtent,
              _maxExtent,
            );
          } else {
            _minExtent = _maxExtent - contentHeight;
            if (_dragOffset < _minExtent) {
              _dragOffset = _minExtent;
            }
            _scrollController.jumpTo(0.0);
          }
          print(_draggable);
        }

        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Stack(
              children: [
                widget.child,
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  top: _dragOffset - _handleHeight - _overscrollOffset,
                  child: Container(
                    decoration: BoxDecoration(
                      color: context.theme.surfaceColor,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(10.0),
                      ),
                    ),
                    padding: const EdgeInsets.only(
                      top: 23.0,
                    ),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        decoration: BoxDecoration(
                          color: context.theme.primaryColor,
                          borderRadius: BorderRadius.circular(100.0),
                        ),
                        height: 4.0,
                        width: 90.0,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  top: _dragOffset,
                  child: _buildScrollable(
                    controller: _scrollController,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  top: _dragOffset - _handleHeight,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onVerticalDragDown: (details) {
                      if (!_scrollController.hasClients) return;
                    },
                    onVerticalDragStart: (details) {
                      if (!_scrollController.hasClients) return;
                      _dragDetails = details;
                    },
                    onVerticalDragUpdate: (details) {
                      if (!_scrollController.hasClients) return;

                      // Dragging down
                      if (isAtTop &&
                          details.primaryDelta! >= 0 &&
                          _dragOffset <= _maxExtent) {
                        _dragOffset += details.primaryDelta!;
                        setState(() {
                          _dragOffset = _dragOffset.clamp(
                            _minExtent,
                            _maxExtent,
                          );
                        });
                        return;
                      }

                      // Dragging up
                      if (isAtTop &&
                          details.primaryDelta! < 0 &&
                          _dragOffset > _minExtent) {
                        _dragOffset += details.primaryDelta!;
                        setState(() {
                          _dragOffset = _dragOffset.clamp(
                            _minExtent,
                            _maxExtent,
                          );
                        });
                        return;
                      }
                      // Start drag if not already dragging
                      if (!_isDragging && _draggable) {
                        _drag =
                            _scrollController.position.drag(_dragDetails!, () {
                          _drag = null;
                        });
                        setState(() {
                          _isDragging = true;
                        });
                      }

                      if (_overscrollOffset != 0) {
                        setState(() {
                          _overscrollOffset = 0;
                        });
                      }

                      _drag?.update(details);
                    },
                    onVerticalDragEnd: (details) {
                      final velocity = isAtTop || _dragOffset >= _maxExtent
                          ? Velocity.zero
                          : details.velocity;
                      _drag?.end(
                        DragEndDetails(
                          globalPosition: details.globalPosition,
                          localPosition: details.localPosition,
                          primaryVelocity: velocity.pixelsPerSecond.dy,
                          velocity: velocity,
                        ),
                      );
                      setState(() {
                        _isDragging = false;
                      });
                    },
                    onVerticalDragCancel: () {
                      _drag?.cancel();
                      _hold?.cancel();
                    },
                  ),
                ),
                Positioned.fill(
                  child: Offstage(
                    offstage: true,
                    child: IgnorePointer(
                      child: Center(
                        child: _buildScrollable(
                          key: _key,
                          shrinkWrap: true,
                        ),
                      ),
                    ),
                  ),
                )
                /*Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: _bottomExtend > 0 ? _bottomExtend + 1 : 0,
                  child: Container(
                    color: context.theme.surfaceColor.highest,
                  ),
                ),
                Positioned.fill(
                  child: RawScrollbar(
                    thumbVisibility: false,
                    trackVisibility: false,
                    interactive: false,
                    thickness: 0,
                    controller: _controller,
                    child: CustomScrollView(
                      controller: _controller,
                      scrollBehavior: GenericScrollBehavior(
                        desktopPhysics: const BouncingScrollPhysics(),
                      ),
                      slivers: [
                        SliverToBoxAdapter(
                          child: Container(
                            height: constraints.maxHeight,
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {},
                            onVerticalDragDown: (details) {
                              if (!_controller.hasClients) return;
        
                              _hold = _controller.position.hold(
                                () {
                                  _hold = null;
                                },
                              );
                            },
                            onVerticalDragStart: (details) {
                              print("DRAG START");
                              _drag = _controller.position.drag(details, () {
                                _drag = null;
                              });
                              setState(() {
                                _isDragging = true;
                              });
                            },
                            onVerticalDragUpdate: (details) {
                              _drag?.update(details);
                            },
                            onVerticalDragEnd: (details) {
                              _drag?.end(details);
                              setState(() {
                                _isDragging = false;
                              });
                            },
                            onVerticalDragCancel: () {
                              _drag?.cancel();
                              _hold?.cancel();
                            },
                            child: Container(
                              key: _key,
                              color: context.theme.surfaceColor.highest,
                              padding: const EdgeInsets.all(16.0),
                              child: GappedColumn(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                gap: 8.0,
                                children: [
                                  Text(
                                    "HOLA GENTE",
                                    style: context.theme.baseTextStyle.copyWith(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Text(
                                      "Necessitatibus perspiciatis accusantium nesciunt architecto. Quia sunt rerum non incidunt voluptate occaecati similique. Odit et nulla maxime."),
                                  Button.primary(
                                    onPressed: () {},
                                    children: const [
                                      Text("Accept"),
                                    ],
                                  ),
                                  Button.outline(
                                    onPressed: () {},
                                    children: const [
                                      Text("Cancel"),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),*/
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildScrollable(
      {Key? key, ScrollController? controller, bool shrinkWrap = false}) {
    return CustomScrollView(
      key: key,
      controller: controller,
      shrinkWrap: shrinkWrap,
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                  """Quam ducimus voluptatem qui mollitia est a illum quae. Laudantium magni est eum explicabo dolor aut consectetur quia. Dolores fugiat repudiandae qui et exercitationem. Sit ullam ad in fugiat consequatur sint nisi. Aut similique ut maxime.
              
              Possimus doloremque necessitatibus sed pariatur consequuntur soluta rerum. Deserunt natus qui voluptas commodi. Quia dolorem voluptatem optio sed dolores deserunt sunt."""),
              Button.primary(
                onPressed: () {},
                children: const [Text("Test")],
              ),
              const Text(
                  """Nulla et excepturi aut ullam aut ea. Quo suscipit nesciunt dicta at iste nesciunt molestias modi. Numquam nesciunt voluptatem similique hic facere saepe. Culpa facere voluptas reiciendis repellendus et consequatur praesentium facere. Ab qui expedita deserunt eligendi beatae reprehenderit voluptates. Mollitia aut quae tempore qui illo.
                                      
                                      Excepturi est dolorem facilis incidunt. Ut et voluptatem consectetur. Eum porro qui reiciendis aliquid velit molestiae sit cumque. Aut perferendis autem enim harum molestiae nihil nemo ut. Velit vel et eius omnis. Voluptatum voluptatem et eos.
                                      
                                      Optio in voluptatem autem et maiores. Saepe quisquam ab quod ipsam. Totam velit est asperiores ipsa eius consequatur velit. Quia necessitatibus ea quo facere ipsum in. Rem nihil sed nisi fugit provident.
                                      
                                      Error eaque iure nostrum placeat dolorem totam perspiciatis. Nulla fuga ut animi illo pariatur itaque. Quidem autem consequuntur iusto nostrum id esse consequuntur aut. Dolorem itaque et error sit. Libero similique quis minima voluptas rerum voluptas. Nulla perspiciatis mollitia error unde.
                                      
                                      Et omnis et dolore qui architecto atque pariatur odio. Repellendus accusantium vitae qui mollitia. Quod aut culpa aut ut enim excepturi non. Consequatur quaerat aut voluptatum aut illum est. Est nostrum est consequatur ducimus id possimus.
                                      
                                      Voluptatem voluptas aut quos recusandae molestiae est sapiente. Dolore est optio quia deserunt. Quis et error necessitatibus tempore.
                                      
                                      Nobis totam delectus cupiditate quas id dolorum illo. Nobis iure quod porro sit repellat incidunt necessitatibus nihil. Quis dolor voluptates voluptatem. Sed reprehenderit in sit animi sint excepturi sit.
                                      
                                      Ducimus in iusto quidem sed velit quidem. Repudiandae atque cumque id. Quae praesentium ut labore ipsam optio dolorem quo. Repellat quos totam ea officiis necessitatibus rerum distinctio quis. Quia autem iusto autem distinctio eaque. Labore nesciunt aspernatur sit voluptates ipsa.""")
            ],
          ),
        ),
      ],
    );
  }
}

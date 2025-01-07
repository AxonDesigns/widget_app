import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:widget_app/components.dart';

class SheetExperiment extends StatefulWidget {
  const SheetExperiment({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<SheetExperiment> createState() => _SheetExperimentState();
}

class _SheetExperimentState extends State<SheetExperiment> {
  late final ScrollController _controller;
  double _bottomExtend = 0.0;
  double _randomNumber = 0.0;
  bool _isDragging = false;
  final _key = GlobalKey();
  RenderBox? _renderBox;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    _controller.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        _renderBox = _key.currentContext?.findRenderObject() as RenderBox?;
        if (_renderBox != null) {
          setState(() {});
        }
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_controller.hasClients) return;
    final scrollDiff =
        _controller.position.maxScrollExtent - _controller.offset;
    if (scrollDiff < 0) {
      setState(() {
        _bottomExtend = -1 * scrollDiff;
      });
    } else {
      setState(() {
        _bottomExtend = 0.0;
      });
    }
  }

  Drag? _drag;
  ScrollHoldController? _hold;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            widget.child,
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
  }
}

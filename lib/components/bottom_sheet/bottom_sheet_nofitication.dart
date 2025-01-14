import 'package:widget_app/components/bottom_sheet/bottom_sheet_layout.dart';
import 'package:widget_app/generic.dart';

class BottomSheetNotification extends StatefulWidget {
  const BottomSheetNotification({super.key});

  @override
  State<BottomSheetNotification> createState() =>
      _BottomSheetNotificationState();
}

class _BottomSheetNotificationState extends State<BottomSheetNotification>
    with SingleTickerProviderStateMixin {
  final _scrollController = ScrollController();
  late final AnimationController _animationController;
  ScrollPhysics? _physics;

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
    _physics = const BouncingScrollPhysics();
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
            delegate: SheetLayoutDelegate(
              maxHeight: _availableHeight,
              progress: _percentage,
            ),
            child: GestureDetector(
              onVerticalDragUpdate: (details) {
                print("ghfdg");
              },
              onVerticalDragEnd: (details) {},
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  ScrollPosition position;

                  if (_scrollController.positions.isNotEmpty) {
                    position = _scrollController.positions.firstWhere(
                      (element) => element.isScrollingNotifier.value,
                      orElse: () => _scrollController.positions.first,
                    );
                  } else {
                    position = _scrollController.position;
                  }

                  final isReverse =
                      position.axisDirection == AxisDirection.down;

                  final offset = isReverse
                      ? position.pixels
                      : position.maxScrollExtent - position.pixels;

                  if (offset <= 0) {
                    //_physics = const NeverScrollableScrollPhysics();

                    if (notification is ScrollEndNotification) {
                      //TODO: handle scroll end
                    }

                    DragUpdateDetails? details;

                    if (notification is ScrollUpdateNotification) {
                      details = notification.dragDetails;
                    }
                    if (notification is OverscrollNotification) {
                      details = notification.dragDetails;
                    }

                    if (details != null) {
                      _curve = Curves.linear;
                      _physics = const ClampingScrollPhysics();
                      _animationController.value -=
                          details.delta.dy / _availableHeight;

                      _isDragging = true;
                    } else if (_isDragging) {
                      _curve = SuspendedCurve(
                        curve: Curves.fastEaseInToSlowEaseOut,
                        from: _animationController.value,
                      );
                      _physics = const BouncingScrollPhysics();
                      print("DRAG END");
                      _isDragging = false;
                    }
                  } else {
                    _physics = const BouncingScrollPhysics();
                  }

                  return false;
                },
                child: ListView.builder(
                  controller: _scrollController,
                  physics: _physics,
                  itemCount: 100,
                  itemBuilder: (context, index) {
                    if (index == 4) {
                      return SizedBox(
                        height: 150,
                        child: PageView.builder(
                          itemCount: 20,
                          itemBuilder: (context, index) {
                            return Container(
                              color: HSVColor.fromAHSV(
                                1.0,
                                index
                                    .toDouble()
                                    .wrap(0, 13)
                                    .remap(0, 13, 0, 360),
                                0.7,
                                1.0,
                              ).toColor(),
                            );
                          },
                        ),
                      );
                    }
                    if (index == 6) {
                      return SizedBox(
                        height: 150,
                        child: ListView.builder(
                          itemCount: 20,
                          itemBuilder: (context, index) {
                            return Container(
                              height: 40,
                              child: Text("Item #${index + 1}"),
                            );
                          },
                        ),
                      );
                    }
                    return _buildButton(index);
                  },
                ),
              ),
            ),
          );
        },
      );
    });
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
            (index + 100).toDouble().wrap(0, 13).remap(0, 13, 0, 360),
            0.7,
            1.0,
          ).toColor();
        },
      ),
      foregroundColor: WidgetStateColor.resolveWith(
        (states) {
          return HSVColor.fromAHSV(
            1.0,
            (index + 100).toDouble().wrap(0, 13).remap(0, 13, 0, 360),
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

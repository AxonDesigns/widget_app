import 'package:widget_app/generic.dart';

class CustomModal extends StatefulWidget {
  const CustomModal({
    super.key,
    required this.child,
    this.scrollController,
  });

  final Widget child;
  final ScrollController? scrollController;

  @override
  State<CustomModal> createState() => _CustomModalState();
}

class _CustomModalState extends State<CustomModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late ScrollController _effectiveScrollController;
  bool _pointerDown = false;
  bool _dragging = false;

  double _currentHeight = 50.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _effectiveScrollController = widget.scrollController ?? ScrollController();
  }

  @override
  void didUpdateWidget(covariant CustomModal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.scrollController != oldWidget.scrollController) {
      _effectiveScrollController.dispose();
      _effectiveScrollController =
          widget.scrollController ?? ScrollController();
    }
  }

  @override
  void dispose() {
    _effectiveScrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxHeight: 400,
            ),
            child: Listener(
              behavior: HitTestBehavior.translucent,
              onPointerDown: (event) {
                setState(() {
                  _pointerDown = true;
                  _dragging = false;
                });
              },
              onPointerMove: (event) {
                if (_pointerDown) {
                  setState(() {
                    _dragging = true;
                  });
                }

                setState(() {
                  _currentHeight -= event.delta.dy;
                  _currentHeight = _currentHeight.clamp(
                    50.0,
                    400.0,
                  );
                });
              },
              onPointerUp: (event) {
                setState(() {
                  _pointerDown = false;
                  if (_dragging) {
                    _dragging = false;
                  }
                });
              },
              child: Container(
                height: _currentHeight,
                color: context.theme.surfaceColor,
                child: SingleChildScrollView(
                  controller: _effectiveScrollController,
                  padding: const EdgeInsets.all(16.0),
                  child: const Text(
                    'Scrollable',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

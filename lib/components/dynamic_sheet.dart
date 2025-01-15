import 'package:widget_app/generic.dart';

class DraggableSheetController extends ChangeNotifier {
  DraggableScrollController? _controller;

  bool get isAttached => _controller != null && _controller!.hasClients;

  void _attach(DraggableScrollController controller) {
    _controller = controller;
    _controller!.extent._extent.addListener(notifyListeners);
  }

  void _detach({disposeExtent = false}) {
    if (disposeExtent) {
      _controller?.extent.dispose();
    } else {
      _controller?.extent._extent.removeListener(notifyListeners);
    }
    _controller = null;
  }
}

class DynamicSheet extends StatefulWidget {
  const DynamicSheet({
    super.key,
    required this.builder,
    this.controller,
    this.physics,
    this.maxHeightFactor = 1.0,
  });

  final Widget Function(
    BuildContext context,
    ScrollController controller,
  ) builder;
  final DraggableSheetController? controller;
  final ScrollPhysics? physics;

  /// How much of the screen should be occupied by the sheet
  final double maxHeightFactor;

  @override
  State<DynamicSheet> createState() => _DynamicSheetState();
}

class _DynamicSheetState extends State<DynamicSheet>
    with SingleTickerProviderStateMixin, AfterLayoutMixin {
  late DraggableScrollController _scrollController;
  late DraggableSheetExtent _extent;
  late AnimationController _animationController;

  double _lastExtent = 0.0;
  double _targetExtent = 0.0;

  double get maxExtent => widget.maxHeightFactor;

  @override
  void initState() {
    super.initState();
    _extent = DraggableSheetExtent(
      currentSize: ValueNotifier<double>(0.0),
      minExtent: 0.0,
      maxExtent: widget.maxHeightFactor,
    );
    _scrollController = DraggableScrollController(
      extent: _extent,
      onHold: () {
        if (_animationController.isAnimating) {
          _animationController.stop();
        }
      },
      onDragEnd: (velocity) {
        if (_animationController.isAnimating) {
          _animationController.stop();
        }
        final canDismiss = _scrollController.hasClients
            ? _scrollController.offset <= 0.0
            : true;

        if (velocity.abs() > 500.0) {
          if (velocity < 0.0 && canDismiss) {
            _targetExtent = 0.0;
          } else {
            _targetExtent = maxExtent;
          }
        } else {
          if (_extent.extent < 0.5) {
            _targetExtent = 0.0;
          } else {
            _targetExtent = maxExtent;
          }
        }

        _lastExtent = _extent.extent;
        if (_lastExtent != _targetExtent) {
          _animationController.forward(from: 0.0);
        }
        if (_targetExtent <= 0) {
          Navigator.of(context).pop();
        }
      },
    );
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animationController.addListener(_onAnimate);
  }

  @override
  void dispose() {
    _animationController.removeListener(_onAnimate);
    _animationController.dispose();
    if (widget.controller == null) {
      _extent.dispose();
    } else {
      widget.controller!._detach(disposeExtent: true);
    }
    super.dispose();
  }

  @override
  void afterLayout(Duration timeStamp) {
    super.afterLayout(timeStamp);
    if (_animationController.isAnimating) {
      _animationController.reset();
    }
    _lastExtent = _extent.extent;
    _targetExtent = widget.maxHeightFactor;
    _animationController.forward(from: 0.0);
  }

  @override
  void didUpdateWidget(covariant DynamicSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      widget.controller!._detach();
      widget.controller!._attach(_scrollController);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void _onAnimate() {
    final value = Curves.fastEaseInToSlowEaseOut
        .transform(_animationController.value)
        .remap(
          0.0,
          1.0,
          _lastExtent,
          _targetExtent,
        );

    if (_animationController.isAnimating) {
      _extent._extent.value = value;
    }
    if (_animationController.isCompleted && !_scrollController.isDragging) {
      _extent._extent.value = value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          if (_animationController.isAnimating) {
            _animationController.reset();
          }
          _lastExtent = _extent.extent;
          _targetExtent = 0.0;
          _animationController.forward(from: 0.0);
        }
      },
      child: LayoutBuilder(builder: (context, constraints) {
        _extent.availablePixels = constraints.maxHeight;
        return ValueListenableBuilder<double>(
          valueListenable: _extent._extent,
          builder: (context, value, child) {
            //print("value $value");
            return Stack(
              fit: StackFit.passthrough,
              children: [
                Positioned.fill(
                  top: _extent.availablePixels -
                      (value * _extent.availablePixels),
                  child: Container(
                    color: context.theme.surfaceColor,
                  ),
                ),
                FractionallySizedBox(
                  alignment: AlignmentDirectional.bottomCenter,
                  heightFactor: _extent.extent,
                  child: child,
                ),
              ],
            );
          },
          child: widget.builder(
            context,
            _scrollController,
          ),
        );
      }),
    );
  }
}

class DraggableSheetExtent {
  DraggableSheetExtent({
    ValueNotifier<double>? currentSize,
    this.minExtent = 0.0,
    this.maxExtent = 1.0,
    this.availablePixels = double.infinity,
  }) : _extent = currentSize ?? ValueNotifier<double>(0.0);

  VoidCallback? _cancelActivity;

  final ValueNotifier<double> _extent;
  final double minExtent;
  final double maxExtent;
  double availablePixels;
  bool hasDragged = false;
  bool hasChanged = false;

  double get extent => _extent.value;

  bool get isAtMin => minExtent >= _extent.value;
  bool get isAtMax => maxExtent <= _extent.value;

  void startActivity(VoidCallback onCanceled) {
    _cancelActivity?.call();
    _cancelActivity = onCanceled;
  }

  void update(double value, BuildContext context) {
    final clamped = value.clamp(minExtent, maxExtent);
    if (clamped == _extent.value) return;
    _extent.value = clamped;
    // TODO: Dispatch notification
  }

  void addPixelDelta(double delta, BuildContext context) {
    if (availablePixels == 0) return;

    hasDragged = true;
    hasChanged = true;
    update(extent + pixelsToSize(delta), context);
  }

  double pixelsToSize(double pixels) {
    return pixels / availablePixels * maxExtent;
  }

  double sizeToPixels(double size) {
    return size / maxExtent * availablePixels;
  }

  void dispose() {
    _extent.dispose();
  }

  DraggableSheetExtent copyWith({
    ValueNotifier<double>? currentSize,
    double? minExtend,
    double? maxExtend,
    double? availablePixels,
  }) {
    return DraggableSheetExtent(
      currentSize: currentSize ?? _extent,
      minExtent: minExtend ?? minExtent,
      maxExtent: maxExtend ?? maxExtent,
      availablePixels: availablePixels ?? this.availablePixels,
    );
  }
}

class DraggableScrollController extends ScrollController {
  DraggableScrollController({
    required this.extent,
    this.onHold,
    this.onDrag,
    this.onDragEnd,
    this.onDragStart,
  });

  final DraggableSheetExtent extent;
  final Function()? onHold;
  final Function()? onDragStart;
  final Function(double delta, bool isScrolling)? onDrag;
  final Function(double velocity)? onDragEnd;

  bool isDragging = false;

  @override
  DraggableScrollPosition get position =>
      super.position as DraggableScrollPosition;

  @override
  DraggableScrollPosition createScrollPosition(
    ScrollPhysics physics,
    ScrollContext context,
    ScrollPosition? oldPosition,
  ) {
    return DraggableScrollPosition(
      context: context,
      physics: physics,
      oldPosition: oldPosition,
      extent: extent,
      onHold: onHold,
      onDragStart: () {
        onDragStart?.call();
        isDragging = true;
      },
      onDrag: onDrag,
      onDragEnd: (velocity) {
        onDragEnd?.call(velocity);
        isDragging = false;
      },
    );
  }
}

class DraggableScrollPosition extends ScrollPositionWithSingleContext {
  DraggableScrollPosition({
    required super.physics,
    required super.context,
    super.oldPosition,
    required this.extent,
    this.onHold,
    this.onDrag,
    this.onDragEnd,
    this.onDragStart,
  });

  final DraggableSheetExtent extent;
  final Function()? onHold;
  final Function()? onDragStart;
  final Function(double delta, bool isScrolling)? onDrag;
  final Function(double velocity)? onDragEnd;

  bool get _shouldScroll => pixels > 0.0;
  bool _dragging = false;

  @override
  void applyUserOffset(double delta) {
    if (!_shouldScroll &&
        (!(extent.isAtMin || extent.isAtMax) ||
            (extent.isAtMin && delta < 0) ||
            (extent.isAtMax && delta > 0))) {
      extent.addPixelDelta(-delta, context.notificationContext!);
      onDrag?.call(delta, false);
    } else {
      super.applyUserOffset(delta);
      onDrag?.call(delta, true);
    }
    _dragging = true;
  }

  @override
  void goBallistic(double velocity) {
    if (_dragging) {
      onDragEnd?.call(velocity);
    }

    if (pixels <= 0.0) {
      super.goBallistic(0.0);
    } else {
      super.goBallistic(velocity);
    }
    _dragging = false;
  }

  @override
  void didStartScroll() {
    onDragStart?.call();
    super.didStartScroll();
  }

  //int lastime = DateTime.now().millisecondsSinceEpoch;
  //double _lastPos = 0.0;
  @override
  ScrollHoldController hold(VoidCallback holdCancelCallback) {
    onHold?.call();
    // In case the overscroll is still active, we set pixels to 0.0
    // and compensate the overscroll with extent.
    if (pixels < 0.0) {
      extent.addPixelDelta(pixels, context.notificationContext!);
      forcePixels(0.0);
    }
    return super.hold(holdCancelCallback);
  }

  /*@override
  void didUpdateScrollMetrics() {
    super.didUpdateScrollMetrics();
    // Predict if next position will be an overscroll.
    // If it is, then jump to 0 to avoid it.
    final deltaSeconds =
        (DateTime.now().millisecondsSinceEpoch - lastime) / 1000;
    final deltaPos = pixels - _lastPos;
    final velocity = deltaPos / deltaSeconds;
    final nextPos = pixels + (velocity * deltaSeconds);

    if (nextPos < 0 && !_dragging) {
      jumpTo(0);
    }

    lastime = DateTime.now().millisecondsSinceEpoch;
    _lastPos = pixels;
  }*/
}

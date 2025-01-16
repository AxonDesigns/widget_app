import 'package:widget_app/generic.dart';

class DraggableSheetController extends ChangeNotifier {
  DraggableScrollController? _controller;

  bool get isAttached => _controller != null && _controller!.hasClients;

  void _attach(DraggableScrollController controller) {
    _controller = controller;
    _controller!.extent._data.addListener(notifyListeners);
  }

  void _detach({disposeExtent = false}) {
    if (disposeExtent) {
      _controller?.extent.dispose();
    } else {
      _controller?.extent._data.removeListener(notifyListeners);
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

class _DynamicSheetState extends State<DynamicSheet> with SingleTickerProviderStateMixin, AfterLayoutMixin {
  late DraggableScrollController _scrollController;
  late DraggableSheetExtent _extent;
  late AnimationController _animationController;

  final _contentKey = GlobalKey(debugLabel: 'draggable sheet content');

  double _contentHeight = double.infinity;
  double _lastExtent = 0.0;
  double _targetExtent = 0.0;

  double get maxExtent {
    if (_contentHeight < _extent.availablePixels * widget.maxHeightFactor) {
      return _contentHeight / _extent.availablePixels;
    }
    return widget.maxHeightFactor;
  }

  @override
  void initState() {
    super.initState();
    _extent = DraggableSheetExtent(
      initialSize: 0.0,
      overscroll: 0.0,
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
      onHoldEnd: () {
        _startAnimation(getTargetExtent(0.0));
      },
      onDragEnd: (velocity) {
        if (_animationController.isAnimating) {
          _animationController.stop();
        }
        final canDismiss = _scrollController.hasClients ? _scrollController.offset <= 0.0 : true;
        double targetExtent = 0.0;
        if (velocity.abs() > 500.0) {
          if (velocity < 0.0 && canDismiss) {
            targetExtent = 0.0;
          } else {
            targetExtent = maxExtent;
          }
        } else {
          if (_extent.extent < 0.5) {
            targetExtent = 0.0;
          } else {
            targetExtent = maxExtent;
          }
        }

        if (_extent.extent != targetExtent) {
          _startAnimation(targetExtent);
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
    final renderBox = _contentKey.currentContext?.findRenderObject() as RenderBox?;
    final height = renderBox?.size.height;
    if (height != null && height < _extent.availablePixels) {
      _contentHeight = height;
    }
    _startAnimation(maxExtent);
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

  void _startAnimation(double target) {
    if (_animationController.isAnimating) {
      _animationController.stop();
    }
    _lastExtent = _extent.extent;
    _targetExtent = target;
    _animationController.forward(from: 0.0);

    if (_targetExtent <= 0.0) {
      //Navigator.of(context).pop();
    }
  }

  void _onAnimate() {
    final value = Curves.fastEaseInToSlowEaseOut.transform(_animationController.value).remap(
          0.0,
          1.0,
          _lastExtent,
          _targetExtent,
        );

    if (_animationController.isAnimating) {
      _extent._data.size = value;
    }
    if (_animationController.isCompleted && !_scrollController.isDragging) {
      _extent._data.size = value;
    }
  }

  double getTargetExtent(double velocity) {
    final canDismiss = _scrollController.hasClients ? _scrollController.offset <= 0.0 : true;
    double targetExtent = 0.0;
    if (velocity.abs() > 500.0) {
      if (velocity < 0.0 && canDismiss) {
        targetExtent = 0.0;
      } else {
        targetExtent = maxExtent;
      }
    } else {
      if (_extent.extent < 0.5) {
        targetExtent = 0.0;
      } else {
        targetExtent = maxExtent;
      }
    }
    return targetExtent;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          _startAnimation(0.0);
        }
      },
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (_extent.availablePixels != constraints.maxHeight) {
              _extent.availablePixels = constraints.maxHeight;
            }
            return ListenableBuilder(
              listenable: _extent._data,
              builder: (context, child) {
                final size = _extent._data.size;
                final overscroll = _extent._data._overscroll;
                return Stack(
                  fit: StackFit.passthrough,
                  children: [
                    Positioned.fill(
                      top: _extent.availablePixels - (size * _extent.availablePixels) - overscroll,
                      child: Container(
                        color: context.theme.surfaceColor,
                      ),
                    ),
                    FractionallySizedBox(
                      alignment: AlignmentDirectional.bottomCenter,
                      heightFactor: _extent.extent,
                      child: child,
                    ),
                    Positioned.fill(
                      child: IgnorePointer(
                        child: Offstage(
                          child: OverflowBox(
                            child: Center(
                              child: KeyedSubtree(
                                key: _contentKey,
                                child: widget.builder(
                                  context,
                                  ScrollController(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
              child: GestureDetector(
                onVerticalDragUpdate: (details) {
                  if (_animationController.isAnimating) {
                    _animationController.stop();
                  }
                  _extent.addPixelDelta(-details.delta.dy, context);
                },
                onVerticalDragEnd: (details) {
                  _startAnimation(getTargetExtent(-details.velocity.pixelsPerSecond.dy));
                },
                child: widget.builder(
                  context,
                  _scrollController,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Stores a notifies if any value changes
class ExtentData extends ChangeNotifier {
  ExtentData({
    required double size,
    required double overscroll,
  })  : _size = size,
        _overscroll = overscroll;

  double _size;
  double _overscroll;

  set size(value) {
    _size = value;
    notifyListeners();
  }

  set overscroll(value) {
    _overscroll = value;
    notifyListeners();
  }

  double get size => _size;
  double get overscroll => _overscroll;
}

class DraggableSheetExtent {
  DraggableSheetExtent({
    double? initialSize,
    double? overscroll,
    this.minExtent = 0.0,
    this.maxExtent = 1.0,
    this.availablePixels = double.infinity,
  }) : _data = ExtentData(size: initialSize ?? 0.0, overscroll: overscroll ?? 0.0);

  VoidCallback? _cancelActivity;

  final ExtentData _data;
  final double minExtent;
  final double maxExtent;
  double availablePixels;
  bool hasDragged = false;
  bool hasChanged = false;

  double get extent => _data.size;

  bool get isAtMin => minExtent >= _data.size;
  bool get isAtMax => maxExtent <= _data.size;

  void startActivity(VoidCallback onCanceled) {
    _cancelActivity?.call();
    _cancelActivity = onCanceled;
  }

  void update(double value, BuildContext context) {
    final clamped = value.clamp(minExtent, maxExtent);
    if (clamped == _data.size) return;
    _data.size = clamped;
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
    _data.dispose();
  }

  DraggableSheetExtent copyWith({
    double? initialSize,
    double? overscroll,
    double? minExtend,
    double? maxExtend,
    double? availablePixels,
  }) {
    return DraggableSheetExtent(
      initialSize: initialSize ?? _data.size,
      overscroll: overscroll ?? _data._overscroll,
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
    this.onHoldEnd,
    this.onDrag,
    this.onDragEnd,
    this.onDragStart,
  });

  final DraggableSheetExtent extent;
  final Function()? onHold;
  final Function()? onHoldEnd;
  final Function()? onDragStart;
  final Function(double delta, bool isScrolling)? onDrag;
  final Function(double velocity)? onDragEnd;

  bool isDragging = false;

  @override
  DraggableScrollPosition get position => super.position as DraggableScrollPosition;

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
      onHoldEnd: onHoldEnd,
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
    this.onHoldEnd,
    this.onDrag,
    this.onDragEnd,
    this.onDragStart,
  });

  final DraggableSheetExtent extent;
  final Function()? onHold;
  final Function()? onHoldEnd;
  final Function()? onDragStart;
  final Function(double delta, bool isScrolling)? onDrag;
  final Function(double velocity)? onDragEnd;

  bool get _shouldScroll => pixels > 0.0;
  bool _dragging = false;

  @override
  void applyUserOffset(double delta) {
    if (!_shouldScroll && (!(extent.isAtMin || extent.isAtMax) || (extent.isAtMin && delta < 0) || (extent.isAtMax && delta > 0))) {
      extent.addPixelDelta(-delta, context.notificationContext!);
      onDrag?.call(delta, false);
    } else {
      super.applyUserOffset(delta);
      onDrag?.call(delta, true);
    }
    _dragging = true;
  }

  bool _wasHold = false;
  @override
  void beginActivity(ScrollActivity? newActivity) {
    if (_wasHold && newActivity is IdleScrollActivity) {
      onHoldEnd?.call();
    }

    _wasHold = newActivity is HoldScrollActivity;
    super.beginActivity(newActivity);
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

  @override
  void didUpdateScrollMetrics() {
    super.didUpdateScrollMetrics();
    if (pixels <= 0.0) {
      if (extent._data.overscroll == pixels) return;
      extent._data.overscroll = pixels;
    }
  }
}

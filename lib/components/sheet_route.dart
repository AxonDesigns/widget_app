import 'package:flutter/rendering.dart';
import 'package:widget_app/generic.dart';
import 'package:sheet/sheet.dart';

extension on double {
  /// Re-maps a number from one range to another.
  ///
  /// A value of fromLow would get mapped to toLow, a value of
  /// fromHigh to toHigh, values in-between to values in-between, etc
  double mapDistance({
    required double fromLow,
    required double fromHigh,
    required double toLow,
    required double toHigh,
  }) {
    final double offset = toLow;
    final double ratio = (toHigh - toLow) / (fromHigh - fromLow);
    return ratio * (this - fromLow) + offset;
  }
}

class BetterSheetRoute<T> extends PageRoute<T>
    with GenericDelegatedTransitionsRoute<T> {
  BetterSheetRoute({
    required this.builder,
    this.maintainState = true,
    this.barrierDismissible = true,
    this.barrierColor,
    this.barrierLabel,
    this.initialExtent = 1,
    this.stops,
    this.draggable = true,
    this.fit = SheetFit.loose,
    this.physics,
    this.animationCurve,
    this.transitionDuration = const Duration(milliseconds: 300),
    this.sheetLabel,
    this.willPopThreshold = 0.8,
    this.decorationBuilder,
    super.settings,
  }) : super(
          fullscreenDialog: true,
        );

  final WidgetBuilder builder;

  @override
  final Color? barrierColor;

  @override
  final String? barrierLabel;

  @override
  final bool barrierDismissible;

  @override
  final bool maintainState;

  @override
  final Duration transitionDuration;

  /// Relative extent up to where the sheet is animated when pushed for
  /// the first time.
  /// Values can't only be between
  ///    - 0: hidden
  ///    - 1: fully animated to the top
  /// By default it is 1
  final double initialExtent;

  /// Possible stops where the sheet can be snapped when dragged
  /// Values can only be between 0 and 1
  /// By default it is null
  final List<double>? stops;

  /// How to size the builder content in the sheet route.
  ///
  /// The constraints passed into the [Sheet] child are either
  /// loosened ([SheetFit.loose]) or tightened to their biggest size
  /// ([SheetFit.expand]).
  final SheetFit fit;

  /// {@macro flutter.widgets.sheet.physics}
  final SheetPhysics? physics;

  /// Defines if the sheet can be translated by user dragging.
  /// If false the route can still be closed by tapping the barrier if
  /// barrierDismissible is true or by [Navigator.pop]
  final bool draggable;

  /// Curve for the transition animation
  final Curve? animationCurve;

  /// Drag threshold to block any interaction if [Route.willPop] returns false
  /// See also:
  ///   * [WillPopScope], that allow to block an attempt to close a [ModalRoute]
  final double willPopThreshold;

  /// The semantic label used for a sheet modal route.
  final String? sheetLabel;

  /// Wraps the child in a custom sheet decoration appearance
  ///
  /// The default value is null.
  final SheetDecorationBuilder? decorationBuilder;

  AnimationController? _routeAnimationController;

  late final SheetController _sheetController;
  SheetController get sheetController => _sheetController;

  @override
  void install() {
    _sheetController = createSheetController();
    super.install();
  }

  /// Called to create the sheet controller that will drive the
  /// sheet transitions
  SheetController createSheetController() {
    return SheetController();
  }

  @override
  AnimationController createAnimationController() {
    assert(_routeAnimationController == null);
    _routeAnimationController = AnimationController(
      vsync: navigator!,
      duration: transitionDuration,
    );
    return _routeAnimationController!;
  }

  @override
  void dispose() {
    _sheetController.dispose();
    super.dispose();
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return _SheetRouteContainer(this);
  }

  @override
  bool canTransitionTo(TransitionRoute<dynamic> nextRoute) =>
      nextRoute is BetterSheetRoute;

  @override
  bool canTransitionFrom(TransitionRoute<dynamic> previousRoute) =>
      previousRoute is PageRoute;

  /// Returns true if the controller should prevent popping for a given extent
  @protected
  bool shouldPreventPopForExtent(double extent) {
    return extent < willPopThreshold &&
        hasScopedWillPopCallback &&
        controller!.velocity <= 0;
  }

  @override
  bool canDriveSecondaryTransitionForPreviousRoute(Route previousRoute) {
    return true;
  }

  @override
  Widget buildSecondaryTransitionForPreviousRoute(BuildContext context,
      Animation<double> secondaryAnimation, Widget child) {
    return child;
  }

  @override
  bool get opaque => false;

  Widget buildSheet(BuildContext context, Widget child) {
    SheetPhysics? effectivePhysics = SnapSheetPhysics(
      stops: stops ?? <double>[0, 1],
      parent: physics,
    );
    if (!draggable) {
      effectivePhysics = const NeverDraggableSheetPhysics();
    }
    return Sheet.raw(
      initialExtent: initialExtent,
      decorationBuilder: decorationBuilder,
      fit: fit,
      physics: effectivePhysics,
      controller: sheetController,
      child: child,
    );
  }
}

class _SheetRouteContainer extends StatefulWidget {
  const _SheetRouteContainer(this.sheetRoute, {super.key});

  final BetterSheetRoute<dynamic> sheetRoute;

  @override
  State<_SheetRouteContainer> createState() => __SheetRouteContainerState();
}

class __SheetRouteContainerState extends State<_SheetRouteContainer>
    with TickerProviderStateMixin {
  BetterSheetRoute<dynamic> get route => widget.sheetRoute;

  SheetController get _sheetController => widget.sheetRoute._sheetController;

  AnimationController get _routeController =>
      widget.sheetRoute._routeAnimationController!;

  @override
  void initState() {
    _routeController.addListener(onRouteAnimationUpdate);
    _sheetController.addListener(onSheetExtentUpdate);
    WidgetsBinding.instance.addPostFrameCallback((Duration timeStamp) {
      _sheetController.relativeAnimateTo(
        route.initialExtent,
        duration: route.transitionDuration,
        curve: route.animationCurve ?? Curves.easeOut,
      );
    });
    super.initState();
  }

  @override
  void dispose() {
    _routeController.removeListener(onRouteAnimationUpdate);
    _sheetController.removeListener(onSheetExtentUpdate);
    super.dispose();
  }

  void onSheetExtentUpdate() {
    if (_routeController.value != _sheetController.animation.value) {
      if (route.isCurrent &&
          !_firstAnimation &&
          !_sheetController.position.preventingDrag &&
          route.shouldPreventPopForExtent(_sheetController.animation.value) &&
          _sheetController.position.userScrollDirection ==
              ScrollDirection.forward) {
        preventPop();
        return;
      }
      if (!_routeController.isAnimating) {
        final double animationValue =
            _sheetController.animation.value.mapDistance(
          fromLow: 0,
          fromHigh: route.initialExtent,
          toLow: 0,
          toHigh: 1,
        );
        _routeController.value = animationValue;
        if (_sheetController.animation.value == 0) {
          _routeController.value = 0.001;
          _routeController.animateBack(0);
          route.navigator?.pop();
        }
      }
    }
  }

  bool _firstAnimation = true;
  void onRouteAnimationUpdate() {
    if (_routeController.isCompleted) {
      _firstAnimation = false;
    }
    if (!_routeController.isAnimating) {
      return;
    }
    // widget.sheetRoute.navigator!.userGestureInProgressNotifier.value = false;

    if (!_firstAnimation &&
        _routeController.value != _sheetController.animation.value) {
      if (_routeController.status == AnimationStatus.forward) {
        final double animationValue = _routeController.value.mapDistance(
          fromLow: 0,
          fromHigh: 1,
          toLow: _sheetController.animation.value,
          toHigh: 1,
        );
        _sheetController.relativeJumpTo(animationValue);
      } else {
        final double animationValue = _routeController.value.mapDistance(
          fromLow: 0,
          fromHigh: 1,
          toLow: 0,
          toHigh: _sheetController.animation.value,
        );
        _sheetController.relativeJumpTo(animationValue);
      }
    }
  }

  /// Stop current sheet transition and call willPop to confirm/cancel the pop
  @protected
  void preventPop() {
    _sheetController.position.preventDrag();
    _sheetController.position.animateTo(
      _sheetController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );

    route.willPop().then(
      (RoutePopDisposition disposition) {
        if (disposition == RoutePopDisposition.pop) {
          _sheetController.relativeAnimateTo(
            0,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
        } else {
          _sheetController.position.stopPreventingDrag();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final BetterSheetRoute<dynamic> route = widget.sheetRoute;

    return Semantics(
      scopesRoute: true,
      namesRoute: true,
      label: route.sheetLabel,
      explicitChildNodes: true,
      child: route.buildSheet(
        context,
        Builder(builder: widget.sheetRoute.builder),
      ),
    );
  }
}

class GenericSheetRoute<T> extends BetterSheetRoute<T> {
  GenericSheetRoute({
    required super.builder,
    super.initialExtent,
    super.stops,
    super.draggable,
    super.fit = SheetFit.loose,
    super.physics,
    super.animationCurve,
    super.transitionDuration,
    super.sheetLabel,
    super.barrierLabel,
    super.barrierColor,
    super.barrierDismissible,
    super.maintainState,
    super.willPopThreshold,
    super.decorationBuilder,
    super.settings,
  });

  @override
  bool canDriveSecondaryTransitionForPreviousRoute(Route previousRoute) {
    return true;
  }

  @override
  bool canTransitionTo(TransitionRoute nextRoute) {
    return nextRoute is GenericSheetRoute;
  }

  @override
  bool canTransitionFrom(TransitionRoute previousRoute) {
    return previousRoute is PageRoute;
  }

  var _firstFrame = true;

  @override
  Widget buildSecondaryTransitionForPreviousRoute(
    BuildContext context,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return AnimatedBuilder(
      animation: secondaryAnimation,
      builder: (context, child) {
        final CurvedAnimation curvedAnimation = CurvedAnimation(
          parent: secondaryAnimation,
          curve: context.theme.curve,
        );

        var currentValue = _firstFrame ? 0.0 : curvedAnimation.value;
        _firstFrame = false;
        return Transform.scale(
          scale: currentValue.remap(
            0.0,
            1.0,
            1.0,
            0.95,
          ),
          filterQuality: FilterQuality.medium,
          child: child,
        );
      },
      child: child,
    );
  }

  var _firstModalFrame = true;

  @override
  Widget buildModalBarrier() {
    final effectiveAnimation = animation!;

    return Builder(builder: (context) {
      return GestureDetector(
        onTap: () {
          Navigator.of(context).pop();
        },
        child: AnimatedBuilder(
          animation: effectiveAnimation,
          builder: (context, _) {
            final curvedAnimation = CurvedAnimation(
              parent: effectiveAnimation,
              curve: context.theme.curve,
            );
            var currentValue = _firstModalFrame ? 0.0 : curvedAnimation.value;
            _firstModalFrame = false;

            return Container(
              color:
                  context.theme.backgroundColor.withOpacity(currentValue * 0.5),
            );
          },
        ),
      );
    });
  }

  @override
  Widget buildSheet(BuildContext context, Widget child) {
    SheetPhysics? effectivePhysics = SnapSheetPhysics(
      stops: stops ?? <double>[0, 1],
      relative: true,
      parent: physics,
    );
    if (!draggable) {
      effectivePhysics = const NeverDraggableSheetPhysics();
    }

    return Sheet.raw(
      initialExtent: initialExtent,
      decorationBuilder: decorationBuilder,
      fit: fit,
      resizable: false,
      physics: effectivePhysics,
      controller: sheetController,
      child: child,
    );
  }
}

/*class BetterSheetRoute<T> extends ModalSheetRoute<T>
    with DelegatedTransitionsRoute<T> {
  BetterSheetRoute({
    required super.builder,
    super.swipeDismissible,
    super.swipeDismissSensitivity,
    super.barrierDismissible,
    super.barrierColor,
    super.barrierLabel,
    super.maintainState,
  });

  @override
  bool canTransitionTo(TransitionRoute nextRoute) {
    return nextRoute is BetterSheetRoute;
  }

  @override
  bool canTransitionFrom(TransitionRoute previousRoute) {
    return previousRoute is PageRoute;
  }

  @override
  bool canDriveSecondaryTransitionForPreviousRoute(Route previousRoute) {
    return true;
  }

  var _firstFrame = true;

  @override
  Widget buildSecondaryTransitionForPreviousRoute(BuildContext context,
      Animation<double> secondaryAnimation, Widget child) {
    return AnimatedBuilder(
      animation: secondaryAnimation,
      builder: (context, child) {
        final curvedAnimation = CurvedAnimation(
          parent: secondaryAnimation,
          curve: context.theme.curve,
        );
        var currentValue = _firstFrame ? 0.0 : curvedAnimation.value;
        _firstFrame = false;

        return Transform.scale(
          scale: currentValue.remap(
            0.0,
            1.0,
            1.0,
            0.95,
          ),
          child: child,
        );
      },
      child: child,
    );
  }
}
*/
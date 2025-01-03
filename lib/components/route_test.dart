import 'package:widget_app/generic.dart';

class GenericModalRoute<T> extends PageRoute<T>
    with DelegatedTransitionsRoute<T> {
  GenericModalRoute({
    super.settings,
    this.barrierColor,
    this.barrierDismissible = true,
    this.barrierLabel,
    required this.builder,
  });

  final WidgetBuilder builder;

  @override
  Color? barrierColor;

  @override
  bool barrierDismissible;

  @override
  String? barrierLabel;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return builder(context);
  }

  @override
  Widget buildModalBarrier() {
    final effectiveAnimation = animation ?? const AlwaysStoppedAnimation(1.0);

    return Builder(builder: (context) {
      return GestureDetector(
        onTap: () {
          Navigator.of(context).pop();
        },
        child: AnimatedBuilder(
          animation: effectiveAnimation,
          builder: (context, child) {
            final curvedAnimation = CurvedAnimation(
              parent: effectiveAnimation,
              curve: context.theme.curve,
            );
            return Container(
              color: context.theme.backgroundColor
                  .withOpacity(curvedAnimation.value * 0.5),
            );
          },
          child: const SizedBox(),
        ),
      );
    });
  }

  @override
  bool get maintainState => true;

  @override
  bool get opaque => false;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: context.theme.curve,
    );
    return FadeTransition(
      opacity: curvedAnimation,
      child: ScaleTransition(
        scale: curvedAnimation.drive(
          Tween(begin: 1.1, end: 1.0),
        ),
        filterQuality: FilterQuality.high,
        child: child,
      ),
    );
  }

  @override
  bool canTransitionTo(TransitionRoute nextRoute) {
    return nextRoute is GenericModalRoute;
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

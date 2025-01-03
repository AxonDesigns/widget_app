import 'dart:ui';

import 'package:sheet/route.dart';
import 'package:widget_app/generic.dart';

class CustomModalRoute<T> extends ModalRoute<T>
    with DelegatedTransitionsRoute<T> {
  CustomModalRoute({
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
            return BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: curvedAnimation.value * 3,
                sigmaY: curvedAnimation.value * 3,
              ),
              child: Container(
                color: context.theme.backgroundColor
                    .withOpacity(curvedAnimation.value * 0.5),
              ),
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
          Tween(
            begin: 1.1,
            end: 1.0,
          ),
        ),
        child: child,
      ),
    );
  }

  @override
  bool canTransitionTo(TransitionRoute nextRoute) {
    return nextRoute is CustomModalRoute;
  }

  @override
  bool canTransitionFrom(TransitionRoute previousRoute) {
    return previousRoute is PageRoute;
  }

  @override
  bool canDriveSecondaryTransitionForPreviousRoute(Route previousRoute) {
    return true;
  }

  @override
  Widget buildSecondaryTransitionForPreviousRoute(BuildContext context,
      Animation<double> secondaryAnimation, Widget child) {
    final CurvedAnimation curvedAnimation = CurvedAnimation(
      parent: secondaryAnimation,
      curve: context.theme.curve,
    );
    return AnimatedBuilder(
      animation: secondaryAnimation,
      builder: (context, child) {
        var currentValue = curvedAnimation.value;

        return Transform.scale(
          scale: currentValue.remap(
            0.0,
            1.0,
            1.0,
            0.95,
          ),
          filterQuality: FilterQuality.high,
          child: child,
        );
      },
      child: child,
    );
  }
}

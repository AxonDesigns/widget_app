import 'package:widget_app/generic.dart';

class GenericPageRoute<T> extends PageRoute<T> {
  GenericPageRoute({
    super.settings,
    required Function(BuildContext context) builder,
    this.duration,
    this.curve = Curves.fastEaseInToSlowEaseOut,
    this.transitionBuilder,
    this.maintainState = true,
  }) : buildContent = builder;

  Function(BuildContext context) buildContent;

  final Duration? duration;
  final Curve curve;

  final Widget Function(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Curve curve,
    Widget child,
  )? transitionBuilder;

  @override
  bool maintainState;

  @override
  Duration get transitionDuration =>
      duration ?? const Duration(milliseconds: 400);

  @override
  String get debugLabel => '${super.debugLabel}(${settings.name})';

  @override
  Color? get barrierColor => const Color(0x00000000);

  @override
  String? get barrierLabel => null;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: buildContent(context),
    );
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final isFlipped = animation.status == AnimationStatus.reverse;
    final isSecondaryFlipped =
        secondaryAnimation.status == AnimationStatus.reverse;

    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: isFlipped ? curve.flipped : curve,
    );
    final curvedSecondaryAnimation = CurvedAnimation(
      parent: secondaryAnimation,
      curve: isSecondaryFlipped ? curve.flipped : curve,
    );

    if (transitionBuilder != null) {
      return transitionBuilder!.call(
        context,
        animation,
        secondaryAnimation,
        curve,
        child,
      );
    }

    // animation = next page
    // secondaryAnimation = current page

    const value = 0.075; // percentage of the screen height

    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset(0.0, isFlipped ? -value : value),
        end: Offset.zero,
      ).animate(curvedAnimation),
      child: Opacity(
        opacity: curvedAnimation.value
            .remap(
              isFlipped ? 0.25 : 0.0,
              isFlipped ? 1.0 : 0.75,
              0.0,
              1.0,
            )
            .saturate(),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: Offset.zero,
            end: Offset(0.0, isSecondaryFlipped ? value : -value),
          ).animate(curvedSecondaryAnimation),
          child: Opacity(
            opacity: (1 - curvedSecondaryAnimation.value)
                .remap(
                  isSecondaryFlipped ? 0.0 : 0.5,
                  isSecondaryFlipped ? 0.5 : 1.0,
                  0.0,
                  1.0,
                )
                .saturate(),
            child: child,
          ),
        ),
      ),
    );
  }
}

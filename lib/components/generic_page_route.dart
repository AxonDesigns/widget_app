import 'package:widget_app/components/generic.dart';

class GenericPageRoute<T> extends PageRoute<T> {
  GenericPageRoute({
    super.settings,
    required Function(BuildContext context) builder,
    this.duration = const Duration(milliseconds: 150),
    this.curve = Curves.fastEaseInToSlowEaseOut,
    this.transitionBuilder,
    this.maintainState = true,
  }) : buildContent = builder;

  Function(BuildContext context) buildContent;

  final Duration duration;
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
  Duration get transitionDuration => duration;

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
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    final curvedAnimation = CurvedAnimation(parent: animation, curve: curve);
    final curvedSecondaryAnimation =
        CurvedAnimation(parent: secondaryAnimation, curve: curve);
    return transitionBuilder?.call(
            context, animation, secondaryAnimation, curve, child) ??
        FadeTransition(
          opacity: Tween(begin: 1.0, end: 0.0).animate(curvedAnimation),
          child: FadeTransition(
            opacity:
                Tween(begin: 0.0, end: 1.0).animate(curvedSecondaryAnimation),
            child: child,
          ),
        );
  }
}

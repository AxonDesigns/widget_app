import 'package:widget_app/generic.dart';

class GenericPageRoute<T> extends PageRoute<T> with GenericRouteTransitionMixin<T> {
  GenericPageRoute({
    super.settings,
    required this.builder,
    this.duration,
    this.curve = Curves.fastEaseInToSlowEaseOut,
    this.maintainState = true,
    super.fullscreenDialog = false,
  });

  final Duration? duration;
  final Curve curve;
  final Widget Function(BuildContext context) builder;

  @override
  final bool maintainState;

  @override
  String get debugLabel => '${super.debugLabel}(${settings.name})';

  @override
  Widget buildContent(BuildContext context) => builder(context);
}

mixin GenericRouteTransitionMixin<T> on PageRoute<T> {
  @protected
  Widget buildContent(BuildContext context);

  @override
  Duration get transitionDuration => const Duration(milliseconds: 450);

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
    return context.theme.transitionsBuilder(
      context,
      animation,
      secondaryAnimation,
      child,
    );
  }

  @override
  bool canTransitionTo(TransitionRoute<dynamic> nextRoute) {
    return (nextRoute is GenericRouteTransitionMixin && !nextRoute.fullscreenDialog);
  }
}

class GenericPage<T> extends Page<T> {
  const GenericPage({
    super.key,
    required this.child,
    this.maintainState = true,
    this.fullscreenDialog = false,
    this.allowSnapshotting = true,
    super.canPop,
    super.onPopInvoked,
    super.name,
    super.arguments,
    super.restorationId,
  });

  final bool maintainState;

  final bool fullscreenDialog;

  final bool allowSnapshotting;

  final Widget child;

  @override
  Route<T> createRoute(BuildContext context) {
    return _PageBasedGenericPageRoute(
      page: this,
      allowSnapshotting: allowSnapshotting,
    );
  }
}

class _PageBasedGenericPageRoute<T> extends PageRoute<T> with GenericRouteTransitionMixin<T> {
  _PageBasedGenericPageRoute({
    required GenericPage<T> page,
    super.allowSnapshotting,
  }) : super(
          settings: page,
        );

  GenericPage<T> get _page => settings as GenericPage<T>;

  @override
  Widget buildContent(BuildContext context) {
    return _page.child;
  }

  @override
  bool get maintainState => _page.maintainState;

  @override
  bool get fullscreenDialog => _page.fullscreenDialog;

  @override
  String get debugLabel => '${super.debugLabel}(${_page.name})';
}

//Extended Routes

class GenericExtendedPageRoute<T> extends GenericPageRoute<T> with GenericDelegatedTransitionsRoute<T> {
  GenericExtendedPageRoute({
    required super.builder,
    super.settings,
    super.maintainState = true,
    super.fullscreenDialog = false,
  });
}

class GenericExtendedPage<T> extends Page<T> {
  /// Creates a material page.
  const GenericExtendedPage({
    required this.child,
    this.maintainState = true,
    this.fullscreenDialog = false,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  });

  /// The content to be shown in the [Route] created by this page.
  final Widget child;

  /// {@macro flutter.widgets.ModalRoute.maintainState}
  final bool maintainState;

  /// {@macro flutter.widgets.PageRoute.fullscreenDialog}
  final bool fullscreenDialog;

  @override
  Route<T> createRoute(BuildContext context) {
    return _PageBasedGenericExtendedPageRoute<T>(page: this);
  }
}

// A page-based version of GenericPageRoute.
//
// This route uses the builder from the page to build its content. This ensures
// the content is up to date after page updates.
class _PageBasedGenericExtendedPageRoute<T> extends GenericExtendedPageRoute<T> {
  _PageBasedGenericExtendedPageRoute({
    required GenericExtendedPage<T> page,
  }) : super(
          settings: page,
          builder: (BuildContext context) => page.child,
        );

  GenericExtendedPage<T> get _page => settings as GenericExtendedPage<T>;

  @override
  Widget buildContent(BuildContext context) {
    return _page.child;
  }

  @override
  bool get maintainState => _page.maintainState;

  @override
  bool get fullscreenDialog => _page.fullscreenDialog;

  @override
  String get debugLabel => '${super.debugLabel}(${_page.name})';
}

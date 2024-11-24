import 'package:widget_app/components/generic.dart';

class GenericPage<T> extends Page<T> {
  const GenericPage({
    super.key,
    required this.builder,
    this.transitionBuilder,
    this.maintainState = true,
    this.fullscreenDialog = true,
    this.allowSnapshotting = true,
    this.duration = const Duration(milliseconds: 150),
    this.curve = Curves.fastEaseInToSlowEaseOut,
  });

  final bool maintainState;

  final bool fullscreenDialog;

  final bool allowSnapshotting;

  final Widget Function(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Curve curve, Widget child)?
      transitionBuilder;

  final Duration duration;

  final Curve curve;

  final Widget Function(BuildContext context) builder;

  @override
  Route<T> createRoute(BuildContext context) {
    return GenericPageRoute(
      settings: this,
      builder: builder,
      maintainState: maintainState,
      duration: duration,
      curve: curve,
      transitionBuilder: transitionBuilder != null
          ? (context, animation, secondaryAnimation, curve, child) {
              return transitionBuilder!.call(context, animation, secondaryAnimation, curve, child);
            }
          : null,
    );
  }
}

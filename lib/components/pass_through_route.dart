import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:widget_app/generic.dart';

typedef PageBuilder = Widget Function(BuildContext context,
    Animation<double> animation, Animation<double> secondaryAnimation);

class PassThroughRoute<T> extends ModalRoute<T> {
  PassThroughRoute({
    super.settings,
    required this.builder,
    this.transitionBuilder,
    this.onPopCallback,
    Duration transitionDuration = const Duration(milliseconds: 200),
  }) : _transitionDuration = transitionDuration;

  final PageBuilder builder;
  final Function(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child)? transitionBuilder;
  final Duration _transitionDuration;
  final Function()? onPopCallback;

  @override
  Color? get barrierColor => Colors.transparent;

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => "PassThroughRoute";

  @override
  Duration get transitionDuration => _transitionDuration;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return builder(context, animation, secondaryAnimation);
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    if (transitionBuilder != null) {
      return transitionBuilder!.call(
        context,
        animation,
        secondaryAnimation,
        child,
      );
    }
    return super
        .buildTransitions(context, animation, secondaryAnimation, child);
  }

  @override
  Widget buildModalBarrier() {
    final isDesktop =
        !kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS);
    if (kIsWeb || isDesktop) {
      return Builder(
        builder: (context) {
          return Listener(
            behavior: HitTestBehavior.translucent,
            onPointerDown: (_) {
              onPopCallback?.call();
            },
          );
        },
      );
    }

    return Builder(
      builder: (context) {
        return Semantics(
          explicitChildNodes: false,
          hidden: true,
          label: "Tap to dismiss",
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              onPopCallback?.call();
            },
          ),
        );
      },
    );
  }

  @override
  bool get maintainState => true;

  @override
  bool get opaque => false;
}

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:widget_app/generic.dart';

class TapThroughOverlayRoute<T> extends TransitionRoute<T> {
  final Duration _transitionDuration;
  final WidgetBuilder builder;

  TapThroughOverlayRoute({
    required this.builder,
    Duration transitionDuration = Duration.zero,
    super.settings,
  }) : _transitionDuration = transitionDuration;

  @override
  Iterable<OverlayEntry> createOverlayEntries() {
    return [OverlayEntry(builder: builder, maintainState: true)];
  }

  @override
  bool get opaque => false;

  @override
  Duration get transitionDuration => _transitionDuration;

  @override
  bool get popGestureEnabled => true;
}

typedef PageBuilder = Widget Function(BuildContext context,
    Animation<double> animation, Animation<double> secondaryAnimation);

class PassThroughRoute<T> extends ModalRoute<T> {
  PassThroughRoute({
    super.settings,
    required this.builder,
    this.onPopCallback,
    Duration transitionDuration = const Duration(milliseconds: 200),
  }) : _transitionDuration = transitionDuration;

  final PageBuilder builder;
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

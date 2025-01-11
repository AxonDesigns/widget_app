import 'package:widget_app/generic.dart';

class SheetController extends InheritedWidget {
  SheetController({
    super.key,
    required this.scrollController,
    required Widget child,
  }) : super(
          child: PrimaryScrollController(
            controller: scrollController,
            child: child,
          ),
        );

  final ScrollController scrollController;

  @override
  bool updateShouldNotify(covariant SheetController oldWidget) {
    return oldWidget.scrollController != scrollController;
  }

  static SheetController of(BuildContext context) {
    final controller =
        context.dependOnInheritedWidgetOfExactType<SheetController>();
    if (controller == null) {
      throw FlutterError(
        'SheetController.of() called with a context that does not contain a SheetController.\n'
        'No SheetController ancestor could be found starting from the context that was passed to SheetController.of().',
      );
    }
    return context.dependOnInheritedWidgetOfExactType<SheetController>()!;
  }

  static SheetController? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<SheetController>();
  }
}

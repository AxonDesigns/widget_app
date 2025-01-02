import 'package:sheet/sheet.dart';
import 'package:widget_app/generic.dart';

class CustomSheetRoute<T> extends ModalRoute<T> {
  CustomSheetRoute({
    required this.builder,
  });

  final WidgetBuilder builder;

  @override
  bool get maintainState => true;

  @override
  Color? get barrierColor => Colors.black.withOpacity(0.5);

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => "";

  AnimationController? _routeAnimationController;
  late final SheetController _sheetController;
  SheetController get sheetController => _sheetController;

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
  void install() {
    _sheetController = SheetController();
    super.install();
  }

  @override
  void dispose() {
    _sheetController.dispose();
    super.dispose();
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return Sheet(
      controller: sheetController,
      initialExtent: 0.5,
      child: builder(context),
    );
  }

  @override
  bool get opaque => false;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 200);
}

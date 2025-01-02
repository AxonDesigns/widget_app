import 'package:sheet/route.dart';
import 'package:sheet/sheet.dart';
import 'package:widget_app/generic.dart';

class GenericSheetRoute<T> extends SheetRoute<T> {
  GenericSheetRoute({
    required super.builder,
    super.initialExtent,
    super.stops,
    super.draggable,
    super.fit,
    super.physics,
    super.animationCurve,
    super.duration,
    super.sheetLabel,
    super.barrierLabel,
    super.barrierColor,
    super.barrierDismissible,
    super.maintainState,
    super.willPopThreshold,
    super.decorationBuilder,
    super.settings,
  });

  @override
  Widget buildSecondaryTransitionForPreviousRoute(BuildContext context,
      Animation<double> secondaryAnimation, Widget child) {
    final CurvedAnimation curvedAnimation = CurvedAnimation(
      parent: secondaryAnimation,
      curve: Curves.fastEaseInToSlowEaseOut,
    );
    return ScaleTransition(
      scale: Tween(begin: 1.0, end: 0.9).animate(curvedAnimation),
      filterQuality: FilterQuality.high,
      child: child,
    );
  }
}

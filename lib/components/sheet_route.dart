import 'package:sheet/route.dart';
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

  var _firstFrame = true;

  @override
  Widget buildSecondaryTransitionForPreviousRoute(
    BuildContext context,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final CurvedAnimation curvedAnimation = CurvedAnimation(
      parent: secondaryAnimation,
      curve: context.theme.curve,
    );

    var currentValue = _firstFrame ? 0.0 : curvedAnimation.value;
    _firstFrame = false;
    return Transform.scale(
      scale: currentValue.remap(
        0.0,
        1.0,
        1.0,
        0.95,
      ),
      filterQuality: FilterQuality.medium,
      child: child,
    );
  }

  var _firstModalFrame = true;

  @override
  Widget buildModalBarrier() {
    final effectiveAnimation = animation!;

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
            var currentValue = _firstModalFrame ? 0.0 : curvedAnimation.value;
            _firstModalFrame = false;

            return Container(
              color:
                  context.theme.backgroundColor.withOpacity(currentValue * 0.5),
            );
          },
          child: const SizedBox(),
        ),
      );
    });
  }
}

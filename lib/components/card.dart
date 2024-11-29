import 'package:widget_app/generic.dart';

class Card extends StatelessWidget {
  const Card({
    super.key,
    this.child,
    this.width,
    this.height,
    this.elevation = 4.0,
    this.padding,
    this.clipBehavior = Clip.none,
  });

  final Widget? child;
  final double? width;
  final double? height;
  final double elevation;
  final EdgeInsetsGeometry? padding;
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      clipBehavior: clipBehavior,
      decoration: BoxDecoration(
        color: context.theme.surfaceColor,
        borderRadius: BorderRadius.circular(context.theme.radiusSize),
        border: Border.all(
          color: context.theme.surfaceColor.highest,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: elevation,
            offset: Offset(0.0, elevation * 0.5),
          ),
        ],
      ),
      padding: padding,
      child: child ?? const SizedBox.shrink(),
    );
  }
}

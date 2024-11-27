import 'package:widget_app/generic.dart';

class Card extends StatelessWidget {
  const Card({
    super.key,
    this.child,
    this.width,
    this.height,
    this.elevation = 4.0,
  });

  final Widget? child;
  final double? width;
  final double? height;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
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
      padding: const EdgeInsets.symmetric(
        horizontal: 18.0,
        vertical: 16.0,
      ),
      child: child ?? const SizedBox.shrink(),
    );
  }
}

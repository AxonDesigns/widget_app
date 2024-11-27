import 'package:widget_app/generic.dart';

class Card extends StatelessWidget {
  const Card({
    super.key,
    this.child,
  });

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.theme.surfaceColor,
        borderRadius: BorderRadius.circular(context.theme.radiusSize),
        border: Border.all(
          color: context.theme.foregroundColor.withOpacity(0.075),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 8.0,
            offset: const Offset(0.0, 5.0),
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

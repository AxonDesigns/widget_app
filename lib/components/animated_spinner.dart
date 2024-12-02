import 'package:rive/rive.dart';
import 'package:widget_app/generic.dart';

/// Displays an animated spinner.
class AnimatedSpinner extends StatelessWidget {
  const AnimatedSpinner({
    super.key,
    this.size,
    this.color = Colors.white,
  });

  /// The size of the spinner.
  /// If null, the size of the spinner is determined by the [GenericTheme.iconSize].
  final double? size;

  /// The color of the spinner.
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size ?? context.theme.iconSize,
      height: size ?? context.theme.iconSize,
      child: ColorFiltered(
        colorFilter: ColorFilter.mode(
          color,
          BlendMode.srcIn,
        ),
        child: const RiveAnimation.asset(
          "assets/rive/spinner.riv",
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

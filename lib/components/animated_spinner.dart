import 'package:rive/rive.dart';

import 'generic.dart';

class AnimatedSpinner extends StatelessWidget {
  const AnimatedSpinner({
    super.key,
    this.size,
    this.color = Colors.white,
  });

  final double? size;
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

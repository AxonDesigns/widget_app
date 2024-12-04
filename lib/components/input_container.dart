import 'package:widget_app/generic.dart';

class InputContainer extends StatelessWidget {
  const InputContainer({
    super.key,
    this.hovered = false,
    this.pressed = false,
    this.focused = false,
    this.backgroundColor,
    this.borderColor,
    this.foregroundColor,
    this.padding,
    required this.child,
  });

  final bool hovered;
  final bool pressed;
  final bool focused;

  /// The background color of the button.
  final WidgetStateColor? backgroundColor;

  /// The border color of the button.
  final WidgetStateColor? borderColor;

  /// The foreground color of the button.
  final WidgetStateColor? foregroundColor;

  final EdgeInsetsGeometry? padding;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final state = {
      if (hovered) WidgetState.hovered,
      if (pressed) WidgetState.pressed,
      if (focused) WidgetState.focused,
    };

    final bgColor = backgroundColor?.resolve(state) ??
        WidgetStateColor.resolveWith((state) {
          if (state.contains(WidgetState.focused)) {
            return context.theme.foregroundColor.withOpacity(0.1);
          }

          if (state.contains(WidgetState.hovered)) {
            return context.theme.foregroundColor.withOpacity(0.05);
          }

          return context.theme.foregroundColor.withOpacity(0.01);
        }).resolve(state);

    final borderColor = WidgetStateColor.resolveWith((state) {
      if (state.contains(WidgetState.focused)) {
        return context.theme.foregroundColor.withOpacity(0.0);
      }
      if (state.contains(WidgetState.hovered)) {
        return context.theme.foregroundColor
            .withOpacity(context.isDarkMode ? 0.1 : 0.2);
      }
      return context.theme.foregroundColor
          .withOpacity(context.isDarkMode ? 0.1 : 0.2);
    }).resolve(state);

    return AnimatedContainer(
      duration: Duration(milliseconds: pressed || hovered ? 0 : 200),
      curve: Curves.fastEaseInToSlowEaseOut,
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(
          color: borderColor,
          strokeAlign: BorderSide.strokeAlignInside,
        ),
        borderRadius: BorderRadius.circular(
          context.theme.radiusSize,
        ),
      ),
      child: Padding(
        padding: padding ??
            EdgeInsets.only(
              bottom: isDesktop ? 10.0 : 12.0,
              top: isDesktop ? 10.0 : 12.0,
              left: isDesktop ? 10.0 : 12.0,
              right: isDesktop ? 10.0 : 12.0,
            ),
        child: child,
      ),
    );
  }
}

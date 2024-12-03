import 'package:widget_app/generic.dart';

/// Variant for a given button.
enum ButtonVariant {
  primary,
  outline,
  ghost,
  glass,
  destructive,
}

/// A widget that displays a button.
/// The button can be configured to have a background color, border color, foreground color, etc.
class Button extends StatefulWidget {
  /// Custom button constructor.
  const Button.custom({
    super.key,
    this.builder,
    required this.onPressed,
    required this.children,
    required this.backgroundColor,
    required this.borderColor,
    required this.foregroundColor,
    this.gap = 5.0,
    this.tooltip,
    this.focusable = true,
    this.disabled = false,
    this.focusNode,
    this.unfocusOnTapOutside = true,
  }) : variant = null;

  /// Primary button constructor.
  const Button.primary({
    super.key,
    this.builder,
    required this.onPressed,
    required this.children,
    this.gap = 5.0,
    this.tooltip,
    this.focusable = true,
    this.disabled = false,
    this.focusNode,
    this.unfocusOnTapOutside = true,
  })  : variant = ButtonVariant.primary,
        foregroundColor = null,
        backgroundColor = null,
        borderColor = null;

  /// Outline button constructor.
  const Button.outline({
    super.key,
    required this.children,
    this.builder,
    required this.onPressed,
    this.gap = 5.0,
    this.tooltip,
    this.focusable = true,
    this.disabled = false,
    this.focusNode,
    this.unfocusOnTapOutside = true,
  })  : variant = ButtonVariant.outline,
        foregroundColor = null,
        backgroundColor = null,
        borderColor = null;

  /// Ghost button constructor.
  const Button.ghost({
    super.key,
    required this.children,
    this.builder,
    required this.onPressed,
    this.gap = 5.0,
    this.tooltip,
    this.focusable = true,
    this.disabled = false,
    this.focusNode,
    this.unfocusOnTapOutside = true,
  })  : variant = ButtonVariant.ghost,
        foregroundColor = null,
        backgroundColor = null,
        borderColor = null;

  /// Glass button constructor.
  const Button.glass({
    super.key,
    required this.children,
    this.builder,
    required this.onPressed,
    this.gap = 5.0,
    this.tooltip,
    this.focusable = true,
    this.disabled = false,
    this.focusNode,
    this.unfocusOnTapOutside = true,
  })  : variant = ButtonVariant.glass,
        foregroundColor = null,
        backgroundColor = null,
        borderColor = null;

  /// Destructive button constructor.
  const Button.destructive({
    super.key,
    required this.children,
    this.builder,
    required this.onPressed,
    this.gap = 5.0,
    this.tooltip,
    this.focusable = true,
    this.disabled = false,
    this.focusNode,
    this.unfocusOnTapOutside = true,
  })  : variant = ButtonVariant.destructive,
        foregroundColor = null,
        backgroundColor = null,
        borderColor = null;

  /// The children of the button.
  /// The children are displayed in a row.
  final List<Widget> children;

  /// Allows to react to the button state, such as hovered, pressed, and focused.
  /// If defined, it will be used instead of [children].
  final Widget Function(bool hovered, bool pressed, bool focused)? builder;

  /// The variant of the button.
  final ButtonVariant? variant;

  /// The tooltip to display when hovering over the button.
  final String? tooltip;

  /// The callback to be called when the button is tapped.
  final VoidCallback? onPressed;

  /// The background color of the button.
  final WidgetStateColor? backgroundColor;

  /// The border color of the button.
  final WidgetStateColor? borderColor;

  /// The foreground color of the button.
  final WidgetStateColor? foregroundColor;

  /// The gap between the children of the button.
  final double gap;

  /// Whether the button is focusable.
  final bool focusable;

  /// Whether the button is disabled.
  final bool disabled;

  /// Whether the button should unfocus when tapped outside.
  final bool unfocusOnTapOutside;

  /// The focus node of the button, if null, the button will create its own focus node.
  final FocusNode? focusNode;

  @override
  State<Button> createState() => _ButtonState();
}

class _ButtonState extends State<Button> {
  var hovered = false;
  var pressed = false;
  var focused = false;
  bool get enabled => widget.onPressed != null && !widget.disabled;
  late var _focusNode = widget.focusNode ?? FocusNode();

  @override
  void didUpdateWidget(covariant Button oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusNode != null && oldWidget.focusNode == null) {
      _focusNode.dispose();
      _focusNode = widget.focusNode!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return TapRegion(
      groupId: Button,
      onTapOutside: widget.unfocusOnTapOutside
          ? (event) {
              if (_focusNode.hasFocus) {
                _focusNode.unfocus();
              }
            }
          : null,
      child: _buildButton(context),
      /*child: widget.tooltip != null
          ? Tooltip(
              message: widget.tooltip,
              child: _buildButton(context),
            )
          : _buildButton(context),*/
    );
  }

  Widget _buildButton(BuildContext context) {
    final state = {
      if (hovered) WidgetState.hovered,
      if (pressed) WidgetState.pressed,
      if (focused) WidgetState.focused,
    };

    final theme = GenericTheme.of(context);

    final isDarkMode = context.isDarkMode;
    const pressedValue = 0.2;
    const hoveredValue = pressedValue * 0.5;

    final bgColor = widget.backgroundColor?.resolve(state) ??
        switch (widget.variant) {
          ButtonVariant.primary => WidgetStateColor.resolveWith((state) {
              var colorHSV = HSVColor.fromColor(theme.primaryColor);

              if (!enabled) {
                return colorHSV.toColor();
              }

              if (state.contains(WidgetState.pressed)) {
                return colorHSV
                    .withValue(colorHSV.value - pressedValue)
                    .toColor();
              }

              if (state.contains(WidgetState.hovered)) {
                return colorHSV
                    .withValue(colorHSV.value - hoveredValue)
                    .toColor();
              }

              return colorHSV.toColor();
            }).resolve(state),
          ButtonVariant.outline ||
          ButtonVariant.ghost =>
            WidgetStateColor.resolveWith((state) {
              if (!enabled) {
                return context.theme.foregroundColor.withOpacity(0.0);
              }

              if (state.contains(WidgetState.pressed)) {
                return context.theme.foregroundColor
                    .withOpacity(context.isDarkMode ? 0.05 : 0.15);
              }
              if (state.contains(WidgetState.hovered)) {
                return context.theme.foregroundColor
                    .withOpacity(context.isDarkMode ? 0.1 : 0.2);
              }
              return context.theme.foregroundColor.withOpacity(0.0);
            }).resolve(state),
          ButtonVariant.glass => WidgetStateColor.resolveWith((state) {
              var color = theme.primaryColor;

              if (!enabled) {
                return color.withOpacity(0.1);
              }

              if (state.contains(WidgetState.pressed)) {
                return color.withOpacity(0.25);
              }
              if (state.contains(WidgetState.hovered)) {
                return color.withOpacity(0.2);
              }

              return color.withOpacity(0.1);
            }).resolve(state),
          ButtonVariant.destructive => WidgetStateColor.resolveWith((state) {
              var colorHSV = HSVColor.fromColor(
                isDarkMode
                    ? (const Color.fromARGB(255, 165, 36, 36))
                    : (const Color.fromARGB(255, 223, 56, 56)),
              );

              if (!enabled) {
                return colorHSV.toColor();
              }

              if (state.contains(WidgetState.pressed)) {
                return colorHSV
                    .withValue(colorHSV.value - pressedValue)
                    .toColor();
              }

              if (state.contains(WidgetState.hovered)) {
                return colorHSV
                    .withValue(colorHSV.value - hoveredValue)
                    .toColor();
              }

              return colorHSV.toColor();
            }).resolve(state),
          _ => Colors.transparent,
        };

    final borderColor = widget.borderColor?.resolve(state) ??
        switch (widget.variant) {
          ButtonVariant.outline => WidgetStateColor.resolveWith((state) {
              if (state.contains(WidgetState.hovered)) {
                return context.theme.foregroundColor.withOpacity(0.0);
              }
              return context.theme.foregroundColor
                  .withOpacity(context.isDarkMode ? 0.1 : 0.2);
            }).resolve(state),
          ButtonVariant.glass => theme.primaryColor.withOpacity(0.5),
          _ => Colors.transparent,
        };

    final fgColor = widget.foregroundColor?.resolve(state) ??
        switch (widget.variant) {
          ButtonVariant.primary => WidgetStateColor.resolveWith((state) {
              return Colors.white;
            }).resolve(state),
          ButtonVariant.glass => theme.primaryColor,
          ButtonVariant.destructive =>
            isDarkMode ? context.theme.foregroundColor : theme.backgroundColor,
          _ => theme.foregroundColor,
        };

    final squarePadding = isDesktop ? 7.5 : 10.0;
    final horizontalPadding = isDesktop ? 12.0 : 20.0;
    final verticalPadding = isDesktop ? 6.0 : 12.0;

    return FocusableActionDetector(
      focusNode: _focusNode,
      onFocusChange: (value) => setState(() => focused = value),
      onShowHoverHighlight: (value) => setState(() => hovered = value),
      mouseCursor: SystemMouseCursors.basic,
      child: GestureDetector(
        behavior: HitTestBehavior.deferToChild,
        onTapDown: (details) => setState(() => pressed = true),
        onTapUp: (details) {
          if (widget.focusable) {
            _focusNode.requestFocus();
          } else if (!widget.focusable && _focusNode.hasFocus) {
            _focusNode.unfocus();
          }
          setState(() => pressed = false);
        },
        onTapCancel: () => setState(() => pressed = false),
        onTap: !enabled
            ? null
            : () {
                widget.onPressed!.call();
              },
        child: Opacity(
          opacity: enabled ? 1.0 : 0.65,
          child: AnimatedContainer(
            duration: Duration(milliseconds: pressed || hovered ? 0 : 200),
            curve: Curves.fastEaseInToSlowEaseOut,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(
                context.theme.radiusSize,
              ),
              border: Border.all(
                strokeAlign: BorderSide.strokeAlignInside,
                width: 1.0,
                color: borderColor,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                /* horizontal: widget.squared ? 7.5 : 12.0,
                vertical: widget.squared ? 7.5 : 6.0, */
                horizontal: widget.children.length == 1 &&
                        widget.children.first is! Text
                    ? squarePadding
                    : horizontalPadding,
                vertical: widget.children.length == 1 &&
                        widget.children.first is! Text
                    ? squarePadding
                    : verticalPadding,
              ),
              child: IconTheme(
                data: IconTheme.of(context).copyWith(
                  color: fgColor,
                ),
                child: DefaultTextStyle(
                  style: context.theme.baseTextStyle.copyWith(
                    color: fgColor,
                  ),
                  child: widget.builder?.call(hovered, pressed, false) ??
                      (widget.children.isNotEmpty
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                  (widget.children.length * 2) - 1,
                                  (index) => index.isEven
                                      ? widget.children[index ~/ 2]
                                      : SizedBox(width: widget.gap)),
                            )
                          : const SizedBox.shrink()),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/widgets.dart';
import 'package:widget_app/components/dark_mode_state.dart';
import 'package:widget_app/components/generic.dart';
import 'package:widget_app/utils.dart';

enum AxType {
  primary,
  secondary,
  outline,
  ghost,
  glass,
}

class Button extends StatefulWidget {
  const Button.custom({
    super.key,
    this.children = const [],
    this.builder,
    required this.onPressed,
    this.interactable = true,
    required this.backgroundColor,
    required this.borderColor,
    required this.foregroundColor,
    this.gap = 5.0,
    this.tooltip,
    this.focusable = true,
    this.focusNode,
    this.unfocusOnTapOutside = true,
  }) : type = null;

  final List<Widget> children;
  final Widget Function(bool hovered, bool pressed, bool focused)? builder;
  final AxType? type;
  final String? tooltip;
  //final bool useOutline;
  //final bool animateOpacity;
  final VoidCallback? onPressed;
  final WidgetStateColor? backgroundColor;
  final WidgetStateColor? borderColor;
  final WidgetStateColor? foregroundColor;
  final bool interactable;
  final double gap;
  final bool focusable;
  final bool unfocusOnTapOutside;
  final FocusNode? focusNode;

  @override
  State<Button> createState() => _ButtonState();
}

class _ButtonState extends State<Button> {
  var hovered = false;
  var pressed = false;
  var focused = false;
  bool get enabled => widget.onPressed != null;
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
    final pressedValue = switch (isDarkMode) { true => 0.25, false => 0.1 };
    final hoveredValue = pressedValue * 0.5;

    //TODO: add light mode
    final bgColor = widget.backgroundColor?.resolve(state) ??
        switch (widget.type) {
          AxType.primary => WidgetStateColor.resolveWith((state) {
              var colorHSV = HSVColor.fromColor(theme.primaryColor);

              if (state.contains(WidgetState.pressed)) {
                return colorHSV.withValue(colorHSV.value - pressedValue).toColor();
              }
              if (state.contains(WidgetState.hovered)) {
                return colorHSV.withValue(colorHSV.value - hoveredValue).toColor();
              }

              return colorHSV.toColor();
            }).resolve(state),
          AxType.secondary => WidgetStateColor.resolveWith((state) {
              var colorHSV = HSVColor.fromColor(theme.primaryColor);

              if (state.contains(WidgetState.pressed)) {
                return colorHSV.withValue(colorHSV.value - pressedValue).toColor();
              }
              if (state.contains(WidgetState.hovered)) {
                return colorHSV.withValue(colorHSV.value - hoveredValue).toColor();
              }

              return colorHSV.toColor();
            }).resolve(state),
          AxType.outline || AxType.ghost => WidgetStateColor.resolveWith((state) {
              var color = theme.foregroundColor;

              if (state.contains(WidgetState.pressed)) {
                return color.withOpacity(0.15);
              }
              if (state.contains(WidgetState.hovered)) {
                return color.withOpacity(0.07);
              }

              return color.withOpacity(0.0);
            }).resolve(state),
          AxType.glass => WidgetStateColor.resolveWith((state) {
              var color = theme.primaryColor;

              if (state.contains(WidgetState.pressed)) {
                return color.withOpacity(0.25);
              }
              if (state.contains(WidgetState.hovered)) {
                return color.withOpacity(0.2);
              }

              return color.withOpacity(0.1);
            }).resolve(state),
          _ => Colors.transparent,
        };

    final borderColor = widget.borderColor?.resolve(state) ??
        switch (widget.type) {
          AxType.outline => theme.foregroundColor,
          AxType.glass => theme.primaryColor,
          _ => Colors.transparent,
        };

    final fgColor = widget.foregroundColor?.resolve(state) ??
        switch (widget.type) {
          AxType.primary => theme.foregroundColor,
          AxType.secondary => theme.foregroundColor,
          AxType.glass => theme.primaryColor,
          _ => theme.foregroundColor,
        };

    final squarePadding = isDesktop ? 7.5 : 10.0;
    final horizontalPadding = isDesktop ? 12.0 : 20.0;
    final verticalPadding = isDesktop ? 6.0 : 12.0;

    return FocusableActionDetector(
      focusNode: _focusNode,
      onFocusChange: (value) => setState(() => focused = value),
      onShowHoverHighlight: (value) => setState(() => hovered = value),
      mouseCursor: enabled ? SystemMouseCursors.basic : SystemMouseCursors.forbidden,
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
        onTap: widget.onPressed == null
            ? null
            : () {
                if (widget.interactable) widget.onPressed!.call();
              },
        child: Opacity(
          opacity: enabled ? 1.0 : 0.65,
          child: AnimatedContainer(
            duration: Duration(milliseconds: pressed ? 50 : 200),
            curve: Curves.fastEaseInToSlowEaseOut,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(4.0),
              border: borderColor.alpha == 0.0
                  ? null
                  : Border.all(
                      strokeAlign: BorderSide.strokeAlignInside,
                      width: 1.0,
                      color: borderColor,
                    ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                /* horizontal: widget.squared ? 7.5 : 12.0,
                vertical: widget.squared ? 7.5 : 6.0, */
                horizontal: widget.children.length == 1 && widget.children.first is! Text ? squarePadding : horizontalPadding,
                vertical: widget.children.length == 1 && widget.children.first is! Text ? squarePadding : verticalPadding,
              ),
              child: IconTheme(
                data: IconThemeData(color: fgColor),
                child: DefaultTextStyle(
                  style: TextStyle(
                    color: fgColor,
                    fontWeight: FontWeight.w400,
                  ),
                  child: widget.builder?.call(hovered, pressed, false) ??
                      (widget.children.isNotEmpty
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate((widget.children.length * 2) - 1,
                                  (index) => index.isEven ? widget.children[index ~/ 2] : SizedBox(width: widget.gap)),
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

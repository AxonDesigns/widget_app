import 'package:widget_app/generic.dart';

class Link extends StatefulWidget {
  const Link({
    super.key,
    required this.text,
    this.onTap,
  });

  final String text;
  final VoidCallback? onTap;

  @override
  State<Link> createState() => _LinkState();
}

class _LinkState extends State<Link> {
  bool _isHovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = widget.onTap != null),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Text(
          widget.text,
          style: context.theme.baseTextStyle.copyWith(
            color: context.theme.primaryColor
                .withOpacity(widget.onTap != null ? 1.0 : 0.5),
            fontWeight: FontWeight.bold,
            decorationThickness: 2,
            decoration: _isHovered ? TextDecoration.underline : null,
          ),
          textHeightBehavior: const TextHeightBehavior(
            applyHeightToLastDescent: false,
            applyHeightToFirstAscent: false,
          ),
        ),
      ),
    );
  }
}

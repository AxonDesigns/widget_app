import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'generic.dart';

class Tooltip extends StatefulWidget {
  const Tooltip({
    super.key,
    required this.child,
    this.message = '',
  });

  final Widget child;
  final String message;

  @override
  State<Tooltip> createState() => _TooltipState();
}

class _TooltipState extends State<Tooltip> {
  bool _showing = false;
  Offset _position = Offset.zero;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _createOverlayEntry();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (event) {
        setState(() {
          _position = event.position;
        });
        _overlayEntry?.markNeedsBuild();
      },
      onEnter: (event) {
        _position = event.position;
        _showTooltip(context, widget.message);
      },
      onExit: (event) {
        _hideTooltip();
      },
      child: widget.child,
    );
  }

  void _showTooltip(BuildContext context, String message) {
    if (kIsWeb) return;
    setState(() {
      _showing = true;
    });
    _overlayEntry?.markNeedsBuild();
  }

  void _hideTooltip() {
    setState(() {
      _showing = false;
    });
    _overlayEntry?.markNeedsBuild();
  }

  void _createOverlayEntry() {
    final overlayState = Overlay.of(context);
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: _position.dy + 10.0,
        left: _position.dx + 10.0,
        child: IgnorePointer(
          child: AnimatedOpacity(
            opacity: _showing ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 25),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              decoration: BoxDecoration(
                color: context.theme.backgroundColor,
                border: Border.all(
                  color: context.theme.surfaceColor.higher,
                  strokeAlign: BorderSide.strokeAlignInside,
                ),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Text(
                widget.message,
                style: TextStyle(
                  color: context.theme.foregroundColor,
                  fontSize: 12.0,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    overlayState.insert(_overlayEntry!);
  }
}

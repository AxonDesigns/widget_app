import 'dart:async';
import 'package:flutter/foundation.dart';
import '../generic.dart';

/// Displays a tooltip when hovering over the child widget.
class Tooltip extends StatefulWidget {
  const Tooltip({
    super.key,
    required this.child,
    required this.message,
    this.startDelay = const Duration(milliseconds: 500),
    this.opacityDelay = const Duration(milliseconds: 75),
  });

  final Widget child;
  final String message;
  final Duration startDelay;
  final Duration opacityDelay;

  @override
  State<Tooltip> createState() => _TooltipState();
}

class _TooltipState extends State<Tooltip> {
  bool _showing = false;
  OverlayEntry? _overlayEntry;
  Offset _enterPosition = Offset.zero;
  Timer? _startDelayTimer;
  Timer? _hideTimer;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (event) {
        if (_showing) return;
        _enterPosition = event.position;
      },
      onEnter: (event) {
        if (_startDelayTimer != null && _startDelayTimer!.isActive) {
          _startDelayTimer!.cancel();
        }

        _startDelayTimer = Timer(widget.startDelay, () {
          _showTooltip(context, widget.message);
        });
      },
      onExit: (event) {
        if (_startDelayTimer != null && _startDelayTimer!.isActive) {
          _startDelayTimer!.cancel();
        }

        _hideTooltip();
      },
      opaque: false,
      child: widget.child,
    );
  }

  void _showTooltip(BuildContext context, String message) {
    if (kIsWeb) return;
    if (_overlayEntry == null) {
      _createOverlayEntry(_enterPosition);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_overlayEntry == null) return;
      setState(() => _showing = true);
      _overlayEntry!.markNeedsBuild();
    });
  }

  void _hideTooltip() {
    setState(() {
      _showing = false;
    });
    _overlayEntry?.markNeedsBuild();

    _hideTimer?.cancel();
    _hideTimer = Timer(widget.opacityDelay, () {
      if (_overlayEntry != null) {
        _overlayEntry!.remove();
        _overlayEntry = null;
      }
    });
  }

  void _createOverlayEntry(Offset startPosition) {
    final overlayState = Overlay.of(context);
    _overlayEntry = OverlayEntry(
      builder: (context) => _TooltipOverlay(
        message: widget.message,
        showing: _showing,
        startPosition: startPosition,
        opacityDelay: widget.opacityDelay,
      ),
    );

    overlayState.insert(_overlayEntry!);
  }
}

class _TooltipOverlay extends StatefulWidget {
  const _TooltipOverlay({
    super.key,
    required this.message,
    required this.showing,
    required this.startPosition,
    required this.opacityDelay,
  });

  final String message;
  final Offset startPosition;
  final bool showing;
  final Duration opacityDelay;

  @override
  State<_TooltipOverlay> createState() => _TooltipOverlayState();
}

class _TooltipOverlayState extends State<_TooltipOverlay> {
  Offset _position = Offset.zero;

  @override
  void initState() {
    super.initState();
    _position = widget.startPosition;
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      opaque: false,
      onHover: (event) {
        setState(() {
          _position = event.position;
        });
      },
      child: Stack(
        children: [
          Positioned(
            top: _position.dy,
            left: _position.dx + 16.0,
            child: IgnorePointer(
              child: AnimatedOpacity(
                opacity: widget.showing ? 1.0 : 0.0,
                duration: widget.opacityDelay,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 4.0),
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
                    style: context.theme.baseTextStyle,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

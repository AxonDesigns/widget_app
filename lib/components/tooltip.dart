import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'package:window_manager/window_manager.dart';
import '../generic.dart';

enum TooltipPosition {
  follow,
  left,
  right,
  top,
  bottom,
}

/// Displays a tooltip when hovering over the child widget.
class Tooltip extends StatefulWidget {
  const Tooltip({
    super.key,
    required this.child,
    required this.message,
    this.mobilePosition = TooltipPosition.top,
    this.desktopPosition = TooltipPosition.follow,
    this.startDelay = const Duration(milliseconds: 500),
    this.opacityDelay = const Duration(milliseconds: 75),
  });

  /// The child widget to display the tooltip for.
  final Widget child;

  /// The message to display in the tooltip.
  final String message;

  /// How long to wait before showing the tooltip.
  final Duration startDelay;

  /// How long it will take for the tooltip to fade out.
  final Duration opacityDelay;

  /// Where the tooltip will be located around the target on mobile devices.
  /// if the tooltip doesn't fit in the defined position,
  /// it will try to display in the opposite one.
  final TooltipPosition mobilePosition;

  /// Where the tooltip will be located around the target on desktop.
  final TooltipPosition desktopPosition;

  @override
  State<Tooltip> createState() => _TooltipState();
}

class _TooltipState extends State<Tooltip> {
  bool _showing = false;
  OverlayEntry? _overlayEntry;
  Timer? _startDelayTimer;
  Timer? _hideTimer;

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (event) {
        _hideTooltip();
      },
      child: MouseRegion(
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
      ),
    );
  }

  void _showTooltip(BuildContext context, String message) async {
    if (kIsWeb) return;

    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }

    await _createOverlayEntry();

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

  Future<void> _createOverlayEntry() async {
    if (context.platformType == PlatformType.mobile) return;
    final overlayState = Overlay.of(context);
    final mousePos = await screenRetriever.getCursorScreenPoint();
    final window = await windowManager.getPosition();
    final isMaximized = await windowManager.isMaximized();

    _overlayEntry = OverlayEntry(
      builder: (context) => _TooltipOverlay(
        message: widget.message,
        showing: _showing,
        startPosition: mousePos - window.translate(8, isMaximized ? 8 : 0),
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      RenderBox box = context.findRenderObject() as RenderBox;
      _position = box.globalToLocal(widget.startPosition);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      opaque: false,
      onHover: (event) {
        setState(() {
          _position = event.localPosition;
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

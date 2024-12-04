import 'package:widget_app/generic.dart';
import 'package:window_manager/window_manager.dart';

class WindowTitleBar extends StatefulWidget {
  const WindowTitleBar({super.key});

  @override
  State<WindowTitleBar> createState() => _WindowTitleBarState();
}

class _WindowTitleBarState extends State<WindowTitleBar> with WindowListener {
  var _isMaximized = false;
  var _isFocused = true;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowMaximize() {
    super.onWindowMaximize();
    setState(() {
      _isMaximized = true;
    });
  }

  @override
  void onWindowUnmaximize() {
    super.onWindowUnmaximize();
    setState(() {
      _isMaximized = false;
    });
  }

  @override
  void onWindowBlur() {
    super.onWindowBlur();
    setState(() {
      _isFocused = false;
    });
  }

  @override
  void onWindowFocus() {
    super.onWindowFocus();
    setState(() {
      _isFocused = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.theme.backgroundColor,
      height: 30.0,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanStart: (details) {
                windowManager.startDragging();
              },
              onDoubleTap: () async {
                if (await windowManager.isMaximized()) {
                  windowManager.restore();
                } else {
                  windowManager.maximize();
                }
              },
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 8.0,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Widget App",
                    style: context.theme.baseTextStyle.copyWith(
                      color: context.theme.foregroundColor
                          .withOpacity(_isFocused ? 1.0 : 0.5),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Button.ghost(
            focusable: false,
            borderRadius: 0.0,
            padding: const EdgeInsets.symmetric(
              horizontal: 6.0,
              vertical: 4.0,
            ),
            onPressed: () async {
              windowManager.minimize();
            },
            children: [
              Image.asset(
                "assets/images/minimize_icon.png",
                height: 16,
                width: 16,
                filterQuality: FilterQuality.high,
                color: context.theme.foregroundColor,
                cacheHeight: 16,
                cacheWidth: 16,
              )
            ],
          ),
          Button.ghost(
            focusable: false,
            borderRadius: 0.0,
            padding: const EdgeInsets.symmetric(
              horizontal: 6.0,
              vertical: 4.0,
            ),
            onPressed: () async {
              if (await windowManager.isMaximized()) {
                windowManager.restore();
              } else {
                windowManager.maximize();
              }
            },
            children: [
              Image.asset(
                _isMaximized
                    ? "assets/images/unmaximize_icon.png"
                    : "assets/images/maximize_icon.png",
                color: context.theme.foregroundColor,
                height: 16,
                width: 16,
                filterQuality: FilterQuality.high,
                cacheHeight: 16,
                cacheWidth: 16,
              )
            ],
          ),
          Button.destructive(
            focusable: false,
            borderRadius: 0.0,
            padding: const EdgeInsets.symmetric(
              horizontal: 6.0,
              vertical: 4.0,
            ),
            onPressed: () async {
              windowManager.close();
            },
            children: [
              Image.asset(
                "assets/images/close_icon.png",
                height: 16,
                width: 16,
                filterQuality: FilterQuality.high,
                cacheHeight: 16,
                cacheWidth: 16,
              )
            ],
          ),
        ],
      ),
    );
  }
}

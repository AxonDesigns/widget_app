import 'dart:ui';
import 'package:widget_app/generic.dart';

class ThemeModeProvider extends StatefulWidget {
  const ThemeModeProvider({
    super.key,
    required this.child,
    this.initial,
    this.storageKey = 'theme_mode',
  });

  final Widget child;
  final ThemeMode? initial;
  final String storageKey;

  @override
  State<ThemeModeProvider> createState() => ThemeModeProviderState();
}

class ThemeModeProviderState extends State<ThemeModeProvider>
    with WidgetsBindingObserver {
  var _isDarkMode = false;

  ThemeMode? _themeMode;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.initial;

    WidgetsBinding.instance.addObserver(this);
    final mode = WidgetsBinding.instance.platformDispatcher.platformBrightness;
    _isDarkMode = _themeMode == ThemeMode.system
        ? mode == Brightness.dark
        : _themeMode == ThemeMode.dark;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    if (_themeMode != ThemeMode.system) return;
    setState(() {
      _updateIsDarkMode();
    });
  }

  void _updateIsDarkMode() {
    final mode = WidgetsBinding.instance.platformDispatcher.platformBrightness;
    _isDarkMode = _themeMode == ThemeMode.system
        ? mode == Brightness.dark
        : _themeMode == ThemeMode.dark;
  }

  @override
  Widget build(BuildContext context) {
    return InheritedThemeMode(
      data: ThemeModeData(
        themeMode: _themeMode ?? ThemeMode.system,
        isDarkMode: _isDarkMode,
        setThemeMode: (mode) {
          setState(() {
            _themeMode = mode;
            _updateIsDarkMode();
          });
          PreferencesProvider.maybeOf(context)?.set(
            widget.storageKey,
            mode.index,
          );
        },
      ),
      child: widget.child,
    );
  }
}

/// A theme that uses the [GenericThemeData] as its [ThemeData].
class InheritedThemeMode extends InheritedWidget {
  const InheritedThemeMode({
    super.key,
    required super.child,
    required this.data,
  });

  final ThemeModeData data;

  @override
  bool updateShouldNotify(covariant InheritedThemeMode oldWidget) {
    return oldWidget.data != data;
  }

  static ThemeModeData of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<InheritedThemeMode>()!
        .data;
  }

  static ThemeModeData? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<InheritedThemeMode>()
        ?.data;
  }
}

class ThemeModeData {
  ThemeModeData({
    required this.themeMode,
    required this.isDarkMode,
    required this.setThemeMode,
  });

  final ThemeMode themeMode;
  final bool isDarkMode;
  final Function(ThemeMode mode) setThemeMode;
}

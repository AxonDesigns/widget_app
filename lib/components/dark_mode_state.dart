import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeModeStateProvider extends StatefulWidget {
  const ThemeModeStateProvider({
    super.key,
    required this.child,
    this.initial,
    this.storageKey = 'theme_mode',
  });

  final Widget child;
  final ThemeMode? initial;
  final String storageKey;

  @override
  State<ThemeModeStateProvider> createState() => ThemeModeStateProviderState();
}

class ThemeModeStateProviderState extends State<ThemeModeStateProvider>
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
    return ThemeModeState(
      data: ThemeModeStateData(
        themeMode: _themeMode ?? ThemeMode.system,
        isDarkMode: _isDarkMode,
        setThemeMode: (mode) {
          setState(() {
            _themeMode = mode;
            _updateIsDarkMode();
          });
          SharedPreferences.getInstance().then(
            (value) => value.setInt(widget.storageKey, _themeMode?.index ?? 0),
          );
        },
      ),
      child: widget.child,
    );
  }
}

/// A theme that uses the [GenericThemeData] as its [ThemeData].
class ThemeModeState extends InheritedWidget {
  const ThemeModeState({
    super.key,
    required super.child,
    required this.data,
  });

  final ThemeModeStateData data;

  @override
  bool updateShouldNotify(covariant ThemeModeState oldWidget) {
    return oldWidget.data != data;
  }

  static ThemeModeStateData of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ThemeModeState>()!.data;
  }

  static ThemeModeStateData? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ThemeModeState>()?.data;
  }
}

class ThemeModeStateData {
  ThemeModeStateData({
    required this.themeMode,
    required this.isDarkMode,
    required this.setThemeMode,
  });

  final ThemeMode themeMode;
  final bool isDarkMode;
  final Function(ThemeMode mode) setThemeMode;
}

enum ThemeMode {
  system,
  light,
  dark,
}

extension ThemeModeStateExtension on BuildContext {
  ThemeMode get themeMode {
    return ThemeModeState.maybeOf(this)?.themeMode ?? ThemeMode.system;
  }

  bool get isDarkMode {
    return ThemeModeState.maybeOf(this)?.isDarkMode ?? false;
  }

  void setThemeMode(ThemeMode mode) {
    ThemeModeState.maybeOf(this)?.setThemeMode(mode);
  }
}

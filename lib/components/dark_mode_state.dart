import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InheritedThemeModeProvider extends StatefulWidget {
  const InheritedThemeModeProvider({
    super.key,
    required this.child,
    this.initial,
    this.storageKey = 'theme_mode',
  });

  final Widget child;
  final ThemeMode? initial;
  final String storageKey;

  @override
  State<InheritedThemeModeProvider> createState() =>
      InheritedThemeModeProviderState();
}

class InheritedThemeModeProviderState extends State<InheritedThemeModeProvider>
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

enum ThemeMode {
  system,
  light,
  dark,
}

extension ThemeModeStateExtension on BuildContext {
  ThemeMode get themeMode {
    return InheritedThemeMode.maybeOf(this)?.themeMode ?? ThemeMode.system;
  }

  bool get isDarkMode {
    return InheritedThemeMode.maybeOf(this)?.isDarkMode ?? false;
  }

  void setThemeMode(ThemeMode mode) {
    InheritedThemeMode.maybeOf(this)?.setThemeMode(mode);
  }
}

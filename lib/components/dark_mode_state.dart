import 'dart:ui';

import 'package:flutter/widgets.dart';

class ThemeModeState extends StatefulWidget {
  const ThemeModeState({
    super.key,
    required this.child,
    required this.initial,
  });

  final Widget child;
  final ThemeMode initial;

  @override
  State<ThemeModeState> createState() => _ThemeModeStateState();
}

class _ThemeModeStateState extends State<ThemeModeState> with WidgetsBindingObserver {
  late bool isDarkMode;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final mode = WidgetsBinding.instance.platformDispatcher.platformBrightness;
    isDarkMode = widget.initial == ThemeMode.system ? mode == Brightness.dark : widget.initial == ThemeMode.dark;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    setState(() {
      final mode = WidgetsBinding.instance.platformDispatcher.platformBrightness;
      isDarkMode = widget.initial == ThemeMode.system ? mode == Brightness.dark : widget.initial == ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _ThemeModeState(
      data: ThemeModeStateData(
        themeMode: widget.initial,
        isDarkMode: isDarkMode,
      ),
      child: widget.child,
    );
  }
}

/// A theme that uses the [GenericThemeData] as its [ThemeData].
class _ThemeModeState extends InheritedWidget {
  const _ThemeModeState({
    super.key,
    required super.child,
    required this.data,
  });

  final ThemeModeStateData data;

  @override
  bool updateShouldNotify(covariant _ThemeModeState oldWidget) {
    return oldWidget.data != data;
  }

  static ThemeModeStateData of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_ThemeModeState>()!.data;
  }

  static ThemeModeStateData? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_ThemeModeState>()?.data;
  }
}

class ThemeModeStateData {
  ThemeModeStateData({
    required this.themeMode,
    required this.isDarkMode,
  });

  final ThemeMode themeMode;
  final bool isDarkMode;
}

enum ThemeMode {
  system,
  light,
  dark,
}

extension ThemeModeStateExtension on BuildContext {
  ThemeMode get themeMode {
    return _ThemeModeState.maybeOf(this)?.themeMode ?? ThemeMode.system;
  }

  bool get isDarkMode {
    return _ThemeModeState.maybeOf(this)?.isDarkMode ?? false;
  }
}

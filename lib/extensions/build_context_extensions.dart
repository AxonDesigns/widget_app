import 'dart:io';
import 'package:widget_app/generic.dart';

extension ThemeModeStateExtension on BuildContext {
  ThemeMode get themeMode {
    final themeMode = PreferencesProvider.of(this).getInt('theme_mode') ?? 0;
    return ThemeMode.values[themeMode];
  }

  bool get isDarkMode {
    return InheritedThemeMode.maybeOf(this)?.isDarkMode ?? false;
  }

  void setThemeMode(ThemeMode mode) {
    InheritedThemeMode.maybeOf(this)?.setThemeMode(mode);
  }
}

extension ContextExtensions on BuildContext {
  Future<bool> showConfirmDialog({
    required String title,
    required String content,
    ConfirmDialogType type = ConfirmDialogType.info,
    String? cancelButtonText,
    String? confirmButtonText,
  }) async {
    final result = await showGenericDialog<bool?>(
      dismissible: true,
      barrierLabel: "Dismiss confirm dialog",
      transitionDuration: const Duration(milliseconds: 150),
      pageBuilder: (context, animation, secondaryAnimation) {
        return ConfirmDialog(
          animation: animation,
          title: title,
          content: content,
          type: type,
          cancelButtonText: cancelButtonText,
          confirmButtonText: confirmButtonText,
        );
      },
    );
    return result ?? false;
  }
}

extension GenericUtilities on BuildContext {
  /// Returns the current platform type.
  PlatformType get platformType => switch (Platform.operatingSystem) {
        'windows' || 'linux' || 'macos' || 'fuchsia' => PlatformType.desktop,
        'android' || 'ios' => PlatformType.mobile,
        'web' => PlatformType.web,
        _ => PlatformType.web,
      };
}

extension GenericDialogExtension on BuildContext {
  /// Shows a dialog above the current contents of the app.
  Future<T?> showGenericDialog<T>({
    required RoutePageBuilder pageBuilder,
    bool dismissible = true,
    String barrierLabel = 'Dismiss',
    Duration transitionDuration = const Duration(milliseconds: 150),
    RouteTransitionsBuilder? transitionBuilder,
    bool useRootNavigator = true,
    RouteSettings? routeSettings,
    Offset? anchorPoint,
  }) {
    return Navigator.of(this, rootNavigator: useRootNavigator).push<T>(
      RawDialogRoute<T>(
        barrierDismissible: dismissible,
        barrierLabel: barrierLabel,
        barrierColor: const Color.fromARGB(0, 0, 0, 0),
        transitionDuration: transitionDuration,
        transitionBuilder: transitionBuilder,
        settings: routeSettings,
        anchorPoint: anchorPoint,
        pageBuilder: pageBuilder,
      ),
    );
  }
}

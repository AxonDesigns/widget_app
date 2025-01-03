import 'dart:io';
import 'package:widget_app/components/route_test.dart';
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
      useRootNavigator: false,
      pageBuilder: (context) {
        return ConfirmDialog(
          animation: const AlwaysStoppedAnimation(1.0),
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
    required WidgetBuilder pageBuilder,
    bool dismissible = true,
    String barrierLabel = 'Dismiss',
    Duration transitionDuration = const Duration(milliseconds: 200),
    RouteTransitionsBuilder? transitionBuilder,
    bool useRootNavigator = false,
    RouteSettings? routeSettings,
    Offset? anchorPoint,
  }) {
    return Navigator.of(this, rootNavigator: useRootNavigator).push<T>(
      GenericModalRoute<T>(
        barrierDismissible: dismissible,
        barrierLabel: barrierLabel,
        barrierColor: Colors.transparent,
        /*transitionDuration: transitionDuration,
        transitionBuilder: transitionBuilder,*/
        settings: routeSettings,
        builder: pageBuilder,
        /*anchorPoint: anchorPoint,
        pageBuilder: pageBuilder,*/
      ),
    );
  }

  Future<T?> showTestDialog<T>({
    required RoutePageBuilder pageBuilder,
    bool dismissible = true,
    String barrierLabel = 'Dismiss',
    Duration transitionDuration = const Duration(milliseconds: 200),
    RouteTransitionsBuilder? transitionBuilder,
    bool useRootNavigator = false,
    RouteSettings? routeSettings,
    Offset? anchorPoint,
  }) {
    return Navigator.of(this, rootNavigator: useRootNavigator).push<T>(
      PageRouteBuilder<T>(
        barrierDismissible: dismissible,
        barrierLabel: barrierLabel,
        barrierColor: Colors.transparent,
        transitionDuration: transitionDuration,
        reverseTransitionDuration: transitionDuration,
        settings: routeSettings,
        fullscreenDialog: false,
        allowSnapshotting: true,
        maintainState: true,
        pageBuilder: (context, animation, secondaryAnimation) {
          return pageBuilder(context, animation, secondaryAnimation);
        },
        opaque: false,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          print(secondaryAnimation.value);
          return child;
        },
      ),
    );
  }
}

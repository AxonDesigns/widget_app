import 'package:widget_app/components/generic.dart';

extension GenericDialogExt on BuildContext {
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
    return Navigator.of(this, rootNavigator: useRootNavigator).push<T>(RawDialogRoute<T>(
      barrierDismissible: dismissible,
      barrierLabel: barrierLabel,
      barrierColor: const Color.fromARGB(0, 0, 0, 0),
      transitionDuration: transitionDuration,
      transitionBuilder: transitionBuilder,
      settings: routeSettings,
      anchorPoint: anchorPoint,
      pageBuilder: pageBuilder,
    ));
  }
}

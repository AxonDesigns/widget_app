import 'package:widget_app/components/dark_mode_state.dart';
import 'package:widget_app/components/generic_scroll_behavior.dart';
import 'package:widget_app/generic.dart';

class AppProvider extends StatelessWidget {
  const AppProvider({
    super.key,
    required this.child,
    required this.initialThemeMode,
  });

  final Widget child;
  final ThemeMode initialThemeMode;

  @override
  Widget build(BuildContext context) {
    return InheritedThemeModeProvider(
      initial: initialThemeMode,
      storageKey: 'theme_mode',
      // The builder is needed, because we need a new context that has access to the theme mode state.
      child: Builder(
        builder: (context) {
          return AnimatedGenericTheme(
            data: context.isDarkMode ? GenericThemeData.dark() : GenericThemeData.light(),
            child: Builder(
              builder: (context) {
                return DefaultTextStyle(
                  style: context.theme.baseTextStyle.copyWith(
                    color: context.theme.foregroundColor,
                  ),
                  child: IconTheme(
                    data: IconThemeData(
                      color: context.theme.foregroundColor,
                      size: context.theme.iconSize,
                    ),
                    child: ScrollConfiguration(
                      behavior: const GenericScrollBehavior(),
                      child: child,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

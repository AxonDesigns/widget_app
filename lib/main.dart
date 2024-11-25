import 'package:shared_preferences/shared_preferences.dart';
import 'package:widget_app/components/dark_mode_state.dart';
import 'package:widget_app/router.dart';
import 'components/generic.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final initialThemeMode = ThemeMode.values[prefs.getInt('theme_mode') ?? 0];

  runApp(MainApp(
    initialThemeMode: initialThemeMode,
  ));
}

class MainApp extends StatelessWidget {
  const MainApp({
    super.key,
    this.initialThemeMode = ThemeMode.system,
  });

  final ThemeMode initialThemeMode;

  @override
  Widget build(BuildContext context) {
    return GenericApp.router(
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return ThemeModeStateProvider(
          initial: initialThemeMode,
          storageKey: 'theme_mode',
          // The builder is needed, because we need a new context that has access to the theme mode state.
          child: Builder(builder: (context) {
            return AnimatedGenericTheme(
              data: context.isDarkMode
                  ? GenericThemeData.dark()
                  : GenericThemeData.light(),
              child: Builder(
                builder: (context) {
                  return DefaultTextStyle(
                    style: TextStyle(
                      color: context.theme.foregroundColor,
                    ),
                    child: child!,
                  );
                },
              ),
            );
          }),
        );
      },
      routerConfig: router,
    );
  }
}

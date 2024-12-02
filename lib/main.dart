import 'package:shared_preferences/shared_preferences.dart';
import 'package:widget_app/components/app_provider.dart';
import 'package:widget_app/components/dark_mode_state.dart';
import 'package:widget_app/router.dart';
import 'generic.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();
  final initialThemeMode = ThemeMode.values[preferences.getInt('theme_mode') ?? 0];

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
    return App.router(
      debugShowCheckedModeBanner: false,
      builder: (context, child) => AppProvider(
        initialThemeMode: initialThemeMode,
        child: child!,
      ),
      routerConfig: router,
    );
  }
}

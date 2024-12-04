import 'package:shared_preferences/shared_preferences.dart';
import 'package:widget_app/components/app_provider.dart';
import 'package:widget_app/router.dart';
import 'package:window_manager_plus/window_manager_plus.dart';
import 'generic.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  await WindowManagerPlus.ensureInitialized(args.isEmpty ? 0 : int.tryParse(args[0]) ?? 0);

  // Now you can use the plugin, such as WindowManagerPlus.current
  WindowOptions windowOptions = const WindowOptions(
    size: Size(800, 600),
    center: true,
    backgroundColor: Colors.transparent,
    titleBarStyle: TitleBarStyle.hidden,
    title: "Widget App",
  );

  WindowManagerPlus.current.waitUntilReadyToShow(windowOptions, () async {
    await WindowManagerPlus.current.show();
    await WindowManagerPlus.current.focus();
  });

  final preferences = await SharedPreferencesWithCache.create(
    cacheOptions: const SharedPreferencesWithCacheOptions(allowList: null),
  );

  runApp(PreferencesProvider(
    preferences: preferences,
    child: const MainApp(),
  ));
}

class MainApp extends StatelessWidget {
  const MainApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return App.router(
      debugShowCheckedModeBanner: false,
      builder: (context, child) => AppProvider(
        child: Builder(
          builder: (context) {
            return Column(
              children: [
                Expanded(child: child!),
              ],
            );
          },
        ),
      ),
      routerConfig: router,
    );
  }
}

import 'package:shared_preferences/shared_preferences.dart';
import 'package:widget_app/components/app_provider.dart';
import 'package:widget_app/router.dart';
import 'generic.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
        child: child!,
      ),
      routerConfig: router,
    );
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:widget_app/router.dart';
import 'package:window_manager/window_manager.dart';
import 'generic.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  GoRouter.optionURLReflectsImperativeAPIs = true;

  if (isDesktop && !kIsWeb) {
    await windowManager.ensureInitialized();

    const windowOptions = WindowOptions(
      size: Size(1067, 600),
      center: true,
      backgroundColor: Colors.transparent,
      titleBarStyle: TitleBarStyle.hidden,
      title: "Widget App",
      windowButtonVisibility: false,
      minimumSize: Size(240, 240),
    );

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

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
                if (isDesktop && !kIsWeb) const WindowTitleBar(),
                Expanded(
                  child: AnnotatedRegion(
                    value: SystemUiOverlayStyle(
                      statusBarColor: context.theme.backgroundColor,
                      statusBarIconBrightness: context.invertedBrightness,
                      systemNavigationBarColor: context.theme.backgroundColor,
                    ),
                    child: child!,
                  ),
                ),
              ],
            );
          },
        ),
      ),
      routerConfig: router,
    );
  }
}

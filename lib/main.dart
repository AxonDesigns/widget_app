import 'package:widget_app/components/dark_mode_state.dart';
import 'package:widget_app/router.dart';
import 'components/generic.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GenericApp.router(
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return ThemeModeState(
          initial: ThemeMode.system,
          child: Builder(builder: (context) {
            return AnimatedGenericTheme(
              data: context.isDarkMode ? GenericThemeData.dark() : GenericThemeData.light(),
              // This builder is needed to make the text style work, otherwise it's just null.
              child: Builder(
                builder: (context) {
                  return DefaultTextStyle(
                    style: TextStyle(
                      color: GenericTheme.of(context).foregroundColor,
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

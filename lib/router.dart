import 'package:go_router/go_router.dart';
import 'package:sheet/route.dart';
import 'package:widget_app/generic.dart';
import 'package:widget_app/pages/about_page.dart';
import 'package:widget_app/pages/home_page.dart';

var router = GoRouter(
  initialLocation: "/",
  routes: [
    GoRoute(
      path: '/',
      name: "home",
      pageBuilder: (context, state) => MaterialExtendedPage(
        key: state.pageKey,
        child: const HomePage(),
      ),
    ),
    GoRoute(
      path: '/about',
      name: "about",
      pageBuilder: (context, state) => MaterialExtendedPage(
        key: state.pageKey,
        child: const AboutPage(),
      ),
    ),
  ],
);

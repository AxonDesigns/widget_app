import 'package:go_router/go_router.dart';
import 'package:widget_app/generic.dart';
import 'package:widget_app/pages/about_page.dart';
import 'package:widget_app/pages/home_page.dart';

import 'components/custom_modal.dart';

class CustomGoRoute extends GoRoute {
  CustomGoRoute({
    required super.path,
    super.name,
    required Widget child,
  }) : super(
          pageBuilder: (context, state) => GenericExtendedPage(
            key: state.pageKey,
            child: child,
          ),
        );
}

var router = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return CustomModal(
          child: child,
        );
      },
      routes: [
        CustomGoRoute(
          path: '/',
          name: 'home',
          child: const HomePage(),
        ),
        CustomGoRoute(
          path: '/about',
          name: 'about',
          child: const AboutPage(),
        ),
      ],
    ),
  ],
);

import 'package:go_router/go_router.dart';
import 'package:widget_app/generic.dart';
import 'package:widget_app/pages/about_page.dart';
import 'package:widget_app/pages/home_page.dart';

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
        return ScrollableSheet(
          maxHeightFactor: 0.9,
          padding: const EdgeInsets.all(16.0),
          sheetBuilder: (context, shrinkWrap) {
            return CustomScrollView(
              primary: true,
              shrinkWrap: shrinkWrap,
              slivers: [
                const SliverToBoxAdapter(
                  child: Text(
                      """Quam ducimus voluptatem qui mollitia est a illum quae. Laudantium magni est eum explicabo dolor aut consectetur quia. Dolores fugiat repudiandae qui et exercitationem. Sit ullam ad in fugiat consequatur sint nisi. Aut similique ut maxime.
              Possimus doloremque necessitatibus sed pariatur consequuntur soluta rerum. Deserunt natus qui voluptas commodi. Quia dolorem voluptatem optio sed dolores deserunt sunt."""),
                ),
                SliverToBoxAdapter(
                  child: Button.primary(
                    onPressed: () {},
                    children: const [Text("Test")],
                  ),
                ),
                const SliverToBoxAdapter(
                  child: Text(
                      """Quam ducimus voluptatem qui mollitia est a illum quae. Laudantium magni est eum explicabo dolor aut consectetur quia. Dolores fugiat repudiandae qui et exercitationem. Sit ullam ad in fugiat consequatur sint nisi. Aut similique ut maxime.
              Possimus doloremque necessitatibus sed pariatur consequuntur soluta rerum. Deserunt natus qui voluptas commodi. Quia dolorem voluptatem optio sed dolores deserunt sunt."""),
                ),
                const SliverToBoxAdapter(
                  child: Text(
                      """Quam ducimus voluptatem qui mollitia est a illum quae. Laudantium magni est eum explicabo dolor aut consectetur quia. Dolores fugiat repudiandae qui et exercitationem. Sit ullam ad in fugiat consequatur sint nisi. Aut similique ut maxime.
              Possimus doloremque necessitatibus sed pariatur consequuntur soluta rerum. Deserunt natus qui voluptas commodi. Quia dolorem voluptatem optio sed dolores deserunt sunt."""),
                ),
                const SliverToBoxAdapter(
                  child: Text(
                      """Quam ducimus voluptatem qui mollitia est a illum quae. Laudantium magni est eum explicabo dolor aut consectetur quia. Dolores fugiat repudiandae qui et exercitationem. Sit ullam ad in fugiat consequatur sint nisi. Aut similique ut maxime.
              Possimus doloremque necessitatibus sed pariatur consequuntur soluta rerum. Deserunt natus qui voluptas commodi. Quia dolorem voluptatem optio sed dolores deserunt sunt."""),
                ),
                const SliverToBoxAdapter(
                  child: Text(
                      """Quam ducimus voluptatem qui mollitia est a illum quae. Laudantium magni est eum explicabo dolor aut consectetur quia. Dolores fugiat repudiandae qui et exercitationem. Sit ullam ad in fugiat consequatur sint nisi. Aut similique ut maxime.
              Possimus doloremque necessitatibus sed pariatur consequuntur soluta rerum. Deserunt natus qui voluptas commodi. Quia dolorem voluptatem optio sed dolores deserunt sunt."""),
                ),
                const SliverToBoxAdapter(
                  child: Text(
                      """Quam ducimus voluptatem qui mollitia est a illum quae. Laudantium magni est eum explicabo dolor aut consectetur quia. Dolores fugiat repudiandae qui et exercitationem. Sit ullam ad in fugiat consequatur sint nisi. Aut similique ut maxime.
              Possimus doloremque necessitatibus sed pariatur consequuntur soluta rerum. Deserunt natus qui voluptas commodi. Quia dolorem voluptatem optio sed dolores deserunt sunt."""),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(
                    height: 16.0,
                  ),
                ),
              ],
            );
          },
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

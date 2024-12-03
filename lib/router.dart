import 'package:go_router/go_router.dart';
import 'package:widget_app/generic.dart';
import 'package:widget_app/pages/about_page.dart';
import 'package:widget_app/pages/home_page.dart';

var router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => GenericPage(
        key: state.pageKey,
        builder: (context) => const HomePage(),
      ),
    ),
    GoRoute(
      path: '/about',
      pageBuilder: (context, state) => GenericPage(
        key: state.pageKey,
        builder: (context) => const AboutPage(),
      ),
    ),
  ],
);

Widget _transition(BuildContext context, Animation<double> animation,
    Animation<double> secondaryAnimation, Curve curve, Widget child) {
  var isHorizontal =
      MediaQuery.sizeOf(context).width > MediaQuery.sizeOf(context).height;
  final inOffset = Offset(
    isHorizontal ? 0.0 : 1.0,
    isHorizontal ? -1.0 : 0.0,
  );

  final outOffset = Offset(
    isHorizontal ? 0.0 : -0.25,
    isHorizontal ? 0.25 : 0.0,
  );

  var isReverse =
      (animation.isAnimating && animation.status == AnimationStatus.reverse) ||
          (secondaryAnimation.isAnimating &&
              secondaryAnimation.status == AnimationStatus.reverse);

  return SlideTransition(
    position: Tween<Offset>(
      begin: inOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(
        parent: animation, curve: isReverse ? curve.flipped : curve)),
    child: SlideTransition(
      position: Tween<Offset>(
        begin: Offset.zero,
        end: outOffset,
      ).animate(CurvedAnimation(
          parent: secondaryAnimation,
          curve: isReverse ? curve.flipped : curve)),
      child: Stack(
        children: [
          Positioned.fill(child: child),
          if (secondaryAnimation.isAnimating)
            IgnorePointer(
              ignoring: true,
              child: Container(
                color: Colors.black.withOpacity(secondaryAnimation.value
                        .invLerp(isReverse ? 0.5 : 0.0, 1.0)
                        .saturate() *
                    0.5),
              ),
            ),
        ],
      ),
    ),
  );
}

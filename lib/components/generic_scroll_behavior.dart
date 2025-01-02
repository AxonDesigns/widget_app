import 'dart:ui';

import 'package:widget_app/generic.dart';

class GenericScrollBehavior extends ScrollBehavior {
  const GenericScrollBehavior({
    this.mobilePhysics,
    this.desktopPhysics,
  });

  final ScrollPhysics? mobilePhysics;
  final ScrollPhysics? desktopPhysics;

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.mouse,
        PointerDeviceKind.touch,
        PointerDeviceKind.stylus,
        PointerDeviceKind.unknown,
      };

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    switch (getPlatform(context)) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return mobilePhysics ?? const BouncingScrollPhysics();
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return desktopPhysics ?? const BouncingScrollPhysics();
    }
  }

  /*@override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    switch (getPlatform(context)) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return child;
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return child;
      case TargetPlatform.android:
        return StretchingOverscrollIndicator(
          axisDirection: details.direction,
          clipBehavior: Clip.antiAlias,
          child: child,
        );
    }
  }*/
}

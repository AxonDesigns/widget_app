import 'dart:ui';

import 'package:widget_app/components/bottom_sheet/bottom_sheet_layout.dart';
import 'package:widget_app/generic.dart';

class DynamicSheet extends StatefulWidget {
  const DynamicSheet({
    super.key,
    required this.builder,
    this.controller,
    this.physics,
    this.maxHeightFactor = 1.0,
  });

  final Widget Function(
    BuildContext context,
    ScrollController controller,
    ScrollPhysics physics,
  ) builder;
  final ScrollController? controller;
  final ScrollPhysics? physics;

  /// How much of the screen should be occupied by the sheet
  final double maxHeightFactor;

  @override
  State<DynamicSheet> createState() => _DynamicSheetState();
}

class _DynamicSheetState extends State<DynamicSheet>
    with SingleTickerProviderStateMixin, AfterLayoutMixin {
  late ScrollController _controller;
  late ScrollPhysics _physics;

  @override
  void initState() {
    _controller = widget.controller ?? ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant DynamicSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _controller.dispose();
      _controller = widget.controller ?? ScrollController();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _physics = widget.physics ??
        ScrollConfiguration.of(context).getScrollPhysics(context);
  }

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: const _SheetScrollBehavior(
        noOverscroll: false,
      ),
      child: Builder(builder: (context) {
        return CustomSingleChildLayout(
          delegate: SheetLayoutDelegate(
            maxHeight: MediaQuery.of(context).size.height,
            progress: 0.9,
          ),
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollUpdateNotification) {
                print("sgffgdfg");
              }
              return false;
            },
            child: widget.builder(
              context,
              _controller,
              ScrollConfiguration.of(context).getScrollPhysics(context),
            ),
          ),
        );
      }),
    );
  }
}

class _SheetScrollBehavior extends ScrollBehavior {
  const _SheetScrollBehavior({
    this.noOverscroll = false,
    this.noScrollbar = false,
  });

  final bool noOverscroll;
  final bool noScrollbar;

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.mouse,
        PointerDeviceKind.touch,
        PointerDeviceKind.stylus,
        PointerDeviceKind.unknown,
      };

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    if (noOverscroll) {
      return const ClampingScrollPhysics();
    }
    return super.getScrollPhysics(context);
  }

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    if (noScrollbar) {
      return child;
    }
    return super.buildScrollbar(context, child, details);
  }

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    if (noOverscroll) {
      return child;
    }
    return super.buildOverscrollIndicator(context, child, details);
  }
}

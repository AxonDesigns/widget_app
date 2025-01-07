import 'package:flutter/widgets.dart';
import 'package:widget_app/components.dart';

class SheetExperiment extends StatefulWidget {
  const SheetExperiment({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<SheetExperiment> createState() => _SheetExperimentState();
}

class _SheetExperimentState extends State<SheetExperiment> {
  final _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: LayoutBuilder(builder: (context, constraints) {
            return CustomScrollView(
              scrollBehavior: const GenericScrollBehavior(),
              hitTestBehavior: HitTestBehavior.translucent,
              controller: _controller,
              slivers: [
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: constraints.maxHeight,
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    decoration: BoxDecoration(
                        color: context.theme.backgroundColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border(
                          top: BorderSide(
                            color: context.theme.foregroundColor.withOpacity(0.1),
                            width: 1,
                          ),
                        )),
                    height: constraints.maxHeight,
                  ),
                )
              ],
            );
          }),
        )
      ],
    );
  }
}

import 'package:flutter/services.dart';
import 'package:widget_app/generic.dart';

class SheetContainer extends StatelessWidget {
  const SheetContainer({
    super.key,
    required this.child,
    this.padding,
    this.handleSpacing = 36,
  });

  final Widget child;
  final EdgeInsets? padding;
  final double handleSpacing;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor: context.theme.surfaceColor.low,
      ),
      child: Container(
        clipBehavior: Clip.antiAlias,
        padding: EdgeInsets.only(
          top: 0,
          bottom: padding?.bottom ?? 20,
          left: padding?.left ?? 20,
          right: padding?.right ?? 20,
        ),
        decoration: BoxDecoration(
          color: context.theme.surfaceColor.low,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(
              context.theme.radiusSize * 3,
            ),
          ),
          border: Border(
            top: BorderSide(
              color: context.theme.foregroundColor.withOpacity(0.075),
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 12.0,
              offset: const Offset(0.0, 0.0),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: GappedColumn(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            gap: handleSpacing,
            children: [
              Align(
                alignment: Alignment.center,
                child: Container(
                  decoration: BoxDecoration(
                    color: context.theme.foregroundColor.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(
                      context.theme.radiusSize,
                    ),
                  ),
                  margin: const EdgeInsets.only(
                    top: 20,
                  ),
                  height: 5,
                  width: 80,
                ),
              ),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

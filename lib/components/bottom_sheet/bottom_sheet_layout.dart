import 'package:widget_app/generic.dart';

class SheetLayoutDelegate extends SingleChildLayoutDelegate {
  SheetLayoutDelegate({
    required this.progress,
    required this.maxHeight,
  });

  final double maxHeight;
  final double progress;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return BoxConstraints(
      minWidth: constraints.maxWidth,
      maxWidth: constraints.maxWidth,
      minHeight: maxHeight > 0
          ? maxHeight * progress
          : constraints.maxHeight * progress,
      maxHeight: maxHeight > 0
          ? maxHeight * progress
          : constraints.maxHeight * progress,
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    return Offset(0.0, size.height - childSize.height);
  }

  @override
  bool shouldRelayout(SheetLayoutDelegate oldDelegate) {
    return progress != oldDelegate.progress;
  }
}

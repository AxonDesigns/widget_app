import 'package:flutter/widgets.dart';

/// A widget that displays its children in a column with a gap between them.
class GappedColumn extends Flex {
  GappedColumn({
    super.key,
    super.mainAxisAlignment,
    super.mainAxisSize,
    super.crossAxisAlignment,
    super.textDirection,
    super.verticalDirection,
    super.textBaseline,
    List<Widget> children = const <Widget>[],
    this.gap = 0.0,
  }) : super(
          direction: Axis.vertical,
          children: GappedColumn._buildChildren(children, gap: gap),
        );

  static List<Widget> _buildChildren(List<Widget> base, {double gap = 0.0}) {
    final result = <Widget>[];
    for (var (index, child) in base.indexed) {
      result.add(child);
      if (index != base.length - 1) {
        result.add(SizedBox(height: gap));
      }
    }
    return result;
  }

  final double gap;
}

/// A widget that displays its children in a row with a gap between them.
class GappedRow extends Flex {
  GappedRow({
    super.key,
    super.mainAxisAlignment,
    super.mainAxisSize,
    super.crossAxisAlignment,
    super.textDirection,
    super.verticalDirection,
    super.textBaseline,
    List<Widget> children = const <Widget>[],
    this.gap = 0.0,
  }) : super(
          direction: Axis.horizontal,
          children: GappedRow._buildChildren(children, gap: gap),
        );

  static List<Widget> _buildChildren(List<Widget> base, {double gap = 0.0}) {
    final result = <Widget>[];
    final length = base.length;
    for (var (index, child) in base.indexed) {
      result.add(child);
      if (index != length - 1) {
        result.add(SizedBox(width: gap));
      }
    }
    return result;
  }

  final double gap;
}

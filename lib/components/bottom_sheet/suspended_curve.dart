import 'package:widget_app/generic.dart';

class SuspendedCurve extends Curve {
  const SuspendedCurve({
    required this.curve,
    this.from,
    this.isReverse = false,
  });

  final Curve curve;
  final double? from;
  final bool isReverse;

  @override
  double transform(double t) {
    assert(t >= 0.0 && t <= 1.0);
    if (from != null) {
      assert(from! >= 0.0 && from! <= 1.0);

      if (t < from!) {
        if (isReverse) {
          final alpha = t.remap(0.0, from!, 0.0, 1.0);

          return curve.flipped.transform(alpha).remap(0.0, 1.0, 0.0, from!);
        }
        return t;
      }

      if (t == 1.0) {
        return t;
      }

      final curveProgress = (t - from!) / (1 - from!);
      final transformed = curve.transform(curveProgress);
      return transformed.lerp(from!, 1);
    } else {
      return curve.transform(t);
    }
  }
}

import 'package:widget_app/generic.dart';

class SuspendedCurve extends Curve {
  const SuspendedCurve({
    required this.curve,
    this.from,
  });

  final Curve curve;
  final double? from;

  @override
  double transform(double t) {
    assert(t >= 0.0 && t <= 1.0);
    if (from != null) {
      assert(from! >= 0.0 && from! <= 1.0);

      if (t < from! || t == 1.0) {
        return t;
      }

      return curve.transform(
        t.remap(from!, 1.0, 0.0, 1.0),
      );
    } else {
      return curve.transform(t);
    }
  }
}

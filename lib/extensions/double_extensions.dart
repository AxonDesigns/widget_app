/*extension DoubleExtension on double {
  /// Linear interpolation.
  ///
  /// e.g.
  /// ```dart
  /// final value = 0.3;
  ///
  /// print(value.lerp(0.0, 100.0)); // 30.0
  /// ```
  /// The result won't be clamped.<br>
  /// use [saturate] to clamp the result value between 0.0 and 1.0.
  double lerp(double from, double to) {
    return (1.0 - this) * from + to * this;
  }

  /// Inverse linear interpolation.
  ///
  /// e.g.
  /// ```dart
  /// final value = 50.0;
  ///
  /// print(value.invLerp(0.0, 100.0)); // 0.5
  /// ```
  ///
  /// The result won't be clamped.<br>
  /// use [saturate] to clamp the result value between 0.0 and 1.0.
  double invLerp(double from, double to) {
    return (this - from) / (to - from);
  }

  /// Remaps the value from one range to another.
  ///
  /// The result value is not clamped by default.<br>
  /// set [clampOutput] to ```true``` to clamp the result value to the output range.
  double remap(
    double iMin,
    double iMax,
    double oMin,
    double oMax,
  ) {
    return invLerp(iMin, iMax).lerp(oMin, oMax);
  }

  /// Clamps the value between 0.0 and 1.0.
  double saturate() {
    return clamp(0.0, 1.0) as double;
  }

  /// Wraps a value within the [min] and [max] range.
  ///
  /// e.g.
  /// ```dart
  /// final value = 15.0;
  ///
  /// print(value.wrap(0.0, 10.0)); // 5.0
  /// ```
  ///
  double wrap(double min, double max) {
    return ((this - min) % (max - min)) + min;
  }

  /// Returns true if the value is between [min] and [max].
  bool isBetween(double min, double max) {
    return this >= min && this <= max;
  }
}
*/
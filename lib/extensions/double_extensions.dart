extension DoubleExtension on double {
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
  /// set [clamp] to ```true``` to clamp the result value to the output range.
  double remap(
    double iMin,
    double iMax,
    double oMin,
    double oMax, {
    bool clamp = false,
  }) {
    if (clamp) {
      return invLerp(iMin, iMax).lerp(oMin, oMax).clamp(oMin, oMax);
    }

    return invLerp(iMin, iMax).lerp(oMin, oMax);
  }

  /// Clamps the value between 0.0 and 1.0
  double saturate() {
    return clamp(0.0, 1.0) as double;
  }
}

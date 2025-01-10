extension NumExtension<T extends num> on T {
  /// Linear interpolation.
  ///
  /// e.g.
  /// ```dart
  /// final value = 0.3;
  ///
  /// print(value.lerp(0.0, 100.0)); // 30.0
  /// ```
  /// The result won't be clamped.<br>
  /// see [saturate], [clamp], [wrap].
  T lerp(T from, T to) {
    return (((1.0 as T) - this) * from + to * this) as T;
  }

  /// Inverse linear interpolation.<br>
  ///
  /// e.g.
  /// ```dart
  /// final value = 50.0;
  ///
  /// print(value.invLerp(0.0, 100.0)); // 0.5
  /// ```
  ///
  /// The result won't be clamped.<br>
  /// see [saturate], [clamp], [wrap].
  T invLerp(T from, T to) {
    return ((this - from) / (to - from)) as T;
  }

  /// Remaps the value from one range to another.<br>
  ///
  /// e.g.
  /// ```dart
  /// final value = 50.0;
  ///
  /// print(value.remap(0.0, 100.0, 0.0, 400.0)); // 200.0
  /// ```
  ///
  /// The result value won't clamped.<br>
  /// see [saturate], [clamp], [wrap].
  T remap(
    T iMin,
    T iMax,
    T oMin,
    T oMax,
  ) {
    return invLerp(iMin, iMax).lerp(oMin, oMax);
  }

  /// Always clamps the value between 0.0 and 1.0.<br>
  /// see [clamp].
  T saturate() {
    return clamp((0.0 as T), (1.0 as T)) as T;
  }

  /// Wraps a value within the [min] and [max] range.<br>
  ///
  /// e.g.
  /// ```dart
  /// final value = 15.0;
  ///
  /// print(value.wrap(0.0, 10.0)); // 5.0
  /// ```
  ///
  T wrap(T min, T max) {
    return ((this - min) % (max - min)) + min as T;
  }

  /// Returns true if the value is between [min] and [max].
  bool isBetween(T min, T max) {
    return this >= min && this <= max;
  }
}

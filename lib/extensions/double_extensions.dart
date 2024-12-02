extension DoubleExtension on double {
  double lerp(double from, double to) {
    return (1.0 - this) * from + to * this;
  }

  double invLerp(double from, double to) {
    return (this - from) / (to - from);
  }

  double remap(double iMin, double iMax, double oMin, double oMax) {
    return invLerp(iMin, iMax).lerp(oMin, oMax);
  }

  double saturate() {
    return clamp(0.0, 1.0) as double;
  }
}

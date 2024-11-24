import 'package:widget_app/components/generic.dart';

/// A theme that uses the [GenericThemeData] as its [ThemeData].
class GenericTheme extends InheritedWidget {
  const GenericTheme({
    super.key,
    required super.child,
    required this.data,
  });

  final GenericThemeData data;

  @override
  bool updateShouldNotify(covariant GenericTheme oldWidget) {
    return oldWidget.data != data;
  }

  static GenericThemeData of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<GenericTheme>()!.data;
  }

  static GenericThemeData? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<GenericTheme>()?.data;
  }
}

/// A theme that animates between [GenericThemeData]s.
class AnimatedGenericTheme extends ImplicitlyAnimatedWidget {
  const AnimatedGenericTheme({
    super.key,
    super.duration = const Duration(milliseconds: 400),
    super.curve = Curves.fastEaseInToSlowEaseOut,
    required this.data,
    required this.child,
  });

  final GenericThemeData data;
  final Widget child;

  @override
  AnimatedWidgetBaseState<AnimatedGenericTheme> createState() => _AnimatedGenericThemeState();
}

class _AnimatedGenericThemeState extends AnimatedWidgetBaseState<AnimatedGenericTheme> {
  GenericThemeDataTween? _data;
  @override
  Widget build(BuildContext context) {
    return GenericTheme(
      data: _data!.evaluate(animation),
      child: widget.child,
    );
  }

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _data = visitor(_data, widget.data, (dynamic value) => GenericThemeDataTween(begin: value))! as GenericThemeDataTween;
  }
}

/// The [ThemeData] used by [GenericTheme].
class GenericThemeData {
  const GenericThemeData({
    required this.primaryColor,
    required this.backgroundColor,
    required this.foregroundColor,
    required Color highestSurfaceColor,
  }) : _highestSurfaceColor = highestSurfaceColor;

  factory GenericThemeData.light() => const GenericThemeData(
        primaryColor: Color.fromARGB(255, 55, 194, 236),
        backgroundColor: Colors.white,
        foregroundColor: Color.fromARGB(255, 20, 20, 20),
        highestSurfaceColor: Color.fromARGB(255, 171, 234, 255),
      );

  factory GenericThemeData.dark() => const GenericThemeData(
        primaryColor: Color.fromARGB(255, 55, 194, 236),
        backgroundColor: Color.fromARGB(255, 20, 20, 20),
        foregroundColor: Color.fromARGB(255, 255, 255, 255),
        highestSurfaceColor: Color.fromARGB(255, 45, 45, 45),
      );

  final Color primaryColor;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color _highestSurfaceColor;

  GenericColorSwatch get surfaceColor => GenericColorSwatch(
        Color.lerp(backgroundColor, _highestSurfaceColor, 0.4285714287)!.value,
        <int, Color>{
          3: _highestSurfaceColor,
          2: Color.lerp(backgroundColor, _highestSurfaceColor, 0.7142857145)!,
          1: Color.lerp(backgroundColor, _highestSurfaceColor, 0.5714285716)!,
          0: Color.lerp(backgroundColor, _highestSurfaceColor, 0.4285714287)!,
          -1: Color.lerp(backgroundColor, _highestSurfaceColor, 0.2857142858)!,
          -2: Color.lerp(backgroundColor, _highestSurfaceColor, 0.1428571429)!,
          -3: backgroundColor,
        },
      );

  static GenericThemeData lerp(GenericThemeData a, GenericThemeData b, double t) {
    if (identical(a, b)) return a;

    return GenericThemeData(
      primaryColor: Color.lerp(a.primaryColor, b.primaryColor, t)!,
      backgroundColor: Color.lerp(a.backgroundColor, b.backgroundColor, t)!,
      foregroundColor: Color.lerp(a.foregroundColor, b.foregroundColor, t)!,
      highestSurfaceColor: Color.lerp(a._highestSurfaceColor, b._highestSurfaceColor, t)!,
    );
  }
}

/// A [Tween] that interpolates between [GenericThemeData]s.
class GenericThemeDataTween extends Tween<GenericThemeData> {
  GenericThemeDataTween({
    super.begin,
    super.end,
  });

  @override
  GenericThemeData lerp(double t) {
    return GenericThemeData.lerp(begin!, end!, t);
  }
}

class GenericColorSwatch extends ColorSwatch<int> {
  const GenericColorSwatch(
    super.primary,
    super.swatch,
  );

  // darkest, darker, dark, normal, light, lighter, lightest
  // lowest, lower, low, normal, high, higher, highest

  Color get lowest => this[-3]!;
  Color get lower => this[-2]!;
  Color get low => this[-1]!;
  Color get normal => this[0]!;
  Color get high => this[1]!;
  Color get higher => this[2]!;
  Color get highest => this[3]!;
}

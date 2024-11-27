import 'dart:ui';

import 'package:widget_app/generic.dart';
import 'package:widget_app/utils.dart';

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
  AnimatedWidgetBaseState<AnimatedGenericTheme> createState() =>
      _AnimatedGenericThemeState();
}

class _AnimatedGenericThemeState
    extends AnimatedWidgetBaseState<AnimatedGenericTheme> {
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
    _data = visitor(_data, widget.data,
            (dynamic value) => GenericThemeDataTween(begin: value))!
        as GenericThemeDataTween;
  }
}

extension type const RadiusSize._(double value) {
  /// 0.0
  static double get none => 0.0;

  /// 4.0
  static double get small => 4.0;

  /// 8.0
  static double get medium => 8.0;

  /// 16.0
  static double get large => 16.0;

  /// 100%
  static double get full => 5000.0;

  /// custom
  static custom(double value) {
    return value;
  }
}

/// The [ThemeData] used by [GenericTheme].
class GenericThemeData {
  const GenericThemeData({
    required this.primaryColor,
    required this.backgroundColor,
    required this.foregroundColor,
    required Color highestSurfaceColor,
    required this.radiusSize,
    required this.baseTextStyle,
  }) : _highestSurfaceColor = highestSurfaceColor;

  factory GenericThemeData.light() => GenericThemeData(
      primaryColor: const Color.fromARGB(255, 35, 145, 255),
      backgroundColor: Colors.white,
      foregroundColor: const Color.fromARGB(255, 20, 20, 20),
      highestSurfaceColor: const Color.fromARGB(255, 223, 223, 223),
      radiusSize: RadiusSize.small,
      baseTextStyle: TextStyle(
        fontFamily: 'Supreme',
        fontSize: isDesktop ? 14.0 : 16.0,
        fontVariations: const [
          FontVariation.weight(400),
        ],
      ));

  factory GenericThemeData.dark() => GenericThemeData(
      primaryColor: const Color.fromARGB(255, 0, 128, 255),
      backgroundColor: const Color.fromARGB(255, 20, 20, 20),
      foregroundColor: const Color.fromARGB(255, 255, 255, 255),
      highestSurfaceColor: const Color.fromARGB(255, 45, 45, 45),
      radiusSize: RadiusSize.small,
      baseTextStyle: TextStyle(
        fontFamily: 'Supreme',
        fontSize: isDesktop ? 14.0 : 16.0,
        letterSpacing: 0.0,
        fontVariations: const [
          FontVariation.weight(400),
        ],
      ));

  final Color primaryColor;
  final Color backgroundColor;
  final Color foregroundColor;
  final double radiusSize;
  final TextStyle baseTextStyle;

  final Color _highestSurfaceColor;

  double get iconSize => isDesktop ? 16.0 : 20.0;

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

  static GenericThemeData lerp(
      GenericThemeData a, GenericThemeData b, double t) {
    if (identical(a, b)) return a;

    return GenericThemeData(
      primaryColor: Color.lerp(a.primaryColor, b.primaryColor, t)!,
      backgroundColor: Color.lerp(a.backgroundColor, b.backgroundColor, t)!,
      foregroundColor: Color.lerp(a.foregroundColor, b.foregroundColor, t)!,
      baseTextStyle: b.baseTextStyle,
      radiusSize: lerpDouble(a.radiusSize, b.radiusSize, t)!,
      highestSurfaceColor:
          Color.lerp(a._highestSurfaceColor, b._highestSurfaceColor, t)!,
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

extension GenericThemeExtension on BuildContext {
  GenericThemeData get theme {
    return GenericTheme.of(this);
  }
}

export 'package:flutter/widgets.dart' hide showGeneralDialog;
export 'app.dart';
export 'generic_page.dart';
export 'generic_page_route.dart';
export 'text_input.dart';
export 'colors.dart';
export 'generic_dialog.dart';
export 'barrier.dart';
export 'gapped_flex.dart';
export 'generic_theme.dart';

import 'dart:io';
import 'package:widget_app/components/generic.dart';

/// Used to categorize the platform types instead of using the [Platform] class for a more generic approach.
enum PlatformType {
  mobile,
  desktop,
  web,
}

extension GenericUtilities on BuildContext {
  /// Returns the current platform type.
  PlatformType get platformType => switch (Platform.operatingSystem) {
        'windows' || 'linux' || 'macos' || 'fuchsia' => PlatformType.desktop,
        'android' || 'ios' => PlatformType.mobile,
        'web' => PlatformType.web,
        _ => PlatformType.web,
      };
}

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

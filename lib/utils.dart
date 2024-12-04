import 'dart:io';

import 'package:flutter/foundation.dart';

bool get isDesktop => kIsWeb
    ? true
    : Platform.isWindows ||
        Platform.isLinux ||
        Platform.isMacOS ||
        Platform.isFuchsia;

bool get isMobile => kIsWeb ? false : Platform.isAndroid || Platform.isIOS;

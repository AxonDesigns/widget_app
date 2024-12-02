import 'dart:io';

bool get isDesktop =>
    Platform.isWindows ||
    Platform.isLinux ||
    Platform.isMacOS ||
    Platform.isFuchsia;

bool get isMobile => Platform.isAndroid || Platform.isIOS;

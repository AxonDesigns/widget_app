import 'dart:io';

import 'package:widget_app/components/button.dart';
import 'package:widget_app/components/dark_mode_state.dart';

import 'generic.dart';

bool get isDesktop =>
    Platform.isWindows ||
    Platform.isLinux ||
    Platform.isMacOS ||
    Platform.isFuchsia;

bool get isMobile => Platform.isAndroid || Platform.isIOS;

enum ConfirmDialogType {
  info,
  destructive,
}

extension ContextExtensions on BuildContext {
  Future<bool> showConfirmDialog({
    required String title,
    required String content,
    ConfirmDialogType type = ConfirmDialogType.info,
    String? cancelButtonText,
    String? confirmButtonText,
  }) async {
    final result = await showGenericDialog<bool?>(
      dismissible: true,
      barrierLabel: "dimiss confirm dialog",
      transitionDuration: const Duration(milliseconds: 150),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  color: context.isDarkMode
                      ? context.theme.backgroundColor.withOpacity(0.5)
                      : Colors.black.withOpacity(0.5),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: AnimatedBuilder(
                  animation: animation,
                  builder: (context, child) {
                    final value =
                        Curves.easeOutQuart.transform(animation.value);
                    return Transform.scale(
                      scale: value.remap(0.0, 1.0, 0.65, 1.0),
                      alignment: Alignment.bottomCenter,
                      child: child!,
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: context.theme.surfaceColor,
                      borderRadius:
                          BorderRadius.circular(context.theme.radiusSize),
                      border: Border.all(
                        color: context.theme.foregroundColor.withOpacity(0.075),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.35),
                          blurRadius: 8.0,
                          offset: const Offset(0.0, 5.0),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18.0,
                      vertical: 16.0,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 18.0,
                              fontFamily: "GeneralSans",
                              fontVariations: [
                                FontVariation.weight(600),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            content,
                            style: context.theme.baseTextStyle,
                          ),
                          const SizedBox(height: 16.0),
                          GappedRow(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.end,
                            gap: 8.0,
                            children: [
                              Button.outline(
                                onPressed: () {
                                  Navigator.of(context).pop(false);
                                },
                                children: [
                                  Text(cancelButtonText ?? "Cancel"),
                                ],
                              ),
                              switch (type) {
                                ConfirmDialogType.info => Button.primary(
                                    onPressed: () {
                                      Navigator.of(context).pop(true);
                                    },
                                    children: [
                                      Text(confirmButtonText ?? "Confirm"),
                                    ],
                                  ),
                                ConfirmDialogType.destructive =>
                                  Button.destructive(
                                    onPressed: () {
                                      Navigator.of(context).pop(true);
                                    },
                                    children: [
                                      Text(confirmButtonText ?? "Confirm"),
                                    ],
                                  ),
                              }
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }
}

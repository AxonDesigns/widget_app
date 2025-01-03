import 'package:widget_app/generic.dart';

class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({
    super.key,
    required this.animation,
    required this.title,
    required this.content,
    required this.type,
    this.cancelButtonText,
    this.confirmButtonText,
  });

  final Animation<double> animation;
  final String title;
  final String content;
  final ConfirmDialogType type;
  final String? cancelButtonText;
  final String? confirmButtonText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            final value = Curves.easeOutQuart.transform(animation.value);
            return Transform.scale(
              scale: value.remap(0.0, 1.0, 0.65, 1.0),
              alignment: Alignment.bottomCenter,
              child: child!,
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: context.theme.surfaceColor,
              borderRadius: BorderRadius.circular(context.theme.radiusSize),
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
                        fontFamily: "Segoe UI",
                        fontWeight: FontWeight.w600),
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
                        ConfirmDialogType.destructive => Button.destructive(
                            onPressed: () {
                              Navigator.of(context).pop(true);
                            },
                            children: [
                              Text(confirmButtonText ?? "Confirm"),
                            ],
                          ),
                      }
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

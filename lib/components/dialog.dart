import 'package:widget_app/generic.dart';

class Dialog extends StatelessWidget {
  const Dialog({
    super.key,
    required this.title,
    required this.content,
    required this.actions,
  });

  final String title;
  final String content;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: context.theme.baseTextStyle.copyWith(
            fontSize: 18.0,
            fontWeight: FontWeight.w600,
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
          children: actions,
        ),
      ],
    );
  }
}

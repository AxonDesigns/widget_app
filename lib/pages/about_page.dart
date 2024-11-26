import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';
import 'package:widget_app/components/button.dart';
import 'package:widget_app/components/generic.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: GenericTheme.of(context).backgroundColor,
      child: Center(
        child: SizedBox(
          width: 200,
          child: GappedColumn(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            gap: 14.0,
            children: [
              Button.primary(
                onPressed: () async {
                  context.pop();
                },
                children: const [
                  Icon(LucideIcons.chevron_left),
                  Text("Primary"),
                ],
              ),
              Button.outline(
                onPressed: () async {
                  context.pop();
                },
                children: const [
                  Icon(LucideIcons.chevron_left),
                  Text("Outline"),
                ],
              ),
              Button.ghost(
                onPressed: () async {
                  context.pop();
                },
                children: const [
                  Icon(LucideIcons.chevron_left),
                  Text("Ghost"),
                ],
              ),
              Button.glass(
                onPressed: () async {
                  context.pop();
                },
                children: const [
                  Icon(LucideIcons.chevron_left),
                  Text("Glass"),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:go_router/go_router.dart';
import 'package:widget_app/components/generic.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: GenericTheme.maybeOf(context)?.backgroundColor,
      child: Center(
        child: GestureDetector(
          onTap: () => context.pop(),
          child: const Text('About Page'),
        ),
      ),
    );
  }
}

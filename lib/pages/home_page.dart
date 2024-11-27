import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';
import 'package:widget_app/components/animated_spinner.dart';
import 'package:widget_app/components/button.dart';
import 'package:widget_app/components/dark_mode_state.dart';
import 'package:widget_app/generic.dart';
import 'package:widget_app/components/tooltip.dart';
import 'package:widget_app/utils.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: GenericTheme.of(context).backgroundColor,
      child: Center(
        child: Container(
          width: 400.0,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: GenericTheme.of(context).surfaceColor,
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: GappedColumn(
            mainAxisSize: MainAxisSize.min,
            gap: 14.0,
            children: [
              TextInput(
                controller: _controller,
                obscureText: false,
                prefix: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(LucideIcons.search),
                ),
                suffix: Button.ghost(
                  focusable: false,
                  onPressed: () async {
                    print("Button pressed");
                  },
                  children: const [Icon(LucideIcons.eye)],
                ),
              ),
              Tooltip(
                message: "Example tooltip",
                child: Button.primary(
                  onPressed: () async {
                    await context.push('/about');
                  },
                  children: const [
                    AnimatedSpinner(size: 20),
                    Text("Go to About Page"),
                  ],
                ),
              ),
              Button.glass(
                onPressed: () async {
                  final result = await context.showConfirmDialog(
                    title: "Are you absolutely sure?",
                    content: "This will delete all your data from our servers, "
                        "and you will not be able to recover it.",
                    type: ConfirmDialogType.destructive,
                  );

                  print(result);
                },
                children: const [Text("Open Confirm Dialog")],
              ),
              Button.outline(
                onPressed: () async {
                  context.setThemeMode(ThemeMode.light);
                },
                children: const [Text("Change to Light Mode")],
              ),
              Button.outline(
                onPressed: () async {
                  context.setThemeMode(ThemeMode.dark);
                },
                children: const [Text("Change to Dark Mode")],
              ),
              Button.outline(
                onPressed: () async {
                  context.setThemeMode(ThemeMode.system);
                },
                children: const [Text("Change to System Mode")],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

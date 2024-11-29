import 'package:flutter/rendering.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';
import 'package:widget_app/components/Card.dart';
import 'package:widget_app/components/animated_spinner.dart';
import 'package:widget_app/components/button.dart';
import 'package:widget_app/components/dark_mode_state.dart';
import 'package:widget_app/components/file_input.dart';
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
  final _scrollController = ScrollController();
  bool _obscureText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (!context.mounted) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: GenericTheme.of(context).backgroundColor,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height - 40,
          ),
          child: Card(
            width: 400.0,
            elevation: 16.0,
            clipBehavior: Clip.antiAlias,
            child: RawScrollbar(
              controller: _scrollController,
              thumbColor: context.theme.foregroundColor.withOpacity(0.1),
              radius: Radius.circular(context.theme.radiusSize),
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(16.0),
                child: GappedColumn(
                  mainAxisSize: MainAxisSize.min,
                  gap: 16.0,
                  children: [
                    const TextInput(),
                    const TextInput(
                      prefix: Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Icon(LucideIcons.search),
                      ),
                    ),
                    TextInput(
                      controller: _controller,
                      obscureText: _obscureText,
                      prefix: const Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Icon(LucideIcons.search),
                      ),
                      suffix: Padding(
                        padding: const EdgeInsets.only(right: 2),
                        child: Button.ghost(
                          focusable: false,
                          disabled: _controller.text.isEmpty,
                          onPressed: () async {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                          children: [
                            Icon(
                              _obscureText
                                  ? LucideIcons.eye
                                  : LucideIcons.eye_off,
                            )
                          ],
                        ),
                      ),
                    ),
                    Tooltip(
                      message: "Example tooltip",
                      child: Button.primary(
                        onPressed: () async {
                          await context.push('/about');
                        },
                        children: const [
                          AnimatedSpinner(size: 16),
                          Text("Go to About Page"),
                        ],
                      ),
                    ),
                    Button.primary(
                      disabled: true,
                      onPressed: () async {
                        await context.push('/about');
                      },
                      children: const [
                        AnimatedSpinner(size: 16),
                        Text("Go to About Page"),
                      ],
                    ),
                    Button.glass(
                      onPressed: () async {
                        final result = await context.showConfirmDialog(
                          title: "Are you absolutely sure?",
                          content:
                              "This will delete all your data from our servers, "
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
                    FileInput(
                      onDropped: (paths) {
                        print(paths);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

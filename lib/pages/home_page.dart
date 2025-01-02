import 'dart:math';

import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';
import 'package:sheet/route.dart';
import 'package:sheet/sheet.dart';
import 'package:widget_app/components/sheet_route.dart';
import 'package:widget_app/generic.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool _obscureText = false;
  int _selectedIndex = 0;
  int _selectedIndex2 = 0;

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
        child: RawScrollbar(
          controller: _scrollController,
          thumbColor: context.theme.foregroundColor.withOpacity(0.1),
          radius: Radius.circular(context.theme.radiusSize),
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: 400,
              child: GappedColumn(
                mainAxisSize: MainAxisSize.min,
                gap: 16.0,
                children: [
                  TextInput(
                    controller: _controller,
                    obscureText: _obscureText,
                    keyboardType: TextInputType.text,
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
                          Icon(_obscureText
                              ? LucideIcons.eye
                              : LucideIcons.eye_off)
                        ],
                      ),
                    ),
                  ),
                  GappedColumn(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    gap: 4.0,
                    children: const [
                      Text("Text Area"),
                      TextInput(
                        maxLines: null,
                        minLines: 4,
                        keyboardType: TextInputType.multiline,
                      ),
                    ],
                  ),
                  GappedRow(
                    gap: 4.0,
                    children: [
                      Expanded(
                        child: SelectInput(
                          expanded: true,
                          selectedIndex: _selectedIndex,
                          onItemSelected: (index) {
                            setState(() {
                              _selectedIndex = index;
                            });
                          },
                          items: const [
                            Option(
                              icon: Icon(LucideIcons.user),
                              text: "Hi!",
                            ),
                            Option(
                              icon: Icon(LucideIcons.bird),
                              text: "This Widget",
                            ),
                            Option(
                              icon: Icon(LucideIcons.building),
                              text: "Resizes",
                            ),
                            Option(
                              icon: Icon(LucideIcons.airplay),
                              text: "Depending on",
                            ),
                            Option(
                              icon: Icon(LucideIcons.list),
                              text: "it's contents!",
                            ),
                            Option(
                              icon: Icon(LucideIcons.list),
                              text: "This one",
                            ),
                            Option(
                              icon: Icon(LucideIcons.list),
                              text: "Does not",
                            ),
                            Option(
                              icon: Icon(LucideIcons.list),
                              text: "Because it",
                            ),
                            Option(
                              icon: Icon(LucideIcons.list),
                              text: "Expands!",
                            ),
                          ],
                        ),
                      ),
                      SelectInput(
                        selectedIndex: _selectedIndex2,
                        onItemSelected: (index) {
                          setState(() {
                            _selectedIndex2 = index;
                          });
                        },
                        items: const [
                          Option(
                            icon: Icon(LucideIcons.user),
                            text: "Hi!",
                          ),
                          Option(
                            icon: Icon(LucideIcons.bird),
                            text: "This",
                          ),
                          Option(
                            icon: Icon(LucideIcons.building),
                            text: "Widget",
                          ),
                          Option(
                            icon: Icon(LucideIcons.airplay),
                            text: "Resizes",
                          ),
                        ],
                      ),
                    ],
                  ),
                  Tooltip(
                    message: "Example tooltip",
                    child: Button.primary(
                      onPressed: () async {
                        await context.push('/about');
                      },
                      children: const [
                        AnimatedSpinner(size: 16),
                        Text("About Page"),
                      ],
                    ),
                  ),
                  Tooltip(
                    message: "This button opens a bottom sheet",
                    child: Button.primary(
                      onPressed: () async {
                        final random = Random();
                        final result = Navigator.of(context).push<bool>(
                          GenericSheetRoute(
                            draggable: true,
                            barrierDismissible: true,
                            animationCurve: Curves.fastEaseInToSlowEaseOut,
                            duration: const Duration(milliseconds: 200),
                            fit: SheetFit.loose,
                            physics: const BouncingSheetPhysics(),
                            builder: (context) {
                              return Container(
                                clipBehavior: Clip.antiAlias,
                                decoration: BoxDecoration(
                                  color: context.theme.backgroundColor,
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(
                                      context.theme.radiusSize * 2,
                                    ),
                                  ),
                                ),
                                child: SingleChildScrollView(
                                  padding: const EdgeInsets.all(16.0),
                                  child: GappedColumn(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    gap: 16.0,
                                    children: [
                                      Align(
                                        alignment: Alignment.center,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: context
                                                .theme.surfaceColor.highest,
                                            borderRadius: BorderRadius.circular(
                                              context.theme.radiusSize,
                                            ),
                                          ),
                                          height: 3,
                                          width: 50,
                                        ),
                                      ),
                                      Text(
                                        "Are you absolutely sure?",
                                        style: context.theme.baseTextStyle
                                            .copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                      Text(
                                        "This will delete all your data from our servers, and you will not be able to recover it.",
                                        style: context.theme.baseTextStyle,
                                      ),
                                      GappedRow(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        gap: 8.0,
                                        children: [
                                          Button.outline(
                                            onPressed: () {
                                              Navigator.of(context).pop(false);
                                            },
                                            children: const [Text("Cancel")],
                                          ),
                                          Button.destructive(
                                            onPressed: () {
                                              Navigator.of(context).pop(true);
                                            },
                                            children: const [Text("Confirm")],
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                      children: const [
                        Text("Open confirm sheet"),
                      ],
                    ),
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
                    children: const [Text("Open confirm dialog")],
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
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FileDropZone(
                        onFiles: (paths) {
                          print(paths);
                        },
                        allowMultiple: true,
                        allowedExtensions: const [".png", ".jpg", ".jpeg"],
                      ),
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

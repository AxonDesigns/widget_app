import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';
import 'package:widget_app/components/bottom_sheet/sheet_controller.dart';
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
  int _selectedIndex3 = 0;

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
                              text: "Does not",
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
                  SelectInput(
                    expanded: true,
                    selectedIndex: _selectedIndex3,
                    onItemSelected: (index) {
                      setState(() {
                        _selectedIndex3 = index;
                      });
                    },
                    items: List.generate(
                      25,
                      (index) {
                        return Option(
                          icon: const Icon(LucideIcons.user),
                          text: "Option $index",
                        );
                      },
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
                        Text("About Page"),
                      ],
                    ),
                  ),
                  Tooltip(
                    message: "This button opens a bottom sheet",
                    child: Button.primary(
                      onPressed: () async {
                        final result = await Navigator.of(context).push<bool>(
                          GenericSheetRoute(
                            barrierDismissible: true,
                            draggable: true,
                            barrierColor:
                                context.theme.backgroundColor.withOpacity(0.5),
                            builder: (context) {
                              return SheetContainer(
                                child: GappedColumn(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  gap: 16.0,
                                  children: [
                                    Text(
                                      "Are you absolutely sure?",
                                      style:
                                          context.theme.baseTextStyle.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                    Text(
                                      "This will delete all your data from our servers, and you will not be able to recover it.",
                                      style: context.theme.baseTextStyle,
                                    ),
                                    const SizedBox(height: 16),
                                    Button.destructive(
                                      onPressed: () {
                                        Navigator.of(context).pop(true);
                                      },
                                      children: const [Text("Confirm")],
                                    ),
                                    Button.outline(
                                      onPressed: () {
                                        Navigator.of(context).pop(false);
                                      },
                                      children: const [Text("Cancel")],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        );
                        print(result);
                      },
                      children: const [
                        Text("Open confirm sheet"),
                      ],
                    ),
                  ),
                  Button.destructive(
                    children: const [Text("Do some crazy SHEET")],
                    onPressed: () {
                      _showCustomSheet(context);
                    },
                  ),
                  Button.glass(
                    onPressed: () async {
                      final result = await context.showConfirmDialog(
                        title: "Are you absolutely sure?",
                        content:
                            "This will delete all your data from our servers, "
                            "and you will not be able to recover it.",
                        type: ConfirmDialogType.destructive,
                        confirmButtonText: "Confirm",
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

  void _showCustomSheet(BuildContext context) {
    Navigator.of(context).push(GenericModalRoute(
      modalTransitionBuilder: (context, animation, child) {
        return child;
      },
      builder: (context) {
        return BottomSheet(
          maxHeightFactor: 1.0,
          builder: (context) => ListView.builder(
            padding: EdgeInsets.zero,
            controller: SheetController.of(context).scrollController,
            itemCount: 100,
            itemBuilder: (context, index) {
              return Button.custom(
                backgroundColor: WidgetStateColor.resolveWith(
                  (states) {
                    var value = 1.0;
                    if (states.contains(WidgetState.hovered)) {
                      value = 0.9;
                    }

                    if (states.contains(WidgetState.pressed)) {
                      value = 0.8;
                    }
                    return HSVColor.fromAHSV(
                      1.0,
                      index.toDouble().wrap(0, 14).remap(0, 14, 0, 360),
                      0.7,
                      value,
                    ).toColor();
                  },
                ),
                borderColor: WidgetStateColor.resolveWith(
                  (states) {
                    return Colors.transparent;
                  },
                ),
                foregroundColor: WidgetStateColor.resolveWith(
                  (states) {
                    return HSVColor.fromAHSV(
                      1.0,
                      (index + 7).toDouble().wrap(0, 14).remap(0, 14, 0, 360),
                      0.7,
                      1.0,
                    ).toColor();
                  },
                ),
                borderRadius: 0,
                onPressed: () {},
                children: [Text("Item #${index + 1}")],
              );
            },
          ),
        );
      },
    ));
  }
}

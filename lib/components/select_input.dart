import 'dart:ui';

import 'package:flutter/material.dart' show Scaffold, AppBar, DefaultMaterialLocalizations;
import 'package:flutter/services.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:sheet/sheet.dart';
import 'package:widget_app/generic.dart';

class SelectInput extends StatefulWidget {
  const SelectInput({
    super.key,
    required this.items,
    this.selectedIndex = -1,
    this.onItemSelected,
    this.expanded = false,
    this.focusNode,
  });

  final List<Option> items;
  final int selectedIndex;
  final Function(int index)? onItemSelected;
  final bool expanded;
  final FocusNode? focusNode;

  @override
  State<SelectInput> createState() => _SelectInputState();
}

class _SelectInputState extends State<SelectInput> {
  var hovered = false;
  var pressed = false;
  var focused = false;
  var _popupOpened = false;

  bool get enabled => true;
  late FocusNode _focusNode;
  late LayerLink _layerLink;

  final _duration = const Duration(milliseconds: 200);

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _setUpFocusNode(_focusNode);
    _layerLink = LayerLink();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant SelectInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusNode != null && oldWidget.focusNode == null) {
      _disposeFocusNode(_focusNode);
      _focusNode = widget.focusNode!;
      _setUpFocusNode(_focusNode);
    }

    if (widget.focusNode == null && oldWidget.focusNode != null) {
      _disposeFocusNode(oldWidget.focusNode!);
      _focusNode = FocusNode();
      _setUpFocusNode(_focusNode);
    }
  }

  void _handleFocusChange() {
    setState(() {});
  }

  void _setUpFocusNode(FocusNode node) {
    node.addListener(_handleFocusChange);
    node.onKeyEvent = (node, event) {
      if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.escape) {
        node.unfocus();
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    };
  }

  void _disposeFocusNode(FocusNode node) {
    node.removeListener(_handleFocusChange);
    node.dispose();
  }

  void _openOverlay() {
    if (_popupOpened) return;

    _focusNode.requestFocus();

    Navigator.of(context)
        .push(
      GenericSheetRoute(
        fit: SheetFit.expand,
        barrierDismissible: true,
        initialExtent: 0.5,
        draggable: true,
        stops: [0.0, 0.5, 0.9],
        physics: const BouncingSheetPhysics(
          overflowViewport: true,
        ),
        builder: (context) {
          return SheetContainer(
              padding: EdgeInsets.zero,
              handleSpacing: 0.0,
              child: SafeArea(
                bottom: false,
                top: false,
                child: ListView.builder(
                  shrinkWrap: true,
                  primary: true,
                  padding: EdgeInsets.zero,
                  physics: const BouncingScrollPhysics(),
                  itemCount: widget.items.length,
                  itemBuilder: (context, index) {
                    return _Option(
                      item: widget.items[index],
                      selected: widget.selectedIndex == index,
                      index: index,
                      onPressed: (idx) {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context, idx);
                        }
                      },
                    );
                  },
                ),
              ));
        },
      ),
    )
        .then(
      (index) {
        _focusNode.unfocus();
        if (index != null && widget.selectedIndex != index) {
          widget.onItemSelected?.call(index);
        }
        setState(() => _popupOpened = false);
      },
    );

    setState(() => _popupOpened = true);
  }

  void _closeOverlay() {
    if (!_popupOpened) return;
    Navigator.of(context).pop();
    _focusNode.unfocus();
    setState(() {
      _popupOpened = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TapRegion(
      groupId: SelectInput,
      child: CompositedTransformTarget(
        link: _layerLink,
        child: FocusableActionDetector(
          focusNode: _focusNode,
          onFocusChange: (value) => setState(() => focused = value),
          onShowHoverHighlight: (value) => setState(() => hovered = value),
          shortcuts: {
            LogicalKeySet(LogicalKeyboardKey.enter): const ButtonActivateIntent(),
          },
          actions: {
            ButtonActivateIntent: CallbackAction<ButtonActivateIntent>(
              onInvoke: (intent) {
                if (_popupOpened) {
                  _closeOverlay();
                } else {
                  _openOverlay();
                }
                return null;
              },
            ),
          },
          child: GestureDetector(
            onTap: () {
              if (_popupOpened) {
                _closeOverlay();
              } else {
                _openOverlay();
              }
            },
            child: InputContainer(
              hovered: hovered,
              pressed: pressed,
              focused: focused || _popupOpened,
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 10.0 : 14.0,
                vertical: isDesktop ? 9.0 : 16.0,
              ),
              child: GappedRow(
                gap: 4.0,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    flex: widget.expanded ? 1 : 0,
                    child: IndexedStack(
                      index: widget.selectedIndex + 1,
                      children: [
                        const Text("Pick an option..."),
                        ...widget.items.map<Widget>((item) {
                          return GappedRow(
                            mainAxisSize: MainAxisSize.min,
                            gap: 4.0,
                            children: [
                              if (item.icon != null) item.icon!,
                              Text(item.text),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                  Icon(
                    LucideIcons.chevrons_up_down,
                    color: context.theme.foregroundColor.withOpacity(0.5),
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

class Option {
  const Option({
    required this.text,
    this.icon,
    this.onPressed,
  });

  final Widget? icon;
  final String text;
  final void Function(int index)? onPressed;
}

class _SelectOverlay extends StatelessWidget {
  const _SelectOverlay({
    super.key,
    required this.items,
    required this.width,
    required this.selectedIndex,
  });

  final List<Option> items;
  final double width;
  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Card(
      padding: const EdgeInsets.all(4.0),
      elevation: 8.0,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: 250.0,
          maxWidth: width,
          minWidth: width,
        ),
        child: _buildList(
          items.indexed.map((e) {
            final (index, item) = e;

            return _Option(
              item: item,
              selected: selectedIndex == index,
              index: index,
              onPressed: (idx) {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context, idx);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildList(List<Widget> children) {
    final content = GappedColumn(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      gap: 4.0,
      children: children,
    );

    return SingleChildScrollView(
      child: content,
    );
  }
}

class _Option extends StatefulWidget {
  const _Option({
    super.key,
    required this.item,
    required this.index,
    required this.onPressed,
    required this.selected,
  });

  final Option item;
  final bool selected;
  final int index;
  final void Function(int index) onPressed;

  @override
  State<_Option> createState() => _OptionState();
}

class _OptionState extends State<_Option> {
  @override
  void initState() {
    super.initState();
    if (!widget.selected) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Scrollable.ensureVisible(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.selected ? context.theme.foregroundColor.withOpacity(0.1) : Colors.transparent,
        border: Border(
          bottom: BorderSide(
            color: context.theme.foregroundColor.withOpacity(0.1),
          ),
        ),
      ),
      child: _buildButton(
        context,
        autofocus: widget.selected,
      ),
    );
  }

  Widget _buildButton(BuildContext context, {bool autofocus = false}) {
    return Button.ghost(
      autofocus: autofocus,
      alignment: MainAxisAlignment.start,
      borderRadius: 0.0,
      onPressed: () {
        widget.onPressed.call(widget.index);
        widget.item.onPressed?.call(widget.index);
      },
      children: [
        if (widget.item.icon != null) widget.item.icon!,
        Text(widget.item.text),
      ],
    );
  }
}

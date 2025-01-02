import 'package:flutter/services.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:widget_app/components/pass_through_route.dart';
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
  var opened = false;

  var _popupOpened = false;

  bool get enabled => true;
  late FocusNode _focusNode;
  late LayerLink _layerLink;

  final _duration = const Duration(milliseconds: 150);

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

    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    Navigator.of(context).push(
      PassThroughRoute(
        transitionDuration: _duration,
        onPopCallback: () {
          if (_popupOpened && !hovered) {
            _closeOverlay();
          }
        },
        builder: (context, animation, secondaryAnimation) {
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.fastEaseInToSlowEaseOut,
          );
          return Stack(
            children: [
              Positioned(
                left: 0,
                top: 0,
                width: size.width,
                child: CompositedTransformFollower(
                  link: _layerLink,
                  followerAnchor: Alignment.topCenter,
                  targetAnchor: Alignment.bottomCenter,
                  offset: const Offset(0, 4),
                  child: TapRegion(
                    groupId: SelectInput,
                    child: FadeTransition(
                      opacity: curvedAnimation,
                      child: SlideTransition(
                        position: Tween(begin: const Offset(0, -0.1), end: Offset.zero).animate(curvedAnimation),
                        child: _SelectOverlay(
                          items: widget.items,
                          selectedIndex: widget.selectedIndex,
                          opened: opened,
                          onItemSelected: (index) {
                            if (_popupOpened) {
                              _closeOverlay();
                            }
                            widget.onItemSelected?.call(index);
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
    setState(() {
      _popupOpened = true;
    });
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
      onTapOutside: (event) {
        if (isDesktop) {
          if (_popupOpened) {
            //_closeOverlay();
          }
          _focusNode.unfocus();
        }
      },
      child: CompositedTransformTarget(
        link: _layerLink,
        child: FocusableActionDetector(
          focusNode: _focusNode,
          onFocusChange: (value) => setState(() => focused = value),
          onShowHoverHighlight: (value) => setState(() => hovered = value),
          //descendantsAreFocusable: false,
          //descendantsAreTraversable: false,
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

class _SelectOverlay extends StatefulWidget {
  const _SelectOverlay({
    super.key,
    required this.items,
    required this.selectedIndex,
    this.opened = false,
    this.onItemSelected,
  });

  final List<Option> items;
  final int selectedIndex;
  final bool opened;
  final Function(int index)? onItemSelected;

  @override
  State<_SelectOverlay> createState() => _SelectOverlayState();
}

class _SelectOverlayState extends State<_SelectOverlay> {
  final scrollController = ScrollController();

  bool get isScrollable {
    if (!scrollController.hasClients) return false;

    return scrollController.position.minScrollExtent != scrollController.position.maxScrollExtent;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      padding: const EdgeInsets.all(4.0),
      elevation: 8.0,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxHeight: 250.0,
        ),
        child: _buildList(
          widget.items.indexed.map((e) {
            final (index, item) = e;
            return _Option(
              item: item,
              selected: widget.selectedIndex == index,
              index: index,
              onPressed: (idx) {
                widget.onItemSelected?.call(idx);
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!widget.selected) return;
      Scrollable.ensureVisible(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.selected) {
      return Container(
        decoration: BoxDecoration(
          color: context.theme.foregroundColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(context.theme.radiusSize),
        ),
        child: _buildButton(
          context,
          autofocus: widget.selected,
        ),
      );
    }

    return _buildButton(context);
  }

  Widget _buildButton(BuildContext context, {bool autofocus = false}) {
    return Button.ghost(
      autofocus: autofocus,
      alignment: MainAxisAlignment.start,
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

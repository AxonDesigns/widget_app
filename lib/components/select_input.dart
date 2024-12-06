import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
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

  final List<SelectItem> items;
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
  bool get enabled => true;
  late FocusNode _focusNode;
  late LayerLink _layerLink;
  OverlayEntry? _overlayEntry;
  Timer? _timer;

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
    setState(() {
      focused = _focusNode.hasFocus;
      if (focused) {
        _openOverlay();
      } else {
        _closeOverlay();
      }
    });
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
    if (_timer != null) {
      _timer!.cancel();
      _timer = null;
    }
    _destroyOverlay();

    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
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
            child: _SelectOverlay(
              items: widget.items,
              selectedIndex: widget.selectedIndex,
              duration: _duration,
              opened: opened,
              onItemSelected: (index) {
                _focusNode.unfocus();
                widget.onItemSelected?.call(index);
              },
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_overlayEntry == null) return;
      setState(() => opened = true);
      _overlayEntry!.markNeedsBuild();
    });
  }

  void _closeOverlay() {
    _timer = Timer(_duration, () {
      _destroyOverlay();
      _timer = null;
    });
    setState(() => opened = false);
    _overlayEntry?.markNeedsBuild();
  }

  void _destroyOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return TapRegion(
      groupId: SelectInput,
      onTapOutside: (event) {
        if (isDesktop) {
          //FocusScope.of(context).requestFocus(FocusNode());
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
          child: GestureDetector(
            onTap: () {
              if (!_focusNode.hasFocus) {
                FocusScope.of(context).requestFocus(_focusNode);
              } else {
                _focusNode.unfocus();
              }
            },
            child: InputContainer(
              hovered: hovered,
              pressed: pressed,
              focused: focused,
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

class SelectItem {
  const SelectItem({
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
    required this.duration,
    this.opened = false,
    this.onItemSelected,
  });

  final List<SelectItem> items;
  final int selectedIndex;
  final Duration duration;
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
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _SelectOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      duration: widget.duration,
      curve: Curves.fastEaseInToSlowEaseOut,
      offset: Offset(0, widget.opened ? 0.0 : -0.05),
      child: AnimatedOpacity(
        duration: widget.duration,
        curve: Curves.fastEaseInToSlowEaseOut,
        opacity: widget.opened ? 1.0 : 0.0,
        child: Card(
          padding: const EdgeInsets.all(4.0),
          elevation: 8.0,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxHeight: 250.0,
            ),
            child: ListView.separated(
              controller: scrollController,
              shrinkWrap: !isScrollable,
              padding: EdgeInsets.zero,
              itemCount: widget.items.length,
              separatorBuilder: (context, index) {
                return const SizedBox(height: 4.0);
              },
              itemBuilder: (context, index) {
                return _SelectItem(
                  item: widget.items[index],
                  selected: widget.selectedIndex == index,
                  index: index,
                  onPressed: (index) {
                    widget.onItemSelected?.call(index);
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectItem extends StatelessWidget {
  const _SelectItem({
    super.key,
    required this.item,
    required this.index,
    required this.onPressed,
    required this.selected,
  });

  final SelectItem item;
  final bool selected;
  final int index;
  final void Function(int index) onPressed;

  @override
  Widget build(BuildContext context) {
    if (selected) {
      return Container(
        decoration: BoxDecoration(
          color: context.theme.foregroundColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(context.theme.radiusSize),
        ),
        child: _buildButton(context),
      );
    }

    return _buildButton(context);
  }

  Widget _buildButton(BuildContext context) {
    return Button.ghost(
      alignment: MainAxisAlignment.start,
      onPressed: () {
        onPressed.call(index);
        item.onPressed?.call(index);
      },
      children: [
        if (item.icon != null) item.icon!,
        Text(item.text),
      ],
    );
  }
}

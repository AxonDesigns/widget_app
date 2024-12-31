import 'package:flutter/services.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:widget_app/components/pass_through_route.dart';
import 'package:widget_app/generic.dart';

class SelectInputNavigator extends StatefulWidget {
  const SelectInputNavigator({
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
  State<SelectInputNavigator> createState() => _SelectInputNavigatorState();
}

class _SelectInputNavigatorState extends State<SelectInputNavigator> {
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
  void didUpdateWidget(covariant SelectInputNavigator oldWidget) {
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
      if (event is KeyDownEvent &&
          event.logicalKey == LogicalKeyboardKey.escape) {
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
                    groupId: SelectInputNavigator,
                    child: FadeTransition(
                      opacity: curvedAnimation,
                      child: SlideTransition(
                        position: Tween(
                                begin: const Offset(0, 0.05), end: Offset.zero)
                            .animate(curvedAnimation),
                        child: SelectOverlay(
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
    setState(() {
      _popupOpened = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TapRegion(
      groupId: SelectInputNavigator,
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

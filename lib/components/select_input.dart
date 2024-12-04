import 'package:flutter/services.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:widget_app/generic.dart';

class SelectInput extends StatefulWidget {
  const SelectInput({
    super.key,
    this.focusNode,
  });

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

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _setUpFocusNode(_focusNode);
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
      if (!focused) {
        opened = false;
      }
    });
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
      child: FocusableActionDetector(
        focusNode: _focusNode,
        onFocusChange: (value) => setState(() => focused = value),
        onShowHoverHighlight: (value) => setState(() => hovered = value),
        descendantsAreFocusable: false,
        descendantsAreTraversable: false,
        child: GestureDetector(
          onTap: () {
            setState(() => opened = !opened);
            if (opened) {
              FocusScope.of(context).requestFocus(_focusNode);
            } else {
              _focusNode.unfocus();
            }
          },
          child: InputContainer(
            hovered: hovered,
            pressed: pressed,
            focused: focused,
            child: Row(
              children: [
                const Expanded(child: Text("Pick an option...")),
                Icon(
                  LucideIcons.chevrons_up_down,
                  color: context.theme.foregroundColor.withOpacity(0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

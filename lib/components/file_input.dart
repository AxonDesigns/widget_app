import 'package:desktop_drop/desktop_drop.dart';
import 'package:widget_app/components/link.dart';
import 'package:widget_app/generic.dart';
import 'package:dotted_border/dotted_border.dart';

class FileInput extends StatefulWidget {
  const FileInput({
    super.key,
    this.onDropped,
  });

  final Function(List<String> filePaths)? onDropped;

  @override
  State<FileInput> createState() => _FileInputState();
}

class _FileInputState extends State<FileInput> {
  var _dragging = false;

  @override
  Widget build(BuildContext context) {
    return DropTarget(
      onDragEntered: (details) {
        setState(() {
          _dragging = true;
        });
      },
      onDragExited: (details) {
        setState(() {
          _dragging = false;
        });
      },
      onDragDone: (details) {
        widget.onDropped?.call(details.files.map((e) => e.path).toList());
      },
      child: _buildWidget(context),
    );
  }

  Widget _buildWidget(BuildContext context) {
    return DottedBorder(
      color: context.theme.primaryColor.withOpacity(0.5),
      borderType: BorderType.RRect,
      radius: Radius.circular(context.theme.radiusSize),
      dashPattern: const [6, 4],
      strokeWidth: 1.5,
      padding: EdgeInsets.zero,
      borderPadding: const EdgeInsets.all(0.75),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.fastEaseInToSlowEaseOut,
        decoration: BoxDecoration(
          color: context.theme.primaryColor.withOpacity(_dragging ? 1.0 : 0.1),
          borderRadius: BorderRadius.circular(context.theme.radiusSize),
        ),
        padding: const EdgeInsets.all(12),
        child: IndexedStack(
          index: _dragging ? 1 : 0,
          alignment: Alignment.center,
          children: [
            RichText(
              text: TextSpan(
                text: "Drag and drop or ",
                style: context.theme.baseTextStyle,
                children: [
                  WidgetSpan(
                    child: Link(
                      text: "browse",
                      onTap: () {
                        print("Choose file");
                      },
                    ),
                    alignment: PlaceholderAlignment.middle,
                  ),
                ],
              ),
            ),
            const Text("Drop file here"),
          ],
        ),
      ),
    );
  }
}

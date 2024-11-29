import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';
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
    return _buildWidget(context);
  }

  Widget _buildWidget(BuildContext context) {
    return DropRegion(
      formats: Formats.standardFormats,
      onDropOver: (event) {
        return DropOperation.copy;
      },
      onDropEnter: (p0) {
        setState(() {
          _dragging = true;
        });
      },
      onDropLeave: (p0) {
        setState(() {
          _dragging = false;
        });
      },
      onPerformDrop: (event) async {
        final items = event.session.items;
        if (items.isEmpty) return;

        final reader = items.first.dataReader;
        if (reader == null) return;
        reader.getValue(Formats.fileUri, (value) {
          if (value == null) return;
          print(value.toFilePath(windows: Platform.isWindows));
        });
      },
      child: DottedBorder(
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
            color:
                context.theme.primaryColor.withOpacity(_dragging ? 1.0 : 0.1),
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
                        onTap: () async {
                          final result = await FilePicker.platform.pickFiles(
                            allowMultiple: false,
                            type: FileType.any,
                          );
                          if (result != null) {
                            print(result.files.single.path);
                          }
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
      ),
    );
  }
}

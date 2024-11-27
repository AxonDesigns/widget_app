import 'package:flutter/widgets.dart';
import 'package:widget_app/generic.dart';
import 'package:dotted_border/dotted_border.dart';

class FileInput extends StatefulWidget {
  const FileInput({super.key});

  @override
  State<FileInput> createState() => _FileInputState();
}

class _FileInputState extends State<FileInput> {
  @override
  Widget build(BuildContext context) {
    return DottedBorder(
      color: context.theme.foregroundColor.withOpacity(0.1),
      borderType: BorderType.RRect,
      radius: Radius.circular(context.theme.radiusSize),
      dashPattern: const [6, 6],
      strokeWidth: 1,
      child: Container(
        decoration: const BoxDecoration(),
        padding: const EdgeInsets.all(12),
        child: const Text("Drag and drop a file here"),
      ),
    );
  }
}

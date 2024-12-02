import 'package:flutter/widgets.dart';

class FileInput extends StatefulWidget {
  const FileInput({
    super.key,
    required this.files,
    this.onFiles,
    this.allowedExtensions,
  });

  final List<String> files;
  final Function(List<String>)? onFiles;
  final List<String>? allowedExtensions;

  @override
  State<FileInput> createState() => _FileInputState();
}

class _FileInputState extends State<FileInput> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
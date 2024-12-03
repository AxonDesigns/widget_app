import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';
import 'package:widget_app/components/link.dart';
import 'package:widget_app/generic.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:path/path.dart' as p;

class FileDropZone extends StatefulWidget {
  const FileDropZone({
    super.key,
    this.onDropped,
    this.onPicked,
    this.onFiles,
    this.allowedExtensions,
    this.allowMultiple = false,
    this.expanded = false,
    this.footer,
  });

  /// Tells native file picker if multi-selection should be available.
  final bool allowMultiple;

  /// Called when files are dropped.
  final Function(List<String> filePaths)? onDropped;

  /// Called when files are picked using the native file picker dialog.
  final Function(List<String> filePaths)? onPicked;

  /// Called when either files are dropped or picked.
  final Function(List<String> filePaths)? onFiles;

  /// Specify which file extensions can be dropped or picked.<br>
  /// If null, all files are allowed. If empty, any files are allowed.<br>
  /// e.g.
  /// ```dart
  /// const [".png", ".jpg", ".jpeg"]
  /// ```
  final List<String>? allowedExtensions;

  final bool expanded;

  final Widget? footer;

  @override
  State<FileDropZone> createState() => _FileDropZoneState();
}

class _FileDropZoneState extends State<FileDropZone> {
  var _hovering = false;
  var _picking = false;

  @override
  Widget build(BuildContext context) {
    return GappedColumn(
      gap: 4.0,
      children: [
        _buildWidget(context),
        if (widget.footer != null) widget.footer!,
      ],
    );
  }

  Widget _buildWidget(BuildContext context) {
    return DropRegion(
      formats: const [],
      onDropOver: _onDropOver,
      onDropEnter: (_) {
        setState(() {
          _hovering = true;
        });
      },
      onDropLeave: (_) {
        setState(() {
          _hovering = false;
        });
      },
      onPerformDrop: _onPerformDrop,
      child: DottedBorder(
        color: context.theme.primaryColor.withOpacity(0.5),
        borderType: BorderType.RRect,
        radius: Radius.circular(context.theme.radiusSize),
        dashPattern: const [6, 4],
        strokeWidth: 1.5,
        padding: EdgeInsets.zero,
        borderPadding: const EdgeInsets.all(0.75),
        child: AnimatedContainer(
          duration: Duration(milliseconds: _hovering ? 0 : 200),
          curve: Curves.fastEaseInToSlowEaseOut,
          decoration: BoxDecoration(
            color:
                context.theme.primaryColor.withOpacity(_hovering ? 1.0 : 0.1),
            borderRadius: BorderRadius.circular(context.theme.radiusSize),
          ),
          padding: EdgeInsets.all(isDesktop ? 16 : 18),
          child: IndexedStack(
            index: _hovering ? 1 : 0,
            alignment: Alignment.center,
            children: [
              GappedColumn(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                gap: 4.0,
                children: [
                  Icon(
                    LucideIcons.upload,
                    size: 20,
                    color: context.theme.foregroundColor.withOpacity(0.5),
                  ),
                  RichText(
                    maxLines: 1,
                    overflow: TextOverflow.visible,
                    text: TextSpan(
                      text: "Drag and drop or ",
                      style: context.theme.baseTextStyle,
                      children: [
                        WidgetSpan(
                          child: Link(
                            text: "browse",
                            onTap: _onBrowse,
                          ),
                          alignment: PlaceholderAlignment.middle,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              GappedRow(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                gap: 4.0,
                children: [
                  const Icon(
                    LucideIcons.plus,
                    size: 16,
                  ),
                  Text(
                    "Drop file here",
                    style: context.theme.baseTextStyle.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onBrowse() async {
    setState(() {
      _picking = true;
    });
    final extensions =
        widget.allowedExtensions?.map((e) => e.replaceAll(".", "")).toList();
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: widget.allowMultiple,
      type: FileType.custom,
      lockParentWindow: true,
      allowedExtensions: extensions,
    );
    if (result != null) {
      print(result.files.first.path);
      widget.onPicked?.call(
        result.files.map((e) => e.path ?? "").toList(),
      );
      widget.onFiles?.call(
        result.files.map((e) => e.path ?? "").toList(),
      );
    }

    setState(() {
      _picking = false;
    });
  }

  Future<void> _onPerformDrop(PerformDropEvent event) async {
    final items = event.session.items;
    if (items.isEmpty) return;
    final paths = <String>[];

    final completer = Completer();
    int count = 0;
    for (var item in items) {
      final reader = item.dataReader;
      if (reader == null) continue;
      reader.getValue(Formats.fileUri, (value) {
        if (value == null) return;
        final path = value.toFilePath(windows: Platform.isWindows);

        final isNull = widget.allowedExtensions == null;
        final isAllowed = widget.allowedExtensions != null &&
            widget.allowedExtensions!.contains(p.extension(path));

        if (isNull || isAllowed) {
          paths.add(path);
        }
        count++;

        if (count >= items.length && !completer.isCompleted) {
          completer.complete();
        }
      });
    }

    await completer.future;
    final result = widget.allowMultiple ? paths : [paths.first];
    widget.onDropped?.call(result);
    widget.onFiles?.call(result);
  }

  FutureOr<DropOperation> _onDropOver(DropOverEvent event) async {
    if (_picking) return DropOperation.none;
    final items = event.session.items;

    if (items.isEmpty) return DropOperation.none;

    bool allowed = false;
    final completer = Completer();
    for (var item in items) {
      final reader = item.dataReader;
      if (reader == null) continue;

      reader.getValue(Formats.fileUri, (value) {
        if (value == null) return;
        final path = value.toFilePath(windows: Platform.isWindows);
        final extension = p.extension(path);

        final isNull = widget.allowedExtensions == null;
        final isAllowed = widget.allowedExtensions != null &&
            widget.allowedExtensions!.contains(extension);

        if (isNull || isAllowed) {
          allowed = true;
          if (!completer.isCompleted) {
            completer.complete();
          }
          return;
        }
      });
    }

    await completer.future;
    return allowed ? DropOperation.copy : DropOperation.none;
  }
}

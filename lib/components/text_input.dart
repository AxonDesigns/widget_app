import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' as material
    show
        Material,
        TextField,
        DefaultMaterialLocalizations,
        InputDecoration,
        InputBorder,
        Theme,
        ThemeData,
        AdaptiveTextSelectionToolbar,
        TextSelectionThemeData;
import 'package:flutter/services.dart';
import 'package:widget_app/generic.dart';

/// Displays a text input.
/// The text input can be configured to have a prefix, suffix, and a background color.
class TextInput extends StatefulWidget {
  const TextInput({
    super.key,
    this.controller,
    this.focusNode,
    this.undoController,
    TextInputType? keyboardType,
    this.prefix,
    this.suffix,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.style,
    this.strutStyle,
    this.textAlign = TextAlign.start,
    this.textAlignVertical,
    this.textDirection,
    this.readOnly = false,
    this.showCursor,
    this.autofocus = false,
    this.obscuringCharacter = '•',
    this.obscureText = false,
    this.autocorrect = true,
    SmartDashesType? smartDashesType,
    SmartQuotesType? smartQuotesType,
    this.enableSuggestions = true,
    this.maxLines = 1,
    this.minLines,
    this.expands = false,
    this.maxLength,
    this.maxLengthEnforcement,
    this.onChanged,
    this.onEditingComplete,
    this.onSubmitted,
    this.onAppPrivateCommand,
    this.inputFormatters,
    this.enabled,
    this.ignorePointers,
    this.cursorWidth = 2.0,
    this.cursorHeight,
    this.cursorRadius,
    this.cursorOpacityAnimates,
    this.cursorColor,
    this.cursorErrorColor,
    this.keyboardAppearance,
    this.scrollPadding = const EdgeInsets.all(20.0),
    this.dragStartBehavior = DragStartBehavior.start,
    bool? enableInteractiveSelection,
    this.contextMenuBuilder,
    this.buildCounter,
    //this.enableInteractiveSelection = true,
    this.selectionControls,
    this.onTap,
    this.onTapAlwaysCalled = false,
    this.onTapOutside,
    this.mouseCursor,
    this.scrollController,
    this.scrollPhysics,
    this.autofillHints = const <String>[],
    this.contentInsertionConfiguration,
    this.clipBehavior = Clip.hardEdge,
    this.scribbleEnabled = true,
    this.enableIMEPersonalizedLearning = true,
    this.canRequestFocus = true,
    this.spellCheckConfiguration,
    this.magnifierConfiguration,
    this.restorationId,
    this.backgroundColor,
  })  : enableInteractiveSelection =
            enableInteractiveSelection ?? (!readOnly || !obscureText),
        keyboardType = keyboardType ??
            (maxLines == 1 ? TextInputType.text : TextInputType.multiline),
        smartDashesType = smartDashesType ??
            (obscureText ? SmartDashesType.disabled : SmartDashesType.enabled),
        smartQuotesType = smartQuotesType ??
            (obscureText ? SmartQuotesType.disabled : SmartQuotesType.enabled);

  /// The magnifier configuration to use for the text input.
  final TextMagnifierConfiguration? magnifierConfiguration;

  /// Controls the text being edited.
  ///
  /// If null, this widget will create its own [TextEditingController].
  final TextEditingController? controller;

  /// Defines the keyboard focus for this widget.
  ///
  /// The [focusNode] is a long-lived object that's typically managed by a
  /// [StatefulWidget] parent. See [FocusNode] for more information.
  ///
  /// To give the keyboard focus to this widget, provide a [focusNode] and then
  /// use the current [FocusScope] to request the focus:
  ///
  /// ```dart
  /// FocusScope.of(context).requestFocus(myFocusNode);
  /// ```
  ///
  /// This happens automatically when the widget is tapped.
  ///
  /// To be notified when the widget gains or loses the focus, add a listener
  /// to the [focusNode]:
  ///
  /// ```dart
  /// myFocusNode.addListener(() { print(myFocusNode.hasFocus); });
  /// ```
  ///
  /// If null, this widget will create its own [FocusNode].
  ///
  /// ## Keyboard
  ///
  /// Requesting the focus will typically cause the keyboard to be shown
  /// if it's not showing already.
  ///
  /// On Android, the user can hide the keyboard - without changing the focus -
  /// with the system back button. They can restore the keyboard's visibility
  /// by tapping on a text field. The user might hide the keyboard and
  /// switch to a physical keyboard, or they might just need to get it
  /// out of the way for a moment, to expose something it's
  /// obscuring. In this case requesting the focus again will not
  /// cause the focus to change, and will not make the keyboard visible.
  ///
  /// This widget builds an [EditableText] and will ensure that the keyboard is
  /// showing when it is tapped by calling [EditableTextState.requestKeyboard()].
  final FocusNode? focusNode;

  /// {@macro flutter.widgets.editableText.keyboardType}
  final TextInputType keyboardType;

  /// {@template flutter.widgets.TextField.textInputAction}
  /// The type of action button to use for the keyboard.
  ///
  /// Defaults to [TextInputAction.newline] if [keyboardType] is
  /// [TextInputType.multiline] and [TextInputAction.done] otherwise.
  /// {@endtemplate}
  final TextInputAction? textInputAction;

  /// {@macro flutter.widgets.editableText.textCapitalization}
  final TextCapitalization textCapitalization;

  /// The style to use for the text being edited.
  ///
  /// This text style is also used as the base style for the [decoration].
  ///
  /// If null, [TextTheme.bodyLarge] will be used. When the text field is disabled,
  /// [TextTheme.bodyLarge] with an opacity of 0.38 will be used instead.
  ///
  /// If null and [ThemeData.useMaterial3] is false, [TextTheme.titleMedium] will
  /// be used. When the text field is disabled, [TextTheme.titleMedium] with
  /// [ThemeData.disabledColor] will be used instead.
  final TextStyle? style;

  /// {@macro flutter.widgets.editableText.strutStyle}
  final StrutStyle? strutStyle;

  /// {@macro flutter.widgets.editableText.textAlign}
  final TextAlign textAlign;

  /// {@macro flutter.material.InputDecorator.textAlignVertical}
  final TextAlignVertical? textAlignVertical;

  /// {@macro flutter.widgets.editableText.textDirection}
  final TextDirection? textDirection;

  /// {@macro flutter.widgets.editableText.autofocus}
  final bool autofocus;

  /// {@macro flutter.widgets.editableText.obscuringCharacter}
  final String obscuringCharacter;

  /// {@macro flutter.widgets.editableText.obscureText}
  final bool obscureText;

  /// {@macro flutter.widgets.editableText.autocorrect}
  final bool autocorrect;

  /// {@macro flutter.services.TextInputConfiguration.smartDashesType}
  final SmartDashesType smartDashesType;

  /// {@macro flutter.services.TextInputConfiguration.smartQuotesType}
  final SmartQuotesType smartQuotesType;

  /// {@macro flutter.services.TextInputConfiguration.enableSuggestions}
  final bool enableSuggestions;

  /// {@macro flutter.widgets.editableText.maxLines}
  ///  * [expands], which determines whether the field should fill the height of
  ///    its parent.
  final int? maxLines;

  /// {@macro flutter.widgets.editableText.minLines}
  ///  * [expands], which determines whether the field should fill the height of
  ///    its parent.
  final int? minLines;

  /// {@macro flutter.widgets.editableText.expands}
  final bool expands;

  /// {@macro flutter.widgets.editableText.readOnly}
  final bool readOnly;

  /// {@macro flutter.widgets.editableText.showCursor}
  final bool? showCursor;

  /// If [maxLength] is set to this value, only the "current input length"
  /// part of the character counter is shown.
  static const int noMaxLength = -1;

  /// The maximum number of characters (Unicode grapheme clusters) to allow in
  /// the text field.
  ///
  /// If set, a character counter will be displayed below the
  /// field showing how many characters have been entered. If set to a number
  /// greater than 0, it will also display the maximum number allowed. If set
  /// to [TextField.noMaxLength] then only the current character count is displayed.
  ///
  /// After [maxLength] characters have been input, additional input
  /// is ignored, unless [maxLengthEnforcement] is set to
  /// [MaxLengthEnforcement.none].
  ///
  /// The text field enforces the length with a [LengthLimitingTextInputFormatter],
  /// which is evaluated after the supplied [inputFormatters], if any.
  ///
  /// This value must be either null, [TextField.noMaxLength], or greater than 0.
  /// If null (the default) then there is no limit to the number of characters
  /// that can be entered. If set to [TextField.noMaxLength], then no limit will
  /// be enforced, but the number of characters entered will still be displayed.
  ///
  /// Whitespace characters (e.g. newline, space, tab) are included in the
  /// character count.
  ///
  /// If [maxLengthEnforcement] is [MaxLengthEnforcement.none], then more than
  /// [maxLength] characters may be entered, but the error counter and divider
  /// will switch to the [decoration]'s [InputDecoration.errorStyle] when the
  /// limit is exceeded.
  ///
  /// {@macro flutter.services.lengthLimitingTextInputFormatter.maxLength}
  final int? maxLength;

  /// Determines how the [maxLength] limit should be enforced.
  ///
  /// {@macro flutter.services.textFormatter.effectiveMaxLengthEnforcement}
  ///
  /// {@macro flutter.services.textFormatter.maxLengthEnforcement}
  final MaxLengthEnforcement? maxLengthEnforcement;

  /// {@macro flutter.widgets.editableText.onChanged}
  ///
  /// See also:
  ///
  ///  * [inputFormatters], which are called before [onChanged]
  ///    runs and can validate and change ("format") the input value.
  ///  * [onEditingComplete], [onSubmitted]:
  ///    which are more specialized input change notifications.
  final ValueChanged<String>? onChanged;

  /// {@macro flutter.widgets.editableText.onEditingComplete}
  final VoidCallback? onEditingComplete;

  /// {@macro flutter.widgets.editableText.onSubmitted}
  ///
  /// See also:
  ///
  ///  * [TextInputAction.next] and [TextInputAction.previous], which
  ///    automatically shift the focus to the next/previous focusable item when
  ///    the user is done editing.
  final ValueChanged<String>? onSubmitted;

  /// {@macro flutter.widgets.editableText.onAppPrivateCommand}
  final AppPrivateCommandCallback? onAppPrivateCommand;

  /// {@macro flutter.widgets.editableText.inputFormatters}
  final List<TextInputFormatter>? inputFormatters;

  /// If false the text field is "disabled": it ignores taps and its
  /// [decoration] is rendered in grey.
  ///
  /// If non-null this property overrides the [decoration]'s
  /// [InputDecoration.enabled] property.
  final bool? enabled;

  /// Determines whether this widget ignores pointer events.
  ///
  /// Defaults to null, and when null, does nothing.
  final bool? ignorePointers;

  /// {@macro flutter.widgets.editableText.cursorWidth}
  final double cursorWidth;

  /// {@macro flutter.widgets.editableText.cursorHeight}
  final double? cursorHeight;

  /// {@macro flutter.widgets.editableText.cursorRadius}
  final Radius? cursorRadius;

  /// {@macro flutter.widgets.editableText.cursorOpacityAnimates}
  final bool? cursorOpacityAnimates;

  /// The color of the cursor.
  ///
  /// The cursor indicates the current location of text insertion point in
  /// the field.
  ///
  /// If this is null it will default to the ambient
  /// [DefaultSelectionStyle.cursorColor]. If that is null, and the
  /// [ThemeData.platform] is [TargetPlatform.iOS] or [TargetPlatform.macOS]
  /// it will use [CupertinoThemeData.primaryColor]. Otherwise it will use
  /// the value of [ColorScheme.primary] of [ThemeData.colorScheme].
  final Color? cursorColor;

  /// The color of the cursor when the [InputDecorator] is showing an error.
  ///
  /// If this is null it will default to [TextStyle.color] of
  /// [InputDecoration.errorStyle]. If that is null, it will use
  /// [ColorScheme.error] of [ThemeData.colorScheme].
  final Color? cursorErrorColor;

  /// The appearance of the keyboard.
  ///
  /// This setting is only honored on iOS devices.
  ///
  /// If unset, defaults to [ThemeData.brightness].
  final Brightness? keyboardAppearance;

  /// {@macro flutter.widgets.editableText.scrollPadding}
  final EdgeInsets scrollPadding;

  /// {@macro flutter.widgets.editableText.enableInteractiveSelection}
  final bool enableInteractiveSelection;

  /// {@macro flutter.widgets.editableText.selectionControls}
  final TextSelectionControls? selectionControls;

  /// {@macro flutter.widgets.scrollable.dragStartBehavior}
  final DragStartBehavior dragStartBehavior;

  /// {@macro flutter.widgets.editableText.selectionEnabled}
  bool get selectionEnabled => enableInteractiveSelection;

  /// {@template flutter.material.textfield.onTap}
  /// Called for the first tap in a series of taps.
  ///
  /// The text field builds a [GestureDetector] to handle input events like tap,
  /// to trigger focus requests, to move the caret, adjust the selection, etc.
  /// Handling some of those events by wrapping the text field with a competing
  /// GestureDetector is problematic.
  ///
  /// To unconditionally handle taps, without interfering with the text field's
  /// internal gesture detector, provide this callback.
  ///
  /// If the text field is created with [enabled] false, taps will not be
  /// recognized.
  ///
  /// To be notified when the text field gains or loses the focus, provide a
  /// [focusNode] and add a listener to that.
  ///
  /// To listen to arbitrary pointer events without competing with the
  /// text field's internal gesture detector, use a [Listener].
  /// {@endtemplate}
  ///
  /// If [onTapAlwaysCalled] is enabled, this will also be called for consecutive
  /// taps.
  final GestureTapCallback? onTap;

  /// Whether [onTap] should be called for every tap.
  ///
  /// Defaults to false, so [onTap] is only called for each distinct tap. When
  /// enabled, [onTap] is called for every tap including consecutive taps.
  final bool onTapAlwaysCalled;

  /// {@macro flutter.widgets.editableText.onTapOutside}
  ///
  /// {@tool dartpad}
  /// This example shows how to use a `TextFieldTapRegion` to wrap a set of
  /// "spinner" buttons that increment and decrement a value in the [TextField]
  /// without causing the text field to lose keyboard focus.
  ///
  /// This example includes a generic `SpinnerField<T>` class that you can copy
  /// into your own project and customize.
  ///
  /// ** See code in examples/api/lib/widgets/tap_region/text_field_tap_region.0.dart **
  /// {@end-tool}
  ///
  /// See also:
  ///
  ///  * [TapRegion] for how the region group is determined.
  final TapRegionCallback? onTapOutside;

  /// The cursor for a mouse pointer when it enters or is hovering over the
  /// widget.
  ///
  /// If [mouseCursor] is a [MaterialStateProperty<MouseCursor>],
  /// [MaterialStateProperty.resolve] is used for the following [MaterialState]s:
  ///
  ///  * [MaterialState.error].
  ///  * [MaterialState.hovered].
  ///  * [MaterialState.focused].
  ///  * [MaterialState.disabled].
  ///
  /// If this property is null, [MaterialStateMouseCursor.textable] will be used.
  ///
  /// The [mouseCursor] is the only property of [TextField] that controls the
  /// appearance of the mouse pointer. All other properties related to "cursor"
  /// stand for the text cursor, which is usually a blinking vertical line at
  /// the editing position.
  final MouseCursor? mouseCursor;

  /// {@macro flutter.widgets.editableText.scrollPhysics}
  final ScrollPhysics? scrollPhysics;

  /// {@macro flutter.widgets.editableText.scrollController}
  final ScrollController? scrollController;

  /// {@macro flutter.widgets.editableText.autofillHints}
  /// {@macro flutter.services.AutofillConfiguration.autofillHints}
  final Iterable<String>? autofillHints;

  /// {@macro flutter.material.Material.clipBehavior}
  ///
  /// Defaults to [Clip.hardEdge].
  final Clip clipBehavior;

  /// {@macro flutter.widgets.editableText.scribbleEnabled}
  final bool scribbleEnabled;

  /// {@macro flutter.services.TextInputConfiguration.enableIMEPersonalizedLearning}
  final bool enableIMEPersonalizedLearning;

  /// {@macro flutter.widgets.editableText.contentInsertionConfiguration}
  final ContentInsertionConfiguration? contentInsertionConfiguration;

  /// {@macro flutter.widgets.EditableText.contextMenuBuilder}
  ///
  /// If not provided, will build a default menu based on the platform.
  ///
  /// See also:
  ///
  ///  * [AdaptiveTextSelectionToolbar], which is built by default.
  final EditableTextContextMenuBuilder? contextMenuBuilder;

  /// Determine whether this text field can request the primary focus.
  ///
  /// Defaults to true. If false, the text field will not request focus
  /// when tapped, or when its context menu is displayed. If false it will not
  /// be possible to move the focus to the text field with tab key.
  final bool canRequestFocus;

  /// {@macro flutter.widgets.undoHistory.controller}
  final UndoHistoryController? undoController;

  /// {@macro flutter.widgets.EditableText.spellCheckConfiguration}
  ///
  /// If [SpellCheckConfiguration.misspelledTextStyle] is not specified in this
  /// configuration, then [materialMisspelledTextStyle] is used by default.
  final SpellCheckConfiguration? spellCheckConfiguration;

  /// Callback that generates a custom [InputDecoration.counter] widget.
  ///
  /// See [InputCounterWidgetBuilder] for an explanation of the passed in
  /// arguments. The returned widget will be placed below the line in place of
  /// the default widget built when [InputDecoration.counterText] is specified.
  ///
  /// The returned widget will be wrapped in a [Semantics] widget for
  /// accessibility, but it also needs to be accessible itself. For example,
  /// if returning a Text widget, set the [Text.semanticsLabel] property.
  ///
  /// {@tool snippet}
  /// ```dart
  /// Widget counter(
  ///   BuildContext context,
  ///   {
  ///     required int currentLength,
  ///     required int? maxLength,
  ///     required bool isFocused,
  ///   }
  /// ) {
  ///   return Text(
  ///     '$currentLength of $maxLength characters',
  ///     semanticsLabel: 'character count',
  ///   );
  /// }
  /// ```
  /// {@end-tool}
  ///
  /// If buildCounter returns null, then no counter and no Semantics widget will
  /// be created at all.
  final Widget? Function(BuildContext context,
      {required int currentLength,
      required int? maxLength,
      required bool isFocused})? buildCounter;

  /// {@macro flutter.widgets.editableText.restorationId}
  final String? restorationId;
  final WidgetStateColor? backgroundColor;

  /// Make sure that the widget is not focusable, so it doesn't
  /// steal focus from the text input.<br>
  /// e.g. password visibility toggle
  final Widget? suffix;

  /// Make sure that the widget is not focusable, so it doesn't
  /// steal focus from the text input.
  final Widget? prefix;

  @override
  State<TextInput> createState() => _TextInputState();
}

class _TextInputState extends State<TextInput>
    with AutomaticKeepAliveClientMixin {
  // Since making a text input is a bit of a pain, I'm just going to use the material one for now.
  var hovered = false;
  var pressed = false;
  var focused = false;
  bool get enabled => true;
  late FocusNode _focusNode;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant TextInput oldWidget) {
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
    });
    _focusNode.onKeyEvent = (node, event) {
      if (event is KeyDownEvent &&
          event.logicalKey == LogicalKeyboardKey.escape) {
        node.unfocus();
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    };
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
    super.build(context);

    return InputContainer(
      hovered: hovered,
      pressed: pressed,
      focused: focused,
      padding: EdgeInsets.zero,
      child: MouseRegion(
        onEnter: (event) => setState(() => hovered = true),
        onExit: (event) => setState(() => hovered = false),
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTapDown: (_) {
            if (_focusNode.hasFocus) return;
            FocusScope.of(context).requestFocus(_focusNode);
          },
          child: _buildMaterialTextField(context),
        ),
      ),
    );
  }

  Widget _buildMaterialTextField(BuildContext context) {
    final app = context.findAncestorWidgetOfExactType<App>();
    return Localizations.override(
      context: context,
      locale: app?.locale ?? const Locale('en'),
      delegates: const [
        material.DefaultMaterialLocalizations.delegate,
      ],
      child: material.Material(
        color: Colors.transparent,
        child: material.Theme(
          data: material.ThemeData(
            textSelectionTheme: material.TextSelectionThemeData(
              cursorColor: context.theme.primaryColor,
              selectionColor: context.theme.primaryColor.withOpacity(0.5),
              selectionHandleColor: context.theme.primaryColor,
            ),
            iconTheme: IconThemeData(
              color: context.theme.foregroundColor,
              size: context.theme.iconSize,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (widget.prefix != null)
                TapRegion(
                  groupId: TextInput,
                  child: IconTheme(
                    data: IconThemeData(
                      size: context.theme.iconSize,
                      color: context.theme.foregroundColor.withOpacity(0.5),
                    ),
                    child: widget.prefix!,
                  ),
                ),
              Expanded(
                child: material.TextField(
                  groupId: TextInput,
                  style: GenericTheme.maybeOf(context)?.baseTextStyle.copyWith(
                        color: context.theme.foregroundColor,
                      ),
                  decoration: material.InputDecoration(
                    filled: false,
                    border: material.InputBorder.none,
                    contentPadding: EdgeInsets.only(
                      bottom: isDesktop ? 12.0 : 13.0,
                      top: isDesktop ? 12.0 : 13.0,
                      left: widget.prefix == null
                          ? isDesktop
                              ? 10.0
                              : 12.0
                          : 0.0,
                      right: widget.suffix == null
                          ? isDesktop
                              ? 10.0
                              : 12.0
                          : 0.0,
                    ),
                    isDense: true,
                  ),
                  controller: widget.controller,
                  focusNode: _focusNode,
                  undoController: widget.undoController,
                  keyboardType: widget.keyboardType,
                  textInputAction: widget.textInputAction,
                  textCapitalization: widget.textCapitalization,
                  autocorrect: widget.autocorrect,
                  autofillHints: widget.autofillHints,
                  autofocus: widget.autofocus,
                  canRequestFocus: widget.canRequestFocus,
                  clipBehavior: widget.clipBehavior,
                  enableInteractiveSelection: widget.enableInteractiveSelection,
                  enableIMEPersonalizedLearning:
                      widget.enableIMEPersonalizedLearning,
                  enableSuggestions: widget.enableSuggestions,
                  maxLength: widget.maxLength,
                  maxLines: widget.maxLines,
                  minLines: widget.minLines,
                  obscureText: widget.obscureText,
                  obscuringCharacter: widget.obscuringCharacter,
                  readOnly: widget.readOnly,
                  showCursor: widget.showCursor,
                  smartDashesType: widget.smartDashesType,
                  smartQuotesType: widget.smartQuotesType,
                  strutStyle: widget.strutStyle,
                  textAlign: widget.textAlign,
                  textAlignVertical: widget.textAlignVertical,
                  textDirection: widget.textDirection,
                  scrollPadding: widget.scrollPadding,
                  dragStartBehavior: widget.dragStartBehavior,
                  selectionControls: widget.selectionControls,
                  onTap: widget.onTap,
                  onTapAlwaysCalled: widget.onTapAlwaysCalled,
                  onTapOutside: widget.onTapOutside,
                  mouseCursor: widget.mouseCursor,
                  contextMenuBuilder: widget.contextMenuBuilder ??
                      (context, editableTextState) {
                        return Localizations.override(
                          context: context,
                          locale: app?.locale ?? const Locale('en'),
                          delegates: const [
                            material.DefaultMaterialLocalizations.delegate,
                          ],
                          child: TapRegion(
                            groupId: TextInput,
                            child: material.AdaptiveTextSelectionToolbar
                                .editableText(
                              editableTextState: editableTextState,
                            ),
                          ),
                        );
                      },
                  contentInsertionConfiguration:
                      widget.contentInsertionConfiguration,
                  cursorColor: widget.cursorColor,
                  cursorHeight: widget.cursorHeight,
                  cursorRadius: widget.cursorRadius,
                  cursorOpacityAnimates: widget.cursorOpacityAnimates,
                  cursorWidth: widget.cursorWidth,
                  keyboardAppearance: widget.keyboardAppearance,
                  maxLengthEnforcement: widget.maxLengthEnforcement,
                  onAppPrivateCommand: widget.onAppPrivateCommand,
                  onEditingComplete: widget.onEditingComplete,
                  cursorErrorColor: widget.cursorErrorColor,
                  scrollController: widget.scrollController,
                  scrollPhysics: widget.scrollPhysics,
                  enabled: widget.enabled,
                  expands: widget.expands,
                  inputFormatters: widget.inputFormatters,
                  ignorePointers: widget.ignorePointers,
                  magnifierConfiguration: widget.magnifierConfiguration,
                  onChanged: widget.onChanged,
                  onSubmitted: widget.onSubmitted,
                  scribbleEnabled: widget.scribbleEnabled,
                  spellCheckConfiguration: widget.spellCheckConfiguration,
                  buildCounter: widget.buildCounter,
                ),
              ),
              if (widget.suffix != null)
                TapRegion(
                  groupId: TextInput,
                  child: IconTheme(
                    data: IconThemeData(
                      size: context.theme.iconSize,
                      color: context.theme.foregroundColor.withOpacity(0.5),
                    ),
                    child: widget.suffix!,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

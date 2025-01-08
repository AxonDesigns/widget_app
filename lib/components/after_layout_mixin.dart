import 'package:widget_app/generic.dart';

mixin AfterLayoutMixin<T extends StatefulWidget> on State<T> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      afterLayout(timeStamp);
    });
  }

  /// Called after the first layout pass.
  void afterLayout(Duration timeStamp) {}
}

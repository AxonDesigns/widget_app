import 'package:widget_app/components/generic.dart';

class Barrier extends StatelessWidget {
  const Barrier({
    super.key,
    required this.animation,
    required this.child,
  });

  final Widget child;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FadeTransition(
          opacity: animation,
          child: IgnorePointer(
            child: Container(
              color: Colors.black.withOpacity(0.5),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

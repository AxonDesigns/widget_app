import 'package:go_router/go_router.dart';
import 'package:widget_app/components/generic.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with AutomaticKeepAliveClientMixin {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      color: GenericTheme.of(context).backgroundColor,
      child: Center(
        child: Container(
          width: 400.0,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: GenericTheme.of(context).surfaceColor,
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: GappedColumn(
            mainAxisSize: MainAxisSize.min,
            gap: 14.0,
            children: [
              TextInput(
                controller: _controller,
              ),
              GestureDetector(
                onTap: () async {
                  await context.push('/about');
                },
                child: const Text('Home Page'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

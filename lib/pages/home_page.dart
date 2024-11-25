import 'package:go_router/go_router.dart';
import 'package:widget_app/components/button.dart';
import 'package:widget_app/components/dark_mode_state.dart';
import 'package:widget_app/components/generic.dart';
import 'package:widget_app/components/tooltip.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
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
              Tooltip(
                message: "Example tooltip",
                child: Button.primary(
                  onPressed: () async {
                    await context.push('/about');
                  },
                  children: [Text("Go to About Page")],
                ),
              ),
              Button.outline(
                onPressed: () async {
                  context.setThemeMode(ThemeMode.light);
                },
                children: [Text("Change to Light Mode")],
              ),
              Button.outline(
                onPressed: () async {
                  context.setThemeMode(ThemeMode.dark);
                },
                children: [Text("Change to Dark Mode")],
              ),
              Button.outline(
                onPressed: () async {
                  context.setThemeMode(ThemeMode.system);
                },
                children: [Text("Change to System Mode")],
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

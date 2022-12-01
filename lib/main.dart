import 'package:fluent_ui/fluent_ui.dart';

void main() {
  // runs the fastim application.
  runApp(const FastIMApp());
}

/// root widget that hosts the entire fastim application.
class FastIMApp extends StatelessWidget {
  const FastIMApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FluentApp(
        themeMode: ThemeMode.dark,
        darkTheme: ThemeData(
          accentColor: Colors.green,
          brightness: Brightness.dark,
        ),
        // hide the debug banner on top right
        debugShowCheckedModeBanner: false,
        title: 'FastIM',
        home: NavigationView(
          appBar: const NavigationAppBar(
            title: Text('Incidents Overview'),
          ),
          pane: NavigationPane(
            selected: 0,
            onChanged: (i) {},
            displayMode: PaneDisplayMode.compact,
            items: [
              PaneItem(
                  icon: const Icon(FluentIcons.issue_tracking),
                  title: const Text('Incidents'),
                  infoBadge: const InfoBadge(source: Text('8')),
                  body: MyHomePage(
                    title: 'abc',
                  )),
            ],
          ),
        ));
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      // for search bar and buttons

      Card(
        // padding: const EdgeInsets.only(top: 20, bottom: 30),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 500, child: SearchBar()),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: FilledButton(
                child: const Text(
                  'search',
                  style: TextStyle(fontSize: 16),
                ),
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),

      // for results list view

      Expanded(
        child: ListView(
          padding:
              const EdgeInsets.only(left: 100, right: 100, top: 20, bottom: 20),
          children: [
            Expander(
                header: const Text(
                  'my problem',
                ),
                // subtitle: Text('ABC000001234'),
                // controlAffinity: ListTileControlAffinity.leading,
                trailing: FilledButton(
                  child: const Text('open'),
                  onPressed: () {},
                ),
                content: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 100,
                          child: TextBox(
                            foregroundDecoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide.none,
                              ),
                            ),
                            placeholder: 'SR No.',
                            placeholderStyle:
                                TextStyle(color: Colors.grey[120]),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: ComboBox<String>(
                              icon: Padding(
                                //Icon at tail, arrow bottom is default icon
                                padding: EdgeInsets.only(left: 15),
                                child: Icon(
                                  FluentIcons.down,
                                ),
                              ),
                              items: [
                                ComboBoxItem(
                                    value: 'WIP/Target',
                                    child: Text('WIP/Target')),
                              ],
                              value: 'WIP/Target',
                              onChanged: (obj) {}),
                        )
                      ],
                    ),
                    Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 10),
                        child: TextBox(
                          foregroundDecoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide.none,
                            ),
                          ),
                        )),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(right: 10),
                              child: Icon(
                                FluentIcons.circle_ring,
                                size: 8,
                              ),
                            ),
                            Text('tried to book'),
                          ],
                        ),
                        Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(right: 10),
                              child: Icon(
                                FluentIcons.circle_ring,
                                size: 8,
                              ),
                            ),
                            Text('tried to book'),
                          ],
                        ),
                      ],
                    ),
                  ],
                )),
          ],
        ),
      ),
    ]);
  }
}

class SearchBar extends StatelessWidget {
  const SearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return TextBox(
      placeholder: 'search ticket or description',
      placeholderStyle: TextStyle(color: Colors.grey[120]),
      onTap: () {},
      style: const TextStyle(fontSize: 14),
    );
  }
}

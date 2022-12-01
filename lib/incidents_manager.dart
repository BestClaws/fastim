import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';

import 'activity_board.dart';

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

class IncidentsManager extends StatefulWidget {
  const IncidentsManager({super.key});

  @override
  State<IncidentsManager> createState() => _IncidentsManagerState();
}

class _IncidentsManagerState extends State<IncidentsManager> {
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      // for search bar and buttons
      _buildSearchBar(),
      // for results list view
      _buildResultsList()
    ]);
  }

  /// Top Search bar with search field and a  button
  _buildSearchBar() {
    return Container(
      color: Colors.grey[190],
      padding: const EdgeInsets.all(15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // TODO: prefer to make this flexible
          const Expanded(child: SearchBar()),
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
    );
  }

  /// Displays the list of results that match the search term in search bar
  _buildResultsList() {
    return Expanded(
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
                          placeholderStyle: TextStyle(color: Colors.grey[120]),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: ComboBox<String>(
                            icon: const Padding(
                              //Icon at tail, arrow bottom is default icon
                              padding: EdgeInsets.only(left: 15),
                              child: Icon(
                                FluentIcons.down,
                              ),
                            ),
                            items: const [
                              ComboBoxItem(
                                  value: 'WIP/Target',
                                  child: Text('WIP/Target')),
                            ],
                            value: 'WIP/Target',
                            onChanged: (obj) {}),
                      )
                    ],
                  ),
                  const ActivityBoard()
                ],
              )),
        ],
      ),
    );
  }
}

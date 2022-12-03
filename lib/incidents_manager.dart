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

/// Main overview page of the incident manager
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
        children: const [
          IncidentTile(),
        ],
      ),
    );
  }
}

class IncidentTile extends StatefulWidget {
  const IncidentTile({
    Key? key,
  }) : super(key: key);

  @override
  State<IncidentTile> createState() => _IncidentTileState();
}

class _IncidentTileState extends State<IncidentTile> {
  @override
  Widget build(BuildContext context) {
    return Expander(
        onStateChanged: (value) {
          print(value);
        },
        // title and description of incident.
        header: const Text(
          'my problem',
        ),
        // button to open the incident in full page for working.
        trailing: FilledButton(
          child: const Text('open'),
          onPressed: () {},
        ),
        // persistant fields and activity board.
        content: ChangeNotifierProvider<IncidentModel>(
          create: (context) {
            return IncidentModel();
          },
          child: Column(
            children: const [PersistantFields(), ActivityBoard()],
          ),
        ));
  }
}

class PersistantFields extends StatelessWidget {
  const PersistantFields({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var incidentModel = Provider.of<IncidentModel>(context, listen: true);

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // SR No field.
        SizedBox(
          width: 100,
          child: TextBox(
            initialValue: incidentModel.srNo,
            onChanged: (value) => incidentModel.srNo = value,
            foregroundDecoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide.none,
              ),
            ),
            placeholder: 'SR No.',
            placeholderStyle: TextStyle(color: Colors.grey[120]),
          ),
        ),
        // Ticket status field.
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
                ComboBoxItem(value: 'other', child: Text('status?')),
                ComboBoxItem(value: 'wip', child: Text('WIP')),
                ComboBoxItem(
                    value: 'external', child: Text('WIP/Work External')),
                ComboBoxItem(value: 'customer', child: Text('WIP/Customer')),
                ComboBoxItem(value: 'target', child: Text('WIP/Target')),
              ],
              value: incidentModel.ticketStatus,
              onChanged: (value) {
                if (value != null) {
                  incidentModel.ticketStatus = value;
                }
              }),
        )
      ],
    );
  }
}

class IncidentModel extends ChangeNotifier {
  String _srNo = "";
  String _ticketStatus = "other";

  set srNo(String srNo) {
    _srNo = srNo;
    notifyListeners();
  }

  String get srNo => _srNo;

  set ticketStatus(String ticketStatus) {
    _ticketStatus = ticketStatus;
    notifyListeners();
  }

  String get ticketStatus => _ticketStatus;

  List<String> activityList = [];

  void addActivity(String activity) {
    activityList.add(activity);
    notifyListeners();
  }
}

import 'dart:convert';
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

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
    // fetch incidents (no and title)

    return Expanded(
      child: ListView(
        padding:
            const EdgeInsets.only(left: 100, right: 100, top: 20, bottom: 20),
        children: const [
          IncidentTile(ticketNo: 'a1', shortDescription: 'hello1'),
          IncidentTile(ticketNo: 'a2', shortDescription: 'hello2'),
        ],
      ),
    );
  }
}

class IncidentTile extends StatelessWidget {
  final String ticketNo;
  final String shortDescription;

  const IncidentTile(
      {Key? key, required this.ticketNo, this.shortDescription = ""})
      : super(key: key);

  _fetchDetails() async {
    var documentsDirectory = await getApplicationDocumentsDirectory();
    var path = documentsDirectory.path;
    String img1 = p.join(path, 'IMG1', 'details.json');
    var file = File(img1);
    var str = await file.readAsString();
    return json.decode(str);
  }

  @override
  Widget build(BuildContext context) {
    late IncidentModel incidentModel;

    return ChangeNotifierProvider<IncidentModel>(
      create: (context) {
        // NOTE: weird way of accessing model in a widget that's above the change notifier's widget tree.
        // consdier making wrapping the content's column with a new widget. this will also allow to
        // cleanly add progress bar for everything that's expanded.
        incidentModel = IncidentModel();
        return incidentModel;
      },
      child: Expander(
        onStateChanged: (opened) async {
          if (opened) {
            var data = await _fetchDetails();
            incidentModel.srNo = data['srNo'];
            incidentModel.ticketStatus = data["ticketStatus"];
            incidentModel.activityList = data["activityList"].cast<String>();
            incidentModel.ready = true;
          } else {
            // persist state to the disk.
          }
        },
        // title and description of incident.
        header: Text("$ticketNo $shortDescription"),
        // button to open the incident in full page for working.
        trailing: FilledButton(
          child: const Text('open'),
          onPressed: () {},
        ),
        // persistant fields and activity board.
        content: Column(
          children: const [PersistantFields(), ActivityBoard()],
        ),
      ),
    );
  }
}

class PersistantFields extends StatelessWidget {
  const PersistantFields({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var incidentModel = Provider.of<IncidentModel>(context);

    if (!incidentModel.ready) {
      return const Center(child: ProgressRing());
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // SR No field.
        SizedBox(
          width: 100,
          child: TextBox(
            initialValue: incidentModel.srNo,
            onChanged: (value) {
              incidentModel.srNo = value;
            },
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
  bool ready = false;
  String _srNo = "--";
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

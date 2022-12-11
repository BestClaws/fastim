import 'dart:convert';
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'activity_board.dart';

/// Main overview page of the incident manager
class IncidentsManager extends StatelessWidget {
  const IncidentsManager({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SearchControllerModel>(
      create: (context) => SearchControllerModel(),
      builder: (context, child) {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // for search bar and buttons
              const IncidentSearchBar(),
              // for results list view
              Consumer<SearchControllerModel>(
                builder: (context, searchController, child) {
                  return IncidentSearchResults(
                      incidents: searchController.searchResults);
                },
              )
            ]);
      },
    );
  }
}

class SearchControllerModel extends ChangeNotifier {
  List<IncidentOverviewModel> _searchResults = const [];

  List<IncidentOverviewModel> get searchResults => _searchResults;

  set searchResults(List<IncidentOverviewModel> searchResults) {
    _searchResults = searchResults;
    notifyListeners();
  }
}

/// Top Search bar with search field and a  button
class IncidentSearchBar extends StatelessWidget {
  const IncidentSearchBar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[190],
      padding: const EdgeInsets.all(15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // TODO: prefer to make this flexible
          Expanded(
              child: TextBox(
            placeholder: 'search ticket or description',
            placeholderStyle: TextStyle(color: Colors.grey[120]),
            onTap: () {},
            style: const TextStyle(fontSize: 14),
          )),
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
}

/// Displays the list of results that match the search term in search bar
class IncidentSearchResults extends StatelessWidget {
  final List<IncidentOverviewModel> incidents;

  const IncidentSearchResults({
    required this.incidents,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView(
        padding:
            const EdgeInsets.only(left: 100, right: 100, top: 20, bottom: 20),
        children: incidents.map((incidentOverview) {
          return IncidentTile(
            ticketNo: incidentOverview.no,
            shortDescription: incidentOverview.shortDescription,
          );
        }).toList(),
      ),
    );
  }
}

class IncidentOverviewModel {
  String no;
  String shortDescription;
  bool archived;

  IncidentOverviewModel(
      {required this.no,
      required this.shortDescription,
      required this.archived});
}

class IncidentTile extends StatelessWidget {
  final String ticketNo;
  final String shortDescription;
  const IncidentTile(
      {Key? key, required this.ticketNo, this.shortDescription = ""})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    late IncidentModel incident;

    return ChangeNotifierProvider<IncidentModel>(
      create: (context) {
        // NOTE-cosmic: weird way of accessing model from a widget that's above the change notifier's widget tree.
        // consdier making wrapping the content's column with a new widget. this will also allow to
        // cleanly add progress bar for everything that's expanded.
        incident = IncidentModel();
        return incident;
      },
      child: Expander(
        onStateChanged: (opened) async {
          if (opened) {
            // load incident tile data from disk.
            var data = await _fetchIncidentFromDisk(ticketNo);
            incident.srNo = data['srNo'];
            incident.ticketStatus = data["ticketStatus"];
            incident._activityList = data["activityList"].cast<String>();
            incident.ready = true;
          } else {
            // persist state to the disk.
            incident.ready = false;
            _saveIncidentToDisk(incident);
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
          // NOTE-cosmic: I can't add a progress bar here and switch it to content when loaded
          // as this is a stateless widget and build() only runs once.
          children: const [IncidentTileFields(), ActivityBoard()],
        ),
      ),
    );
  }

  _fetchIncidentFromDisk(String ticketNo) async {
    var documentsDirectory = await getApplicationDocumentsDirectory();
    var documentsDirectoryPath = documentsDirectory.path;
    String detailsJsonpath = p.join(documentsDirectoryPath, 'fastim',
        'incidents', ticketNo, 'details.json');
    var file = File(detailsJsonpath);
    // TODO: fails if file not found, need to handle this.
    var str = await file.readAsString();
    return json.decode(str);
  }

  _saveIncidentToDisk(IncidentModel incident) async {
    var documentDirectory = await getApplicationDocumentsDirectory();
    var documentsDirectoryPath = documentDirectory.path;
    var detailsJsonPath = p.join(documentsDirectoryPath, 'fastim', 'incidents',
        ticketNo, 'details.json');
    var file = File(detailsJsonPath);
    dynamic data = {};
    data['srNo'] = incident.srNo;
    data["ticketStatus"] = incident.ticketStatus;
    data["activityList"] = incident._activityList;
    var encodedData = jsonEncode(data);
    await file.writeAsString(encodedData);
  }
}

class IncidentTileFields extends StatelessWidget {
  const IncidentTileFields({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var incident = Provider.of<IncidentModel>(context);

    if (!incident.ready) {
      return const Center(child: ProgressRing());
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // SR No field.
        SizedBox(
          width: 100,
          child: TextBox(
            initialValue: incident.srNo,
            onChanged: (value) {
              incident.srNo = value;
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
              value: incident.ticketStatus,
              onChanged: (value) {
                if (value != null) {
                  incident.ticketStatus = value;
                }
              }),
        )
      ],
    );
  }
}

// represents the entire state of an incident tile.
class IncidentModel extends ChangeNotifier {
  String _srNo = "";
  String _ticketStatus = "other";
  bool _ready = false;
  List<String> _activityList = [];

  bool get ready => _ready;

  set ready(bool ready) {
    _ready = ready;
    notifyListeners();
  }

  String get srNo => _srNo;

  set srNo(String srNo) {
    _srNo = srNo;
    notifyListeners();
  }

  String get ticketStatus => _ticketStatus;

  set ticketStatus(String ticketStatus) {
    _ticketStatus = ticketStatus;
    notifyListeners();
  }

  List<String> get activityList => _activityList;

  void addActivity(String activity) {
    _activityList.add(activity);
    notifyListeners();
  }
}

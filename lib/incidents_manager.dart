import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
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
              // create new incident.

              // for results list view
              Consumer<SearchControllerModel>(
                builder: (context, searchController, child) {
                  if (searchController.searchResults.isEmpty) {
                    return NewIncidentForm('imgtest');
                  }
                  return IncidentSearchResults(
                      incidents: searchController.searchResults);
                },
              )
            ]);
      },
    );
  }
}

class NewIncidentForm extends StatefulWidget {
  final String incidentNo;
  const NewIncidentForm(this.incidentNo, {super.key});

  @override
  State<NewIncidentForm> createState() => _NewIncidentFormState();
}

class _NewIncidentFormState extends State<NewIncidentForm> {
  String shortDescription = "";
  String fullDescription = "";
  String ticketHistory = "";

  // void foosh() async {
  //   print((await Clipboard.getData("text/plain"))!.text!);
  // }

  @override
  Widget build(BuildContext context) {
    // var counter = 100;
    // Timer.periodic(const Duration(seconds: 2), (timer) {
    //   foosh();

    //   counter--;
    //   if (counter == 0) {
    //     print('Cancel timer');
    //     timer.cancel();
    //   }
    // });

    return Expanded(
      child: Center(
          child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // short description capure
          Padding(
              padding: const EdgeInsets.all(5),
              child: FilledButton(
                  onPressed: () async {
                    // TODO: see alternatives to !
                    shortDescription =
                        (await Clipboard.getData("text/plain"))!.text!;
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: const [
                        Icon(FluentIcons.paste_as_text),
                        Text("Short Desc.,")
                      ],
                    ),
                  ))),
          // full description capture
          Padding(
              padding: const EdgeInsets.all(5),
              child: FilledButton(
                  onPressed: () async {
                    // TODO: see alternatives to !
                    fullDescription =
                        (await Clipboard.getData("text/plain"))!.text!;
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: const [
                        Icon(FluentIcons.paste_as_text),
                        Text("Full Desc.,")
                      ],
                    ),
                  ))),
          // ticket history capture
          Padding(
              padding: const EdgeInsets.all(5),
              child: FilledButton(
                  onPressed: () async {
                    // TODO: see alternatives to !
                    ticketHistory =
                        (await Clipboard.getData("text/plain"))!.text!;
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: const [
                        Icon(FluentIcons.paste_as_text),
                        Text("Ticket History")
                      ],
                    ),
                  ))),
        ],
      )),
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
            onChanged: (x) async {
              // process search query.
              // currently only supports searching incidents.

              List<IncidentOverviewModel> results = [];

              var searchControllerModel =
                  Provider.of<SearchControllerModel>(context, listen: false);

              List<dynamic> incidentOverviews =
                  await _fetchAllIncidentsOverview();

              for (var incidentOverview in incidentOverviews) {
                if (incidentOverview["ticketNo"].contains(x) ||
                    incidentOverview["shortDescription"].contains(x)) {
                  var incidentOverviewModel = IncidentOverviewModel(
                      no: incidentOverview["ticketNo"],
                      shortDescription: incidentOverview["shortDescription"],
                      archived: incidentOverview["archived"]);
                  results.add(incidentOverviewModel);
                }
              }

              searchControllerModel.searchResults = results;
            },
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

  _fetchAllIncidentsOverview() async {
    // TODO: cache the search. with override flag.
    var documentsDirectory = await getApplicationDocumentsDirectory();
    var incidentsIndexPath =
        p.join(documentsDirectory.path, 'fastim', 'incidents', 'index.json');
    var file = File(incidentsIndexPath);
    var str = await file.readAsString();
    return json.decode(str);
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
    var children = incidents.map((incidentOverview) {
      return IncidentTile(
        ticketNo: incidentOverview.no,
        shortDescription: incidentOverview.shortDescription,
      );
    }).toList();

    return Expanded(
      child: ListView(
        padding:
            const EdgeInsets.only(left: 100, right: 100, top: 20, bottom: 20),
        children: children,
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
    return ChangeNotifierProvider<IncidentModel>(
      create: (context) => IncidentModel(),
      builder: (context, child) {
        var incident = Provider.of<IncidentModel>(context, listen: false);
        return Expander(
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
          content: Consumer<IncidentModel>(
            builder: (context, inci, child) {
              // until expanded and data loaded.
              if (!inci.ready) return const Center(child: ProgressRing());
              // persistant fields and activity board.
              return Column(
                children: const [IncidentTileFields(), ActivityBoard()],
              );
            },
          ),
        );
      },
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
    var incident = Provider.of<IncidentModel>(context, listen: false);

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

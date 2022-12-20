import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fastim/utils/fs.dart';
import 'package:fastim/utils/save_load.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:url_launcher/url_launcher.dart';

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
              Consumer<SearchControllerModel>(
                builder: (context, searchController, child) {
                  // populate entries if search was reset.
                  if (searchController.textController.text == "") {
                    searchController.searchAndPopulate("");
                  }

                  // decide wether to show new incident form or
                  // show search results.
                  if (searchController.searchResults.isEmpty &&
                      searchController.textController.text != "") {
                    // create new incident.
                    return NewIncidentForm(
                        searchController.textController.text);
                  } else {
                    // show results.
                    return IncidentSearchResults(
                        searchController.searchResults);
                  }
                },
              )
            ]);
      },
    );
  }
}

// TODO: make sure its text before dealing with clipboard.
// TODO: holding control on text fields inside this widget.
// seems to cause some flutter error (not just here but everywhere i can see so far)
// keep an eye on this.
class NewIncidentForm extends StatefulWidget {
  final String incidentNo;
  const NewIncidentForm(this.incidentNo, {super.key});

  @override
  State<NewIncidentForm> createState() => _NewIncidentFormState();
}

class _NewIncidentFormState extends State<NewIncidentForm> {
  String lastClip = "";
  var shortDescriptionField = PasteField(2, "Give a short description...");
  var fullDescriptionField = PasteField(4, "Give a full description...");
  var incidentHistoryField =
      PasteField(7, "Give the incidient history so far...");

  @override
  Widget build(BuildContext context) {
    var co = context;

    // capture clipboard every 500ms
    Timer.periodic(const Duration(milliseconds: 500), (timer) async {
      String text = (await Clipboard.getData("text/plain"))!.text!;

      // this prevents triggering the autopaste.
      if (lastClip == "") lastClip = text;

      // see who has focus
      PasteField? whoHasFocus;

      if (shortDescriptionField.focusNode.hasFocus) {
        whoHasFocus = shortDescriptionField;
      } else if (fullDescriptionField.focusNode.hasFocus) {
        whoHasFocus = fullDescriptionField;
      } else if (incidentHistoryField.focusNode.hasFocus) {
        whoHasFocus = incidentHistoryField;
      }

      // if clipboard is fresh and either of three fields have focus.
      if (lastClip != text && whoHasFocus != null) {
        // update the focused field's text.
        whoHasFocus.controller.text = text;

        // request focus for next item.
        PasteField? nextFocus;

        if (shortDescriptionField.focusNode.hasFocus) {
          nextFocus = fullDescriptionField;
        } else if (fullDescriptionField.focusNode.hasFocus) {
          nextFocus = incidentHistoryField;
        }

        if (nextFocus != null) {
          FocusScope.of(co).requestFocus(nextFocus.focusNode);
        }

        lastClip = text;
      }

      // cancel timer when all are filled.
    });

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(left: 100, right: 100),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            shortDescriptionField,
            fullDescriptionField,
            incidentHistoryField,
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Button(
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("Create"),
                  ),
                  onPressed: () {
                    createIncident(
                        widget.incidentNo,
                        shortDescriptionField.controller.text,
                        fullDescriptionField.controller.text,
                        incidentHistoryField.controller.text);
                    var searchController = Provider.of<SearchControllerModel>(
                        context,
                        listen: false);
                    searchController.resetSearch();
                  }),
            )
          ],
        ),
      ),
    );
  }

  // persists the new incident to disk.
  createIncident(String incidentNo, String shortDescription,
      String fullDescription, String incidentHistory) async {
    // create a new directory for saving new incident data

    // add incident to index.
    var data = (await loadObj(await getIncidentsIndexFile())) as List<dynamic>;
    data.add({
      "incidentNo": incidentNo,
      "shortDescription": shortDescription,
      "archived": false,
    });
    await saveObj(await getIncidentsIndexFile(), data);

    // create and populate incident details.json
    var incidentDetailsFile = await createIncidentDetailsFile(incidentNo);

    var newData = {
      "incidentNo": incidentNo,
      "shortDescription": shortDescription,
      "fullDescription": fullDescription,
      "incidentHistory": incidentHistory,
      "srNo": "",
      "incidentStatus": "",
      "activityList": []
    };

    await saveObj(incidentDetailsFile, newData);

    // create details.txt
    var detailsTxtPath =
        p.join((await getIncidentDirectory(incidentNo)).path, 'details.txt');

    var str = "$incidentNo\n\n###########\n\n"
        "$shortDescription\n\n###########\n\n"
        "$fullDescription\n\n###########\n\n"
        "$incidentHistory";

    var file = await File(detailsTxtPath).create();
    await file.writeAsString(str);
  }
}

class PasteField extends StatelessWidget {
  final int minMaxLines;
  final String placeholder;
  final controller = TextEditingController();
  final focusNode = FocusNode();

  PasteField(
    this.minMaxLines,
    this.placeholder, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var tb = TextBox(
      controller: controller,
      minLines: minMaxLines,
      maxLines: minMaxLines,
      focusNode: focusNode,
      placeholder: placeholder,
    );

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: tb,
    );
  }
}

class SearchControllerModel extends ChangeNotifier {
  List<IndexEntryModel> _searchResults = const [];
  final _textController = TextEditingController();

  TextEditingController get textController => _textController;

  resetSearch() {
    _textController.text = "";
    notifyListeners();
  }

  List<IndexEntryModel> get searchResults => _searchResults;

  set searchResults(List<IndexEntryModel> searchResults) {
    _searchResults = searchResults;
    notifyListeners();
  }

  Future<void> searchAndPopulate(searchQuery) async {
    List<IndexEntryModel> results = [];

    List<dynamic> indexEntries = await _fetchIncidentsIndex();

    for (var indexEntry in indexEntries) {
      if (indexEntry["incidentNo"].contains(searchQuery) ||
          indexEntry["shortDescription"].contains(searchQuery)) {
        var indexEntryModel = IndexEntryModel(
            incidentNo: indexEntry["incidentNo"],
            shortDescription: indexEntry["shortDescription"],
            archived: indexEntry["archived"]);
        results.add(indexEntryModel);
      }
    }
    searchResults = results;
  }

  _fetchIncidentsIndex() async {
    // TODO: cache the search. with override flag.
    var documentsDirectory = await getApplicationDocumentsDirectory();
    var incidentsIndexPath =
        p.join(documentsDirectory.path, 'fastim', 'incidents', 'index.json');
    var file = File(incidentsIndexPath);
    var str = await file.readAsString();
    return json.decode(str);
  }
}

/// Top Search bar with search field and a  button
class IncidentSearchBar extends StatelessWidget {
  const IncidentSearchBar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var searchControllerModel =
        Provider.of<SearchControllerModel>(context, listen: false);

    return Container(
      color: Colors.grey[190],
      padding: const EdgeInsets.all(15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // TODO: prefer to make this flexible
          Expanded(
              child: TextBox(
            controller: searchControllerModel.textController,
            placeholder: 'search ticket or description',
            placeholderStyle: TextStyle(color: Colors.grey[120]),
            // TODO: extract function
            // process search query.
            // currently only supports searching incidents via no and short desc.
            onChanged: (searchQuery) async {
              searchControllerModel.searchAndPopulate(searchQuery);
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
}

/// Displays the list of results that match the search term in search bar
class IncidentSearchResults extends StatelessWidget {
  final List<IndexEntryModel> incidentsIndex;

  const IncidentSearchResults(
    this.incidentsIndex, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var children = incidentsIndex.map((indexEntry) {
      return IncidentTile(
        incidentNo: indexEntry.incidentNo,
        shortDescription: indexEntry.shortDescription,
      );
    }).toList();

    return Expanded(
      child: ListView(
        padding:
            const EdgeInsets.only(left: 80, right: 80, top: 20, bottom: 20),
        children: children,
      ),
    );
  }
}

/// Incident Overview as stored in the index.
class IndexEntryModel {
  String incidentNo;
  String shortDescription;
  bool archived;

  IndexEntryModel(
      {required this.incidentNo,
      required this.shortDescription,
      required this.archived});
}

class IncidentTile extends StatelessWidget {
  final String incidentNo;
  final String shortDescription;
  const IncidentTile(
      {Key? key, required this.incidentNo, this.shortDescription = ""})
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
              var data = await _fetchIncidentFromDisk(incidentNo);
              incident.srNo = data['srNo'];
              incident.incidentStatus = data["incidentStatus"];
              incident.activityList = data["activityList"].cast<String>();
              incident.ready = true;
            } else {
              // persist state to the disk.
              incident.ready = false;
              _updateIncidentOnDisk(incident);
            }
          },
          // title and description of incident.
          header: Text("$incidentNo $shortDescription"),
          // button to open the incident in full page for working.
          trailing: FilledButton(
            child: const Text('open'),
            onPressed: () async {
              var dir = (await getIncidentDirectory(incidentNo)).path;
              await launchUrl(Uri.directory(dir));
            },
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

  _fetchIncidentFromDisk(String incidentNo) async {
    var incidentDetailsFile = await getIncidentDetailsFile(incidentNo);
    return loadObj(incidentDetailsFile);
  }

  _updateIncidentOnDisk(IncidentModel incident) async {
    var incidentDetailsFile = await getIncidentDetailsFile(incidentNo);
    var data = await loadObj(incidentDetailsFile);
    data['srNo'] = incident.srNo;
    data['incidentStatus'] = incident.incidentStatus;
    data['activityList'] = incident.activityList;
    await saveObj(incidentDetailsFile, data);
  }
}

class IncidentTileFields extends StatelessWidget {
  const IncidentTileFields({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var incident = Provider.of<IncidentModel>(context, listen: true);

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
              value: incident.incidentStatus,
              onChanged: (value) {
                if (value != null) {
                  incident.incidentStatus = value;
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
  String _incidentStatus = "other";
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

  String get incidentStatus => _incidentStatus;

  set incidentStatus(String incidentStatus) {
    _incidentStatus = incidentStatus;
    notifyListeners();
  }

  List<String> get activityList => _activityList;

  set activityList(List<String> activities) {
    _activityList = activities;
    notifyListeners();
  }

  void addActivity(String activity) {
    _activityList.add(activity);
    notifyListeners();
  }
}

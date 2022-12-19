import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

Future<String> getFastimHomePath() async {
  var documentsDirectoryPath = (await getApplicationDocumentsDirectory()).path;
  return p.join(documentsDirectoryPath, 'fastim');
}

Future<String> getIncidentsHomePath() async {
  var fastimHomePath = await getFastimHomePath();
  return p.join(fastimHomePath, 'incidents');
}

/// creates a new directory for a given incident number.
/// does nothing if it already exists.
Future<String> createIncidentDirectory(String incidentNo) async {
  var incidentsHomePath = await getIncidentsHomePath();
  var targetPath = p.join(incidentsHomePath, incidentNo);
  var directory = await Directory(targetPath).create();
  return directory.path;
}

// TODO: needs validation.
Future<String> createIncidentDetailsJson(String incidentNo) async {
  // NOTE: call to this function is kinda reduntant
  // you could instead call File(path).create({recursive: true})
  var incidentDirectoryPath = await createIncidentDirectory(incidentNo);

  var incidentDetailsJsonPath = p.join(incidentDirectoryPath, 'details.json');

  var incidentDetailsJsonFile = await File(incidentDetailsJsonPath).create();

  return incidentDetailsJsonFile.path;
}

Future<String> getIncidentsIndexPath() async {
  var incidentsPath = await getIncidentsHomePath();
  return p.join(incidentsPath, 'index.json');
}

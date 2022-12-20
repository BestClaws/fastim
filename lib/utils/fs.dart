import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

Future<Directory> getFastimHome() async {
  var targetPath =
      p.join((await getApplicationDocumentsDirectory()).path, 'fastim');
  return Directory(targetPath);
}

Future<Directory> getIncidentsHome() async {
  var fastimHomePath = (await getFastimHome()).path;
  return Directory(p.join(fastimHomePath, 'incidents'));
}

/// creates a new directory for a given incident number.
/// does nothing if it already exists.
Future<Directory> createIncidentDirectory(String incidentNo) async {
  var targetPath = p.join((await getIncidentsHome()).path, incidentNo);
  return await Directory(targetPath).create();
}

Future<Directory> getIncidentDirectory(String incidentNo) async {
  var incidentsHomePath = (await getIncidentsHome()).path;
  var targetPath = p.join(incidentsHomePath, incidentNo);
  return Directory(targetPath);
}

// TODO: needs validation.
Future<File> createIncidentDetailsFile(String incidentNo) async {
  // NOTE: call to this function is kinda reduntant
  // you could instead call File(path).create({recursive: true})
  var incidentDirectory = await createIncidentDirectory(incidentNo);
  var incidentDetailsJsonPath = p.join(incidentDirectory.path, 'details.json');
  var incidentDetailsJsonFile = await File(incidentDetailsJsonPath).create();

  return incidentDetailsJsonFile;
}

Future<File> getIncidentDetailsFile(String incidentNo) async {
  var targetPath =
      p.join((await getIncidentDirectory(incidentNo)).path, 'details.json');
  return File(targetPath);
}

Future<File> getIncidentsIndexFile() async {
  var targetPath = p.join((await getIncidentsHome()).path, 'index.json');
  return File(targetPath);
}

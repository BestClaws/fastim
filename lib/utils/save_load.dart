import 'dart:convert';
import 'dart:io';

saveObj(String path, dynamic obj) async {
  var file = File(path);
  var str = jsonEncode(obj);
  await file.writeAsString(str);
}

dynamic loadObj(String path) async {
  var file = File(path);
  var dataStr = await file.readAsString();
  return jsonDecode(dataStr);
}

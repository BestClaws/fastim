import 'dart:convert';
import 'dart:io';

saveObj(File file, dynamic obj) async {
  var str = jsonEncode(obj);
  await file.writeAsString(str);
}

dynamic loadObj(File file) async {
  var dataStr = await file.readAsString();
  return jsonDecode(dataStr);
}

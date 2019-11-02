import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class Database {
  static var box;
  static Future init() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;
    Hive.init(appDocPath);
    box = await Hive.openBox('argo_famiglia');
    if (box != null) {
      return 'ok';
    }
  }

  static Future put(key, value) async {
    var r = await box.put(key, value);
    return r;
  }

  static Future get(key) async {
    var r = await box.get(key);
    return r;
  }
}

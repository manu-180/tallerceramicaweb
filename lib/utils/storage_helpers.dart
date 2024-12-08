// ignore: depend_on_referenced_packages
import 'package:shared_preferences/shared_preferences.dart';

class StorageHelper {
  static Future<void> clearCache() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}

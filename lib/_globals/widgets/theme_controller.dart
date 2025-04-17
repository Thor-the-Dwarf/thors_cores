import 'package:flutter/material.dart';

import '../../_admin/main_admin.dart';

class ThemeController extends ChangeNotifier {
  static final ThemeController _instance = ThemeController._internal();

  factory ThemeController() {
    debug("ThemeController() {");
    debug("\tSingleton-Instance zurückgegeben.");
    debug("}");
    return _instance;
  }

  ThemeMode _themeMode = ThemeMode.dark;

  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    debug("toggleTheme() {");
    debug("\tVorheriges ThemeMode: $_themeMode");
    _themeMode =
    _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    debug("\tNeues ThemeMode: $_themeMode");
    notifyListeners();
    debug("}");
  }

  ThemeController._internal() {
    debug("ThemeController._internal() {");
    debug("\tThemeController instanziert.");
    debug("}");
  }
}
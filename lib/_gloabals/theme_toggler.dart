import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void debug(String text) {
  // if (false || DEBUG_EVERYTHING) printYellow("[ThemeController] $text");
}

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
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
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

class ThemeToggler extends StatelessWidget {
  const ThemeToggler({super.key});

  @override
  Widget build(BuildContext context) {
    debug("ThemeToggler.build() {");

    final widgetTree = ChangeNotifierProvider.value(
      value: ThemeController(),
      child: Consumer<ThemeController>(
        builder: (context, vm, child) {
          debug("\tConsumer wird neu aufgebaut. Aktuelles Theme: ${vm.themeMode}");
          return IconButton(
            onPressed: () {
              debug("\tTheme-Toggle-Button gedrückt.");
              vm.toggleTheme();
            },
            icon: Icon(vm.themeMode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode),
          );
        },
      ),
    );

    debug("}");
    return widgetTree;
  }
}

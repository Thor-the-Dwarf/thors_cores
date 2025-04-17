import 'package:flutter/material.dart';
import 'package:neon_thors_cores/_globals/widgets/theme_controller.dart';
import 'package:provider/provider.dart';

void debug(String text) {
  // if (false || DEBUG_EVERYTHING) printYellow("[ThemeController] $text");
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
          debug(
            "\tConsumer wird neu aufgebaut. Aktuelles Theme: ${vm.themeMode}",
          );
          return IconButton(
            onPressed: () {
              debug("\tTheme-Toggle-Button gedrückt.");
              vm.toggleTheme();
            },
            icon: Icon(
              vm.themeMode == ThemeMode.dark
                  ? Icons.dark_mode
                  : Icons.light_mode,
            ),
          );
        },
      ),
    );

    debug("}");
    return widgetTree;
  }
}

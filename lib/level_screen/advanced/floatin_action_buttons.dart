import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../_globals/widgets/theme_controller.dart';

class FloatingActionButtons extends StatelessWidget {
  final VoidCallback onToggleMenu;
  final VoidCallback onTogglePayScreen;
  final bool isMenuOpen;
  final bool isPayScreenOpen;

  const FloatingActionButtons({
    Key? key,
    required this.onToggleMenu,
    required this.onTogglePayScreen,
    required this.isMenuOpen,
    required this.isPayScreenOpen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 24.0,
      right: MediaQuery.of(context).size.width * 0.025,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 40.0),
          FloatingActionButton(
            heroTag: 'theme_toggler',
            onPressed: () {
              Provider.of<ThemeController>(context, listen: false).toggleTheme();
            },
            mini: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Consumer<ThemeController>(
              builder: (context, controller, _) => Icon(
                controller.themeMode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode,
                color: Theme.of(context).iconTheme.color,
                size: 48.0,
              ),
            ),
          ),
          const SizedBox(height: 40.0),
          FloatingActionButton(
            heroTag: 'menu_toggle',
            onPressed: onToggleMenu,
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Icon(
              isMenuOpen ? Icons.close : Icons.menu,
              color: Theme.of(context).iconTheme.color,
              size: 48.0,
            ),
          ),
          const SizedBox(height: 40.0),
          FloatingActionButton(
            heroTag: 'support_me',
            onPressed: onTogglePayScreen,
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Icon(
              isPayScreenOpen ? Icons.close : Icons.handshake,
              color: Theme.of(context).iconTheme.color,
              size: 48.0,
            ),
          ),
        ],
      ),
    );
  }
}


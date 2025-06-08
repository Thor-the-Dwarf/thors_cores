import 'dart:math';
import 'package:flutter/material.dart';

List<String> btn_sprueche = [
  "🔥 Du bist auf dem richtigen Weg!",
  "🎯 Fokus! Du packst das!",
];

String zufaelliger_btn_spruch() {
  return btn_sprueche[Random().nextInt(btn_sprueche.length)];
}

class AchievementPopup extends StatelessWidget {
  const AchievementPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Runde abgeschlossen!",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              zufaelliger_btn_spruch(),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../main.dart';

class MyCustomPainter extends CustomPainter {
  final ThemeData theme;
  final double animationValue;
  final List<Offset> initialPoints;
  final List<Offset> targetPoints;

  MyCustomPainter(this.theme, this.animationValue, this.initialPoints, this.targetPoints);

  // Dynamische Punktfarben basierend auf dem Theme
  List<Color> _getPointColors() {
    if (theme.brightness == Brightness.dark) {
      // Helle, kontrastreiche Farben für Dark Mode
      return [
        Colors.redAccent,
        Colors.pinkAccent,
        Colors.purpleAccent,
        Colors.deepPurpleAccent,
        Colors.indigoAccent,
        Colors.blueAccent,
        Colors.lightBlueAccent,
        Colors.cyanAccent,
        Colors.tealAccent,
        Colors.greenAccent,
        Colors.lightGreenAccent,
        Colors.limeAccent,
        Colors.yellowAccent,
        Colors.amberAccent,
        Colors.orangeAccent,
        Colors.deepOrangeAccent,
        Colors.white70, // Leicht gedimmt für besseren Kontrast
      ];
    } else {
      // Dunklere, kontrastreiche Farben für Light Mode
      return [
        Colors.red,
        Colors.pink,
        Colors.purple,
        Colors.deepPurple,
        Colors.indigo,
        Colors.blue,
        Colors.cyan,
        Colors.teal,
        Colors.green,
        Colors.lightGreen,
        Colors.lime,
        Colors.yellow,
        Colors.amber,
        Colors.orange,
        Colors.deepOrange,
        Colors.brown,
        Colors.grey,
      ];
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    debug("paint() {");
    debug("\tCanvas Größe: ${size.width} x ${size.height}");

    // Animierte Punkte berechnen
    List<Offset> animatedPoints = List.generate(
      initialPoints.length,
          (index) => Offset(
        lerpDouble(initialPoints[index].dx, targetPoints[index].dx, animationValue)!,
        lerpDouble(initialPoints[index].dy, targetPoints[index].dy, animationValue)!,
      ),
    );

    // Linien zwischen Punkten zeichnen
    final lineColor = theme.colorScheme.onSurface.withOpacity(0.1); // Theme-konsistent
    for (int i = 0; i < animatedPoints.length; i++) {
      for (int j = i + 1; j < animatedPoints.length; j++) {
        final linePaint = Paint()
          ..color = lineColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.5;

        canvas.drawLine(
          Offset(animatedPoints[i].dx * size.width, animatedPoints[i].dy * size.height),
          Offset(animatedPoints[j].dx * size.width, animatedPoints[j].dy * size.height),
          linePaint,
        );
      }
    }

    // Punkte zeichnen
    final pointColors = _getPointColors();
    for (int i = 0; i < animatedPoints.length; i++) {
      final circlePaint = Paint()
        ..color = pointColors[i % pointColors.length] // Sicherstellen, dass wir nicht über den Index hinausgehen
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 18.0);

      canvas.drawCircle(
        Offset(animatedPoints[i].dx * size.width, animatedPoints[i].dy * size.height),
        size.width * 0.02,
        circlePaint,
      );
    }

    debug("\tPunkte und Linien gezeichnet.");
    debug("}");
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
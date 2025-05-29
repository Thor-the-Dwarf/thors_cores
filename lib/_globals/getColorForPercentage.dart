import 'dart:ui';
import 'package:flutter/material.dart';

// Eigenständige Methode für den Farbverlauf
Color getColorForPercentage(double percentage) {
  Color orangeRed = Color(0xFFFF4500);
  Color hotPink = Color(0xFFFF69B4);
  Color magenta = Color(0xFFFF00FF);

  List<Color> spectrumColors = [
    Colors.grey,        // 0% - Grau
    Colors.lightGreen,  // Grün
    Colors.lime,        // Grün
    Colors.cyan,        // Übergang zu Blau
    Colors.lightBlue,   // Blau
    Colors.blue,        // Blau
    Colors.indigo,      // Übergang zu Violett
    Colors.purple,      // Violett
    Colors.deepPurple,  // Violett
    magenta,            // Violett-Rosa
    hotPink,            // Rosa
    Colors.pink,        // Rosa
    Colors.red,         // Rot
    orangeRed,          // Rot-Orange
    Colors.orange,      // Orange
    Colors.yellow,      // Gelb - 100%
  ];

  final clampedPercentage = percentage.clamp(0, 100).toDouble();
  double segmentSize = 100 / (spectrumColors.length - 1);
  final double normalized = clampedPercentage / segmentSize;
  final int startIndex = normalized.floor();
  final double fraction = normalized - startIndex;

  if (startIndex >= spectrumColors.length - 1) {
    return spectrumColors.last;
  }

  return Color.lerp(
    spectrumColors[startIndex],
    spectrumColors[startIndex + 1],
    fraction,
  )!;
}
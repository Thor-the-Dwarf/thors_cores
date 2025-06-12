import 'package:flutter/material.dart';

// Klasse für Levels (kann mehrere Sublevels und Cores haben)
class Level extends ChangeNotifier {
  final String levelPk;
  final List<Level> sublevel; // Liste von Sublevel-Objekten
  final List<Core> cores; // Liste von Core-Objekten, die diesem Level gehören
  final String name;
  final String details;
  bool isExpanded;
  final Color? color;

  Level({
    required this.levelPk,
    this.sublevel = const [],
    this.cores = const [],
    required this.name,
    required this.details,
    this.isExpanded = false,
    this.color,
  });
}

// Klasse für Cores (gehört zu einem oder mehreren Levels)
class Core extends ChangeNotifier {
  final String corePk;
  final String name;
  final String details;
  bool isExpanded;
  final Color? color;

  Core({
    required this.corePk,
    required this.name,
    required this.details,
    this.isExpanded = false,
    this.color,
  });
}

// Klasse für Essence
class Essence {
  final String essencePk;
  final String coreFk;
  final String name;

  Essence({
    required this.essencePk,
    required this.coreFk,
    required this.name,
  });
}


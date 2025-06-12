import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Color ProgressColor(double progress){
//   //todo stelle sicher das progress zwiscchen 0 und 100 liegt
//   // todo farbskala:
//   //  0% voll rot
//   //  16,66% voll orange
//   //  33,33% voll gelb
//   //  49,99% voll grün
//   //  66,66% voll blau
//   //  100% voll purpur
// }

// Klasse für Levels (kann mehrere Sublevels und Cores haben)
class Level extends ChangeNotifier {
  bool isLoaded = false;
  double progress = 0.0;
  final String level_pk;
  late final List<Level> sublevel; // Liste von Sublevel-Objekten
  late final List<Core> cores; // Liste von Core-Objekten, die diesem Level gehören
  late final String name;
  late final String details;
  bool _isExpanded = false;

  bool get isExpanded => _isExpanded;

  void set isExpanded(bool value){
    _isExpanded = value;
    if (! _isExpanded)
      for(Level level in sublevel)
        level.isExpanded = false;
    notifyListeners();
  }

  Level({
    required this.level_pk,
  }){_load();}

  Future<void> _load() async {
    try {
      final supabase = Supabase.instance.client;

      // 1. Lade Hauptdaten des Levels (name, details)
      final levelData = await supabase
          .from('levels')
          .select('name, details')
          .eq('level_pk', level_pk)
          .single();

      name = levelData['name'] as String;
      details = levelData['details'] as String;

      // 2. Lade Sublevel (aus der Tabelle sub_levels)
      final sublevelData = await supabase
          .from('sub_levels')
          .select('child_level_fk')
          .eq('parent_level_fk', level_pk);

      sublevel = [];
      for (var sub in sublevelData) {
        final childLevelPk = sub['child_level_fk'] as String;
        sublevel.add(Level(level_pk: childLevelPk));
      }

      // 3. Lade Cores (aus der Tabelle level_cores)
      final coreData = await supabase
          .from('level_cores')
          .select('core_fk')
          .eq('parent_level_fk', level_pk);

      cores = [];
      for (var core in coreData) {
        final corePk = core['core_fk'] as String;
        cores.add(Core(corePk: corePk));
      }

      isLoaded = true;
    } catch (e) {
      print('Fehler beim Laden von Level $level_pk: $e');
      name = '';
      details = '';
      sublevel = [];
      cores = [];
      isLoaded = true;
    }

    notifyListeners();
  }

}


// Klasse für Cores (gehört zu einem oder mehreren Levels)
class Core extends ChangeNotifier {
  bool isLoaded = false;
  double progress = 0.0;
  final String corePk;
  late final String name;
  late final String details;
  late final int essences_length;

  Core({
    required this.corePk,
  });

  Future<void> load() async {
    try {
      final supabase = Supabase.instance.client;

      // 1. Lade Hauptdaten des Cores (name, details)
      final coreData = await supabase
          .from('cores')
          .select('name, details')
          .eq('corePk', corePk)
          .single();

      name = coreData['name'] as String;
      details = coreData['details'] as String;

      // 2. Lade die Anzahl der Essences (essences_length)
      final essencesCount = await supabase
          .from('essences')
          .count()
          .eq('coreFk', corePk);

      essences_length = essencesCount;

      isLoaded = true;
    } catch (e) {
      print('Fehler beim Laden von Core $corePk: $e');
      name = '';
      details = '';
      essences_length = 0;
      isLoaded = true;
    }

    notifyListeners();
  }
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


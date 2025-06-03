import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../level_manager.dart';
import '../tree_node.dart';

abstract class Player extends ChangeNotifier {
  bool _isLoaded = false;
  String key = "";
  List<Core> cores = [];
  Map<String, double> experience = {};

  bool get isLoaded => _isLoaded;

  set isLoaded(bool value) {
    this._isLoaded = value;
    notifyListeners();
  }

  // Speichert eine Liste von Core_-Objekten
  Future<void> save();

  // Lädt eine Liste von Core_-Objekten
  Future<void> load({required String key});

  Future<void> loadExpirience({required TreeNode treeNode}) async {
    final coreData = SupabaseManager().coreData;

    // Erstelle eine Map von Core-ID zu Player.Core für schnellen Zugriff
    final coreMap = Map<String, Core>.fromEntries(
      cores.map((core) => MapEntry(core.id, core)),
    );

    // Rekursive Funktion zur Berechnung des Level-Fortschritts
    Future<double> calculateLevelProgress(TreeNode node) async {
      List<double> progresses = [];

      // 1. Core-Fortschritt berechnen, wenn der Node Cores hat
      if (node.hasCores) {
        final coresForLevel = coreData[node.id] as List<dynamic>? ?? [];
        for (var treeCore in coresForLevel) {
          final coreId = treeCore['id'] as String; // Core-ID aus coreData
          final playerCore =
              coreMap[coreId] ??
              Core(
                id: coreId,
                richtigeEssenzen: [],
                falscheEssenzen: [],
              ); // Fallback

          // Hole essences_count aus coreData
          final essencesCount = treeCore['essences_count'] as int? ?? 0;
          final richtigeEssenzenCount =
              playerCore.richtigeEssenzen?.length ?? 0;

          // Berechne Fortschritt gemäß der Formel
          final progress =
              essencesCount == 0
                  ? 0.0
                  : (essencesCount / 100.0) * richtigeEssenzenCount;

          playerCore.progress = progress;
          progresses.add(progress);

          // Aktualisiere coreMap, falls ein neues Core erstellt wurde
          coreMap[coreId] = playerCore;
        }
      }

      // 2. Sublevel-Fortschritt berechnen
      for (var child in node.children) {
        final childProgress = await calculateLevelProgress(child);
        progresses.add(childProgress);
      }

      // 3. Aggregiere Fortschritte (Durchschnitt)
      final levelProgress =
          progresses.isNotEmpty
              ? progresses.reduce((a, b) => a + b) / progresses.length
              : 0.0;

      // Speichere Level-Fortschritt
      experience[node.id] = levelProgress;
      return levelProgress;
    }

    // Berechne Fortschritt für den gegebenen TreeNode
    await calculateLevelProgress(treeNode);

    // Aktualisiere cores-Liste
    cores = coreMap.values.toList();

    // Speichere aktualisierte Cores
    await save();
    notifyListeners(); // Benachrichtige UI über Änderungen
  }

  void answered({required bool correct, required String essence_id, required String question_id}) {
    // Finde oder erstelle das relevante Core_-Objekt
    Core? core = cores.firstWhere(
          (core) => core.id == essence_id,
      orElse: () {
        final newCore = Core(
          id: essence_id,
          richtigeEssenzen: [],
          falscheEssenzen: [],
        );
        cores.add(newCore);
        return newCore;
      },
    );

    // Finde oder erstelle das Essence_-Objekt
    Essence? essence = core.richtigeEssenzen?.firstWhere(
          (e) => e.essenceFk == essence_id,
      orElse: () => Essence(essenceFk: essence_id, richtigeFragen: [], falscheFragen: []),
    ) ??
        core.falscheEssenzen?.firstWhere(
              (e) => e.essenceFk == essence_id,
          orElse: () => Essence(essenceFk: essence_id, richtigeFragen: [], falscheFragen: []),
        );

    if (essence == null) {
      essence = Essence(essenceFk: essence_id, richtigeFragen: [], falscheFragen: []);
      if (correct) {
        core.richtigeEssenzen ??= [];
        core.richtigeEssenzen!.add(essence);
      } else {
        core.falscheEssenzen ??= [];
        core.falscheEssenzen!.add(essence);
      }
    }

    // Bewege die Frage zwischen richtigeFragen und falscheFragen
    if (correct) {
      essence.falscheFragen?.remove(question_id);
      essence.richtigeFragen ??= [];
      if (!essence.richtigeFragen!.contains(question_id)) {
        essence.richtigeFragen!.add(question_id);
      }
      // Bewege Essence zu richtigeEssenzen, falls es in falscheEssenzen ist
      if (core.falscheEssenzen?.contains(essence) ?? false) {
        core.falscheEssenzen!.remove(essence);
        core.richtigeEssenzen ??= [];
        core.richtigeEssenzen!.add(essence);
      }
    } else {
      essence.richtigeFragen?.remove(question_id);
      essence.falscheFragen ??= [];
      if (!essence.falscheFragen!.contains(question_id)) {
        essence.falscheFragen!.add(question_id);
      }
      // Bewege Essence zu falscheEssenzen, falls es in richtigeEssenzen ist
      if (core.richtigeEssenzen?.contains(essence) ?? false) {
        core.richtigeEssenzen!.remove(essence);
        core.falscheEssenzen ??= [];
        core.falscheEssenzen!.add(essence);
      }
    }
  }
}

class Core {
  late String id; // Hinzugefügt
  late double progress;
  List<Essence>? richtigeEssenzen;
  List<Essence>? falscheEssenzen;

  Core({
    required this.id,
    this.progress = 0.0,
    this.richtigeEssenzen,
    this.falscheEssenzen,
  });

  static Core fromJson(Map<String, dynamic> json) {
    return Core(
      id: json['id'], // Hinzugefügt
      richtigeEssenzen:
          (json['richtige_essenzen'] as List?)
              ?.map((e) => Essence.fromJson(e))
              .toList(),
      falscheEssenzen:
          (json['falsche_essenzen'] as List?)
              ?.map((e) => Essence.fromJson(e))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id, // Hinzugefügt
      'richtige_essenzen': richtigeEssenzen?.map((e) => e.toJson()).toList(),
      'falsche_essenzen': falscheEssenzen?.map((e) => e.toJson()).toList(),
    };
  }
}

class Essence {
  String? essenceFk;
  List<String>? richtigeFragen;
  List<String>? falscheFragen;

  Essence({this.essenceFk, this.richtigeFragen, this.falscheFragen});

  // Interne Methode zum Parsen des JSON für ein Essence-Objekt
  static Essence fromJson(Map<String, dynamic> json) {
    return Essence(
      essenceFk: json['essence_fk'],
      richtigeFragen: (json['richtige_fragen'] as List?)?.cast<String>(),
      falscheFragen: (json['falsche_fragen'] as List?)?.cast<String>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'essence_fk': essenceFk,
      'richtige_fragen': richtigeFragen,
      'falsche_fragen': falscheFragen,
    };
  }
}

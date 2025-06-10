import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../_globals/debug_prints.dart';
import '../supabase_manager.dart';
import '../tree_node.dart';

/**  Beispiel:
    {
    "id": "012b4753-c19c-42ab-99e6-dfa962456f2c",
    "richtige_essenzen": [
    {
    "essence_fk": "2a19e5d7-8c6f-4337-92c1-d1ace5494b08",
    "richtige_fragen": [
    "efb078e7-3c26-4fdb-96f6-981e9cec0b26",
    "f745fd6b-f3da-401d-be1c-c5380c7815e2",
    "12b9033b-a644-47f5-bbe6-cc0f7bbe98ea",
    "bf60e906-c4dd-4dc9-b3bc-0cacc1589b0e",
    "5afe3428-61e6-447f-9bf0-c9a88c2de0da",
    "74ca79cd-8e03-4819-9206-f3ed0c82da3c",
    "19bdb243-c9ed-44c0-8b8c-9b02f64237ce",
    "c8e0949e-93f3-464c-807d-323b1cf568eb",
    "8fab4d72-59d0-48f1-80a0-488c5441cf70",
    "1399b421-e03a-4394-9afb-6a2dcaa2783d",
    "478b1b94-2393-4fcf-8a05-a3c3bc5d3a17",
    "34662e16-d9d5-48aa-b871-15765b616333",
    "ebe33c34-f326-4966-a43b-681d851f4d0d",
    "047b998a-696e-4fc8-9bba-cbc3927a573e",
    "bfbcbe03-1d1a-4f52-93d8-884d7de12606",
    "3ca82c3f-4fbd-477e-98b4-8d8c1faa91b9",
    "eb4e3880-0a80-4756-861d-26fc662c572c",
    "8f3c0079-bb9f-44a4-8ccd-c92524f0e4dc",
    "ba726ea8-8a5b-42eb-a88c-ad1d80cd7416",
    "0943f115-0a44-4627-a1d4-a67f80cb10bb"
    ],
    "falsche_fragen": []
    }
    ],
    "falsche_essenzen": []
    }
 * */

void DEBUG(String text) {
  if (true || DEBUG_EVERYTHING) printYellow("[Player] $text");
}

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
  Future<void> loadOrCreate({required String key});

  Future<void> loadExpirience({required TreeNode treeNode}) async {
    // Vermeide mehrfache Verarbeitung desselben Cores
    final coreMap = <String, Core>{};
    for (var core in this.cores) {
      if (!coreMap.containsKey(core.id)) {
        coreMap[core.id] = core;
        final essencesCount = (core.richtigeEssenzen?.length ?? 0) + (core.falscheEssenzen?.length ?? 0);
        final richtigeEssenzenCount = core.richtigeEssenzen?.where((e) => e.richtigeFragen?.isNotEmpty ?? false).length ?? 0;
        core.progress = essencesCount > 0 ? (richtigeEssenzenCount / essencesCount) * 100.0 : 0.0;
        DEBUG('Core ${core.id}: essencesCount=$essencesCount, richtigeEssenzenCount=$richtigeEssenzenCount, progress=${core.progress}');
      }
    }

    Future<double> calculateLevelProgress(TreeNode node) async {
      List<double> progresses = [];
      if (node.hasCores) {
        final coresForLevel = this.cores.where((c) => c.levelId == node.id).toList(); // Zuordnung über levelId
        for (var core in coresForLevel) {
          progresses.add(core.progress);
          DEBUG('Core ${core.id} for level ${node.id} progress: ${core.progress}');
        }
      }
      for (var child in node.children) {
        final childProgress = await calculateLevelProgress(child);
        progresses.add(childProgress);
      }
      final levelProgress = progresses.isNotEmpty ? progresses.reduce((a, b) => a + b) / progresses.length : 0.0;
      experience[node.id] = levelProgress;
      DEBUG('Level ${node.id} progress: $levelProgress');
      return levelProgress;
    }

    await calculateLevelProgress(treeNode);
    cores = coreMap.values.toList();
    await save();
    notifyListeners();
  }

  void answered({required bool correct, required String essence_id, required String question_id, required context}) {
    Core? core = cores.firstWhere(
          (core) => core.id == essence_id,
      orElse: () {
        TreeNode? findNodeWithEssence(String essenceId, List<TreeNode> nodes) {
          for (var node in nodes) {
            if (node.hasCores) {
              final cores = Provider.of<SupabaseManager>(context, listen: false).coreData[node.id] ?? [];
              if (cores.any((c) => c['id'] == essenceId)) {
                return node;
              }
            }
            if (node.children.isNotEmpty) {
              final found = findNodeWithEssence(essenceId, node.children);
              if (found != null) return found;
            }
          }
          return null;
        }
        final node = findNodeWithEssence(essence_id, Provider.of<SupabaseManager>(context, listen: false).tree);
        final newCore = Core(
          id: essence_id,
          levelId: node?.id ?? '',
          richtigeEssenzen: [],
          falscheEssenzen: [],
        );
        cores.add(newCore);
        return newCore;
      },
    );

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

    if (correct) {
      essence.falscheFragen?.remove(question_id);
      essence.richtigeFragen ??= [];
      if (!essence.richtigeFragen!.contains(question_id)) {
        essence.richtigeFragen!.add(question_id);
      }
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
      if (core.richtigeEssenzen?.contains(essence) ?? false) {
        core.richtigeEssenzen!.remove(essence);
        core.falscheEssenzen ??= [];
        core.falscheEssenzen!.add(essence);
      }
    }

    // Aktualisiere Core-Progress
    final essencesCount = (core.richtigeEssenzen?.length ?? 0) + (core.falscheEssenzen?.length ?? 0);
    final richtigeEssenzenCount = core.richtigeEssenzen?.where((e) => e.richtigeFragen?.isNotEmpty ?? false).length ?? 0;
    core.progress = essencesCount > 0 ? (richtigeEssenzenCount / essencesCount) * 100.0 : 0.0;

    // Aktualisiere experience für den Level
    final levelId = core.levelId;
    if (levelId.isNotEmpty) {
      final levelCores = cores.where((c) => c.levelId == levelId).toList();
      final levelProgress = levelCores.isNotEmpty
          ? levelCores.map((c) => c.progress).reduce((a, b) => a + b) / levelCores.length
          : 0.0;
      experience[levelId] = levelProgress;
      // Aktualisiere auch die Eltern-Level
      final supabaseManager = Provider.of<SupabaseManager>(context, listen: false);
      var currentNode = supabaseManager.tree.firstWhere(
            (node) => node.id == levelId,
        orElse: () => TreeNode(id: '', name: '', children: []),
      );
      while (currentNode.id.isNotEmpty) {
        final parentLevelCores = cores.where((c) => c.levelId == currentNode.id).toList();
        final parentProgress = parentLevelCores.isNotEmpty
            ? parentLevelCores.map((c) => c.progress).reduce((a, b) => a + b) / parentLevelCores.length
            : 0.0;
        experience[currentNode.id] = parentProgress;
        currentNode = supabaseManager.tree.firstWhere(
              (node) => node.children.any((child) => child.id == currentNode.id),
          orElse: () => TreeNode(id: '', name: '', children: []),
        );
      }
    }

    save();
    notifyListeners();
  }

}

class Core {
  late String id;
  late String levelId; // Neue Eigenschaft
  late double progress;
  List<Essence>? richtigeEssenzen;
  List<Essence>? falscheEssenzen;

  Core({
    required this.id,
    required this.levelId,
    this.progress = 0.0,
    this.richtigeEssenzen,
    this.falscheEssenzen,
  });

  static Core fromJson(Map<String, dynamic> json) {
    return Core(
      id: json['id'],
      levelId: json['level_id'] ?? '', // Muss in deinen Daten vorhanden sein
      richtigeEssenzen: (json['richtige_essenzen'] as List?)?.map((e) => Essence.fromJson(e)).toList(),
      falscheEssenzen: (json['falsche_essenzen'] as List?)?.map((e) => Essence.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'level_id': levelId,
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
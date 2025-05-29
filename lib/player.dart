import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';

// Dummy-Player mit Testdaten
Player dummyPlayer = Player(
  'dummy',
  [],
);



class Player {
  final String id;
  final List<Core_> cores;

  Player(this.id, this.cores);

  static Future<Player?> fromId(String id) async {
    final supabase = Supabase.instance.client;
    final response = await supabase
        .from('player')
        .select('id, cores')
        .eq('id', id)
        .maybeSingle();

    return response == null ? null : Player.fromJson(response);
  }


  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      json['id'] as String,
      (json['cores'] as List<dynamic>? ?? [])
          .map((e) => Core_.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cores': cores.map((e) => e.toJson()).toList(),
    };
  }

  String get coresAsJsonString => jsonEncode(cores.map((e) => e.toJson()).toList());

  Future<void> saveToSupabase() async {
    final supabase = Supabase.instance.client;
    await supabase
        .from('player')
        .update({'cores': cores.map((e) => e.toJson()).toList()})
        .eq('id', id);
  }

  void answeredCorrect(String essence_id, String frage_id) {
    Core_? targetCore;
    Essence_? targetEssence;
    bool inRichtigeEssenzen = false;

    for (var core in cores) {
      for (var essence in core.richtigeEssenzen) {
        if (essence.essence_id == essence_id) {
          targetCore = core;
          targetEssence = essence;
          inRichtigeEssenzen = true;
          break;
        }
      }
      if (targetEssence == null) {
        for (var essence in core.falscheEssenzen) {
          if (essence.essence_id == essence_id) {
            targetCore = core;
            targetEssence = essence;
            break;
          }
        }
      }
      if (targetEssence != null) break;
    }

    if (targetEssence == null || targetCore == null) {
      return;
    }

    if (targetEssence.falscheFragen.contains(frage_id)) {
      targetEssence.falscheFragen.remove(frage_id);
      if (!targetEssence.richtigeFragen.contains(frage_id)) {
        targetEssence.richtigeFragen.add(frage_id);
      }
    }

    if (targetEssence.falscheFragen.isEmpty && !inRichtigeEssenzen) {
      targetCore.falscheEssenzen.removeWhere((e) => e.essence_id == essence_id);
      if (!targetCore.richtigeEssenzen.any((e) => e.essence_id == essence_id)) {
        targetCore.richtigeEssenzen.add(targetEssence);
      }
    }

    saveToSupabase();
  }

  void answeredWrong(String essence_id, String frage_id) {
    Core_? targetCore;
    Essence_? targetEssence;
    bool inFalscheEssenzen = false;

    for (var core in cores) {
      for (var essence in core.falscheEssenzen) {
        if (essence.essence_id == essence_id) {
          targetCore = core;
          targetEssence = essence;
          inFalscheEssenzen = true;
          break;
        }
      }
      if (targetEssence == null) {
        for (var essence in core.richtigeEssenzen) {
          if (essence.essence_id == essence_id) {
            targetCore = core;
            targetEssence = essence;
            break;
          }
        }
      }
      if (targetEssence != null) break;
    }

    if (targetEssence == null || targetCore == null) {
      return;
    }

    if (targetEssence.richtigeFragen.contains(frage_id)) {
      targetEssence.richtigeFragen.remove(frage_id);
      if (!targetEssence.falscheFragen.contains(frage_id)) {
        targetEssence.falscheFragen.add(frage_id);
      }
    }

    if (targetEssence.richtigeFragen.isEmpty && !inFalscheEssenzen) {
      targetCore.richtigeEssenzen.removeWhere((e) => e.essence_id == essence_id);
      if (!targetCore.falscheEssenzen.any((e) => e.essence_id == essence_id)) {
        targetCore.falscheEssenzen.add(targetEssence);
      }
    }

    saveToSupabase();
  }
}


class Core_ {
  final List<Essence_> richtigeEssenzen;
  final List<Essence_> falscheEssenzen;

  Core_(this.richtigeEssenzen, this.falscheEssenzen);

  factory Core_.fromJson(Map<String, dynamic> json) {
    return Core_(
      (json['richtige_essenzen'] as List<dynamic>? ?? [])
          .map((e) => Essence_.fromJson(e as Map<String, dynamic>))
          .toList(),
      (json['falsche_essenzen'] as List<dynamic>? ?? [])
          .map((e) => Essence_.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'richtige_essenzen': richtigeEssenzen.map((e) => e.toJson()).toList(),
      'falsche_essenzen': falscheEssenzen.map((e) => e.toJson()).toList(),
    };
  }
}

class Essence_ {
  final String essence_id;
  final List<String> richtigeFragen;
  final List<String> falscheFragen;

  Essence_(this.essence_id, this.richtigeFragen, this.falscheFragen);

  factory Essence_.fromJson(Map<String, dynamic> json) {
    return Essence_(
      json['essence_id'] as String,
      (json['richtige_fragen'] as List<dynamic>? ?? []).cast<String>(),
      (json['falsche_fragen'] as List<dynamic>? ?? []).cast<String>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'essence_id': essence_id,
      'richtige_fragen': richtigeFragen,
      'falsche_fragen': falscheFragen,
    };
  }
}
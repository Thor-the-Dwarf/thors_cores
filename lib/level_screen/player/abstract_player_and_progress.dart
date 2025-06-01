import 'package:flutter/cupertino.dart';

abstract class Player extends ChangeNotifier {
  bool _isLoaded = false;
  String key = "thors_cores";
  List<Core> cores = [];

  bool get isLoaded => _isLoaded;

  set isLoaded(bool value) {
    this._isLoaded = value;
    notifyListeners();
  }

  // Speichert eine Liste von Core-Objekten
  Future<void> save();

  // Lädt eine Liste von Core-Objekten
  Future<void> load({required String key});
}

class Core {
  List<Essence>? richtigeEssenzen;
  List<Essence>? falscheEssenzen;

  Core({this.richtigeEssenzen, this.falscheEssenzen});

  // Interne Methode zum Parsen des JSON für ein Core-Objekt
  static Core fromJson(Map<String, dynamic> json) {
    return Core(
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

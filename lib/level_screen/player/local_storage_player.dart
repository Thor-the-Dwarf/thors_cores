import 'dart:convert';
import 'dart:html' show window;
import 'abstract_player_and_progress.dart';

class LocalStoragePlayer extends Player {
  // Privater Konstruktor
  LocalStoragePlayer._internal();

  // Statische Instanz, die lazy initialisiert wird
  static final LocalStoragePlayer _instance = LocalStoragePlayer._internal();

  // Factory Konstruktor für Zugriff
  factory LocalStoragePlayer() {
    return _instance;
  }


  @override
  Future<void> save() async {
    if (key == null || key.isEmpty) return; // wenn der user "nicht speichern" gewählt hat
    final jsonData = cores.map((core) => core.toJson()).toList();
    window.localStorage[key] = jsonEncode(jsonData);
  }

  @override
  Future<void> load({required String? key}) async {
    // wenn der user "nicht speichern" gewählt hat
    if (key == null || key.isEmpty) {
      cores = [];
      isLoaded = true;
      notifyListeners();
      return;
    }

    this.key = key;
    final jsonString = window.localStorage[key];

    try {
      if (jsonString == null) throw Exception('Kein Eintrag im localStorage');
      final jsonData = jsonDecode(jsonString) as List;
      this.cores = jsonData.map((item) => Core.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      this.cores = [];
      window.localStorage[key] = jsonEncode([]); // Leeren JSON-Array speichern


      isLoaded = true;
      notifyListeners();
    }
  }
}
import 'dart:convert';
import 'dart:html' show window;
import 'dart:math';
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


    // Generiert einen UUID-ähnlichen Schlüssel
  static String _generateCustomUuid() {
    const String chars = '0123456789abcdef';
    final Random random = Random();
    String generateSegment(int length) {
      return String.fromCharCodes(
        Iterable.generate(
          length,
              (_) => chars.codeUnitAt(random.nextInt(chars.length)),
        ),
      );
    }
    return '${generateSegment(8)}-${generateSegment(4)}-${generateSegment(4)}-${generateSegment(4)}-${generateSegment(12)}';
  }

  @override
  Future<void> save() async {
    final jsonData = cores.map((core) => core.toJson()).toList();
    window.localStorage[key] = jsonEncode(jsonData);
  }

  @override
  Future<void> load({required key}) async {
    this.key = key;
    final jsonString = window.localStorage[key];
    if (jsonString == null || jsonString.isEmpty) {
      this.cores = [];
    }
    else{
      final jsonData = jsonDecode(jsonString) as List;
      this.cores =  jsonData.map((item) => Core.fromJson(item as Map<String, dynamic>)).toList();
    }
  }
}
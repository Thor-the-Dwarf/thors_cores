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
    if (key == null || key.isEmpty) {
      DEBUG('Save abgebrochen: Kein Schlüssel gesetzt');
      return;
    }
    // Füge die Pseudodaten zur cores-Liste hinzu
    final pseudoData = {
      "id": "c217e4bd-376b-4b98-9802-528f451f5de9",
      "richtige_essenzen": [
        {
          "essence_fk": "0e8a4c72-6771-4e2d-9bba-a4808a86e8d4",
          "richtige_fragen": [
            "c62550e7-4a34-444d-8ed3-2c48311c1719",
            "64c59e42-231e-4c49-9b58-36067cc8d53a",
            "8e5ff0a8-6a2d-4c1a-8fa7-898dce9adee0",
            "8c3e7108-d825-48e4-8d8a-7f5a5f521a15",
            "cc469786-fa74-4789-8b0d-ec87e80b1160",
            "db1fe9ff-2011-4931-82a6-7982df4d0366",
            "97067f28-1952-426b-b098-7e5e0ec7cdcc",
            "4208aea6-4b7b-4b2c-8067-23209ab65900",
            "0564d7c5-5d5b-45d8-874c-e780f835dade",
            "c417b6fc-1b60-4e9f-af7e-94dc4cf70e833d",
            "1919164e-a10c-4896-b76e-123d0765c634",
            "d56d7c02-965b-4d19-8bfd-876820f049d8",
            "18b732f7-f920-4035-8eb8-17c2a7bae728",
            "a4dc5a68-503f-485e-b7d2-d5e30da9f453",
            "4aefcf74-a20f-46cd-9f1a-692631b69dd0",
            "2f3b2da7-d914-4319-80f5-0a15abcaef30",
            "a2337f5f-8a4a-4bd8-b6d7-5832e4a0e3ca",
            "bc179e00-8db4-4591-9f40-51abea5e24de",
            "4e760428-1879-47c4-8e6e-942f8e80875c",
            "7a94aea4-4d50-4681-8906-9a19d2a613f1"
          ],
          "falsche_fragen": []
        }
      ],
      "falsche_essenzen": []
    };
    // Konvertiere Pseudodaten zu Core-Objekt und füge sie hinzu, falls nicht vorhanden
    final pseudoCore = Core.fromJson({
      ...pseudoData,
      'level_id': 'c51fc206-6b94-4dd0-bb62-2bd9044c0963',
    });
    if (!cores.any((core) => core.id == pseudoCore.id)) {
      cores.add(pseudoCore);
    }
    final jsonData = cores.map((core) => core.toJson()).toList();
    window.localStorage[key] = jsonEncode(jsonData);
    DEBUG('Gespeichert unter Schlüssel $key: $jsonData');
    notifyListeners();
  }

  @override
  Future<bool> enterLocalStorage({required String key}) async {
    // Prüfe, ob Daten unter dem gegebenen key im LocalStorage vorhanden sind
    final jsonString = window.localStorage[key];

    if (jsonString != null && jsonString.isNotEmpty) {
      // Daten vorhanden, setze den key und lade die Daten
      this.key = key;
      await loadOrCreate(key: key);
      return true; // Erfolgreich initialisiert
    } else {
      // Keine Daten vorhanden, setze cores auf leere Liste
      this.cores = [];
      this.key = key;
      isLoaded = true;
      notifyListeners();
      return false; // Kein LocalStoragePlayer erstellt
    }
  }

  @override
  Future<void> loadOrCreate({required String? key}) async {
    if (key == null || key.isEmpty) {
      cores = [];
      isLoaded = true;
      notifyListeners();
      return;
    }

    this.key = key;
    final jsonString = window.localStorage[key];
    DEBUG('Loaded JSON String: $jsonString');

    try {
      if (jsonString == null) throw Exception('Kein Eintrag im localStorage');
      final jsonData = jsonDecode(jsonString) as List;
      this.cores = jsonData.map((item) => Core.fromJson(item as Map<String, dynamic>)).toList();
      DEBUG('Loaded cores from JSON: ${this.cores.map((c) => c.toJson()).toList()}');
    } catch (e) {
      DEBUG('Error parsing JSON, initializing with test data: $e');
      final testData = {
        "level_id": "032e4fac-bbe1-481e-89be-4946bce69d62", // Zuordnung zum Level
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
      };

      final core = Core.fromJson(testData);
      this.cores = [core];
      final encodedData = jsonEncode([testData]);
      window.localStorage[key] = encodedData;
      DEBUG('Initialized cores with test data: ${this.cores.map((c) => c.toJson()).toList()}');
      DEBUG('Stored JSON: $encodedData');
      isLoaded = true;
      notifyListeners();
    }
  }
}
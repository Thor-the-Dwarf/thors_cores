import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../_gloabals/widgets/my_background.dart';
import '../_gloabals/widgets/theme_toggler.dart';

// Datenklasse für die Baumstruktur
class TreeNode {
  final String id;          // UUID aus level_pk oder core_pk
  final String name;        // Name des Levels oder Cores
  final bool isCore;        // Unterscheidet Core (true) von Level (false)
  final List<TreeNode> children; // Liste der Unterknoten (Sublevels oder Cores)
  final bool hasCores;      // Neue Eigenschaft: Hat dieses Level/Sublevel Cores?

  TreeNode({
    required this.id,
    required this.name,
    this.isCore = false,
    List<TreeNode>? children,
    this.hasCores = false, // Standardmäßig false
  }) : children = children ?? [];
}

// Funktion zum Aufbau des Baums aus flachen Daten (ohne Cores)
List<TreeNode> buildTree(List<Map<String, dynamic>> rawData, Map<String, Set<String>> levelCoreConnections) {
  // Map für schnellen Zugriff auf Knoten nach ID
  final Map<String, TreeNode> nodes = {};
  // Map, die Kinder-IDs nach Eltern-ID gruppiert
  final Map<String, List<String>> childMap = {};

  // Schritt 1: Erstelle alle Knoten (nur Levels/Sublevels, keine Cores)
  for (var row in rawData) {
    if (row['is_core'] == true) {
      continue; // Überspringe Cores für die Baumstruktur
    }
    nodes[row['id']] = TreeNode(
      id: row['id'],
      name: row['name'],
      isCore: row['is_core'],
      hasCores: levelCoreConnections.containsKey(row['id']), // Hat dieses Level/Sublevel Cores?
    );
    // Wenn es einen Parent gibt, füge die ID zur childMap hinzu
    if (row['parent_id'] != null) {
      childMap.putIfAbsent(row['parent_id'], () => []).add(row['id']);
    }
  }

  // Schritt 2: Verknüpfe Kinder mit ihren Eltern
  List<TreeNode> roots = []; // Liste der Wurzelknoten (ohne Eltern)
  nodes.forEach((id, node) {
    // Wenn dieser Knoten Kinder hat, füge sie hinzu
    if (childMap.containsKey(id)) {
      for (var childId in childMap[id]!) {
        node.children.add(nodes[childId]!);
      }
    }
    // Wenn der Knoten kein Elternteil in den Daten hat, ist er eine Wurzel
    if (!rawData.any((row) => row['id'] == id && row['parent_id'] != null)) {
      roots.add(node);
    }
  });

  return roots; // Gib die Wurzelknoten zurück
}

// Haupt-Widget für den Spalten-Baum
class LevelScreen extends StatefulWidget {
  const LevelScreen({super.key});

  @override
  _LevelScreenState createState() => _LevelScreenState();
}

class _LevelScreenState extends State<LevelScreen> {
  bool isLoading = true; // Ladezustand
  List<TreeNode> tree = []; // Der aufgebaute Baum
  late final SupabaseClient supabase; // Supabase-Client für Datenbankzugriff
  List<List<TreeNode>> columns = [[]]; // Liste der Spalten (von rechts nach links)
  TreeNode? selectedNode; // Aktuell ausgewählter Knoten

  @override
  void initState() {
    super.initState();
    supabase = Supabase.instance.client; // Initialisiere Supabase
    _loadTreeData(); // Lade die Baumdaten
  }

  // Funktion zum Laden der Baumdaten aus der Datenbank
  Future<void> _loadTreeData() async {
    try {
      // Hole alle Levels
      final levelsResponse = await supabase
          .from('levels')
          .select('level_pk, name')
          .order('name');

      // Hole alle Sublevels
      final subLevelsResponse = await supabase
          .from('sub_levels')
          .select('parent_level_fk, child_level_fk');

      // Hole alle Cores
      final coresResponse = await supabase
          .from('core')
          .select('core_pk, name');

      // Hole alle Level-Cores-Verknüpfungen
      final levelCoresResponse = await supabase
          .from('level_cores')
          .select('parent_level_fk, core_fk');

      // Kombiniere die Daten in eine flache Liste
      List<Map<String, dynamic>> rawData = [];

      // Levels hinzufügen
      if (levelsResponse != null && levelsResponse is List) {
        rawData.addAll(levelsResponse.map((row) => {
          'id': row['level_pk'] as String,
          'name': row['name'] as String,
          'parent_id': null,
          'is_core': false,
        }).toList());
      }

      // Sublevels hinzufügen
      if (subLevelsResponse != null && subLevelsResponse is List) {
        rawData.addAll(subLevelsResponse.map((row) => {
          'id': row['child_level_fk'] as String,
          'name': '', // Name wird aus levels geholt, hier nur Platzhalter
          'parent_id': row['parent_level_fk'] as String,
          'is_core': false,
        }).toList());
      }

      // Erstelle eine Map der Level-Core-Verknüpfungen
      Map<String, Set<String>> levelCoreConnections = {};
      if (levelCoresResponse != null && levelCoresResponse is List) {
        for (var row in levelCoresResponse) {
          final parentId = row['parent_level_fk'] as String;
          levelCoreConnections.putIfAbsent(parentId, () => {}).add(parentId); // Nur parent_id für die Logik
        }
      }

      // Aktualisiere die Namen der Sublevels aus den Levels-Daten
      for (var subLevel in rawData.where((row) => row['parent_id'] != null && !row['is_core'])) {
        final levelData = rawData.firstWhere(
              (row) => row['id'] == subLevel['id'] && row['parent_id'] == null,
          orElse: () => {'name': 'Unknown Level'},
        );
        subLevel['name'] = levelData['name'];
      }

      setState(() {
        tree = buildTree(rawData, levelCoreConnections); // Baue den Baum (ohne Cores)
        columns = [tree]; // Initialisiere die erste Spalte (Hauptordner, ganz rechts)
        isLoading = false; // Ladezustand beenden
      });
    } catch (e) {
      print('Fehler beim Laden der Baumdaten: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Funktion zum Aktualisieren der Spalten basierend auf dem ausgewählten Knoten
  void _updateColumns(TreeNode node) {
    setState(() {
      selectedNode = node;
      // Finde den Index des aktuellen Knotens in seiner Spalte
      int currentColumnIndex = columns.indexWhere((column) => column.contains(node));
      if (currentColumnIndex == -1) {
        // Knoten wurde noch nicht gefunden, füge ihn zur letzten Spalte hinzu
        columns.add([node]);
      } else {
        // Aktualisiere die Spalten ab dem aktuellen Knoten
        columns = columns.sublist(0, currentColumnIndex + 1);
        if (node.children.isNotEmpty) {
          columns.add(node.children); // Füge die Kinder als neue Spalte hinzu
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const ThemeToggler(), // Theme-Switcher in der AppBar
        title: const Text('Levels'), // Titel der AppBar
        backgroundColor: Colors.grey[200], // Leicht grauer Hintergrund wie im Finder
        elevation: 0, // Kein Schatten für einen flachen Look
      ),
      body: Stack(
        children: [
          // Statischer Hintergrund
          const MyBackGround(key: Key('bg_key')),
          // Inhalt
          isLoading
              ? const Center(child: CircularProgressIndicator()) // Ladeanzeige
              : columns.isEmpty
              ? const Center(child: Text('Keine Daten verfügbar')) // Fallback für leere Daten
              : Column(
            mainAxisAlignment: MainAxisAlignment.center, // Vertikale Zentrierung
            children: [
              Align(
                alignment: Alignment.centerRight, // Rechtsbündige Ausrichtung
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal, // Horizontale Scrollbar
                  reverse: true, // Scrollt von rechts nach links (Hauptordner rechts)
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: List.generate(columns.length, (index) {
                      // Erstelle eine Spalte (von rechts nach links)
                      return _buildColumn(
                        columns[index],
                        columns.length - 1 - index, // Index von rechts nach links
                      );
                    }).reversed.toList(), // Umkehren der Spalten (Hauptordner rechts)
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Hilfsfunktion zum Erstellen einer Spalte
  Widget _buildColumn(List<TreeNode> nodes, int columnIndex) {
    return Container(
      width: 200, // Feste Breite für jede Spalte
      margin: const EdgeInsets.symmetric(vertical: 8.0), // Leichter Abstand oben und unten
      decoration: const BoxDecoration(), // Keine Trennlinie
      child: SizedBox(
        height: 300, // Feste Höhe für die Spalte, um vertikale Zentrierung zu unterstützen
        child: ListView.builder(
          itemCount: nodes.length,
          itemBuilder: (context, index) {
            final node = nodes[index];
            return Container(
              color: Colors.transparent, // Komplett transparent, auch bei Auswahl
              child: InkWell(
                onTap: () {
                  _updateColumns(node); // Aktualisiere die Spalten bei Auswahl
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center, // Zentriert die Inhalte
                    children: [
                      Icon(
                        node.hasCores ? Icons.circle : Icons.folder, // Kreis für Levels mit Cores, sonst Ordner
                        size: node.hasCores ? 16 : 20, // Kleinere Größe für Kreis
                        color: Colors.blueGrey, // Farbe für Icons
                      ),
                      const SizedBox(width: 8), // Abstand zwischen Icon und Text
                      Expanded(
                        child: Text(
                          node.name,
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).textTheme.bodyMedium?.color, // Theme-Farbe für Text
                          ),
                          overflow: TextOverflow.ellipsis, // Kürzt lange Namen
                          textAlign: TextAlign.center, // Text zentriert
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
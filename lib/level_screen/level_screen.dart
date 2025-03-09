import 'package:flutter/material.dart';
import 'package:neon_thors_cores/level_screen/tree_node.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../_gloabals/widgets/my_background.dart';
import '../_gloabals/widgets/theme_toggler.dart';
import '../quiz_screen/quiz__screen.dart';

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
  final Set<String> expandedNodes = {}; // Verfolgt, welche Knoten aufgeklappt sind

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
        // Toggle die nächste Spalte (Kinder hinzufügen/entfernen)
        if (node.children.isNotEmpty) {
          if (expandedNodes.contains(node.id)) {
            // Wenn schon aufgeklappt, dann zuklappen (Kinder entfernen)
            columns.removeRange(currentColumnIndex + 1, columns.length);
            expandedNodes.remove(node.id);
          } else {
            // Aufklappen (Kinder hinzufügen)
            columns.add(node.children);
            expandedNodes.add(node.id);
          }
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
      width: 250, // Breite erhöht, um mehr Platz für Text zu schaffen
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0), // Leichter Abstand
      decoration: columnIndex < columns.length - 1 && expandedNodes.contains(columns[columnIndex][0]?.id)
          ? BoxDecoration(
        color: Colors.blue.withOpacity(0.1), // Leicht blaues Highlight für aufgeklappte Spalte
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 4.0,
            offset: const Offset(0, 2),
          ),
        ],
        borderRadius: BorderRadius.circular(8.0), // Abgerundete Ecken
      )
          : const BoxDecoration(), // Kein Highlight, wenn zugeklappt
      child: SizedBox(
        height: 300, // Feste Höhe für die Spalte, um vertikale Zentrierung zu unterstützen
        child: ListView.builder(
          itemCount: nodes.length,
          itemBuilder: (context, index) {
            final node = nodes[index];
            return InkWell(
              onTap: () {
                // Prüfe, ob das Level ein Kreis-Icon hat (hasCores: true)
                if (node.hasCores) {
                  print('Level mit Kreis-Icon geklickt: ${node.name} (ID: ${node.id})');
                  // Navigator.push zum QuizScreen mit der level_id (node.id)
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuizScreen(
                        selected_level_pk: node.id, // Übergib die node.id als selected_level_pk
                      ),
                    ),
                  );
                } else {
                  _updateColumns(node); // Toggle Spalte nur für Levels ohne Kreis-Icon
                }
              },
              child: Container(
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
                        softWrap: true, // Text umbrechen
                        overflow: TextOverflow.visible, // Text nicht abschneiden
                        textAlign: TextAlign.center, // Text zentriert
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
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
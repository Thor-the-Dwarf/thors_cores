import 'dart:math';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../_gloabals/widgets/my_background.dart';
import '../_gloabals/widgets/theme_toggler.dart';
import '../quiz_screen/quiz__screen.dart';

class TreeNode {
  final String id;
  final String name;
  final bool isCore;
  final List<TreeNode> children;
  final bool hasCores;
  final Color? color;

  TreeNode({
    required this.id,
    required this.name,
    this.isCore = false,
    List<TreeNode>? children,
    this.hasCores = false,
    this.color,
  }) : children = children ?? [];
}

class LevelScreen extends StatefulWidget {
  const LevelScreen({super.key});

  @override
  _LevelScreenState createState() => _LevelScreenState();
}

class _LevelScreenState extends State<LevelScreen> {
  bool isLoading = true;
  List<TreeNode> tree = [];
  late final SupabaseClient supabase;
  List<List<TreeNode>> columns = [[]];
  final Map<int, TreeNode?> selectedNodesByColumn = {};

  @override
  void initState() {
    super.initState();
    supabase = Supabase.instance.client;
    _loadTreeData();
  }

  Future<void> _loadTreeData() async {
    try {
      final levelsResponse = await supabase.from('levels').select('level_pk, name').order('name');
      final subLevelsResponse = await supabase.from('sub_levels').select('parent_level_fk, child_level_fk');
      final coresResponse = await supabase.from('core').select('core_pk, name');
      final levelCoresResponse = await supabase.from('level_cores').select('parent_level_fk, core_fk');
      final essenceResponse = await supabase.from('essence').select('essence_pk, core_fk, name');

      List<Map<String, dynamic>> rawData = [];

      if (levelsResponse != null && levelsResponse is List) {
        rawData.addAll(levelsResponse.map((row) => {
          'id': row['level_pk'] as String,
          'name': row['name'] as String,
          'parent_id': null,
          'is_core': false,
        }).toList());
      }

      if (subLevelsResponse != null && subLevelsResponse is List) {
        rawData.addAll(subLevelsResponse.map((row) => {
          'id': row['child_level_fk'] as String,
          'name': '',
          'parent_id': row['parent_level_fk'] as String,
          'is_core': false,
        }).toList());
      }

      if (coresResponse != null && coresResponse is List) {
        rawData.addAll(coresResponse.map((row) => {
          'id': row['core_pk'] as String,
          'name': row['name'] as String,
          'parent_id': null,
          'is_core': true,
        }).toList());
      }

      if (essenceResponse != null && essenceResponse is List) {
        rawData.addAll(essenceResponse.map((row) => {
          'id': row['essence_pk'] as String,
          'name': row['name'] as String,
          'parent_id': row['core_fk'] as String,
          'is_core': true,
        }).toList());
      }

      Map<String, Set<String>> levelCoreConnections = {};
      if (levelCoresResponse != null && levelCoresResponse is List) {
        for (var row in levelCoresResponse) {
          final parentId = row['parent_level_fk'] as String;
          final coreId = row['core_fk'] as String;
          levelCoreConnections.putIfAbsent(parentId, () => {}).add(coreId);
          rawData.firstWhere((data) => data['id'] == coreId)['parent_id'] = parentId;
        }
      }

      for (var subLevel in rawData.where((row) => row['parent_id'] != null && !row['is_core'])) {
        final levelData = rawData.firstWhere(
              (row) => row['id'] == subLevel['id'] && row['parent_id'] == null,
          orElse: () => {'name': 'Unknown Level'},
        );
        subLevel['name'] = levelData['name'];
      }

      setState(() {
        tree = buildTree(rawData, levelCoreConnections);
        columns = [tree];
        isLoading = false;
      });
    } catch (e) {
      print('Fehler beim Laden der Baumdaten: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _updateColumns(TreeNode node, int columnIndex) {
    setState(() {
      if (selectedNodesByColumn[columnIndex] == node) {
        selectedNodesByColumn[columnIndex] = null;
        if (columnIndex + 1 < columns.length) {
          columns.removeRange(columnIndex + 1, columns.length);
          selectedNodesByColumn.removeWhere((key, value) => key > columnIndex);
        }
        if (columnIndex == 0) {
          columns = [tree];
          selectedNodesByColumn.clear();
        }
      } else {
        selectedNodesByColumn[columnIndex] = node;
        if (columnIndex + 1 < columns.length) {
          columns.removeRange(columnIndex + 1, columns.length);
          selectedNodesByColumn.removeWhere((key, value) => key > columnIndex);
        }
        if (node.children.isNotEmpty) {
          columns.add(node.children);
        }
      }
    });
  }

  bool _isNodeSelected(TreeNode node) {
    return selectedNodesByColumn.values.contains(node);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const ThemeToggler(),
        title: const Text('Wiederholung ist die Mutter des Lernens'),
        elevation: 0,
      ),
      body: Container(
        child: Stack(
          children: [
            MyBackGround(),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : columns.isEmpty
                ? const Center(child: Text('Keine Daten verfügbar'))
                : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    reverse: true,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: List.generate(columns.length, (index) {
                        return _buildColumn(columns[index], index);
                      }).reversed.toList(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColumn(List<TreeNode> nodes, int columnIndex) {
    return Container(
      width: MediaQuery.of(context).size.width / 3,
      padding: const EdgeInsets.fromLTRB(0, 32, 64, 32),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: selectedNodesByColumn[columnIndex] != null && nodes.contains(selectedNodesByColumn[columnIndex])
            ? [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.3),
            blurRadius: 4.0,
            offset: const Offset(0, 2),
          ),
        ]
            : null,
      ),
      child: SizedBox(
        height: 300,
        child: ListView.builder(
          itemCount: nodes.length,
          itemBuilder: (context, index) {
            final node = nodes[index];
            return InkWell(
              onTap: () => _updateColumns(node, columnIndex),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                color: _isNodeSelected(node) ? Colors.cyan.withOpacity(0.5) : Colors.transparent,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (node.hasCores && !node.isCore) {
                          print('Level mit Kreis-Icon geklickt: ${node.name} (ID: ${node.id})');
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => QuizScreen(selected_level_pk: node.id),
                            ),
                          );
                        }
                      },
                      child: Icon(
                        node.isCore
                            ? Icons.circle_outlined
                            : node.hasCores
                            ? Icons.quiz_outlined
                            : Icons.folder,
                        color: node.isCore
                            ? (node.color ?? getRandomColor())
                            : node.hasCores
                            ? Colors.yellow
                            : Colors.lightBlue,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        node.name,
                        style: Theme.of(context).textTheme.bodyMedium,
                        softWrap: true,
                        overflow: TextOverflow.visible,
                        textAlign: TextAlign.left,
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

Color getRandomColor() {
  final List<Color> solidColors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
    Colors.cyan,
  ];
  final random = Random();
  return solidColors[random.nextInt(solidColors.length)];
}

List<TreeNode> buildTree(List<Map<String, dynamic>> rawData, Map<String, Set<String>> levelCoreConnections) {
  final Map<String, TreeNode> nodes = {};
  final Map<String, List<String>> childMap = {};

  // Schritt 1: Erstelle alle Knoten (Levels, Sub-Levels, Cores, Essences)
  for (var row in rawData) {
    nodes[row['id']] = TreeNode(
      id: row['id'],
      name: row['name'],
      isCore: row['is_core'],
      hasCores: levelCoreConnections.containsKey(row['id']),
      color: row['is_core'] ? getRandomColor() : (levelCoreConnections.containsKey(row['id']) ? getRandomColor() : null),
    );
    if (row['parent_id'] != null) {
      childMap.putIfAbsent(row['parent_id'], () => []).add(row['id']);
    }
  }

  // Schritt 2: Verknüpfe Kinder mit ihren Eltern, vermeide Duplikate mit einem Set
  List<TreeNode> roots = [];
  nodes.forEach((id, node) {
    // Verwende ein Set, um Kinder-IDs eindeutig zu halten
    final Set<String> uniqueChildIds = {};

    // Füge Kinder hinzu (Sub-Levels, Cores, Essences) aus childMap
    if (childMap.containsKey(id)) {
      uniqueChildIds.addAll(childMap[id]!);
    }

    // Füge Cores hinzu aus levelCoreConnections
    if (levelCoreConnections.containsKey(id)) {
      uniqueChildIds.addAll(levelCoreConnections[id]!);
    }

    // Konvertiere uniqueChildIds in TreeNode-Liste und füge sie zu children hinzu
    for (var childId in uniqueChildIds) {
      if (nodes.containsKey(childId)) {
        node.children.add(nodes[childId]!);
      }
    }

    // Wurzelknoten finden
    if (!rawData.any((row) => row['id'] == id && row['parent_id'] != null)) {
      roots.add(node);
    }
  });

  return roots;
}
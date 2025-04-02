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
  bool isExpanded; // Zustand für Aufklappen/Zuklappen

  TreeNode({
    required this.id,
    required this.name,
    this.isCore = false,
    List<TreeNode>? children,
    this.hasCores = false,
    this.color,
    this.isExpanded = false, // Standardmäßig zugeklappt
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

      if (levelsResponse != null) {
        rawData.addAll(levelsResponse.map((row) => {
          'id': row['level_pk'] as String,
          'name': row['name'] as String,
          'parent_id': null,
          'is_core': false,
        }).toList());
      }

      if (subLevelsResponse != null) {
        rawData.addAll(subLevelsResponse.map((row) => {
          'id': row['child_level_fk'] as String,
          'name': '',
          'parent_id': row['parent_level_fk'] as String,
          'is_core': false,
        }).toList());
      }

      if (coresResponse != null) {
        rawData.addAll(coresResponse.map((row) => {
          'id': row['core_pk'] as String,
          'name': row['name'] as String,
          'parent_id': null,
          'is_core': true,
        }).toList());
      }

      if (essenceResponse != null) {
        rawData.addAll(essenceResponse.map((row) => {
          'id': row['essence_pk'] as String,
          'name': row['name'] as String,
          'parent_id': row['core_fk'] as String,
          'is_core': true,
        }).toList());
      }

      Map<String, Set<String>> levelCoreConnections = {};
      if (levelCoresResponse != null) {
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
        isLoading = false;
      });
    } catch (e) {
      print('Fehler beim Laden der Baumdaten: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _buildVisibleNodes(List<TreeNode> nodes, int depth) {
    List<Map<String, dynamic>> visibleNodes = [];
    for (var node in nodes) {
      visibleNodes.add({'node': node, 'depth': depth});
      if (node.isExpanded && node.children.isNotEmpty) {
        visibleNodes.addAll(_buildVisibleNodes(node.children, depth + 1));
      }
    }
    return visibleNodes;
  }

  void _toggleNode(TreeNode node) {
    setState(() {
      node.isExpanded = !node.isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final visibleNodes = _buildVisibleNodes(tree, 0);

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
                : visibleNodes.isEmpty
                ? const Center(child: Text('Keine Daten verfügbar'))
                : Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildNodeList(visibleNodes),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNodeList(List<Map<String, dynamic>> visibleNodes) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.3),
            blurRadius: 4.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.builder(
        itemCount: visibleNodes.length,
        itemBuilder: (context, index) {
          final node = visibleNodes[index]['node'] as TreeNode;
          final depth = visibleNodes[index]['depth'] as int;

          return InkWell(
            onTap: () => _toggleNode(node), // Nur für Expand/Collapse
            child: Container(
              padding: EdgeInsets.fromLTRB(16.0 + depth * 16.0, 8.0, 16.0, 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  if (node.children.isNotEmpty)
                    Icon(
                      node.isExpanded ? Icons.expand_more : Icons.chevron_right,
                      color: Colors.grey,
                    )
                  else
                    const SizedBox(width: 24), // Platzhalter für Ausrichtung
                  const SizedBox(width: 8),
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

  List<TreeNode> roots = [];
  nodes.forEach((id, node) {
    final Set<String> uniqueChildIds = {};

    if (childMap.containsKey(id)) {
      uniqueChildIds.addAll(childMap[id]!);
    }

    if (levelCoreConnections.containsKey(id)) {
      uniqueChildIds.addAll(levelCoreConnections[id]!);
    }

    for (var childId in uniqueChildIds) {
      if (nodes.containsKey(childId)) {
        final childNode = nodes[childId]!;
        bool isEssence = childNode.isCore && !levelCoreConnections.values.any((coreSet) => coreSet.contains(childId));
        if (!isEssence) {
          node.children.add(childNode);
        }
      }
    }

    if (!rawData.any((row) => row['id'] == id && row['parent_id'] != null)) {
      roots.add(node);
    }
  });

  return roots;
}
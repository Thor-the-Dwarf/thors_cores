import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:neon_thors_cores/level_screen/tree_node.dart';
import 'dart:math';

class SupabaseManager extends ChangeNotifier {
  static final SupabaseManager _instance = SupabaseManager._internal();
  factory SupabaseManager() => _instance;
  SupabaseManager._internal();

  final SupabaseClient _supabase = Supabase.instance.client;
  bool _isLoading = true;
  List<TreeNode> _tree = [];
  Map<String, List<Map<String, dynamic>>> _coreData = {};

  bool get isLoading => _isLoading;
  List<TreeNode> get tree => _tree;
  Map<String, List<Map<String, dynamic>>> get coreData => _coreData;

  Future<void> loadTreeData() async {
    try {
      _isLoading = true;
      notifyListeners();

      final levelsResponse = await _supabase
          .from('levels')
          .select('level_pk, name')
          .order('name');
      final subLevelsResponse = await _supabase
          .from('sub_levels')
          .select('parent_level_fk, child_level_fk');
      final coresResponse = await _supabase.from('core').select('core_pk, name');
      final levelCoresResponse = await _supabase
          .from('level_cores')
          .select('parent_level_fk, core_fk');
      final essenceResponse = await _supabase
          .from('essence')
          .select('essence_pk, core_fk, name');

      List<Map<String, dynamic>> rawData = [];

      if (levelsResponse != null) {
        rawData.addAll(
          levelsResponse
              .map(
                (row) => {
              'id': row['level_pk'] as String,
              'name': row['name'] as String,
              'parent_id': null,
              'is_core': false,
            },
          )
              .toList(),
        );
      }

      if (subLevelsResponse != null) {
        rawData.addAll(
          subLevelsResponse
              .map(
                (row) => {
              'id': row['child_level_fk'] as String,
              'name': '',
              'parent_id': row['parent_level_fk'] as String,
              'is_core': false,
            },
          )
              .toList(),
        );
      }

      Map<String, int> essenceCounts = {};
      if (essenceResponse != null) {
        for (var row in essenceResponse) {
          final coreId = row['core_fk'] as String;
          essenceCounts[coreId] = (essenceCounts[coreId] ?? 0) + 1;
        }
      }

      if (coresResponse != null) {
        for (var row in coresResponse) {
          final coreId = row['core_pk'] as String;
          _coreData.putIfAbsent('unassigned', () => []).add({
            'id': coreId,
            'name': row['name'] as String,
            'essences_count': essenceCounts[coreId] ?? 0,
          });
        }
      }

      Map<String, Set<String>> levelCoreConnections = {};
      if (levelCoresResponse != null) {
        for (var row in levelCoresResponse) {
          final parentId = row['parent_level_fk'] as String;
          final coreId = row['core_fk'] as String;
          levelCoreConnections.putIfAbsent(parentId, () => {}).add(coreId);
          if (_coreData.containsKey('unassigned')) {
            var core = _coreData['unassigned']!.firstWhere(
                  (c) => c['id'] == coreId,
              orElse: () => {},
            );
            if (core.isNotEmpty) {
              _coreData.putIfAbsent(parentId, () => []).add({
                'id': coreId,
                'name': core['name'],
                'essences_count': essenceCounts[coreId] ?? 0,
              });
              _coreData['unassigned']!.remove(core);
            }
          }
        }
      }

      for (var subLevel in rawData.where(
            (row) => row['parent_id'] != null && !row['is_core'],
      )) {
        final levelData = rawData.firstWhere(
              (row) => row['id'] == subLevel['id'] && row['parent_id'] == null,
          orElse: () => {'name': 'Unknown Level'},
        );
        subLevel['name'] = levelData['name'];
      }

      // Entfernt: Zufällige Generierung von _nodeProgressMap
      _tree = _buildTree(rawData, levelCoreConnections);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Fehler beim Laden der Baumdaten: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  List<TreeNode> _buildTree(
      List<Map<String, dynamic>> rawData,
      Map<String, Set<String>> levelCoreConnections,
      ) {
    final Map<String, TreeNode> nodes = {};
    final Map<String, List<String>> childMap = {};

    for (var row in rawData) {
      if (row['is_core'] == true) {
        continue;
      }
      nodes[row['id']] = TreeNode(
        id: row['id'],
        name: row['name'],
        isCore: row['is_core'],
        hasCores: levelCoreConnections.containsKey(row['id']),
        color: levelCoreConnections.containsKey(row['id']) ? _getRandomColor() : null,
      );
      if (row['parent_id'] != null) {
        childMap.putIfAbsent(row['parent_id'], () => []).add(row['id']);
      }
    }

    List<TreeNode> roots = [];
    nodes.forEach((id, node) {
      if (childMap.containsKey(id)) {
        for (var childId in childMap[id]!) {
          node.children.add(nodes[childId]!);
        }
      }
      if (!rawData.any((row) => row['id'] == id && row['parent_id'] != null)) {
        roots.add(node);
      }
    });

    return roots;
  }

  Color _getRandomColor() {
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
}
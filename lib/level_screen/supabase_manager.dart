import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:neon_thors_cores/level_screen/tree_node.dart';

// Definiere DEBUG, da es nicht global verfügbar ist
void DEBUG(String text) {
  print("[SupabaseManager] $text");
}

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

  Future<void> loadTreeData({required List<String> topLevelIds}) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Lade Daten direkt mit der neuen API
      final levelsResponse = await _supabase
          .from('levels')
          .select('level_pk, name')
          .order('name');
      final subLevelsResponse = await _supabase
          .from('sub_levels')
          .select('parent_level_fk, child_level_fk');
      final coresResponse = await _supabase
          .from('core')
          .select('core_pk, name');
      final levelCoresResponse = await _supabase
          .from('level_cores')
          .select('parent_level_fk, core_fk');
      final essenceResponse = await _supabase
          .from('essence')
          .select('essence_pk, core_fk, name');

      final levels = (levelsResponse as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
      final subLevels = (subLevelsResponse as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
      final cores = (coresResponse as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
      final levelCores = (levelCoresResponse as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
      final essences = (essenceResponse as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];

      // Zähle Essences pro Core
      final essenceCounts = <String, int>{};
      for (var essence in essences) {
        final coreId = essence['core_fk'] as String? ?? '';
        essenceCounts[coreId] = (essenceCounts[coreId] ?? 0) + 1;
      }

      // Initialisiere coreData mit allen Cores
      _coreData.clear();
      for (var core in cores) {
        final coreId = core['core_pk'] as String? ?? '';
        _coreData.putIfAbsent('unassigned', () => []).add({
          'id': coreId,
          'name': core['name'] as String? ?? 'Unnamed Core',
          'essences_count': essenceCounts[coreId] ?? 0,
        });
      }

      // Weise Cores den Levels zu basierend auf level_cores
      for (var levelCore in levelCores) {
        final parentId = levelCore['parent_level_fk'] as String? ?? '';
        final coreId = levelCore['core_fk'] as String? ?? '';
        final core = _coreData['unassigned']?.firstWhere(
              (c) => c['id'] == coreId,
          orElse: () => {},
        );
        if (core!.isNotEmpty) {
          _coreData.putIfAbsent(parentId, () => []).add(core!);
          _coreData['unassigned']?.removeWhere((c) => c['id'] == coreId); // Sicherstellen, dass der Core entfernt wird
        }
      }

      // Baue den Baum
      final rawData = [
        ...levels.map((level) => {
          'id': level['level_pk'] as String? ?? '',
          'name': level['name'] as String? ?? 'Unnamed Level',
          'parent_id': null,
          'is_core': false,
        }),
        ...subLevels.map((sub) => {
          'id': sub['child_level_fk'] as String? ?? '',
          'name': '',
          'parent_id': sub['parent_level_fk'] as String? ?? '',
          'is_core': false,
        }),
      ];

      for (var subLevel in rawData.where((row) => row['parent_id'] != null && !(row['is_core'] as bool? ?? false))) {
        final levelData = rawData.firstWhere(
              (row) => row['id'] == subLevel['id'] && row['parent_id'] == null,
          orElse: () => {'name': 'Unnamed Level'},
        );
        subLevel['name'] = levelData['name'] as String? ?? 'Unnamed Level';
      }

      _tree = _buildTree(rawData, _coreData, topLevelIds);
      _isLoading = false;
      DEBUG('coreData geladen: $_coreData');
      notifyListeners();
    } catch (e) {
      print('Fehler beim Laden der Baumdaten: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  List<TreeNode> _buildTree(
      List<Map<String, dynamic>> rawData,
      Map<String, List<Map<String, dynamic>>> coreData,
      List<String> topLevelIds,
      ) {
    final Map<String, TreeNode> nodes = {};
    final Map<String, List<String>> childMap = {};

    for (var row in rawData) {
      if (row['is_core'] == true) continue;
      nodes[row['id']] = TreeNode(
        id: row['id'] as String? ?? '',
        name: row['name'] as String? ?? '',
        hasCores: coreData.containsKey(row['id']),
      );
      if (row['parent_id'] != null) {
        childMap.putIfAbsent(row['parent_id'] as String? ?? '', () => []).add(row['id'] as String? ?? '');
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
        if (topLevelIds.contains(id)) {
          roots.add(node);
        }
      }
    });

    return roots;
  }

}

import 'package:supabase_flutter/supabase_flutter.dart';
import 'db_Core.dart';

class Level {
  final String id;
  String? _name;
  String? _details;
  List<Level> _subLevels = [];
  List<Core> _cores = [];
  late bool hasCores; // Neue Eigenschaft für hasCores

  Level({
    required this.id,
    String? name,
    String? details,
    List<Level>? subLevels,
    List<Core>? cores,
  }) {
    _name = name;
    _details = details;
    if (subLevels != null) _subLevels = subLevels;
    if (cores != null) _cores = cores;
    hasCores = _cores.isNotEmpty;
  }

  String get name => _name ?? 'Unknown Level';
  String? get details => _details;
  List<Level> get subLevels => _subLevels;
  List<Core> get cores => _cores;

  Future<void> loadDetails() async {
    if (_name != null) return;
    final response = await Supabase.instance.client
        .from('levels')
        .select('name, details')
        .eq('level_pk', id)
        .single();
    _name = response['name'] as String;
    _details = response['details'] as String?;
  }

  Future<void> loadSubLevels() async {
    final subLevelsResponse = await Supabase.instance.client
        .from('sub_levels')
        .select('child_level_fk')
        .eq('parent_level_fk', id);

    final childLevelIds = subLevelsResponse.map((row) => row['child_level_fk'] as String).toList();

    _subLevels = [];
    for (var childId in childLevelIds) {
      final childLevel = Level(id: childId);
      await childLevel.loadDetails();
      _subLevels.add(childLevel);
    }
  }

  Future<void> loadSubLevelsRecursively() async {
    await loadSubLevels();
    for (var subLevel in _subLevels) {
      await subLevel.loadSubLevelsRecursively();
      await subLevel.loadCores();
      subLevel.hasCores = subLevel.cores.isNotEmpty; // Update hasCores für Sublevels
    }
  }

  Future<void> loadCores() async {
    final levelCoresResponse = await Supabase.instance.client
        .from('level_cores')
        .select('core_fk')
        .eq('parent_level_fk', id);

    final coreIds = levelCoresResponse.map((row) => row['core_fk'] as String).toList();

    _cores = [];
    for (var coreId in coreIds) {
      final core = Core(id: coreId);
      await core.loadDetails();
      await core.countEssences();
      _cores.add(core);
    }
    hasCores = _cores.isNotEmpty; // Update hasCores nach dem Laden
  }
}
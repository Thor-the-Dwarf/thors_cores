// level_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:neon_thors_cores/level_screen/core_button.dart';
import 'package:neon_thors_cores/level_screen/new_Try1/view_Level.dart';
import 'package:neon_thors_cores/pay_screen.dart';
import 'package:neon_thors_cores/quiz_screen/quiz__screen.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../_globals/widgets/my_background.dart';
import '../../_globals/widgets/theme_controller.dart';
import 'db_Core.dart';
import 'db_Level.dart';

class LevelScreen_v1 extends StatefulWidget {
  final List<String> levelPks;

  const LevelScreen_v1({super.key, required this.levelPks});

  @override
  _LevelScreenState createState() => _LevelScreenState();
}

class _LevelScreenState extends State<LevelScreen_v1> with TickerProviderStateMixin {
  bool isLoading = true;
  List<Level> levels = [];
  late final SupabaseClient supabase;
  bool _isMenuOpen = false;
  bool _isPayScreenOpen = false;

  late AnimationController _animationController;
  late AnimationController _payAnimationController;
  late Animation<Offset> _slideAnimation;
  late Animation<Offset> _paySlideAnimation;

  String? _selectedLevelId;
  Set<String> _highlightedLevelIds = {};

  @override
  void initState() {
    super.initState();
    supabase = Supabase.instance.client;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _payAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: const Offset(0.0, 0.0),
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _paySlideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: const Offset(0.0, 0.0),
    ).animate(
      CurvedAnimation(parent: _payAnimationController, curve: Curves.easeInOut),
    );
    _loadTreeData(widget.levelPks);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _payAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadTreeData(List<String> levelPks) async {
    try {
      final futures = await Future.wait([
        supabase
            .from('levels')
            .select('level_pk, name, details')
            .order('name')
            .then((res) => res as List<dynamic>),
        supabase
            .from('sub_levels')
            .select('parent_level_fk, child_level_fk')
            .then((res) => res as List<dynamic>),
        supabase
            .from('core')
            .select('core_pk, name, details')
            .then((res) => res as List<dynamic>),
        supabase
            .from('level_cores')
            .select('parent_level_fk, core_fk')
            .then((res) => res as List<dynamic>),
        supabase
            .from('essence')
            .select('essence_pk, core_fk, name')
            .then((res) => res as List<dynamic>),
      ]);

      final levelsResponse = futures[0];
      final subLevelsResponse = futures[1];
      final coresResponse = futures[2];
      final levelCoresResponse = futures[3];
      final essenceResponse = futures[4];

      final Map<String, Level> levelMap = {};
      final Map<String, List<Level>> childMap = {};

      for (var row in levelsResponse) {
        final levelId = row['level_pk'] as String;
        levelMap[levelId] = Level(
          id: levelId,
          name: row['name'] as String,
          details: row['details'] as String?,
        );
      }

      for (var row in subLevelsResponse) {
        final parentId = row['parent_level_fk'] as String;
        final childId = row['child_level_fk'] as String;
        if (levelMap.containsKey(parentId) && levelMap.containsKey(childId)) {
          childMap.putIfAbsent(parentId, () => []).add(levelMap[childId]!);
        }
      }

      final Map<String, Core> coreMap = {};
      final Map<String, int> essenceCounts = {};

      for (var row in coresResponse) {
        final coreId = row['core_pk'] as String;
        coreMap[coreId] = Core(
          id: coreId,
          name: row['name'] as String,
          details: row['details'] as String?,
        );
      }

      for (var row in essenceResponse) {
        final coreId = row['core_fk'] as String;
        essenceCounts[coreId] = (essenceCounts[coreId] ?? 0) + 1;
      }

      essenceCounts.forEach((coreId, count) {
        if (coreMap.containsKey(coreId)) {
          coreMap[coreId] = Core(
            id: coreId,
            name: coreMap[coreId]!.name,
            details: coreMap[coreId]!.details,
            essenceCount: count,
          );
        }
      });

      final Map<String, List<Core>> levelCoreMap = {};
      for (var row in levelCoresResponse) {
        final parentId = row['parent_level_fk'] as String;
        final coreId = row['core_fk'] as String;
        if (levelMap.containsKey(parentId) && coreMap.containsKey(coreId)) {
          levelCoreMap.putIfAbsent(parentId, () => []).add(coreMap[coreId]!);
        }
      }

      levelMap.forEach((levelId, level) {
        final subLevels = childMap[levelId] ?? [];
        final cores = levelCoreMap[levelId] ?? [];
        levelMap[levelId] = Level(
          id: levelId,
          name: level.name,
          details: level.details,
          subLevels: subLevels,
          cores: cores,
        );
      });

      for (var levelPk in widget.levelPks) {
        final level = levelMap[levelPk];
        if (level != null) {
          levels.add(level);
        }
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Fehler beim Laden der Baumdaten: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _togglePayScreen() {
    setState(() {
      _isPayScreenOpen = !_isPayScreenOpen;
      if (_isPayScreenOpen) {
        _payAnimationController.forward();
      } else {
        _payAnimationController.reverse();
      }
    });
  }

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
      if (_isMenuOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _toggleCores(String levelId) {
    setState(() {
      if (_selectedLevelId == levelId) {
        _selectedLevelId = null;
        _highlightedLevelIds.clear();
      } else {
        _selectedLevelId = levelId;
        _highlightedLevelIds = _getParentLevelIds(levelId);
        // Debugging: Überprüfen Sie die gesammelten IDs
        print('Highlighted IDs: $_highlightedLevelIds');
      }
    });
  }

  Set<String> _getParentLevelIds(String levelId) {
    final Set<String> parentIds = {};

    // Hilfsfunktion, um die ID des übergeordneten Levels zu finden
    String? getParentId(String childId, List<Level> levels) {
      for (var level in levels) {
        // Prüft, ob das aktuelle Level das gesuchte Child als Sub-Level hat
        if (level.subLevels.any((sub) => sub.id == childId)) {
          return level.id;
        }
        // Rekursiv in den Sub-Levels suchen
        final parentId = getParentId(childId, level.subLevels);
        if (parentId != null) {
          return parentId;
        }
      }
      return null;
    }

    // Start mit der ausgewählten Level-ID
    String? currentId = levelId;
    while (currentId != null) {
      parentIds.add(currentId); // Fügt die aktuelle ID zum Set hinzu
      currentId = getParentId(currentId, levels); // Findet den nächsten Parent
    }

    return parentIds;
  }

  List<Map<String, dynamic>> _collectAllCores(String levelId, List<Level> levels) {
    List<Map<String, dynamic>> allCores = [];
    final level = _findLevel(levelId, levels);
    if (level == null) return allCores;

    void collectCores(Level level) {
      if (level.cores.isNotEmpty) {
        allCores.addAll(level.cores.map((core) => {'id': core.id, 'name': core.name}).toList());
      }
      for (var subLevel in level.subLevels) {
        collectCores(subLevel);
      }
    }

    collectCores(level);
    return allCores;
  }

  Level? _findLevel(String id, List<Level> levels) {
    for (var level in levels) {
      if (level.id == id) return level;
      if (level.subLevels.isNotEmpty) {
        final found = _findLevel(id, level.subLevels);
        if (found != null) return found;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wiederholung ist die Mutter des Lernens'),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: GestureDetector(
        onTap: () {
          if (_isMenuOpen) _toggleMenu();
          if (_isPayScreenOpen) _togglePayScreen();
        },
        child: Stack(
          children: [
            MyBackGround(),
            if (_selectedLevelId != null)
              Container(
                color: Colors.transparent,
                child: GridView.builder(
                  padding: const EdgeInsets.all(16.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                    childAspectRatio: 3 / 2,
                  ),
                  itemCount: _collectAllCores(_selectedLevelId!, levels).length,
                  itemBuilder: (context, index) {
                    final core = _collectAllCores(_selectedLevelId!, levels)[index];
                    return GestureDetector(
                      onTap: () {
                        print('Core geklickt: ${core['name']} (ID: ${core['id']})');
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(8.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.transparent,
                              blurRadius: 4.0,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: HaloSphere(
                            text: core['name'] as String,
                            color: getRandomColor(),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            SlideTransition(
              position: _slideAnimation,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                color: Colors.transparent,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : levels.isEmpty
                        ? const Center(child: Text('Keine Daten verfügbar'))
                        : ListView(
                      children: levels
                          .map((level) => LevelView(
                        level: level,
                        onCoreToggle: () => _toggleCores(level.id),
                        selectedLevelId: _selectedLevelId,
                        highlightedLevelIds: _highlightedLevelIds,
                      ))
                          .toList(),
                    ),
                  ),
                ),
              ),
            ),
            SlideTransition(
              position: _paySlideAnimation,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                color: Colors.transparent,
                child: GestureDetector(
                  onTap: () {},
                  child: const PayScreen(),
                ),
              ),
            ),
            Positioned(
              bottom: 24.0,
              right: MediaQuery.of(context).size.width * 0.025,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 40.0),
                  FloatingActionButton(
                    heroTag: 'theme_toggler',
                    onPressed: () {
                      Provider.of<ThemeController>(context, listen: false).toggleTheme();
                    },
                    mini: true,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    child: Consumer<ThemeController>(
                      builder: (context, controller, _) => Icon(
                        controller.themeMode == ThemeMode.dark
                            ? Icons.dark_mode
                            : Icons.light_mode,
                        color: Theme.of(context).iconTheme.color,
                        size: 48.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40.0),
                  FloatingActionButton(
                    heroTag: 'menu_toggle',
                    onPressed: _toggleMenu,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    child: Icon(
                      _isMenuOpen ? Icons.close : Icons.menu,
                      color: Theme.of(context).iconTheme.color,
                      size: 48.0,
                    ),
                  ),
                  const SizedBox(height: 40.0),
                  FloatingActionButton(
                    heroTag: 'support_me',
                    onPressed: _togglePayScreen,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    child: Icon(
                      _isPayScreenOpen ? Icons.close : Icons.handshake,
                      color: Theme.of(context).iconTheme.color,
                      size: 48.0,
                    ),
                  ),
                ],
              ),
            ),
          ],
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
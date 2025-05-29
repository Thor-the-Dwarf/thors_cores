import 'dart:math';
import 'package:flutter/material.dart';
import 'package:neon_thors_cores/level_screen/core_icon.dart';
import 'package:neon_thors_cores/level_screen/tree_node.dart';
import 'package:neon_thors_cores/pay_screen.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../_globals/widgets/my_background.dart';
import '../_globals/widgets/theme_controller.dart';
import '../quiz_screen/quiz__screen.dart';
import 'core_cluster_icon.dart';

class LevelScreen extends StatefulWidget {
  const LevelScreen({super.key});

  @override
  _LevelScreenState createState() => _LevelScreenState();
}

class _LevelScreenState extends State<LevelScreen> with TickerProviderStateMixin {
  bool isLoading = true;
  List<TreeNode> tree = [];
  late final SupabaseClient supabase;
  Map<String, List<Map<String, dynamic>>> coreData = {};
  bool _isMenuOpen = false;
  bool _isPayScreenOpen = false;

  late AnimationController _animationController;
  late AnimationController _payAnimationController;
  late Animation<Offset> _slideAnimation;
  late Animation<Offset> _paySlideAnimation;

  String? _selectedLevelId;
  Map<String, double> nodeProgressMap = {};

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
    _loadTreeData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _payAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadTreeData() async {
    try {
      final levelsResponse = await supabase
          .from('levels')
          .select('level_pk, name')
          .order('name');
      final subLevelsResponse = await supabase
          .from('sub_levels')
          .select('parent_level_fk, child_level_fk');
      final coresResponse = await supabase.from('core').select('core_pk, name');
      final levelCoresResponse = await supabase
          .from('level_cores')
          .select('parent_level_fk, core_fk');
      final essenceResponse = await supabase
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

      if (coresResponse != null) {
        for (var row in coresResponse) {
          coreData.putIfAbsent('unassigned', () => []).add({
            'id': row['core_pk'] as String,
            'name': row['name'] as String,
          });
        }
      }

      if (essenceResponse != null) {
        for (var row in essenceResponse) {
          final coreId = row['core_fk'] as String;
          coreData.putIfAbsent(coreId, () => []).add({
            'id': row['essence_pk'] as String,
            'name': row['name'] as String,
          });
        }
      }

      Map<String, Set<String>> levelCoreConnections = {};
      if (levelCoresResponse != null) {
        for (var row in levelCoresResponse) {
          final parentId = row['parent_level_fk'] as String;
          final coreId = row['core_fk'] as String;
          levelCoreConnections.putIfAbsent(parentId, () => {}).add(coreId);
          if (coreData.containsKey('unassigned')) {
            var core = coreData['unassigned']!.firstWhere(
                  (c) => c['id'] == coreId,
              orElse: () => {},
            );
            if (core.isNotEmpty) {
              coreData.putIfAbsent(parentId, () => []).add(core);
              coreData['unassigned']!.remove(core);
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

      for (var row in rawData) {
        nodeProgressMap[row['id']] = Random().nextDouble() * 100;
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

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
      if (_isMenuOpen) {
        _isPayScreenOpen = false;
        _payAnimationController.reverse();
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _togglePayScreen() {
    setState(() {
      _isPayScreenOpen = !_isPayScreenOpen;
      if (_isPayScreenOpen) {
        _isMenuOpen = false;
        _animationController.reverse();
        _payAnimationController.forward();
      } else {
        _payAnimationController.reverse();
      }
    });
  }

  void _toggleCores(String levelId, List<TreeNode> tree) {
    setState(() {
      if (_selectedLevelId == levelId) {
        _selectedLevelId = null;
      } else {
        _selectedLevelId = levelId;
        if (_isMenuOpen) {
          _isMenuOpen = false;
          _animationController.reverse();
        }
      }
    });
  }

  String _getLevelName(String levelId, List<TreeNode> tree) {
    TreeNode? findNode(String id, List<TreeNode> nodes) {
      for (var node in nodes) {
        if (node.id == id) return node;
        if (node.children.isNotEmpty) {
          final found = findNode(id, node.children);
          if (found != null) return found;
        }
      }
      return null;
    }

    final node = findNode(levelId, tree);
    return node?.name ?? 'Unbekanntes Level';
  }

  List<Map<String, dynamic>> _collectAllCores(String levelId, List<TreeNode> tree) {
    List<Map<String, dynamic>> allCores = [];

    TreeNode? findNode(String id, List<TreeNode> nodes) {
      for (var node in nodes) {
        if (node.id == id) return node;
        if (node.children.isNotEmpty) {
          final found = findNode(id, node.children);
          if (found != null) return found;
        }
      }
      return null;
    }

    final node = findNode(levelId, tree);
    if (node == null) return allCores;

    void collectCores(TreeNode node) {
      if (node.hasCores && coreData[node.id] != null) {
        allCores.addAll(coreData[node.id]!);
      }
      for (var child in node.children) {
        collectCores(child);
      }
    }

    collectCores(node);
    return allCores;
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

  Widget _buildNodeList(List<Map<String, dynamic>> visibleNodes) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
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
          final isSelected = node.id == _selectedLevelId;
          final isDarkMode = Theme.of(context).brightness == Brightness.dark;

          return InkWell(
            onTap: () {
              if (node.children.isNotEmpty) {
                _toggleNode(node);
              }
            },
            child: Container(
              padding: EdgeInsets.fromLTRB(16.0 + depth * 16.0, 8.0, 16.0, 8.0),
              color: isSelected
                  ? (isDarkMode
                  ? Colors.white.withOpacity(0.2)
                  : Colors.black.withOpacity(0.2))
                  : Colors.transparent,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 24,
                    child: node.children.isNotEmpty
                        ? GestureDetector(
                      onTap: () => _toggleNode(node),
                      child: Icon(
                        node.isExpanded
                            ? Icons.expand_more
                            : Icons.chevron_right,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    )
                        : null,
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      _toggleCores(node.id, tree);
                    },
                    child: CoreClusterIcon(
                      percentage: nodeProgressMap[node.id] ?? 0.0,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        _toggleCores(node.id, tree);
                      },
                      child: Text(
                        node.name,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected
                              ? (isDarkMode ? Colors.white : Colors.black)
                              : Theme.of(context).textTheme.bodyMedium!.color,
                        ),
                        softWrap: true,
                        overflow: TextOverflow.visible,
                        textAlign: TextAlign.left,
                      ),
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

  @override
  Widget build(BuildContext context) {
    final visibleNodes = _buildVisibleNodes(tree, 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wiederholung ist die Mutter des Lernens'),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: GestureDetector(
        onTap: () {
          if (_isMenuOpen) {
            _toggleMenu();
          }
          if (_isPayScreenOpen) {
            _togglePayScreen();
          }
        },
        child: Stack(
          children: [
            MyBackGround(),
            if (_selectedLevelId != null)
              Stack(
                children: [
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
                      itemCount: _collectAllCores(_selectedLevelId!, tree).length,
                      itemBuilder: (context, index) {
                        final core = _collectAllCores(_selectedLevelId!, tree)[index];
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
                                percentage: Random().nextDouble() * 100,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () {
                        print('Quiz gestartet für Level ID: $_selectedLevelId');
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QuizScreen(
                              selected_level_pk: _selectedLevelId!,
                              tree: tree,
                              coreData: coreData,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        height: 56.0,
                        color: Theme.of(context).primaryColor,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.play_arrow,
                            ),
                            const SizedBox(width: 8.0),
                            Text(
                              'Quiz starten',
                              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            SlideTransition(
              position: _slideAnimation,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                color: Colors.transparent,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : visibleNodes.isEmpty
                          ? const Center(child: Text('Keine Daten verfügbar'))
                          : Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: _buildNodeList(visibleNodes),
                      ),
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
                      Provider.of<ThemeController>(
                        context,
                        listen: false,
                      ).toggleTheme();
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

List<TreeNode> buildTree(
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
      color: levelCoreConnections.containsKey(row['id']) ? getRandomColor() : null,
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
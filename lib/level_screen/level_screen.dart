import 'package:flutter/material.dart';
import 'package:neon_thors_cores/level_screen/core_icon.dart';
import 'package:neon_thors_cores/level_screen/player/abstract_player_and_progress.dart';
import 'package:neon_thors_cores/level_screen/tree_node.dart';
import 'package:provider/provider.dart';
import '../_globals/widgets/my_background.dart';
import '../_globals/widgets/theme_controller.dart';
import '../pay_screen.dart';
import '../quiz_screen/db_question.dart';
import 'core_cluster_icon.dart';
import 'level_manager.dart';
import 'player/local_storage_player.dart';

class LevelScreen extends StatefulWidget {

  LevelScreen({super.key, String? accesKey}){
    // if(accesKey != null) LocalStoragePlayer()..load(key: accesKey);
  }

  @override
  _LevelScreenState createState() => _LevelScreenState();
}

class _LevelScreenState extends State<LevelScreen> with TickerProviderStateMixin {
  bool _isMenuOpen = false;
  bool _isPayScreenOpen = false;
  late AnimationController _animationController;
  late AnimationController _payAnimationController;
  late Animation<Offset> _slideAnimation;
  late Animation<Offset> _paySlideAnimation;
  String? _selectedLevelId;

  @override
  void initState() {
    super.initState();
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

    // Lade Tree-Daten und berechne Fortschritt
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final supabaseManager = Provider.of<SupabaseManager>(context, listen: false);
      final player = Provider.of<LocalStoragePlayer>(context, listen: false);

      supabaseManager.loadTreeData().then((_) {
        // Berechne Fortschritt für den gesamten Baum
        for (var root in supabaseManager.tree) {
          player.loadExpirience(treeNode: root);
        }
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _payAnimationController.dispose();
    super.dispose();
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

  List<Map<String, dynamic>> _collectAllCores(String levelId, List<TreeNode> tree) {
    List<Map<String, dynamic>> allCores = [];
    final coreData = Provider.of<SupabaseManager>(context, listen: false).coreData;

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
    return Consumer<LocalStoragePlayer>(
      builder: (context, player, child) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
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

              return InkWell(
                onTap: () {
                  if (node.children.isNotEmpty) {
                    _toggleNode(node);
                  }
                },
                child: Container(
                  padding: EdgeInsets.fromLTRB(16.0 + depth * 16.0, 8.0, 16.0, 8.0),
                  color: isSelected
                      ? (isDarkMode ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.2))
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
                            node.isExpanded ? Icons.expand_more : Icons.chevron_right,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        )
                            : null,
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          _toggleCores(node.id, Provider.of<SupabaseManager>(context, listen: false).tree);
                        },
                        child: CoreClusterIcon(
                          progress: player.experience[node.id] ?? 0.0,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            _toggleCores(node.id, Provider.of<SupabaseManager>(context, listen: false).tree);
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
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Consumer<SupabaseManager>(
      builder: (context, supabaseManager, child) {
        final visibleNodes = _buildVisibleNodes(supabaseManager.tree, 0);
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
                  Consumer<LocalStoragePlayer>(
                    builder: (context, player, child) {
                      return Stack(
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
                              itemCount: _collectAllCores(_selectedLevelId!, supabaseManager.tree).length,
                              itemBuilder: (context, index) {
                                final core = _collectAllCores(_selectedLevelId!, supabaseManager.tree)[index];
                                final coreProgress = player.cores.firstWhere(
                                      (c) => c.id == core['id'],
                                  orElse: () => Core(id: core['id']),
                                ).progress;
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
                                        progress: coreProgress,
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
                                      tree: supabaseManager.tree,
                                      coreData: supabaseManager.coreData,
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
                                    Icon(Icons.play_arrow),
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
                      );
                    },
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
                          child: supabaseManager.isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : visibleNodes.isEmpty
                              ? const Center(child: Text('Keine Daten verfügbar'))
                              : Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: _buildNodeList(visibleNodes), // Direkt aufrufen
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
      },
    );
  }
}
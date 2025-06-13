import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:neon_thors_cores/level_screen/core_icon.dart';
import 'package:neon_thors_cores/level_screen/player/abstract_player_and_progress.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../_globals/debug_prints.dart';
import '../_globals/widgets/my_background.dart';
import '../_globals/widgets/theme_controller.dart';
import '../pay_screen.dart';
import '../quiz_screen/quiz__screen.dart';
import 'core_cluster_icon.dart';
import 'level_widget.dart';
import 'player/local_storage_player.dart';

void DEBUG(String text) {
  if (true || DEBUG_EVERYTHING) printYellow("[LevelScreen] $text");
}

class LevelScreen extends StatefulWidget {
  const LevelScreen({super.key, required this.levelIds, this.accessKey});

  final List<String> levelIds;
  final String? accessKey;

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
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
    _paySlideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: const Offset(0.0, 0.0),
    ).animate(CurvedAnimation(parent: _payAnimationController, curve: Curves.easeInOut));

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

  void _toggleCores(String levelId) {
    setState(() {
      _selectedLevelId = _selectedLevelId == levelId ? null : levelId;
      if (_isMenuOpen && _selectedLevelId != null) {
        _isMenuOpen = false;
        _animationController.reverse();
      }
    });
  }


  Future<List<Map<String, dynamic>>> _collectAllCores(String levelId) async {
    try {
      final supabase = Supabase.instance.client;
      final coreData = await supabase
          .from('level_cores')
          .select('core_fk, name')
          .eq('parent_level_fk', levelId);
      final cores = coreData.map((core) => {
        'id': core['core_fk'],
        'name': core['name'] ?? 'Core',
      }).toList();
      DEBUG('Cores für Level $levelId: ${cores.length} gefunden');
      return cores;
    } catch (e) {
      DEBUG('Fehler beim Laden der Cores für Level $levelId: $e');
      return [];
    }
  }

  Widget _buildNodeList() {
    return ListView(
      children: widget.levelIds.map((levelId) {
        return LevelWidget(
          level_pk: levelId,
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
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
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: _collectAllCores(_selectedLevelId!),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final cores = snapshot.data!;
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
                            itemCount: cores.length,
                            itemBuilder: (context, index) {
                              final core = cores[index];
                              return GestureDetector(
                                onTap: () => print('Core geklickt: ${core['name']} (ID: ${core['id']})'),
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
                                      progress: 0.0,
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
                            onTap: () async {
                              final coreData = await _collectAllCores(_selectedLevelId!);
                              print('Quiz gestartet für Level ID: $_selectedLevelId');
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => QuizScreen(
                                    selected_level_pk: _selectedLevelId!,
                                    coreData: {_selectedLevelId!: coreData},
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
                        child: widget.levelIds.isEmpty
                            ? const Center(child: Text('Keine Daten verfügbar'))
                            : Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: _buildNodeList(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SlideTransition(
                position: _paySlideAnimation,
                child: _isPayScreenOpen
                    ? Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  color: Colors.transparent,
                  child: const PayScreen(),
                )
                    : const SizedBox.shrink(),
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
                          controller.themeMode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode,
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
      ),
    );
  }
}
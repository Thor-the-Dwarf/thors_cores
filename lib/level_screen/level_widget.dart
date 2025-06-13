import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LevelWidget extends StatefulWidget {
  final String level_pk;
  late final String name;
  late final String details;
  late final List<LevelWidget> sublevel;
  late final List<String> cores;

  LevelWidget({
    super.key,
    required this.level_pk,
    String? name,
    String? details,
    List<LevelWidget>? sublevel,
    List<String>? cores,
  })  : name = name ?? '',
        details = details ?? '',
        sublevel = sublevel ?? const [],
        cores = cores ?? const [];

  @override
  _LevelWidgetState createState() => _LevelWidgetState();
}

class _LevelWidgetState extends State<LevelWidget> {
  double progress = 0.0;
  bool isExpanded = false;
  static final Map<String, LevelWidget> _cache = {};

  @override
  void initState() {
    super.initState();
    print('initState für Level ${widget.level_pk}');
    if (_cache[widget.level_pk] == null) {
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final levelWidget = _cache[widget.level_pk] ?? widget;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: levelWidget.sublevel.isNotEmpty
              ? () {
            setState(() {
              isExpanded = !isExpanded;
            });
          }
              : null,
          child: Container(
            color: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Row(
              children: [
                Icon(
                  Icons.chevron_right,
                  color: isExpanded ? Colors.white : Colors.grey,
                  size: 24.0,
                ),
                const SizedBox(width: 8.0),
                Container(
                  width: 40.0,
                  height: 40.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey, width: 2.0),
                  ),
                  child: Center(
                    child: Text('$progress%'),
                  ),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Text(levelWidget.name),
                ),
              ],
            ),
          ),
        ),
        if (isExpanded && levelWidget.sublevel.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: levelWidget.sublevel,
            ),
          ),
      ],
    );
  }


  Future<void> _load() async {
    try {
      final supabase = Supabase.instance.client;

      final levelData = await supabase
          .from('levels')
          .select('name, details')
          .eq('level_pk', widget.level_pk)
          .limit(1)
          .maybeSingle();

      if (levelData == null) {
        print('⚠️ Kein Level gefunden mit ID: ${widget.level_pk}');
        return;
      }

      final sublevelData = await supabase
          .from('sub_levels')
          .select('child_level_fk')
          .eq('parent_level_fk', widget.level_pk);

      final coreData = await supabase
          .from('level_cores')
          .select('core_fk')
          .eq('parent_level_fk', widget.level_pk);

      final newWidget = LevelWidget(
        key: widget.key,
        level_pk: widget.level_pk,
        name: levelData['name'] ?? 'Kein Name',
        details: levelData['details'] ?? '',
        sublevel: (sublevelData as List<dynamic>)
            .map((sub) => LevelWidget(
          key: ValueKey(sub['child_level_fk']),
          level_pk: sub['child_level_fk'] as String,
        ))
            .toList(),
        cores: (coreData as List<dynamic>)
            .map((core) => core['core_fk'] as String)
            .toList(),
      );

      setState(() {
        _cache[widget.level_pk] = newWidget;
      });
    } catch (e, stack) {
      print('❌ Fehler in _load(): $e\n$stack');
    }
  }

  @override
  void dispose() {
    print('Dispose Level ${widget.level_pk}');
    super.dispose();
  }
}

class LevelListTestGui extends StatelessWidget {
  final List<String> levelPks;

  const LevelListTestGui({super.key, required this.levelPks});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Level List Test'),
      ),
      body: ListView.builder(
        itemCount: levelPks.length,
        itemBuilder: (context, index) {
          return LevelWidget(level_pk: levelPks[index]);
        },
      ),
    );
  }
}
// view_Level.dart
import 'package:flutter/material.dart';
import 'package:neon_thors_cores/level_screen/new_Try1/db_Level.dart';
import 'package:neon_thors_cores/quiz_screen/quiz__screen.dart';

class LevelView extends StatefulWidget {
  final Level level;
  final int depth;
  final VoidCallback? onCoreToggle;
  final String? selectedLevelId;
  final Set<String> highlightedLevelIds;

  const LevelView({
    Key? key,
    required this.level,
    this.depth = 0,
    this.onCoreToggle,
    this.selectedLevelId,
    required this.highlightedLevelIds,
  }) : super(key: key);

  @override
  _LevelViewState createState() => _LevelViewState();
}

class _LevelViewState extends State<LevelView> {
  bool _isExpanded = false;
  late bool _hasCores;

  @override
  void initState() {
    super.initState();
    _hasCores = widget.level.hasCores;
    _loadSubLevels();
  }

  Future<void> _loadSubLevels() async {
    await widget.level.loadSubLevelsRecursively();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.level.id == widget.selectedLevelId;
    final isHighlighted = widget.highlightedLevelIds.contains(widget.level.id);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            if (widget.level.subLevels.isNotEmpty) {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            }
          },
          child: Container(
            padding: EdgeInsets.fromLTRB(16.0 + widget.depth * 16.0, 8.0, 16.0, 8.0),
            color: isHighlighted
                ? (isDarkMode ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.2))
                : Colors.transparent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: 24,
                  child: widget.level.subLevels.isNotEmpty
                      ? GestureDetector(
                    onTap: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                    child: Icon(
                      _isExpanded ? Icons.expand_more : Icons.chevron_right,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  )
                      : null,
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    if (_hasCores) {
                      print('Level mit Core-Verbindung geklickt: ${widget.level.name} (ID: ${widget.level.id})');
                      print('Zugehörige Cores: ${widget.level.cores.map((c) => c.name).toList()}');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QuizScreen(selected_level_pk: widget.level.id),
                        ),
                      );
                    }
                  },
                  child: Icon(
                    _hasCores ? Icons.quiz_outlined : Icons.folder,
                    color: _hasCores ? Colors.yellow : Colors.lightBlue,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      widget.onCoreToggle?.call();
                    },
                    child: Text(
                      widget.level.name,
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
        ),
        if (_isExpanded && widget.level.subLevels.isNotEmpty)
          Column(
            children: widget.level.subLevels
                .map((subLevel) => LevelView(
              level: subLevel,
              depth: widget.depth + 1,
              onCoreToggle: widget.onCoreToggle,
              selectedLevelId: widget.selectedLevelId,
              highlightedLevelIds: widget.highlightedLevelIds,
            ))
                .toList(),
          ),
      ],
    );
  }
}
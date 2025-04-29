import 'package:flutter/material.dart';
import '../../quiz_screen/quiz__screen.dart';
import '../level_screen.dart';

class LevelTreeWidget extends StatelessWidget {
  final List<TreeNode> tree;
  final String? selectedLevelId;
  final Function(TreeNode) onToggleNode;
  final Function(String, List<TreeNode>) onToggleCores;
  final bool isLoading;

  const LevelTreeWidget({
    Key? key,
    required this.tree,
    required this.selectedLevelId,
    required this.onToggleNode,
    required this.onToggleCores,
    required this.isLoading,
  }) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    final visibleNodes = _buildVisibleNodes(tree, 0);
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : visibleNodes.isEmpty
          ? const Center(child: Text('Keine Daten verfügbar'))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
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
              final isSelected = node.id == selectedLevelId;
              final isDarkMode = Theme.of(context).brightness == Brightness.dark;

              return InkWell(
                onTap: () {
                  if (node.children.isNotEmpty) {
                    onToggleNode(node);
                  }
                },
                child: Container(
                  padding: EdgeInsets.fromLTRB(16.0 + depth * 16.0, 8.0, 16.0, 8.0),
                  color: isSelected
                      ? (isDarkMode ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.2))
                      : Colors.transparent,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 24,
                        child: node.children.isNotEmpty
                            ? IconButton(
                          icon: Icon(
                            node.isExpanded ? Icons.expand_more : Icons.chevron_right,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                          onPressed: () => onToggleNode(node),
                        )
                            : null,
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          if (node.hasCores && !node.isCore) {
                            print('Level mit Core-Verbindung geklickt: ${node.name} (ID: ${node.id})');
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => QuizScreen(selected_level_pk: node.id),
                              ),
                            );
                          }
                        },
                        child: Icon(
                          node.hasCores ? Icons.quiz_outlined : Icons.folder,
                          color: node.hasCores ? Colors.yellow : Colors.lightBlue,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => onToggleCores(node.id, tree),
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
        ),
      ),
    );
  }
  }
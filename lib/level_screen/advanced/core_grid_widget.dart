import 'package:flutter/material.dart';
import '../core_button.dart';
import '../level_screen.dart';

class CoreGridWidget extends StatelessWidget {
  final String selectedLevelId;
  final List<TreeNode> tree;
  final Map<String, List<Map<String, dynamic>>> coreData;

  const CoreGridWidget({
    Key? key,
    required this.selectedLevelId,
    required this.tree,
    required this.coreData,
  }) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          childAspectRatio: 3 / 2,
        ),
        itemCount: _collectAllCores(selectedLevelId, tree).length,
        itemBuilder: (context, index) {
          final core = _collectAllCores(selectedLevelId, tree)[index];
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
    );
  }
}
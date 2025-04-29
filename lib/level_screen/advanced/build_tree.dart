import '../level_screen.dart';

List<TreeNode> buildTree(
    List<Map<String, dynamic>> rawData,
    Map<String, Set<String>> levelCoreConnections,
    Map<String, List<Map<String, dynamic>>> coreData,
    ) {
  final Map<String, TreeNode> nodes = {};
  final Map<String, List<String>> childMap = {};

  for (var row in rawData) {
    if (row['is_core'] == true) continue;
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

  // Speichere coreData global oder gib es zurück, wenn nötig
  return roots;
}
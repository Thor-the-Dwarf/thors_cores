
// Datenklasse für die Baumstruktur
class TreeNode {
  final String id;          // UUID aus level_pk oder core_pk
  final String name;        // Name des Levels oder Cores
  final bool isCore;        // Unterscheidet Core (true) von Level (false)
  final List<TreeNode> children; // Liste der Unterknoten (Sublevels oder Cores)
  final bool hasCores;      // Neue Eigenschaft: Hat dieses Level/Sublevel Cores?

  TreeNode({
    required this.id,
    required this.name,
    this.isCore = false,
    List<TreeNode>? children,
    this.hasCores = false, // Standardmäßig false
  }) : children = children ?? [];
}

// Funktion zum Aufbau des Baums aus flachen Daten (ohne Cores)
List<TreeNode> buildTree(List<Map<String, dynamic>> rawData, Map<String, Set<String>> levelCoreConnections) {
  // Map für schnellen Zugriff auf Knoten nach ID
  final Map<String, TreeNode> nodes = {};
  // Map, die Kinder-IDs nach Eltern-ID gruppiert
  final Map<String, List<String>> childMap = {};

  // Schritt 1: Erstelle alle Knoten (nur Levels/Sublevels, keine Cores)
  for (var row in rawData) {
    if (row['is_core'] == true) {
      continue; // Überspringe Cores für die Baumstruktur
    }
    nodes[row['id']] = TreeNode(
      id: row['id'],
      name: row['name'],
      isCore: row['is_core'],
      hasCores: levelCoreConnections.containsKey(row['id']), // Hat dieses Level/Sublevel Cores?
    );
    // Wenn es einen Parent gibt, füge die ID zur childMap hinzu
    if (row['parent_id'] != null) {
      childMap.putIfAbsent(row['parent_id'], () => []).add(row['id']);
    }
  }

  // Schritt 2: Verknüpfe Kinder mit ihren Eltern
  List<TreeNode> roots = []; // Liste der Wurzelknoten (ohne Eltern)
  nodes.forEach((id, node) {
    // Wenn dieser Knoten Kinder hat, füge sie hinzu
    if (childMap.containsKey(id)) {
      for (var childId in childMap[id]!) {
        node.children.add(nodes[childId]!);
      }
    }
    // Wenn der Knoten kein Elternteil in den Daten hat, ist er eine Wurzel
    if (!rawData.any((row) => row['id'] == id && row['parent_id'] != null)) {
      roots.add(node);
    }
  });

  return roots; // Gib die Wurzelknoten zurück
}
class TreeNode {
  final String id;
  final String name;
  final List<TreeNode> children;
  final bool hasCores;

  TreeNode({
    required this.id,
    required this.name,
    List<TreeNode>? children,
    this.hasCores = false,
  }) : children = children ?? [];
}

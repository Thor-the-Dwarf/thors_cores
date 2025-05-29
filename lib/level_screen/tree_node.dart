import 'package:flutter/material.dart';

class TreeNode {
  final String id;
  final String name;
  final bool isCore;
  final List<TreeNode> children;
  final bool hasCores;
  final Color? color;
  bool isExpanded;

  TreeNode({
    required this.id,
    required this.name,
    this.isCore = false,
    List<TreeNode>? children,
    this.hasCores = false,
    this.color,
    this.isExpanded = false,
  }) : children = children ?? [];
}
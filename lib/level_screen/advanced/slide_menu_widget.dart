import 'package:flutter/material.dart';
import '../level_screen.dart';
import 'level_tree_widget.dart';

class SlideMenuWidget extends StatefulWidget {
  final List<TreeNode> tree;
  final String? selectedLevelId;
  final bool isMenuOpen;
  final Function(TreeNode) onToggleNode;
  final Function(String, List<TreeNode>) onToggleCores;
  final bool isLoading;

  const SlideMenuWidget({
    Key? key,
    required this.tree,
    required this.selectedLevelId,
    required this.isMenuOpen,
    required this.onToggleNode,
    required this.onToggleCores,
    required this.isLoading,
  }) : super(key: key);

  @override
  _SlideMenuWidgetState createState() => _SlideMenuWidgetState();
}

class _SlideMenuWidgetState extends State<SlideMenuWidget> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: const Offset(0.0, 0.0),
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    if (widget.isMenuOpen) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(SlideMenuWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isMenuOpen != oldWidget.isMenuOpen) {
      if (widget.isMenuOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.transparent,
        child: Align(
          alignment: Alignment.centerLeft,
          child: GestureDetector(
            onTap: () {},
            child: LevelTreeWidget(
              tree: widget.tree,
              selectedLevelId: widget.selectedLevelId,
              onToggleNode: widget.onToggleNode,
              onToggleCores: widget.onToggleCores,
              isLoading: widget.isLoading,
            ),
          ),
        ),
      ),
    );
  }
}
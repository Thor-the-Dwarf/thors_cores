import 'package:flutter/material.dart';

import '../../pay_screen.dart';

class PayScreenWidget extends StatefulWidget {
  final bool isPayScreenOpen;

  const PayScreenWidget({
    Key? key,
    required this.isPayScreenOpen,
  }) : super(key: key);

  @override
  _PayScreenWidgetState createState() => _PayScreenWidgetState();
}

class _PayScreenWidgetState extends State<PayScreenWidget> with TickerProviderStateMixin {
  late AnimationController _payAnimationController;
  late Animation<Offset> _paySlideAnimation;

  @override
  void initState() {
    super.initState();
    _payAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _paySlideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: const Offset(0.0, 0.0),
    ).animate(
      CurvedAnimation(parent: _payAnimationController, curve: Curves.easeInOut),
    );
    if (widget.isPayScreenOpen) {
      _payAnimationController.forward();
    }
  }

  @override
  void didUpdateWidget(PayScreenWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPayScreenOpen != oldWidget.isPayScreenOpen) {
      if (widget.isPayScreenOpen) {
        _payAnimationController.forward();
      } else {
        _payAnimationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _payAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _paySlideAnimation,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.transparent,
        child: GestureDetector(
          onTap: () {},
          child: const PayScreen(),
        ),
      ),
    );
  }
}
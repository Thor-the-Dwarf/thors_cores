import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:math';
import '../debug_prints.dart';
import 'my_coustum_painter.dart';

void debug(String text) {
  if (false) printBlue("[MyBackGround] $text");
}

class MyBackGround extends StatefulWidget {
  const MyBackGround({Key? key}) : super(key: key);

  @override
  State<MyBackGround> createState() => _MyBackGroundState();

  static _MyBackGroundState? of(BuildContext context) {
    return context.findAncestorStateOfType<_MyBackGroundState>();
  }
}

class _MyBackGroundState extends State<MyBackGround> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Offset> initialPoints;
  late List<Offset> targetPoints;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 500),
      vsync: this,
    )..addListener(() {
      if (mounted) {
        setState(() {});
      }
    })..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _controller.forward();
      }
    })..forward();

    const int numberOfPoints = 17;
    initialPoints = List.generate(
      numberOfPoints,
          (index) => Offset(Random().nextDouble() * 0.8 + 0.1, Random().nextDouble() * 0.8 + 0.1),
    );
    targetPoints = List.generate(
      numberOfPoints,
          (index) => Offset(Random().nextDouble() * 0.8 + 0.1, Random().nextDouble() * 0.8 + 0.1),
    );
  }

  @override
  void dispose() {
    _controller.stop();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: MyCustomPainter(
        Theme.of(context),
        _controller.value,
        initialPoints,
        targetPoints,
      ),
    );
  }
}
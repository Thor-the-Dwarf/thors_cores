import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:math';
import '../debug_prints.dart';
import 'my_coustum_painter.dart'; // Stelle sicher, dass diese Datei existiert

final GlobalKey<_MyBackGroundState> BG_KEY = GlobalKey<_MyBackGroundState>();

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

    // Anzahl der Punkte fest definieren, da pointColors jetzt dynamisch ist
    const int numberOfPoints = 17; // Entspricht der Länge der kürzeren Liste in _getPointColors()
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
        Theme.of(context), // Übergibt das aktuelle Theme
        _controller.value,
        initialPoints,
        targetPoints,
      ),
    );
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _toggleThemeMode() {
    debug("_toggleThemeMode() {");
    debug("\tVorheriges ThemeMode: $_themeMode");
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
    debug("\tNeues ThemeMode: $_themeMode");
    debug("}");
  }

  @override
  Widget build(BuildContext context) {
    debug("MyApp.build() {");

    final widgetTree = MaterialApp(
      title: 'Animierter Microchip',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: _themeMode,
      home: const MyBackGround(),
    );

    debug("}");
    return widgetTree;
  }
}
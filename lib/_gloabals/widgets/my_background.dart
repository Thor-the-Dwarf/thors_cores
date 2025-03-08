import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:math';
import '../debug_prints.dart';

void debug(String text) {
  if (false) printBlue("[MyBackGround] $text");
}


class MyBackGround extends StatefulWidget {
  final Widget content;
  const MyBackGround({Key? key, required this.content}) : super(key: key);

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
  late Widget _currentContent;

  @override
  void initState() {
    debug("initState() {");

    super.initState();
    _currentContent = widget.content;
    debug("\tInitialisiere _currentContent.");

    _controller = AnimationController(
      duration: const Duration(seconds: 500),
      vsync: this,
    )..addListener(() {
      setState(() {});
    })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          debug("\tAnimation beendet -> reverse");
          _controller.reverse();
        } else if (status == AnimationStatus.dismissed) {
          debug("\tAnimation dismissed -> forward");
          _controller.forward();
        }
      })
      ..forward();

    debug("\tAnimationController initialisiert.");

    int numberOfPoints = MyCustomPainter.pointColors.length;
    initialPoints = List.generate(
      numberOfPoints,
          (index) => Offset(Random().nextDouble() * 0.8 + 0.1, Random().nextDouble() * 0.8 + 0.1),
    );

    targetPoints = List.generate(
      numberOfPoints,
          (index) => Offset(Random().nextDouble() * 0.8 + 0.1, Random().nextDouble() * 0.8 + 0.1),
    );

    debug("\tPunkte initialisiert: $numberOfPoints Stück.");
    debug("}");
  }

  void updateContent(Widget newContent) {
    debug("updateContent() {");
    debug("\tNeuer Content wird gesetzt.");
    setState(() {
      _currentContent = newContent;
    });
    debug("}");
  }

  @override
  void dispose() {
    debug("dispose() {");
    _controller.stop();
    _controller.dispose();
    debug("\tAnimationController gestoppt und disposed.");
    debug("}");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debug("build() {");

    final widgetTree = Stack(
        children: [
          CustomPaint(
            size: Size.infinite,
            painter: MyCustomPainter(
              Theme.of(context),
              _controller.value,
              initialPoints,
              targetPoints,
            ),
          ),
          Positioned.fill(
            child: _currentContent,
          ),
        ],
      );

    debug("}");
    return widgetTree;
  }
}

class MyCustomPainter extends CustomPainter {
  final ThemeData theme;
  final double animationValue;
  final List<Offset> initialPoints;
  final List<Offset> targetPoints;

  static final List<Color> pointColors = [
    Colors.red, Colors.pink, Colors.purple, Colors.deepPurple,
    Colors.indigo, Colors.blue, Colors.lightBlue, Colors.cyan,
    Colors.teal, Colors.green, Colors.lightGreen, Colors.lime,
    Colors.yellow, Colors.amber, Colors.orange, Colors.deepOrange,
    Colors.brown, Colors.grey, Colors.blueGrey, Colors.black, Colors.white,
  ];

  MyCustomPainter(this.theme, this.animationValue, this.initialPoints, this.targetPoints);

  @override
  void paint(Canvas canvas, Size size) {
    debug("paint() {");
    debug("\tCanvas Größe: ${size.width} x ${size.height}");

    List<Offset> animatedPoints = List.generate(
      initialPoints.length,
          (index) => Offset(
        lerpDouble(initialPoints[index].dx, targetPoints[index].dx, animationValue)!,
        lerpDouble(initialPoints[index].dy, targetPoints[index].dy, animationValue)!,
      ),
    );

    for (int i = 0; i < animatedPoints.length; i++) {
      for (int j = i + 1; j < animatedPoints.length; j++) {
        final linePaint = Paint()
          ..color = (theme.brightness == Brightness.light ? Colors.black : Colors.white).withOpacity(0.1)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.5;

        canvas.drawLine(
          Offset(animatedPoints[i].dx * size.width, animatedPoints[i].dy * size.height),
          Offset(animatedPoints[j].dx * size.width, animatedPoints[j].dy * size.height),
          linePaint,
        );
      }
    }

    for (int i = 0; i < animatedPoints.length; i++) {
      final circlePaint = Paint()
        ..color = pointColors[i]
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 18.0);

      canvas.drawCircle(
        Offset(animatedPoints[i].dx * size.width, animatedPoints[i].dy * size.height),
        size.width * 0.02,
        circlePaint,
      );
    }

    debug("\tPunkte und Linien gezeichnet.");
    debug("}");
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
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
      home: const MyBackGround(content: SizedBox()),
    );

    debug("}");
    return widgetTree;
  }
}

import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:math';

// Globale Schlüssel und Debug-Funktion
final GlobalKey<_MyStringBackgroundState> BG_KEY = GlobalKey<_MyStringBackgroundState>();

void debug(String text) {
  if (false) print("[MyStringBackground] $text");
}

class MyStringBackground extends StatefulWidget {
  const MyStringBackground({Key? key}) : super(key: key);

  @override
  State<MyStringBackground> createState() => _MyStringBackgroundState();

  static _MyStringBackgroundState? of(BuildContext context) {
    return context.findAncestorStateOfType<_MyStringBackgroundState>();
  }
}

class _MyStringBackgroundState extends State<MyStringBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<StringParticle> particles;
  double hue = 8; // Für den Farbwechsel des Rahmens

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(minutes: 10), // Langsame Animation
      vsync: this,
    )..addListener(() {
      if (mounted) {
        setState(() {
          for (var particle in particles) {
            particle.update();
          }
          // Farbwechsel des Rahmens
          hue = (hue + 1) % 360; // Langsamer Farbwechsel durch den HSV-Farbraum
        });
      }
    })..repeat(); // Endlosschleife

    // Weniger Strings (5)
    const int numberOfStrings = 5;
    particles = List.generate(
      numberOfStrings,
          (index) => StringParticle(),
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
      painter: StringPainter(
        Theme.of(context),
        particles,
        hue,
      ),
    );
  }
}

// Klasse für String-Partikel (tanzende Kreise)
class StringParticle {
  List<Offset> points; // Punkte für einen geschlossenen Kreis
  List<Offset> velocities;
  Color color;

  StringParticle()
      : points = List.generate(
    8, // Mehr Punkte für einen weicheren Kreis
        (index) {
      final angle = 2 * pi * index / 8; // Gleichmäßige Verteilung auf einem Kreis
      final radius = Random().nextDouble() * 0.05 + 0.05; // Kleiner Radius für den Kreis
      final centerX = Random().nextDouble() * 0.5 + 0.25; // Innerhalb des Rahmens (0.25 bis 0.75)
      final centerY = Random().nextDouble() * 0.5 + 0.25;
      return Offset(
        centerX + radius * cos(angle),
        centerY + radius * sin(angle),
      );
    },
  ),
        velocities = List.generate(
          8,
              (index) => Offset(
            (Random().nextDouble() - 0.5) * 0.000002, // Langsame Bewegung
            (Random().nextDouble() - 0.5) * 0.000002,
          ),
        ),
        color = Colors.primaries[Random().nextInt(Colors.primaries.length)].withOpacity(0.8);

  void update() {
    for (int i = 0; i < points.length; i++) {
      points[i] += velocities[i];
      // Bounce innerhalb des engeren Bereichs (0.25 bis 0.75 in normierten Koordinaten)
      if (points[i].dx < 0.25 || points[i].dx > 0.75) velocities[i] = Offset(-velocities[i].dx, velocities[i].dy);
      if (points[i].dy < 0.25 || points[i].dy > 0.75) velocities[i] = Offset(velocities[i].dx, -velocities[i].dy);
    }
  }
}

// Custom Painter für die Strings und den Rahmen
class StringPainter extends CustomPainter {
  final ThemeData theme;
  final List<StringParticle> particles;
  final double hue;

  StringPainter(this.theme, this.particles, this.hue);

  @override
  void paint(Canvas canvas, Size size) {
    final stringPaint = Paint()
      ..strokeWidth = 0.5 // Dicke der Strings
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final framePaint = Paint()
      ..strokeWidth = 60 // Dünnerer Rahmen
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Hintergrund
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = theme.scaffoldBackgroundColor,
    );

    // Rahmen (kleinerer Kreis mit sanften Glow-Effekt)
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.22; // Kleinerer Kreis
    framePaint
      ..color = HSVColor.fromAHSV(1.0, hue, 1.0, 1.0).toColor()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20.0); // Sanfter Glow-Effekt
    canvas.drawCircle(center, radius, framePaint);

    // Strings (tanzende Kreise) zeichnen
    for (var particle in particles) {
      stringPaint
        ..color = particle.color
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0); // Glow für Strings

      // Erstelle einen geschlossenen Kreis durch die Punkte
      final path = Path();
      path.moveTo(particle.points[0].dx * size.width, particle.points[0].dy * size.height);
      for (int i = 0; i < particle.points.length; i++) {
        final nextIndex = (i + 1) % particle.points.length; // Schließt den Kreis
        final midX = (particle.points[i].dx + particle.points[nextIndex].dx) / 2 * size.width;
        final midY = (particle.points[i].dy + particle.points[nextIndex].dy) / 2 * size.height;
        path.quadraticBezierTo(
          particle.points[i].dx * size.width,
          particle.points[i].dy * size.height,
          midX,
          midY,
        );
      }
      path.close(); // Schließt den Pfad
      canvas.drawPath(path, stringPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Main-App bleibt gleich
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
      title: 'Tanzende Strings mit Rahmen',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: _themeMode,
      home: const MyStringBackground(),
    );

    debug("}");
    return widgetTree;
  }
}
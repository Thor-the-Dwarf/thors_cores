import 'package:flutter/material.dart';
import '../_globals/getColorForPercentage.dart'; // Annahme: Diese Funktion existiert


class HaloSphere extends StatefulWidget {
  final String text;
  double progress; // Fortschritt in Prozent

  HaloSphere({
    super.key,
    required this.text,
    required this.progress,
  });

  @override
  _HaloSphereState createState() => _HaloSphereState();
}

class _HaloSphereState extends State<HaloSphere> {
  late double _percentage;

  @override
  void initState() {
    super.initState();
    _percentage = widget.progress; // Initialer Wert
  }

  @override
  void didUpdateWidget(HaloSphere oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      setState(() {
        _percentage = widget.progress; // Aktualisiere den Fortschritt
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1, // Quadratisch
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.all(50),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).cardColor.withOpacity(0.93),
              boxShadow: [
                BoxShadow(
                  color: getColorForPercentage(_percentage), // Farbe basierend auf Fortschritt
                  blurRadius: 125,
                  spreadRadius: 5,
                ),
              ],
            ),
          ),
          Center(
            child: Text(
              widget.text,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dart Widget Demo',
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: Colors.black),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(child: HaloSphere(text: 'ist', progress: 10)),
              Expanded(child: HaloSphere(text: 'ist', progress: 20)),
              Expanded(child: HaloSphere(text: 'ist', progress: 30)),
              Expanded(child: HaloSphere(text: 'ist', progress: 40)),
            ],
          ),
        ),
      ),
    );
  }
}

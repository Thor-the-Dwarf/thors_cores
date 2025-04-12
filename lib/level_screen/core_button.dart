import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

class HaloSphere extends StatelessWidget {
  String text;
  Color color;

  HaloSphere({super.key, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1, // Quadratisch
      child: Stack(
        children: [
          Container(
            // padding: EdgeInsets.all(80),
            margin: EdgeInsets.all(50),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).cardColor.withOpacity(0.93),
              boxShadow: [
                BoxShadow(
                  color: color,
                  blurRadius: 125,
                  spreadRadius: 5,
                ),
              ],
            ),
          ),
          Center(
            child: Text(
              text,
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
              Expanded(child: HaloSphere(text: 'ist', color: Colors.red,)),
              Expanded(child: HaloSphere(text: 'ist', color: Colors.red,)),
              Expanded(child: HaloSphere(text: 'ist', color: Colors.red,)),
            ],
          ),
        ),
      ),
    );
  }
}

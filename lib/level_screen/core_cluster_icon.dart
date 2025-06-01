import 'package:flutter/material.dart';
import '../_globals/getColorForPercentage.dart';

class CoreClusterIcon extends StatefulWidget {
  double progress; // Fortschritt in Prozent

  CoreClusterIcon({
    super.key,
    required this.progress,
  });

  @override
  _CoreClusterIconState createState() => _CoreClusterIconState();
}

class _CoreClusterIconState extends State<CoreClusterIcon> {
  late double _percentage;

  @override
  void initState() {
    super.initState();
    _percentage = widget.progress; // Initialer Wert
  }

  @override
  void didUpdateWidget(CoreClusterIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      setState(() {
        _percentage = widget.progress; // Aktualisiere den Fortschritt
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(
          Icons.blur_circular,
          size: 48,
          color: getColorForPercentage(_percentage),
        ),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: Text(
            '${_percentage.toStringAsFixed(0)}%',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ClusterButton Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ClusterButton Example'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              21,
                  (index) {
                final percentage = index * 5.0;
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: CoreClusterIcon(progress: percentage),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
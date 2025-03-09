import 'dart:math';
import 'package:flutter/material.dart';
import 'package:neon_thors_cores/_gloabals/widgets/my_background.dart';
import 'package:neon_thors_cores/_gloabals/widgets/theme_toggler.dart';
import 'package:neon_thors_cores/quiz_screen/quiz__screen.dart';

List<String> btn_sprueche = [
  "🔥 Du bist auf dem richtigen Weg!",
  "🎯 Fokus! Du packst das!",
  // ... (rest of the list unchanged)
];

String zufaelliger_btn_spruch() {
  return btn_sprueche[Random().nextInt(btn_sprueche.length)];
}

class ArchivemendScreen extends StatefulWidget {
  const ArchivemendScreen({super.key});

  @override
  State<ArchivemendScreen> createState() => _ArchivemendScreenState();
}

class _ArchivemendScreenState extends State<ArchivemendScreen> {
  final String btn_text = zufaelliger_btn_spruch();
  double _progress = 0.0;
  bool _showLoadingBar = true;
  bool _hasStarted = false;

  @override
  void initState() {
    super.initState();
    _startLoading();
  }

  void _startLoading() {
    if (_hasStarted) return;
    _hasStarted = true;
    Future.delayed(Duration.zero, () async {
      for (int i = 0; i <= 100; i++) {
        await Future.delayed(const Duration(milliseconds: 10));
        if (!mounted) return;
        setState(() {
          _progress = i / 100;
        });
      }
      if (!mounted) return;
      setState(() {
        _showLoadingBar = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: ThemeToggler(),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: Stack(
        children: [
          MyBackGround(key: BG_KEY),
          Center(
            child: Column(
              children: [
                const Spacer(),
                _showLoadingBar
                    ? Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 200,
                      height: 20,
                      child: LinearProgressIndicator(
                        value: _progress,
                        backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.5),
                        valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                      ),
                    ),
                    Text(
                      _progress < 1 ? "Speichere Fortschritte" : "",
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                    ),
                  ],
                )
                    : const SizedBox.shrink(),
                const Spacer(),
                Text(
                  "Wiederholung ist die Mutter des Lernens",
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => QuizScreen(selected_level_pk: "188de553-db8e-499e-8bf5-049884b88a05",)),
                    );
                  },
                  child: Text(btn_text),
                ),
                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
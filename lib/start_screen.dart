import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:neon_thors_cores/_globals/widgets/my_background.dart';
import 'package:neon_thors_cores/_globals/widgets/theme_controller.dart';
import 'package:neon_thors_cores/level_screen/level_screen.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

import 'level_screen/player/local_storage_player.dart'; // Für zufällige Benutzer-ID

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const String keyData = r"Alpha_B8$kFm2@rW^bXe!4pZ*u&oR6%1HjLq#G7Nv?Td";
    final TextEditingController _keyController = TextEditingController();

    // Funktion zum Generieren einer zufälligen Benutzer-ID
    String generateUserId() {
      const String chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
      Random random = Random();
      return String.fromCharCodes(
        Iterable.generate(
          10,
              (_) => chars.codeUnitAt(random.nextInt(chars.length)),
        ),
      );
    }


// Funktion zum Anzeigen des PopUps
    Future<void> _showKeyPopup(BuildContext context) async {
      // Funktion zum Generieren eines UUID-ähnlichen Schlüssels im Format 8-4-4-4-12
      String generateCustomUuid() {
        const String chars = '0123456789abcdef';
        final Random random = Random();
        String generateSegment(int length) {
          return String.fromCharCodes(
            Iterable.generate(
              length,
                  (_) => chars.codeUnitAt(random.nextInt(chars.length)),
            ),
          );
        }
        return '${generateSegment(8)}-${generateSegment(4)}-${generateSegment(4)}-${generateSegment(4)}-${generateSegment(12)}';
      }

      String userId = generateCustomUuid(); // Generiere Schlüssel (z. B. 78dba1ff-63d5-4e39-b477-6435aeab3a3e)

      // Prüfe, ob bereits eine ID im Local Storage existiert
      final prefs = await SharedPreferences.getInstance();
      userId = prefs.getString('user_id') ?? userId;
      if (prefs.getString('user_id') == null) {
        await prefs.setString('user_id', userId); // Speichere neue ID
      }

      showDialog(
        context: context,
        builder: (BuildContext context) {
          bool saveProgress = false; // Zustand der Checkbox innerhalb des Dialogs
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                // backgroundColor: Colors.grey[900], // Dunkler, schlichter Hintergrund
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                title: const Text(
                  'Dein persönlicher Schlüssel',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                  ),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Hey, hier ist dein Schlüssel: ',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                        SelectableText(
                          userId,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF00FF00), // Neon-Grün für den Schlüssel
                            shadows: [
                              Shadow(
                                color: Color(0xFF00FF00),
                                blurRadius: 5,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(
                            Icons.copy,
                            size: 20,
                            color: Colors.white70,
                          ),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: userId));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Schlüssel kopiert!",
                                  style: TextStyle(color: Colors.white),
                                ),
                                backgroundColor: Colors.grey,
                              ),
                            );
                          },
                          tooltip: "Schlüssel kopieren",
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Speicher ihn gut ab! Wenn du das nächste Mal kommst, sind dort deine Fortschritte gespeichert.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Checkbox(
                          value: saveProgress,
                          onChanged: (bool? value) {
                            setState(() {
                              saveProgress = value ?? false;
                            });
                          },
                          activeColor: Colors.white,
                          checkColor: Colors.black,
                        ),
                        const Flexible(
                          child: Text(
                            'Fortschritte lokal speichern? (Wenn du das Häkchen setzt, wird dein Fortschritt mit deinem Schlüssel auf deinem Gerät gesichert.)',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                actions: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: !saveProgress
                            ? () {
                          Navigator.of(context).pop(); // Schließe das PopUp
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LevelScreen(),
                            ),
                          );
                        }
                            : null,
                        child: const Text('Ohne Speichern fortfahren'),
                      ),
                      ElevatedButton(
                        onPressed: saveProgress
                            ? () async {
                          await LocalStoragePlayer().load(key: keyData); // Erstellt die Singleton-Instanz
                          Navigator.of(context).pop();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LevelScreen(),
                            ),
                          );
                        }
                            : null,
                        child: const Text('Speichern ermöglichen'),
                      ),
                    ],
                  ),
                ],
              );
            },
          );
        },
      );
    }

    return Consumer<ThemeController>(
      builder: (context, themeController, child) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(
                themeController.themeMode == ThemeMode.dark
                    ? Icons.dark_mode
                    : Icons.light_mode,
                color: Theme.of(context).iconTheme.color,
              ),
              onPressed: () {
                themeController.toggleTheme();
              },
            ),
          ),
          body: Stack(
            children: [
              const MyBackGround(),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Sichere dir diesen Schlüssel solange er hier eingeblendet ist!",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    const Text(
                        "Bald kann man die Web-App nur noch mit diesem oder ähnlichen Schlüsseln betreten."),
                    const Text(
                        "Dieser Alpha-Schlüssel wird vstl. bis Juni Zutritt verschaffen."),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Alpha-Schlüssel:  "),
                        const SelectableText(
                          keyData,
                          style: TextStyle(fontSize: 30),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.copy, size: 20),
                          onPressed: () {
                            Clipboard.setData(
                                const ClipboardData(text: keyData));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Schlüssel kopiert!")),
                            );
                          },
                          tooltip: "Schlüssel kopieren",
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 200,
                          child: TextField(
                            controller: _keyController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: "Schlüssel eingeben",
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () async {
                            final subscriptionId = _keyController.text.trim();
                            if (subscriptionId.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Bitte geben Sie eine Subscription ID ein!')),
                              );
                              return;
                            }

                            try {
                              final supabase = Supabase.instance.client;
                              final response = await supabase
                                  .from('access_keys')
                                  .select()
                                  .eq('paypal_subscription_id', subscriptionId)
                                  .maybeSingle();

                              if (response != null &&
                                  DateTime.parse(response['valid_until'])
                                      .isAfter(DateTime.now())) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const LevelScreen()),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Ungültige oder abgelaufene Subscription ID!')),
                                );
                              }
                            } catch (error) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                    Text('Fehler bei der Überprüfung!')),
                              );
                            }
                          },
                          child: const Text('Betreten'),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () => _showKeyPopup(context), // Zeige PopUp
                      child: const Text("ausprobieren"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
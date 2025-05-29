import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:neon_thors_cores/_globals/widgets/my_background.dart';
import 'package:neon_thors_cores/_globals/widgets/theme_controller.dart';
import 'package:neon_thors_cores/level_screen/level_screen.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const String keyData = r"Alpha_B8$kFm2@rW^bXe!4pZ*u&oR6%1HjLq#G7Nv?Td";
    final TextEditingController _keyController = TextEditingController();

    return Consumer<ThemeController>(
      builder: (context, themeController, child) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(
                themeController.themeMode == ThemeMode.dark
                    ? Icons.dark_mode
                    : Icons.light_mode,
                color: Theme
                    .of(context)
                    .iconTheme
                    .color,
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
                    Text(
                        "Bald kann man die Web-App nur noch mit diesem oder ähnlichen Schlüsseln betreten."),
                    Text(
                        "Dieser Alpha-Schlüssel wird vstl. bis Juni Zutritt verschaffen."),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Alpha-Schlüssel:  "),
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
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              hintText: "Schlüssel eingeben",
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // ElevatedButton(
                        //   onPressed: () {
                        //     if (_keyController.text == keyData) {
                        //       Navigator.push(
                        //         context,
                        //         MaterialPageRoute(
                        //           builder:
                        //               (context) =>
                        //               LevelScreen(),
                        //         ),
                        //       );
                        //     } else {
                        //       ScaffoldMessenger.of(context).showSnackBar(
                        //         const SnackBar(
                        //             content: Text("Falscher Schlüssel!")),
                        //       );
                        //     }
                        //   },
                        //   child: const Text("Betreten"),
                        // ),

                        ElevatedButton(
                          onPressed: () async {
                            final subscriptionId = _keyController.text.trim();
                            if (subscriptionId.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text(
                                    'Bitte geben Sie eine Subscription ID ein!')),
                              );
                              return;
                            }

                            try {
                              final supabase = Supabase.instance
                                  .client; // Supabase-Client initialisieren
                              final response = await supabase
                                  .from('access_keys')
                                  .select()
                                  .eq('paypal_subscription_id', subscriptionId)
                                  .maybeSingle();

                              if (response != null && DateTime.parse(
                                  response['valid_until']).isAfter(
                                  DateTime.now())) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => LevelScreen()),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text(
                                      'Ungültige oder abgelaufene Subscription ID!')),
                                );
                              }
                            } catch (error) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Fehler bei der Überprüfung!')),
                              );
                            }
                          },
                          child: const Text('Betreten'),
                        ),
                      ],
                    ),
                    ElevatedButton(
                        onPressed: () =>
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) =>
                                  LevelScreen()),
                            ),
                        child: Text("ausprobieren"))
                  ],
                ),
              ),
            ]
            ,
          )
          ,
        );
      },
    );
  }
}
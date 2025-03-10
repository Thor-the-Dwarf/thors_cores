import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:neon_thors_cores/_gloabals/widgets/my_background.dart';
import 'package:neon_thors_cores/quiz_screen/quiz__screen.dart';
import 'package:neon_thors_cores/quiz_screen/tenth_q_screen.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '_gloabals/debug_prints.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import '_gloabals/widgets/theme_toggler.dart';
import 'firebase_options.dart';
import 'level_screen/level_screen.dart';
import 'level_screen/tree_node.dart';

void debug(String text) {
  if (false || DEBUG_EVERYTHING) printRed("[main] $text");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );
  WidgetsFlutterBinding.ensureInitialized();

  setUrlStrategy(PathUrlStrategy());

  try {
    await Supabase.initialize(
      url: 'https://ecwnrkrknjirkvkmdbsq.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVjd25ya3Jrbmppcmt2a21kYnNxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDEwMDEwMTQsImV4cCI6MjA1NjU3NzAxNH0.Jc2Adsk7-py5kxAtN83zBPvpouWfahBekPVFKiAFEcc',
    );
    print("✅ Supabase erfolgreich initialisiert!");
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("testKey", "Testwert");
    print("✅ SharedPreferences erfolgreich gespeichert!");
  } catch (e) {
    print("❌ Fehler bei Supabase- oder SharedPreferences-Init: $e");
  }

  runApp(const MyApp()); // Kein Provider mehr nötig, da Theme fest ist

  debug("App gestartet!");
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: ThemeController(), // Singleton-Instanz
      child: Consumer<ThemeController>(
        builder: (context, themeController, child) {
          return MaterialApp(
            theme: ThemeData.light(), // Light Mode Theme
            darkTheme: ThemeData.dark(), // Dark Mode Theme
            themeMode: themeController.themeMode, // Dynamisch vom Controller
            home:

            // const ArchivemendScreen(),
            // QuizScreen(selected_level_pk: "188de553-db8e-499e-8bf5-049884b88a05"),
            const LevelScreen()
          );
        },
      ),
    );
  }
}


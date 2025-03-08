import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:neon_thors_cores/quiz_screen/quiz__screen.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '_gloabals/debug_prints.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import '_gloabals/widgets/theme_toggler.dart';
import 'firebase_options.dart';

void debug(String text) {
  if (false || DEBUG_EVERYTHING) printRed("[main] $text");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseFirestore.instance.settings = const Settings(
    // macht alles kostengünstiger
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Web-Plugins explizit registrieren
  setUrlStrategy(PathUrlStrategy());

  try {
    await Supabase.initialize(
      url: 'https://ecwnrkrknjirkvkmdbsq.supabase.co', // 🛑 Deine Supabase URL
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVjd25ya3Jrbmppcmt2a21kYnNxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDEwMDEwMTQsImV4cCI6MjA1NjU3NzAxNH0.Jc2Adsk7-py5kxAtN83zBPvpouWfahBekPVFKiAFEcc', // 🛑 Dein API Key
    );
    print("✅ Supabase erfolgreich initialisiert!");

    // ✅ Teste SharedPreferences nach Init
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("testKey", "Testwert");
    print("✅ SharedPreferences erfolgreich gespeichert!");
  } catch (e) {
    print("❌ Fehler bei Supabase- oder SharedPreferences-Init: $e");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeController()),
      ],
      child: const MyApp(),
    ),
  );

  debug("App gestartet!");
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Startseite")),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder:
                    (context) =>
                        // Swiper(),
                        QuizScreen(),
                // const AllQuestionsPage(),
              ),
            );
          },
          child: const Text("open LevelScreen"),
        ),
      ),
    );
  }
}

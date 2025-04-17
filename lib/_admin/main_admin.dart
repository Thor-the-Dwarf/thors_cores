import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:neon_thors_cores/_admin/SQL_Execution_Screen.dart';
import 'package:neon_thors_cores/start_screen.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import '../_globals/debug_prints.dart';
import '../_globals/widgets/theme_controller.dart';
import '../_globals/widgets/theme_toggler.dart';
import '../firebase_options.dart';

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

    // Benutzer anmelden
    final authResponse = await Supabase.instance.client.auth.signInWithPassword(
      email: 'thor.schott@gmail.com', // Deine echte E-Mail-Adresse
      password: '{LäberKas',     // Dein Passwort
    );

    if (authResponse.user == null) {
      print('❌ Fehler bei der Anmeldung: Kein Benutzer gefunden.');
      return;
    }

    print("✅ Benutzer erfolgreich angemeldet: ${authResponse.user?.email}");
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("testKey", "Testwert");
    print("✅ SharedPreferences erfolgreich gespeichert!");
  } catch (e) {
    print("❌ Fehler bei Supabase-oder SharedPreferences-Init: $e");
  }

  runApp(const MyApp());
  debug("App gestartet!");
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: ThemeController(),
      child: Consumer<ThemeController>(
        builder: (context, themeController, child) {
          return MaterialApp(
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            themeMode: themeController.themeMode,
            home: const SqlExecutionPage(),
          );
        },
      ),
    );
  }
}
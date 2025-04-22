// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'dart:convert';
//
// class SqlExecutionPage extends StatefulWidget {
//   const SqlExecutionPage({super.key});
//
//   @override
//   _SqlExecutionPageState createState() => _SqlExecutionPageState();
// }
//
// class _SqlExecutionPageState extends State<SqlExecutionPage> {
//   String _statusMessage = 'Keine Dateien ausgewählt.';
//   bool _isLoading = false;
//
//   final SupabaseClient supabase = Supabase.instance.client;
//
//   Future<void> _pickAndExecuteSqlFiles() async {
//     setState(() {
//       _isLoading = true;
//       _statusMessage = 'Dateien werden ausgewählt...';
//     });
//
//     try {
//       FilePickerResult? result = await FilePicker.platform.pickFiles(
//         type: FileType.custom,
//         allowedExtensions: ['sql'],
//         allowMultiple: true,
//       );
//
//       if (result == null || result.files.isEmpty) {
//         setState(() {
//           _statusMessage = 'Keine Dateien ausgewählt.';
//           _isLoading = false;
//         });
//         return;
//       }
//
//       List<String> successFiles = [];
//       List<String> failedFiles = [];
//
//       for (PlatformFile platformFile in result.files) {
//         final fileName = platformFile.name;
//
//         if (platformFile.bytes == null) {
//           failedFiles.add('$fileName: Keine Daten verfügbar.');
//           continue;
//         }
//
//         final sqlContent = utf8.decode(platformFile.bytes!);
//         final statements = sqlContent.split(';').where((s) => s.trim().isNotEmpty).toList();
//
//         if (statements.isEmpty) {
//           failedFiles.add('$fileName: Enthält keine gültigen SQL-Befehle.');
//           continue;
//         }
//
//         final coreName = fileName.endsWith('.sql') ? fileName.substring(0, fileName.length - 4) : fileName;
//
//         for (String statement in statements) {
//           if (statement.trim().startsWith('--')) continue;
//           try {
//             await supabase.rpc('mass_insert.execute_sql', params: {'query': statement});
//           } catch (e) {
//             failedFiles.add('Fehler in "$fileName" bei Statement "$statement": $e');
//             break;
//           }
//         }
//
//         try {
//           await supabase.rpc('mass_insert.process_questions', params: {
//             'core_name_param': coreName,
//             'insert_statements': 'SELECT 1',
//           });
//           successFiles.add(fileName);
//         } catch (e) {
//           failedFiles.add('Fehler in "$fileName" bei process_questions: $e');
//         }
//       }
//
//       setState(() {
//         _statusMessage = 'Erfolgreich: $successFiles\nFehler: $failedFiles';
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _statusMessage = 'Allgemeiner Fehler: $e';
//         _isLoading = false;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('SQL-Dateien ausführen')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             ElevatedButton(
//               onPressed: _isLoading ? null : _pickAndExecuteSqlFiles,
//               child: const Text('SQL-Dateien auswählen und ausführen'),
//             ),
//             const SizedBox(height: 20),
//             _isLoading
//                 ? const CircularProgressIndicator()
//                 : Text(
//               _statusMessage,
//               style: const TextStyle(fontSize: 16),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
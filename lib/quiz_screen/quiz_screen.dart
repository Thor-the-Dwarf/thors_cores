// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:provider/provider.dart';
// import 'package:tiktoklikescroller/tiktoklikescroller.dart';
// import '../_gloabals/debug_prints.dart';
// import '../_gloabals/key_map.dart';
// import '../_gloabals/my_background.dart';
//
// void debug(String text) {
//   if (false || DEBUG_EVERYTHING) printYellow("[QuizScreen] $text");
// }
//
// class QuizScreen extends StatefulWidget {
//   const QuizScreen({super.key});
//
//   @override
//   _QuizScreenState createState() => _QuizScreenState();
// }
//
// class _QuizScreenState extends State<QuizScreen> {
//   final RegExp filter = RegExp(
//     r'^[a-z]$|enter|arrow up|arrow down',
//     caseSensitive: false,
//   );
//   final FocusNode _focusNode = FocusNode();
//   final Controller ticTokController = Controller();
//
//   @override
//   void initState() {
//     super.initState();
//     Future.delayed(Duration.zero, () => _focusNode.requestFocus());
//   }
//
//   @override
//   void dispose() {
//     _focusNode.dispose();
//     super.dispose();
//   }
//
//   void _handleKey(RawKeyEvent event) {
//     debug("_handleKey(){");
//
//     if (event is RawKeyDownEvent) {
//       LogicalKeyboardKey logicalKey = event.logicalKey;
//       String keyLabel = logicalKey.keyLabel.toLowerCase();
//
//       // Falls keyLabel leer ist, verwende debugName als Fallback
//       if (keyLabel.isEmpty) {
//         keyLabel = logicalKey.debugName?.toLowerCase() ?? "";
//       }
//
//       debug("\tTaste gedrückt: $keyLabel");
//
//       // Navigation mit Pfeiltasten
//       if (logicalKey == LogicalKeyboardKey.arrowUp) {
//         _arrowUpEvent();
//       } else if (logicalKey == LogicalKeyboardKey.arrowDown) {
//         _arrowDownEvent();
//       }
//       // Enter zum Locken
//       else if (logicalKey == LogicalKeyboardKey.enter) {
//         final quizmaster = Provider.of<QuizVM>(context, listen: false);
//         final currentQuestion =
//             quizmaster.question_history[quizmaster.currentQuestionIndex];
//         debug("\t⏎ Enter-Taste erkannt!");
//         currentQuestion.lock();
//       }
//       // Auswahl einer Antwort per Buchstaben
//       else if (RegExp(r'^[a-z]$', caseSensitive: false).hasMatch(keyLabel)) {
//         final quizmaster = Provider.of<QuizVM>(context, listen: false);
//         final currentQuestion =
//             quizmaster.question_history[quizmaster.currentQuestionIndex];
//         debug("\t🔤 Buchstabe erkannt: $keyLabel");
//
//         if (keyMap.containsKey(logicalKey.keyId)) {
//           int selectedIndex = keyMap[logicalKey.keyId]!;
//           if (selectedIndex < currentQuestion.questionSelections.length) {
//             currentQuestion.selectQuestion(selectedIndex);
//           }
//         }
//       }
//     }
//
//     debug("}");
//   }
//
//   void _arrowDownEvent() {
//     final quizmaster = Provider.of<QuizVM>(context, listen: false);
//     final currentQuestion =
//         quizmaster.question_history[quizmaster.currentQuestionIndex];
//     debug("\t⬇️ Pfeil nach unten erkannt!");
//     if (quizmaster.currentQuestionIndex > 0) {
//       // **Fix: Kein negatives Index**
//       quizmaster.currentQuestionIndex -= 1;
//       debug(
//         "🛑 TikTokController soll sich bewegen zu: ${quizmaster.currentQuestionIndex}",
//       );
//       ticTokController.animateToPosition(quizmaster.currentQuestionIndex);
//     } else {
//       debug("⚠️ Erste Frage erreicht – kann nicht weiter zurück.");
//     }
//   }
//
//   void _arrowUpEvent() {
//     final quizmaster = Provider.of<QuizVM>(context, listen: false);
//     final currentQuestion =
//         quizmaster.question_history[quizmaster.currentQuestionIndex];
//     debug("\t⬆️ Pfeil nach oben erkannt!");
//     if (quizmaster.currentQuestionIndex <
//         quizmaster.question_history.length - 1) {
//       quizmaster.currentQuestionIndex += 1;
//       debug(
//         "🛑 TikTokController soll sich bewegen zu: ${quizmaster.currentQuestionIndex}",
//       );
//       ticTokController.animateToPosition(quizmaster.currentQuestionIndex);
//     } else {
//       debug("⚠️ Kein weiteres Element mehr – Grenze erreicht.");
//     }
//   }
//
//   int? lastPopupIndex; // 🛑 Speichert den letzten gezeigten Index
//
//   void checkAndShowPopup(BuildContext context, int index, QuizVM vm) {
//     if (index % 10 == 0 && index != 0 && !vm.question_history[index].isLocked) {
//       if (lastPopupIndex != index) {
//         // 🔥 Nur anzeigen, wenn noch nicht passiert
//         lastPopupIndex = index;
//         Future.delayed(Duration.zero, () => showFullscreenPopup(context));
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: RawKeyboardListener(
//         onKey: _handleKey,
//         focusNode: _focusNode..requestFocus(),
//         autofocus: true,
//         child: MyBackGround(
//           content: Consumer<QuizVM>(
//             builder: (context, vm, _) {
//               return vm.question_history.isEmpty
//                   ? const Center(child: Text("Keine Fragen verfügbar"))
//                   : TikTokStyleFullPageScroller(
//                     contentSize: vm.question_history.length,
//                     swipePositionThreshold: 0.2,
//                     swipeVelocityThreshold: 2000,
//                     animationDuration: const Duration(milliseconds: 400),
//                     controller: ticTokController,
//                     builder: (context, index) {
//                       checkAndShowPopup(context, index, vm);
//                       return ChangeNotifierProvider.value(
//                         value: vm.question_history[vm.currentQuestionIndex],
//                         child: Consumer<QuizQuestion>(
//                           builder: (context, currentQVM, _) {
//                             return FrageWidget(
//                               currentQVM: currentQVM,
//                               onArrowUp: () => _arrowUpEvent(),
//                               onArrowDown: () => _arrowDownEvent(),
//                             ); // NEUES WIDGET HIER!
//                           },
//                         ),
//                       );
//                     },
//                   );
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }

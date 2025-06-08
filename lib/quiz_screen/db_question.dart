import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:neon_thors_cores/quiz_screen/question_vm.dart';
import 'package:neon_thors_cores/quiz_screen/question_widget.dart';
import 'package:neon_thors_cores/quiz_screen/tenth_q_screen.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../_globals/debug_prints.dart';
import '../_globals/key_map.dart';
import '../_globals/widgets/my_background.dart';
import '../_globals/widgets/theme_toggler.dart';
import '../level_screen/tree_node.dart';
import 'db_question.dart';

void debug(String text) {
  if (false || DEBUG_EVERYTHING) printYellow("[QuizScreen] $text");
}

class Question {
  final String question_pk;
  final String text;
  final int points;
  final List<Option> options;
  final String essence_fk; // Hinzugefügt

  Question({
    required this.question_pk,
    required this.text,
    required this.points,
    required this.options,
    required this.essence_fk, // Hinzugefügt
  });

  factory Question.fromSupaBase(Map<String, dynamic> data) {
    List<Option> options = (data['options'] as List<dynamic>)
        .map((opt) => Option.fromJson(opt))
        .toList();

    options.shuffle(Random());

    return Question(
      question_pk: data['question_pk']?.toString() ?? 'unknown',
      text: data['text'] ?? 'Keine Frage gefunden',
      points: data['points'] ?? 0,
      options: options,
      essence_fk: data['essence_fk']?.toString() ?? 'unknown', // Hinzugefügt
    );
  }
}

class Option {
  final String text;
  final String because;
  final bool correct;

  Option({required this.text, required this.because, required this.correct});

  factory Option.fromJson(Map<String, dynamic> json) {
    return Option(
      text: json['text'] as String,
      because: json['because'] as String,
      correct: json['correct'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {'text': text, 'because': because, 'correct': correct};
  }
}

// class QuizScreen extends StatefulWidget {
//   final String selected_level_pk;
//   final List<TreeNode> tree;
//   final Map<String, List<Map<String, dynamic>>> coreData;
//   late final SupabaseClient supabase;
//   List<QuestionWidget> history = [];
//   List<QuestionWidget> questions = [];
//
//   QuizScreen({
//     super.key,
//     required this.selected_level_pk,
//     required this.tree,
//     required this.coreData,
//   });
//
//   @override
//   _QuizScreenState createState() => _QuizScreenState();
// }
//
// class _QuizScreenState extends State<QuizScreen> {
//   final FocusNode _focusNode = FocusNode();
//   final PageController _pageController = PageController();
//   int currentIndex = 0;
//   bool isLoading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     widget.supabase = Supabase.instance.client;
//     _load10Questions(widget.selected_level_pk);
//     Future.delayed(Duration.zero, () => _focusNode.requestFocus());
//   }
//
//   @override
//   void dispose() {
//     _focusNode.dispose();
//     _pageController.dispose();
//     super.dispose();
//   }
//
//   void _handleKey(RawKeyEvent event) {
//     if (event is RawKeyDownEvent) {
//       LogicalKeyboardKey logicalKey = event.logicalKey;
//
//       if (logicalKey == LogicalKeyboardKey.arrowUp) {
//         _scrollUp();
//       } else if (logicalKey == LogicalKeyboardKey.arrowDown) {
//         _scrollDown();
//       } else if (logicalKey == LogicalKeyboardKey.enter) {
//         _lockEvent();
//       } else if (RegExp(
//         r'^[a-z]$',
//         caseSensitive: false,
//       ).hasMatch(logicalKey.keyLabel.toLowerCase())) {
//         if (keyMap.containsKey(logicalKey.keyId)) {
//           int selectedIndex = keyMap[logicalKey.keyId]!;
//           widget.history[currentIndex].questionVM.selectQuestion(selectedIndex);
//         }
//       }
//     }
//   }
//
//   void _scrollUp() {
//     if (widget.history[currentIndex].questionVM.isLocked) {
//       if (currentIndex < widget.history.length - 1) {
//         setState(() {
//           currentIndex++;
//           _pageController.animateToPage(
//             currentIndex,
//             duration: const Duration(milliseconds: 300),
//             curve: Curves.easeInOut,
//           );
//         });
//       } else if (widget.history.length < 10 && widget.questions.isNotEmpty) {
//         setState(() {
//           widget.history.add(widget.questions.removeAt(0));
//           currentIndex++;
//           _pageController.animateToPage(
//             currentIndex,
//             duration: const Duration(milliseconds: 300),
//             curve: Curves.easeInOut,
//           );
//         });
//       } else if (currentIndex == 9) {
//         Navigator.of(context).pushReplacement(
//           MaterialPageRoute(builder: (context) => ArchivemendScreen(selected_level_pk: widget.selected_level_pk)),
//         );
//       }
//     }
//   }
//
//   void _scrollDown() {
//     if (currentIndex > 0) {
//       setState(() {
//         currentIndex--;
//         _pageController.animateToPage(
//           currentIndex,
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeInOut,
//         );
//       });
//     }
//   }
//
//   void _lockEvent() {
//     widget.history[currentIndex].questionVM.lock();
//   }
//
//   List<Map<String, dynamic>> _collectAllCores(String levelId, List<TreeNode> tree) {
//     List<Map<String, dynamic>> allCores = [];
//
//     TreeNode? findNode(String id, List<TreeNode> nodes) {
//       for (var node in nodes) {
//         if (node.id == id) return node;
//         if (node.children.isNotEmpty) {
//           final found = findNode(id, node.children);
//           if (found != null) return found;
//         }
//       }
//       return null;
//     }
//
//     final node = findNode(levelId, tree);
//     if (node == null) return allCores;
//
//     void collectCores(TreeNode node) {
//       if (node.hasCores && widget.coreData[node.id] != null) {
//         allCores.addAll(widget.coreData[node.id]!);
//       }
//       for (var child in node.children) {
//         collectCores(child);
//       }
//     }
//
//     collectCores(node);
//     return allCores;
//   }
//
//   Future<void> _load10Questions(String levelPk) async {
//     List<QuestionWidget> list = [];
//
//     // Sammle alle Cores des Levels und seiner Sub-Levels
//     final allCores = _collectAllCores(levelPk, widget.tree);
//
//     if (allCores.isEmpty) {
//       debug('Keine Cores in diesem Level oder seinen Sub-Levels gefunden.');
//       setState(() {
//         isLoading = false;
//       });
//       return;
//     }
//
//     // Sammle alle Essences, die mit den Cores verknüpft sind
//     List<String> essencePks = [];
//     for (var core in allCores) {
//       final coreId = core['id'] as String;
//       final essenceResponse = await widget.supabase
//           .from('essence')
//           .select('essence_pk')
//           .eq('core_fk', coreId);
//
//       if (essenceResponse != null && essenceResponse.isNotEmpty) {
//         essencePks.addAll(essenceResponse.map((e) => e['essence_pk'] as String));
//       }
//     }
//
//     if (essencePks.isEmpty) {
//       debug('Keine Essences für die Cores gefunden.');
//       setState(() {
//         isLoading = false;
//       });
//       return;
//     }
//
//     // Lade alle Fragen für die Essences
//     List<Map<String, dynamic>> availableQuestions = [];
//     final questionResponse = await widget.supabase
//         .from('question')
//         .select('question_pk, text, points, options')
//         .inFilter('essence_fk', essencePks);
//
//     debug('Question Response: $questionResponse');
//
//     if (questionResponse != null && questionResponse.isNotEmpty) {
//       availableQuestions = questionResponse.cast<Map<String, dynamic>>();
//     }
//
//     if (availableQuestions.isEmpty) {
//       debug('Keine Fragen für die Essences gefunden.');
//       setState(() {
//         isLoading = false;
//       });
//       return;
//     }
//
//     // Filtere Fragen, die bereits in der History sind
//     List<String> excludedPks = widget.history
//         .map((qw) => qw.questionVM.question.question_pk)
//         .toList();
//     availableQuestions = availableQuestions
//         .where((q) => !excludedPks.contains(q['question_pk'] as String))
//         .toList();
//
//     // Wähle zufällig 10 Fragen aus (oder weniger, wenn nicht genug verfügbar)
//     final random = Random();
//     while (list.length < 10 && availableQuestions.isNotEmpty) {
//       final questionIndex = random.nextInt(availableQuestions.length);
//       final questionData = availableQuestions[questionIndex];
//       debug('Verarbeitete Frage: $questionData');
//       list.add(
//         QuestionWidget(
//           questionVM: QuestionVM(question: Question.fromSupaBase(questionData)),
//         ),
//       );
//       availableQuestions.removeAt(questionIndex);
//     }
//
//     if (list.length < 10) {
//       debug('Nicht genug Fragen gefunden. Gefundene Fragen: ${list.length}');
//     }
//
//     setState(() {
//       widget.questions = list;
//       if (widget.questions.isNotEmpty) {
//         widget.history.add(
//           widget.questions.removeAt(random.nextInt(widget.questions.length)),
//         );
//       }
//       isLoading = false;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(leading: const ThemeToggler()),
//       body: Stack(
//         children: [
//           MyBackGround(
//             key: BG_KEY,
//           ),
//           isLoading
//               ? const Center(child: CircularProgressIndicator())
//               : widget.history.isEmpty
//               ? const Center(child: Text('Keine Fragen verfügbar'))
//               : RawKeyboardListener(
//             onKey: _handleKey,
//             focusNode: _focusNode..requestFocus(),
//             autofocus: true,
//             child: GestureDetector(
//               onVerticalDragEnd: (details) {
//                 if (details.primaryVelocity! > 0) {
//                   _scrollDown();
//                 } else if (details.primaryVelocity! < 0 &&
//                     widget.history[currentIndex].questionVM.isLocked) {
//                   _scrollUp();
//                 }
//               },
//               child: PageView.builder(
//                 controller: _pageController,
//                 scrollDirection: Axis.vertical,
//                 itemCount: widget.history.length,
//                 physics: const PageScrollPhysics(),
//                 onPageChanged: (index) {
//                   setState(() {
//                     currentIndex = index;
//                   });
//                 },
//                 itemBuilder: (context, index) {
//                   return Column(
//                     children: [
//                       Flexible(
//                         child: ConstrainedBox(
//                           constraints: BoxConstraints(
//                             minHeight: 0,
//                             maxHeight: MediaQuery.of(context).size.height * 0.7,
//                           ),
//                           child: Scrollbar(
//                             child: SingleChildScrollView(
//                               child: widget.history[index],
//                             ),
//                           ),
//                         ),
//                       ),
//                       SizedBox(
//                         height: 60,
//                         child: Row(
//                           children: [
//                             Expanded(
//                               child: Material(
//                                 color: Colors.transparent,
//                                 child: InkWell(
//                                   onTap: _scrollDown,
//                                   hoverColor: Colors.grey.withOpacity(0.1),
//                                   highlightColor: Colors.grey.withOpacity(0.1),
//                                   splashColor: Colors.grey.withOpacity(0.1),
//                                   child: const Center(
//                                     child: Icon(Icons.arrow_drop_down),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             ChangeNotifierProvider.value(
//                               value: widget.history[index].questionVM,
//                               child: Consumer<QuestionVM>(
//                                 builder: (context, vm, child) {
//                                   return Visibility(
//                                     visible: !vm.isLocked,
//                                     child: Expanded(
//                                       child: Material(
//                                         color: Colors.transparent,
//                                         child: InkWell(
//                                           onTap: _lockEvent,
//                                           hoverColor: Colors.grey.withOpacity(0.1),
//                                           highlightColor: Colors.grey.withOpacity(0.1),
//                                           splashColor: Colors.grey.withOpacity(0.1),
//                                           child: const Center(
//                                             child: Icon(Icons.lock),
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   );
//                                 },
//                               ),
//                             ),
//                             Expanded(
//                               child: Material(
//                                 color: Colors.transparent,
//                                 child: InkWell(
//                                   onTap: _scrollUp,
//                                   hoverColor: Colors.grey.withOpacity(0.1),
//                                   highlightColor: Colors.grey.withOpacity(0.1),
//                                   splashColor: Colors.grey.withOpacity(0.1),
//                                   child: const Center(
//                                     child: Icon(Icons.arrow_drop_up),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   );
//                 },
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
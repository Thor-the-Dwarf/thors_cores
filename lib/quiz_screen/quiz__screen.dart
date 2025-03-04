import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:neon_thors_cores/quiz_screen/question_vm.dart';
import 'package:neon_thors_cores/quiz_screen/question_widget.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tiktoklikescroller/tiktoklikescroller.dart';
import '../_gloabals/debug_prints.dart';
import '../_gloabals/key_map.dart';
import '../_gloabals/my_background.dart';
import 'db_question.dart';

void debug(String text) {
  if (false || DEBUG_EVERYTHING) printYellow("[QuizScreen] $text");
}

class QuizScreen extends StatefulWidget {
  late final SupabaseClient supabase;
  late Controller tikTokController;
  List<QuestionWidget> questions = [];

  QuizScreen({super.key});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final RegExp filter = RegExp(
    r'^[a-z]$|enter|arrow up|arrow down',
    caseSensitive: false,
  );
  final FocusNode _focusNode = FocusNode();
  final Controller ticTokController = Controller();

  @override
  void initState() {
    super.initState();

    widget.supabase = Supabase.instance.client;
    widget.tikTokController = Controller();

    _loadNewQuestions();
    Future.delayed(Duration.zero, () => _focusNode.requestFocus());
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _handleKey(RawKeyEvent event) {
    debug("_handleKey(){");

    if (event is RawKeyDownEvent) {
      LogicalKeyboardKey logicalKey = event.logicalKey;
      String keyLabel = logicalKey.keyLabel.toLowerCase();
      //
      // // Falls keyLabel leer ist, verwende debugName als Fallback
      // if (keyLabel.isEmpty) {
      //   keyLabel = logicalKey.debugName?.toLowerCase() ?? "";
      // }
      //
      // debug("\tTaste gedrückt: $keyLabel");

      // Navigation mit Pfeiltasten
      if (logicalKey == LogicalKeyboardKey.arrowUp) {
        _arrowUpEvent();
      } else if (logicalKey == LogicalKeyboardKey.arrowDown) {
        _arrowDownEvent();
      }
      // Enter zum Locken
      else if (logicalKey == LogicalKeyboardKey.enter) {
      }
      // Auswahl einer Antwort per Buchstaben
      else if (RegExp(r'^[a-z]$', caseSensitive: false).hasMatch(keyLabel)) {
        // if (keyMap.containsKey(logicalKey.keyId)) {
        //   int selectedIndex = keyMap[logicalKey.keyId]!;
        //   if (selectedIndex < currentQuestion.questionSelections.length) {
        //     currentQuestion.selectQuestion(selectedIndex);
        //   }
        // }
      }
    }

    debug("}");
  }

  void _arrowDownEvent() {
    if (currentIndex == widget.questions.length - 2) {
      print("🟣 'Down' gedrückt, lade neue Frage...");
      _bufferQuestion();
    }
    setState(() {
      currentIndex++;
      print("🟣 'Down' gedrückt, neuer currentIndex: $currentIndex");
    });
    widget.tikTokController.animateToPosition(currentIndex);
  }

  void _arrowUpEvent() {
    if (currentIndex == 0) {
      return;
    }
    setState(() {
      currentIndex--;
      print("🟣 'Up' gedrückt, neuer currentIndex: $currentIndex");
    });
    widget.tikTokController.animateToPosition(currentIndex);
  }

  void _lockEvent(){
    widget.questions[currentIndex].questionVM.lock();
  }

  int? lastPopupIndex; // 🛑 Speichert den letzten gezeigten Index

  // void checkAndShowPopup(BuildContext context, int index, QuizVM vm) {
  //   if (index % 10 == 0 && index != 0 && !vm.question_history[index].isLocked) {
  //     if (lastPopupIndex != index) { // 🔥 Nur anzeigen, wenn noch nicht passiert
  //       lastPopupIndex = index;
  //       Future.delayed(Duration.zero, () => showFullscreenPopup(context));
  //     }
  //   }
  // }

  int currentIndex = 0;
  bool isLoading = true;

  Future<void> _loadNewQuestions() async {
    await _bufferQuestion();
    await _bufferQuestion();
    await _bufferQuestion();
    setState(() {
      isLoading = false;
      print("🟡 Fragen geladen, Anzahl: ${widget.questions.length}");
    });
  }

  Future<void> _bufferQuestion() async {
    final response =
        await Supabase.instance.client.rpc('get_random_question').maybeSingle();

    if (response != null) {
      setState(() {
        widget.questions.add(
          QuestionWidget(
            questionVM: QuestionVM(question: Question.fromSupaBase(response)),
          ),
        );
        print(
          "🟢 Neue Frage hinzugefügt: ${widget.questions.last.questionVM.question.text}",
        );
      });
    } else {
      print("⚠️ Keine Frage gefunden!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : RawKeyboardListener(
                onKey: _handleKey,
                focusNode: _focusNode..requestFocus(),
                autofocus: true,
                child: TikTokStyleFullPageScroller(
                  contentSize: widget.questions.length,
                  swipePositionThreshold: 0.2,
                  swipeVelocityThreshold: 2000,
                  animationDuration: const Duration(milliseconds: 300),
                  controller: widget.tikTokController,
                  builder: (BuildContext context, int index) {
                    print(
                      "🔵 Builder aufgerufen für Index: $index, aktueller currentIndex: $currentIndex",
                    );
                    return MyBackGround(
                      content: Column(
                        children: [
                          widget.questions[currentIndex],
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () => _arrowUpEvent(),
                                    child: Center(
                                      child: Icon(Icons.arrow_drop_up),
                                    ),
                                  ),
                                ),
                                ChangeNotifierProvider.value(
                                  value:
                                      widget.questions[currentIndex].questionVM,
                                  child: Consumer<QuestionVM>(
                                    builder: (context, vm, child) {
                                      return Visibility(
                                        visible: !vm.isLocked,
                                        child: Expanded(
                                          child: InkWell(
                                            onTap: () => _lockEvent(),
                                            child: Center(
                                              child: Icon(Icons.lock),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                Expanded(
                                  child: InkWell(
                                    child: Center(child: Icon(Icons.arrow_drop_down)),
                                    onTap: () => _arrowDownEvent(),                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
    );
  }
}

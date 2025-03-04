import 'package:flutter/material.dart';
import 'package:neon_thors_cores/quiz_screen/question_vm.dart';
import 'package:neon_thors_cores/quiz_screen/question_widget.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tiktoklikescroller/tiktoklikescroller.dart';
import 'db_question.dart';
import 'package:tiktoklikescroller/controller.dart';

class Swiper extends StatefulWidget {
  late final SupabaseClient supabase;
  late Controller tikTokController;
  List<QuestionWidget> questions = [];

  Swiper({Key? key}) : super(key: key);

  @override
  State<Swiper> createState() => _SwiperState();
}

class _SwiperState extends State<Swiper> {
  int currentIndex = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    widget.supabase = Supabase.instance.client;
    widget.tikTokController = Controller();

    _loadNewQuestions();
  }

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
              : TikTokStyleFullPageScroller(
                contentSize: widget.questions.length,
                swipePositionThreshold: 0.2,
                swipeVelocityThreshold: 2000,
                animationDuration: const Duration(milliseconds: 300),
                controller: widget.tikTokController,
                builder: (BuildContext context, int index) {
                  print(
                    "🔵 Builder aufgerufen für Index: $index, aktueller currentIndex: $currentIndex",
                  );
                  return Stack(
                    children: [
                      widget.questions[currentIndex],
                      Positioned(
                        bottom: 30,
                        left: 0,
                        right: 0,
                        child: Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                child: Text("up", key: Key('btn_animateUp')),
                                onPressed: () {
                                  if (currentIndex == 0) {
                                    print(
                                      "🟣 'Up' gedrückt, aber bereits bei Index 0",
                                    );
                                    return;
                                  }
                                  setState(() {
                                    currentIndex--;
                                    print(
                                      "🟣 'Up' gedrückt, neuer currentIndex: $currentIndex",
                                    );
                                  });
                                  widget.tikTokController.animateToPosition(
                                    currentIndex,
                                  );
                                },
                              ),
                            ),
                            ChangeNotifierProvider.value(
                              value: widget.questions[currentIndex].questionVM,
                              child: Consumer<QuestionVM>(
                                  builder: (context, vm, child) {
                                    return Visibility(
                                    visible: ! vm.isLocked,
                                    child: Expanded(
                                      child: TextButton(
                                      child: Text("lock", key: Key('btn_lock()')),
                                      onPressed: () => vm.lock(),
                                                                                ),
                                    ),
                                  );
                                }
                              ),
                            ),
                            Expanded(
                              child: TextButton(
                                child: Text(
                                  "down",
                                  key: Key('btn_animateDown'),
                                ),
                                onPressed: () async {
                                  if (currentIndex ==
                                      widget.questions.length - 2) {
                                    print(
                                      "🟣 'Down' gedrückt, lade neue Frage...",
                                    );
                                    await _bufferQuestion();
                                  }
                                  setState(() {
                                    currentIndex++;
                                    print(
                                      "🟣 'Down' gedrückt, neuer currentIndex: $currentIndex",
                                    );
                                  });
                                  widget.tikTokController.animateToPosition(
                                    currentIndex,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
    );
  }
}

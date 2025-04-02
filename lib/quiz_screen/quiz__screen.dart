import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:neon_thors_cores/quiz_screen/question_vm.dart';
import 'package:neon_thors_cores/quiz_screen/question_widget.dart';
import 'package:neon_thors_cores/quiz_screen/tenth_q_screen.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../_gloabals/debug_prints.dart';
import '../_gloabals/key_map.dart';
import '../_gloabals/widgets/my_background.dart';
import '../_gloabals/widgets/theme_toggler.dart';
import 'db_question.dart';

void debug(String text) {
  if (false || DEBUG_EVERYTHING) printYellow("[QuizScreen] $text");
}

class QuizScreen extends StatefulWidget {
  final String selected_level_pk;
  late final SupabaseClient supabase;
  List<QuestionWidget> history = [];
  List<QuestionWidget> questions = [];

  QuizScreen({super.key, required this.selected_level_pk});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final FocusNode _focusNode = FocusNode();
  final PageController _pageController = PageController();
  int currentIndex = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _load10Questions(widget.selected_level_pk);
    widget.supabase = Supabase.instance.client;
    Future.delayed(Duration.zero, () => _focusNode.requestFocus());
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _handleKey(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      LogicalKeyboardKey logicalKey = event.logicalKey;

      if (logicalKey == LogicalKeyboardKey.arrowUp) {
        _scrollUp();
      } else if (logicalKey == LogicalKeyboardKey.arrowDown) {
        _scrollDown();
      } else if (logicalKey == LogicalKeyboardKey.enter) {
        _lockEvent();
      } else if (RegExp(
        r'^[a-z]$',
        caseSensitive: false,
      ).hasMatch(logicalKey.keyLabel.toLowerCase())) {
        if (keyMap.containsKey(logicalKey.keyId)) {
          int selectedIndex = keyMap[logicalKey.keyId]!;
          widget.history[currentIndex].questionVM.selectQuestion(selectedIndex);
        }
      }
    }
  }

  void _scrollUp() {
    // Nur weiterscrollen, wenn die aktuelle Frage locked ist
    if (widget.history[currentIndex].questionVM.isLocked) {
      if (currentIndex < widget.history.length - 1) {
        setState(() {
          currentIndex++;
          _pageController.animateToPage(
            currentIndex,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        });
      } else if (widget.history.length < 10 && widget.questions.isNotEmpty) {
        setState(() {
          widget.history.add(widget.questions.removeAt(0));
          currentIndex++;
          _pageController.animateToPage(
            currentIndex,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        });
      } else if (currentIndex == 9){
        // todo navigiere zu ArchievmentScreen()
        // Navigiere zu AchievementScreen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => ArchivemendScreen(selected_level_pk: widget.selected_level_pk)),
        );
      }
    }
  }

  void _scrollDown() {
    // Zurückscrollen immer möglich, solange currentIndex > 0
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
        _pageController.animateToPage(
          currentIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  void _lockEvent() {
    widget.history[currentIndex].questionVM.lock();
  }

  // Future<void> _load10Questions() async {
  //   List<QuestionWidget> list = [];
  //   while (list.length < 10) {
  //     final response =
  //         await Supabase.instance.client
  //             .rpc('get_random_question')
  //             .maybeSingle();
  //     if (response != null) {
  //       list.add(
  //         QuestionWidget(
  //           questionVM: QuestionVM(question: Question.fromSupaBase(response)),
  //         ),
  //       );
  //     }
  //   }

    // Future<void> _load10Questions(String levelPk) async {
    //   List<QuestionWidget> list = [];
    //   while (list.length < 10) {
    //     final response = await Supabase.instance.client
    //         .rpc('get_random_question', params: {
    //       'level_id': levelPk,          // Level-PK als Parameter
    //       'excluded_question_pks': widget.history,  // todo hier soll der histopry alle ids entnommen werden
    //     })
    //         .maybeSingle();
    //     if (response != null) {
    //       list.add(
    //         QuestionWidget(
    //           questionVM: QuestionVM(question: Question.fromSupaBase(response)),
    //         ),
    //       );
    //     }
    //   }
    // }

  Future<void> _load10Questions(String levelPk) async {
    List<QuestionWidget> list = [];
    while (list.length < 10) {
      List<String> excludedPks = widget.history
          .map((qw) => qw.questionVM.question.question_pk)
          .toList();
      final response = await Supabase.instance.client.rpc(
        'get_random_question',
        params: {
          'level_id': levelPk,
          'excluded_question_pks': excludedPks,
        },
      ).maybeSingle();
      if (response != null) {
        list.add(
          QuestionWidget(
            questionVM: QuestionVM(question: Question.fromSupaBase(response)),
          ),
        );
      }
    }
    setState(() {
      widget.questions = list;
      widget.history.add(
        widget.questions.removeAt(Random().nextInt(widget.questions.length)),
      );
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: const ThemeToggler()),
      body: Stack(
        children: [
          // Statischer Hintergrund
          MyBackGround(
            key: BG_KEY,
          ),
          // Scrollender Inhalt
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : RawKeyboardListener(
                onKey: _handleKey,
                focusNode: _focusNode..requestFocus(),
                autofocus: true,
                child: GestureDetector(
                  onVerticalDragEnd: (details) {
                    if (details.primaryVelocity! > 0) {
                      _scrollDown(); // Nach unten swipen (zurück)
                    } else if (details.primaryVelocity! < 0 &&
                        widget.history[currentIndex].questionVM.isLocked) {
                      _scrollUp(); // Nach oben swipen (weiter), nur wenn locked
                    }
                  },
                  child: PageView.builder(
                    controller: _pageController,
                    scrollDirection: Axis.vertical,
                    itemCount: widget.history.length,
                    physics: const PageScrollPhysics(),
                    // Snap-Effekt
                    onPageChanged: (index) {
                      setState(() {
                        currentIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          // Obere Widget soll sich ausdehnen, aber scrollbar werden, wenn nötig
                          Flexible(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: 0,
                                maxHeight:
                                    MediaQuery.of(context).size.height *
                                    0.7, // Max 70% der Bildschirmhöhe
                              ),
                              child: Scrollbar(
                                child: SingleChildScrollView(
                                  child: widget.history[index],
                                ),
                              ),
                            ),
                          ),
                          // Untere Row bleibt erreichbar
                          SizedBox(
                            height: 60, // Feste Höhe für die Buttons, anpassbar
                            child: Row(
                              children: [
                                Expanded(
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: _scrollDown,
                                      hoverColor: Colors.grey.withOpacity(0.1),
                                      highlightColor: Colors.grey.withOpacity(
                                        0.1,
                                      ),
                                      splashColor: Colors.grey.withOpacity(0.1),
                                      child: const Center(
                                        child: Icon(Icons.arrow_drop_down),
                                      ),
                                    ),
                                  ),
                                ),
                                ChangeNotifierProvider.value(
                                  value: widget.history[index].questionVM,
                                  child: Consumer<QuestionVM>(
                                    builder: (context, vm, child) {
                                      return Visibility(
                                        visible: !vm.isLocked,
                                        child: Expanded(
                                          child: Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              onTap: _lockEvent,
                                              hoverColor: Colors.grey
                                                  .withOpacity(0.1),
                                              highlightColor: Colors.grey
                                                  .withOpacity(0.1),
                                              splashColor: Colors.grey
                                                  .withOpacity(0.1),
                                              child: const Center(
                                                child: Icon(Icons.lock),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                Expanded(
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: _scrollUp,
                                      hoverColor: Colors.grey.withOpacity(0.1),
                                      highlightColor: Colors.grey.withOpacity(
                                        0.1,
                                      ),
                                      splashColor: Colors.grey.withOpacity(0.1),
                                      child: const Center(
                                        child: Icon(Icons.arrow_drop_up),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );

                      //   Column(
                      //   children: [
                      //     Expanded(child: widget.history[index]),
                      //     Expanded(
                      //       child: Row(
                      //         children: [
                      //           Expanded(
                      //             child: Material(
                      //               color: Colors.transparent,
                      //               child: InkWell(
                      //                 onTap: _scrollDown,
                      //                 hoverColor: Colors.grey.withOpacity(0.1),
                      //                 highlightColor: Colors.grey.withOpacity(0.1),
                      //                 splashColor: Colors.grey.withOpacity(0.1),
                      //                 child: const Center(
                      //                   child: Icon(Icons.arrow_drop_down),
                      //                 ),
                      //               ),
                      //             ),
                      //           ),
                      //           ChangeNotifierProvider.value(
                      //             value: widget.history[index].questionVM,
                      //             child: Consumer<QuestionVM>(
                      //               builder: (context, vm, child) {
                      //                 return Visibility(
                      //                   visible: !vm.isLocked,
                      //                   child: Expanded(
                      //                     child: Material(
                      //                       color: Colors.transparent,
                      //                       child: InkWell(
                      //                         onTap: _lockEvent,
                      //                         hoverColor: Colors.grey.withOpacity(0.1),
                      //                         highlightColor: Colors.grey.withOpacity(0.1),
                      //                         splashColor: Colors.grey.withOpacity(0.1),
                      //                         child: const Center(
                      //                           child: Icon(Icons.lock),
                      //                         ),
                      //                       ),
                      //                     ),
                      //                   ),
                      //                 );
                      //               },
                      //             ),
                      //           ),
                      //           Expanded(
                      //             child: Material(
                      //               color: Colors.transparent,
                      //               child: InkWell(
                      //                 onTap: _scrollUp,
                      //                 hoverColor: Colors.grey.withOpacity(0.1),
                      //                 highlightColor: Colors.grey.withOpacity(0.1),
                      //                 splashColor: Colors.grey.withOpacity(0.1),
                      //                 child: const Center(
                      //                   child: Icon(Icons.arrow_drop_up),
                      //                 ),
                      //               ),
                      //             ),
                      //           ),
                      //         ],
                      //       ),
                      //     ),
                      //   ],
                      // );
                    },
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

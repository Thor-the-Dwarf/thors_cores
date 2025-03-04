import 'package:flutter/material.dart';
import 'package:neon_thors_cores/quiz_screen/question_vm.dart';
import 'package:provider/provider.dart';

class QuestionWidget extends StatelessWidget {
  final QuestionVM questionVM;

  const QuestionWidget({super.key, required this.questionVM});

  @override
  Widget build(BuildContext context) {
    return

      Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        Text(questionVM.question.text),
        const SizedBox(height: 20),
        SingleChildScrollView(
          child: Column(
            children: [
              Column(
                children: List.generate(
                  questionVM.questionSelections.length,
                      (index) =>
                          Padding(
                    padding: const EdgeInsets.all(8),
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white.withOpacity(0.2)
                              : Colors.black.withOpacity(0.2),
                              width: 1),
                        boxShadow: [
                          if (questionVM.isLocked)
                            BoxShadow(
                              color: questionVM.question.options[index].correct == true
                                  ? (questionVM.questionSelections[index] ? Colors.green : Colors.yellow)
                                  : questionVM.question.options[index].correct == false
                                  ? (questionVM.questionSelections[index] ? Colors.red : Colors.transparent)
                                  : (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          if (!questionVM.isLocked && questionVM.questionSelections[index])
                            const BoxShadow(
                              color: Colors.blue,
                              blurRadius: 8,
                              spreadRadius: 2,
                              offset: Offset(0, 2),
                            ),
                        ],
                        borderRadius: BorderRadius.circular(
                          questionVM.question.options.where((opt) => opt.correct).length > 1 ? 0 : 1000,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          questionVM.question.options.where((opt) => opt.correct).length > 1 ? 0 : 1000,
                        ),
                        child: TextButton(
                          onPressed: () {
                            questionVM.selectQuestion(index);
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            backgroundColor: Theme.of(context).brightness == Brightness.dark
                                ? Colors.black.withOpacity(questionVM.isLocked || questionVM.questionSelections[index] ? 1.0 : 0.2)
                                : Colors.white.withOpacity(questionVM.isLocked || questionVM.questionSelections[index] ? 1.0 : 0.2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                questionVM.question.options.where((opt) => opt.correct).length > 1 ? 0 : 1000,
                              ),
                            ),
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("${String.fromCharCode(97 + index)}) ${questionVM.question.options[index].text}"),
                                if (questionVM.shouldShowReason(index))
                                  Padding(
                                    padding: const EdgeInsets.only(top: 5),
                                    child: Text(
                                      questionVM.question.options[index].because,
                                      style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 36),
              // Row(
              //   children: [
              //     Spacer(),
              //     IconButton(onPressed: ()=> onArrowDown(), icon: const Icon(Icons.arrow_circle_down_sharp)),
              //     const SizedBox(width: 64),
              //     Expanded(
              //       child: Visibility(
              //         visible: !questionVM.isLocked,
              //         child: ElevatedButton(
              //           onPressed: () {
              //             questionVM.lock();
              //           },
              //           child: const Text("lock"),
              //         ),
              //       ),
              //     ),
              //     const SizedBox(width: 64),
              //     IconButton(onPressed: ()=> onArrowUp(), icon: const Icon(Icons.arrow_circle_up_sharp)),
              //     Spacer(),
              //   ],
              // ),
            ],
          ),
        ),
      ],
          );
  }
}

import 'package:flutter/material.dart';
import 'package:neon_thors_cores/quiz_screen/question_vm.dart';
import 'package:provider/provider.dart';

class QuestionWidget extends StatelessWidget {
  final QuestionVM questionVM;

  const QuestionWidget({super.key, required this.questionVM});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        Text(questionVM.question.text),
        const SizedBox(height: 20),
        SingleChildScrollView(
          child: Column(
            children: [
              ChangeNotifierProvider.value(
                value: questionVM,
                child: Column(
                  children: List.generate(
                    questionVM.questionSelections.length,
                    (index) => Padding(
                      padding: const EdgeInsets.all(8),
                      child: Consumer<QuestionVM>(
                        builder: (context, vm, child) {
                          return Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color:
                                    Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white.withOpacity(0.2)
                                        : Colors.black.withOpacity(0.2),
                                width: 1,
                              ),
                              boxShadow: [
                                if (vm.isLocked)
                                  BoxShadow(
                                    color:
                                        vm.question.options[index].correct ==
                                                true
                                            ? (vm.questionSelections[index]
                                                ? Colors.green
                                                : Colors.yellow)
                                            : vm
                                                    .question
                                                    .options[index]
                                                    .correct ==
                                                false
                                            ? (vm.questionSelections[index]
                                                ? Colors.red
                                                : Colors.transparent)
                                            : (Theme.of(context).brightness ==
                                                    Brightness.dark
                                                ? Colors.white
                                                : Colors.black),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                if (!vm.isLocked &&
                                    vm.questionSelections[index])
                                  const BoxShadow(
                                    color: Colors.blue,
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                    offset: Offset(0, 2),
                                  ),
                              ],
                              borderRadius: BorderRadius.circular(
                                vm.question.options
                                            .where((opt) => opt.correct)
                                            .length >
                                        1
                                    ? 0
                                    : 1000,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                vm.question.options
                                            .where((opt) => opt.correct)
                                            .length >
                                        1
                                    ? 0
                                    : 1000,
                              ),
                              child: TextButton(
                                onPressed: () {
                                  vm.selectQuestion(index);
                                },
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 16,
                                  ),
                                  backgroundColor:
                                      Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.black.withOpacity(
                                            vm.isLocked ||
                                                    vm.questionSelections[index]
                                                ? 1.0
                                                : 0.2,
                                          )
                                          : Colors.white.withOpacity(
                                            vm.isLocked ||
                                                    vm.questionSelections[index]
                                                ? 1.0
                                                : 0.2,
                                          ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      vm.question.options
                                                  .where((opt) => opt.correct)
                                                  .length >
                                              1
                                          ? 0
                                          : 1000,
                                    ),
                                  ),
                                ),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${String.fromCharCode(97 + index)}) ${vm.question.options[index].text}",
                                      ),
                                      if (vm.isLocked)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 5,
                                          ),
                                          child: Text(
                                            vm.question.options[index].because,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
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
              //         visible: !vm.isLocked,
              //         child: ElevatedButton(
              //           onPressed: () {
              //             vm.lock();
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

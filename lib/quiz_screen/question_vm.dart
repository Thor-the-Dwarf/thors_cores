import 'package:flutter/material.dart';

import '../_gloabals/debug_prints.dart';
import 'db_question.dart';

class QuestionVM with ChangeNotifier {
  void debug(String text) {
    if (false || DEBUG_EVERYTHING) printCyan("[QuestionViewModel] ${question.text} $text");
  }

  Question question;
  List<bool> _questionSelections = [];
  bool _isLocked = false;

  List<bool> get questionSelections => _questionSelections;
  bool get isLocked => _isLocked;

  QuestionVM({required this.question}) {
    debug("QuizQuestion(){");
    _questionSelections = List.generate(question.options.length, (index) => false);
    debug("\tInitialisierte Selections: $_questionSelections");
    debug("}");
  }

  void selectQuestion(int index) {
    debug("selectQuestion($index){");

    if (_isLocked) {
    } else {
      final newSelections = List<bool>.from(questionSelections);
      debug("\tnewSelections = $newSelections");

      if (question.options.where((opt) => opt.correct).length > 1 ){
        newSelections.fillRange(0, newSelections.length, false); // ✅ Korrekt alle abwählen
        debug("\tAlle Optionen wurden abgewählt!");
      }

      newSelections[index] = !newSelections[index]; // Wert toggeln
      debug("\tnewSelections[index] = ${newSelections[index]}");

      _questionSelections = newSelections;
      debug("\t_questionSelections = ${_questionSelections}");
    }

    notifyListeners();
    debug("\t_notifyListeners aufgerufen");
    debug("}");
  }


  void lock() {
    if(!questionSelections.contains(true)) return;
    _isLocked = true;
    notifyListeners();
    debug("lock(){");
  }

  QuestionVM clone() {
    debug("clone(){");
    final clone = QuestionVM(
      question: this.question,
    ).._questionSelections = List.from(this._questionSelections);
    debug("\tErstellter Clone: $clone");
    debug("}");
    return clone;
  }
}

import 'package:flutter/material.dart';
import '../_gloabals/debug_prints.dart';
import 'db_question.dart';

class QuestionVM with ChangeNotifier {
  void debug(String text) {
    if (false || DEBUG_EVERYTHING)
      printCyan("[QuestionViewModel] ${question.text} $text");
  }

  Question question;
  List<bool> _questionSelections = [];
  bool _isLocked = false;

  List<bool> get questionSelections => _questionSelections;

  bool get isLocked => _isLocked;

  QuestionVM({required this.question}) {
    debug("QuizQuestion(){");
    _questionSelections = List.generate(
      question.options.length,
      (index) => false,
    );
    debug("\tInitialisierte Selections: $_questionSelections");
    debug("}");
  }

  void selectQuestion(int index) {
    debug("selectQuestion($index){");

    if (_isLocked || index > questionSelections.length - 1) {
      debug("\tFrage ist gesperrt, keine Änderung möglich");
      return;
    }

    final newSelections = List<bool>.from(questionSelections);
    debug("\tnewSelections = $newSelections");

    // Prüfen, ob es eine SingleChoice- oder MultipleChoice-Frage ist
    bool isSingleChoice =
        question.options.where((opt) => opt.correct).length == 1;

    if (isSingleChoice) {
      // RadioButton-Verhalten: Nur eine Option kann ausgewählt sein
      newSelections.fillRange(0, newSelections.length, false); // Alle abwählen
      newSelections[index] = true; // Nur die geklickte Option auswählen
      debug("\tSingleChoice erkannt: Nur Option $index ausgewählt");
    } else {
      // Checkbox-Verhalten: Mehrere Optionen können ausgewählt bleiben
      newSelections[index] = !newSelections[index]; // Wert toggeln
      debug("\tMultipleChoice erkannt: Option $index getoggelt");
    }

    _questionSelections = newSelections;
    debug("\t_questionSelections = ${_questionSelections}");
    notifyListeners();
    debug("\t_notifyListeners aufgerufen");
    debug("}");
  }

  void lock() {
    if (!questionSelections.contains(true)) return;
    _isLocked = true;
    notifyListeners();
    debug("lock(){");
  }

  QuestionVM clone() {
    debug("clone(){");
    final clone = QuestionVM(question: this.question)
      .._questionSelections = List.from(this._questionSelections);
    debug("\tErstellter Clone: $clone");
    debug("}");
    return clone;
  }
}

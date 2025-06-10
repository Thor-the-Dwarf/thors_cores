import 'package:flutter/material.dart';
import 'package:neon_thors_cores/level_screen/player/local_storage_player.dart';
import '../_globals/debug_prints.dart';
import 'db_question.dart';

class QuestionVM with ChangeNotifier {
  void DEBUG(String text) {
    if (false || DEBUG_EVERYTHING)
      printCyan("[QuestionViewModel] ${question.text} $text");
  }

  Question question;
  List<bool> _questionSelections = [];
  bool _isLocked = false;

  List<bool> get questionSelections => _questionSelections;

  bool get isLocked => _isLocked;

  QuestionVM({required this.question}) {
    DEBUG("QuizQuestion(){");
    _questionSelections = List.generate(
      question.options.length,
      (index) => false,
    );
    DEBUG("\tInitialisierte Selections: $_questionSelections");
    DEBUG("}");
  }

  void selectQuestion(int index) {
    DEBUG("selectQuestion($index){");

    if (_isLocked || index > questionSelections.length - 1) {
      DEBUG("\tFrage ist gesperrt, keine Änderung möglich");
      return;
    }

    final newSelections = List<bool>.from(questionSelections);
    DEBUG("\tnewSelections = $newSelections");

    // Prüfen, ob es eine SingleChoice- oder MultipleChoice-Frage ist
    bool isSingleChoice =
        question.options.where((opt) => opt.correct).length == 1;

    if (isSingleChoice) {
      // RadioButton-Verhalten: Nur eine Option kann ausgewählt sein
      newSelections.fillRange(0, newSelections.length, false); // Alle abwählen
      newSelections[index] = true; // Nur die geklickte Option auswählen
      DEBUG("\tSingleChoice erkannt: Nur Option $index ausgewählt");
    } else {
      // Checkbox-Verhalten: Mehrere Optionen können ausgewählt bleiben
      newSelections[index] = !newSelections[index]; // Wert toggeln
      DEBUG("\tMultipleChoice erkannt: Option $index getoggelt");
    }

    _questionSelections = newSelections;
    DEBUG("\t_questionSelections = ${_questionSelections}");
    notifyListeners();
    DEBUG("\t_notifyListeners aufgerufen");
    DEBUG("}");
  }

  void lock() {
    if (!questionSelections.contains(true)) return;
    _isLocked = true;
    notifyListeners();
    DEBUG("lock(){");
  }

  QuestionVM clone() {
    DEBUG("clone(){");
    final clone = QuestionVM(question: this.question)
      .._questionSelections = List.from(this._questionSelections);
    DEBUG("\tErstellter Clone: $clone");
    DEBUG("}");
    return clone;
  }
}

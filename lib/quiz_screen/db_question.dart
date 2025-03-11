import 'dart:math';

class Question {
  final String question_pk; // Neu: Entspricht der Supabase-ID (question_pk)
  final String text;
  final int points;
  final List<Option> options;

  Question({
    required this.question_pk, // Neu hinzugefügt
    required this.text,
    required this.points,
    required this.options,
  });

  /// 🔹 Konvertiert Supabase-Daten in eine Question-Instanz und mischt die Optionen
  factory Question.fromSupaBase(Map<String, dynamic> data) {
    // Erstelle die Liste der Optionen aus den Supabase-Daten
    List<Option> options = (data['options'] as List<dynamic>)
        .map((opt) => Option.fromJson(opt))
        .toList();

    // Mische die Optionen direkt nach der Erstellung
    options.shuffle(Random());

    return Question(
      question_pk: data['question_pk']?.toString() ?? 'unknown',
      text: data['question_text'] ?? 'Keine Frage gefunden',
      points: data['points'] ?? 0,
      options: options,
    );
  }
}

/// 🔹 `Option` Datenklasse für JSON-Parsing in `options`
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
import 'dart:convert';

class Question {
  final String text;
  final int points;
  final List<Option> options;

  Question({
    required this.text,
    required this.points,
    required this.options,
  });

  /// 🔹 Konvertiert Supabase-Daten in eine Question-Instanz
  factory Question.fromSupaBase(Map<String, dynamic> data) {
    return Question(
      text: data['text'] ?? 'Keine Frage gefunden',
      points: data['points'] ?? 0, // Hier war vorher `punkte`
      options: (data['options'] as List<dynamic>)
          .map((opt) => Option.fromJson(opt))
          .toList(),
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
    return {
      'text': text,
      'because': because,
      'correct': correct,
    };
  }
}

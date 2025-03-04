import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tiktoklikescroller/tiktoklikescroller.dart';
import 'db_question.dart';

class HomeWidget extends StatefulWidget {
  const HomeWidget({Key? key}) : super(key: key);

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  late Controller controller = Controller()
  ..addListener(_handleCallbackEvent);
  final SupabaseClient supabase = Supabase.instance.client;
  List<Question> questions = [];

  @override
  void initState() {
    super.initState();
    _loadInitialQuestions();
  }

  /// 🔹 Lädt 3 Fragen beim Start
  Future<void> _loadInitialQuestions() async {
    final data = await supabase
        .from('question')
        .select()
        .limit(3);

    setState(() {
      questions = data.map((q) => Question.fromSupaBase(q)).toList();
    });
  }

  /// 🔹 Lädt eine neue Frage & fügt sie zur Liste hinzu
  Future<void> _loadNewQuestion() async {
    final data = await supabase
        .from('question')
        .select()
        .limit(1)
        .single();

    setState(() {
      questions.add(Question.fromSupaBase(data)); // Vorne einfügen
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: questions.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : TikTokStyleFullPageScroller(
        contentSize: questions.length,
        swipePositionThreshold: 0.2,
        swipeVelocityThreshold: 2000,
        animationDuration: const Duration(milliseconds: 400),
        controller: controller,
        builder: (BuildContext context, int index) {
          if (index == 0) { // Sobald am Anfang, neue Frage laden
            _loadNewQuestion();
            Future.delayed(const Duration(milliseconds: 50), () {
              controller.animateToPosition(1); // Springt auf die nächste Frage
            });
          }

          return Container(
            padding: const EdgeInsets.all(16),
            color: Colors.black,
            child: Center(
              child: Text(
                questions[index].text,
                style: const TextStyle(fontSize: 24, color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleCallbackEvent(ScrollEvent event) {
    if (event.direction == ScrollDirection.FORWARD) {
      _loadNewQuestion(); // Neue Frage nur bei Swipe nach vorne
    }
  }
}

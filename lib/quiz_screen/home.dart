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
  late Controller controller;
  final SupabaseClient supabase = Supabase.instance.client;

  List<Question> questions = [];

  @override
  void initState() {
    super.initState();
    controller = Controller()..addListener(_handleCallbackEvent);
    _loadInitialQuestions();
  }

  /// 🔹 Lädt 3 zufällige Fragen beim Start
  Future<void> _loadInitialQuestions() async {
    final data = await supabase
        .from('question')
        .select()
        .order('question_pk') // RANDOM() nicht in Supabase nutzbar
        .limit(3);

    setState(() {
      questions = data.map((q) => Question.fromSupaBase(q)).toList();
    });
  }


  /// 🔹 Lädt eine neue zufällige Frage & fügt sie zur Liste hinzu
  Future<void> _loadNewQuestion() async {
    final data = await supabase
        .from('question')
        .select()
        .limit(1)
        .single();

    setState(() {
      questions.add(Question.fromSupaBase(data));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: questions.isEmpty
          ? const Center(child: CircularProgressIndicator()) // Ladeanzeige
          : TikTokStyleFullPageScroller(
        contentSize: questions.length,
        swipePositionThreshold: 0.2,
        swipeVelocityThreshold: 2000,
        animationDuration: const Duration(milliseconds: 400),
        controller: controller,
        builder: (BuildContext context, int index) {
          if (index == questions.length - 2) _loadNewQuestion(); // Dynamisches Laden

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
    print("ScrollEvent: {direction: ${event.direction}, page: ${event.pageNo}}");
  }
}

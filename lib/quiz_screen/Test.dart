import 'dart:math';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tiktoklikescroller/tiktoklikescroller.dart';

import 'db_question.dart';

Controller tikTokController = Controller();

class Swiper extends StatefulWidget {
  // Controller controller = Controller()..addListener(_handleCallbackEvent);



  late final SupabaseClient supabase;
  List<Question> questions = [];

  Swiper({Key? key}) : super(key: key);

  @override
  State<Swiper> createState() => _SwiperState();
}

class _SwiperState extends State<Swiper> {
  bool isLoading = true; // ✅ Ladezustand

  @override
  void initState() {
    super.initState();
    tikTokController = Controller()..addListener(_handleCallbackEvent);
    widget.supabase = Supabase.instance.client;
    _loadNewQuestions();
  }


  Future<void> _loadNewQuestions() async {
    // try {
    //   final data = await widget.supabase.from('question').select();
    //   setState(() {
    //     widget.questions = data.map((q) => Question.fromSupaBase(q)).toList();
    //     widget.questions.shuffle(Random());
    //     isLoading = false; // ✅ Ladezustand aktualisieren
    //   });
    // } catch (e) {
    //   print("Fehler beim Laden der Fragen: $e");
    //   setState(() {
    //     isLoading = false; // Fehler trotzdem beenden
    //   });
    // }
    await getRandomQuestion();
    await getRandomQuestion();
    await getRandomQuestion();
    setState(() {
      isLoading = false; // 🔥 Ladezustand deaktivieren, wenn alle Fragen geladen sind
    });
  }

  Future<void> getRandomQuestion() async {
    final response = await Supabase.instance.client
        .rpc('get_random_question')
        .maybeSingle(); // Falls keine Zeile existiert, gibt es NULL zurück

    if (response != null) {
      setState(() {
        widget.questions.add(Question.fromSupaBase(response));
      });
    } else {
      print("⚠️ Keine Frage gefunden!");
    }
  }



  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // ✅ Anzeige während des Ladens
          : TikTokStyleFullPageScroller(
        contentSize: widget.questions.length,
        swipePositionThreshold: 0.2,
        swipeVelocityThreshold: 2000,
        animationDuration: const Duration(milliseconds: 300),
        controller: tikTokController,
        builder: (BuildContext context, int index) {
          return Stack(
            children: [
              Center(
                child: Text(
                  widget.questions[currentIndex].text,
                  key: Key('$index-text'),
                  style: const TextStyle(fontSize: 48, color: Colors.white),
                ),
              ),
              Positioned(
                bottom: 30,
                left: 0,
                right: 0,
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        child: Text(
                          "up",
                          key: Key('btn_animateUp'),
                        ),
                        onPressed: () {
                          setState(() {
                            currentIndex--;
                          });
                          tikTokController.animateToPosition(currentIndex);
                        },
                      ),
                    ),
                    Expanded(
                      child: TextButton(
                        child: Text(
                          "down",
                          key: Key('btn_animateDown'),
                        ),
                        onPressed: () async {
                          if(currentIndex == widget.questions.length-2)
                            await getRandomQuestion();
                          setState(() {
                            currentIndex++;
                          });
                          tikTokController.animateToPosition(currentIndex);
                        },
                      ),
                    ),
                  ]
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _handleCallbackEvent(ScrollEvent event) {
    print(
        "Scroll callback received with data: {direction: ${event.direction}, success: ${event.success} and page: ${event.pageNo ?? 'not given'}}");
    if (event.percentWhenReleased != null) {
      print("Percent when released: ${event.percentWhenReleased}");
    }
  }
}

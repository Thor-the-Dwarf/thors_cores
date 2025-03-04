import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tiktoklikescroller/tiktoklikescroller.dart';

import 'db_question.dart';

class Swiper extends StatefulWidget {

  late Controller controller;
  late final SupabaseClient supabase;
  List<Question> questions = [];


  Swiper({
    Key? key,
  }) : super(key: key);

  @override
  State<Swiper> createState() => _SwiperState();
}

class _SwiperState extends State<Swiper> {


  @override
  initState() {
    widget.controller = Controller()
      ..addListener((event) {
        _handleCallbackEvent(event);
      });
    widget.supabase = Supabase.instance.client;

    _loadNewQuestions();
    super.initState();
  }

  Future<void> _loadNewQuestions() async {
    final data = await widget.supabase.from('question').select();

    setState(() {
      widget.questions = data.map((q) => Question.fromSupaBase(q)).toList(); // Alle Fragen laden
    });
  }


  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TikTokStyleFullPageScroller(
        contentSize: widget.questions.length,
        swipePositionThreshold: 0.2,
        // ^ the fraction of the screen needed to scroll
        swipeVelocityThreshold: 2000,
        // ^ the velocity threshold for smaller scrolls
        animationDuration: const Duration(milliseconds: 400),
        // ^ how long the animation will take
        controller: widget.controller,
        // ^ registering our own function to listen to page changes
        builder: (BuildContext context, int index) {
          return Container(
            child: Stack(children: [
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
                child: Container(
                  padding: const EdgeInsets.only(top: 8, bottom: 8),
                  color: Colors.white.withAlpha(125),
                  child: Column(
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ...Iterable<int>.generate(widget.questions.length)
                                .toList()
                                .map(
                                  (newIndex) => MaterialButton(
                                color: Colors.white.withAlpha(125),
                                child: Text(
                                  newIndex.toString(),
                                  key: Key('$newIndex-animate'),
                                ),
                                onPressed: () {
                                  setState(() {
                                    currentIndex = newIndex;
                                  });
                                      widget.controller.animateToPosition(currentIndex);
                                }
                              ),
                            )
                                .toList(),
                          ]),
                    ],
                  ),
                ),
              ),
            ]),
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
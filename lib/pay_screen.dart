// pay_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:neon_thors_cores/_globals/widgets/theme_controller.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '_globals/widgets/my_background.dart';

class PayScreen extends StatelessWidget {
  const PayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 32, 40, 0),
      child: Stack(
        children: [
          const MyBackGround(),
          ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Stell dir eine Welt vor, in der man die App durchspielt, "
                  "zur IHK-Abschlussprüfung geht, besteht und dann mit dem "
                  "Zeugnis auf Praktikumssuche geht. Ich will das Land mit "
                  "Fachkräften bewerfen! Du bist nicht nur Alphatester. Du "
                  "entscheidest, in welche Richtung es weitergeht. Die App "
                  "ist noch klein, aber mit großem Potenzial! Hier kannst du "
                  "mit einem Klick nicht nur Danke sagen, sondern auch "
                  "entscheiden, welche Features als Nächstes kommen. Spende "
                  "für das Feature, das DICH begeistert, und hilf mit, dieses "
                  "Projekt zu etwas Großem zu machen.",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              const SizedBox(height: 36),
              CoolLoadingBar(
                progress: 25.12,
                head: "User-Fortschritte speichern",
                body:
                    "Dir wird für jeden einzelnen Core angezeigt, wie gut du "
                    "dich bisher geschlagen hast. 'Wiederholung ist die Mutter "
                    "des Lernens' – du verlierst jede Woche 1% deiner Fortschritte.",
                commingUp: [
                  ListTile(
                    title: const Text("Gute Frage!"),
                    subtitle: Text(
                      "Du wirst häufiger mit Fragen konfrontiert, die du bereits "
                      "falsch beantwortet hast. Doch du erkennst sie nicht wieder, "
                      "denn sie wird in einer anderen Version gezeigt.",
                    ),
                  ),
                  ListTile(
                    title: const Text("Achievement-System"),
                    subtitle: Text(
                      "Durch das Beantworten von Fragen sammelst du Punkte. Mit "
                      "den Punkten kannst du weitere Features freischalten.",
                    ),
                  ),
                ],
              ),
              CoolLoadingBar(
                progress: 0,
                head: "Crowd-Intelligenz",
                body:
                    "Kommentar- und Bewertungsfunktion an jeder Frage für alle "
                    "User. Feedback wird umgesetzt. Qualität und Quantität der "
                    "Fragen werden besser für alle.",
                commingUp: [],
              ),
              CoolLoadingBar(
                progress: 0,
                head: "Release als App",
                body:
                    "Die App kommt in den App- und Playstore. Das hat mit "
                    "persönlichen Daten zu tun, daher wird jemand beauftragt, "
                    "der sich auskennt.",
                commingUp: [
                  ListTile(
                    title: const Text("Listen to me!"),
                    subtitle: Text(
                      "Fragen werden vorgelesen. Antworten kann man mit den "
                      "Lautstärke-Tasten.",
                    ),
                  ),
                ],
              ),
              CoolLoadingBar(
                progress: 0,
                head: "Quiz Fire",
                body:
                    "Tägliches Event: z. B. User haben 5 Minuten Zeit, so viele "
                    "Ja-oder-Nein-Fragen wie möglich zu beantworten.",
                commingUp: [],
              ),
              CoolLoadingBar(
                progress: 0,
                head: "Good Job! Thanks Thor",
                body: "Bezahlte Entwicklungszeit: 0 / 1238 Stunden",
                commingUp: [],
              ),
              const SizedBox(height: 16),
              const Text(
                "Noch erfolgt die Länge der Fortschrittsbalken nicht in Echtzeit. Ich mach das manuell.",
              ),
              const Text("Restgeld wird auf alle Unternehmensziele verteilt"),
            ],
          ),
        ],
      ),
    );
  }
}

class CoolLoadingBar extends StatefulWidget {
  final double progress;
  final String head;
  final String body;
  final List<Widget> commingUp;

  const CoolLoadingBar({
    super.key,
    required this.progress,
    required this.head,
    required this.body,
    required this.commingUp,
  });

  @override
  State<CoolLoadingBar> createState() => _CoolLoadingBarState();
}

class _CoolLoadingBarState extends State<CoolLoadingBar> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            if (mounted) {
                              setState(() => isExpanded = !isExpanded);
                            }
                          },
                          icon: Icon(
                            isExpanded ? Icons.expand_less : Icons.expand_more,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            widget.head,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      ],
                    ),
                    Visibility(
                      visible: isExpanded,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
                        child: Text(
                          widget.body,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                width:
                                    constraints.maxWidth *
                                    (widget.progress.clamp(0, 100) / 100),
                                height: 40,
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFF00FFCC),
                                      Color(0xFFFF007A),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Text(
                          '${widget.progress.clamp(0, 100).toStringAsFixed(2)}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Visibility(
                      visible: isExpanded && widget.commingUp.isNotEmpty,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 16.0,
                              top: 8.0,
                              bottom: 4.0,
                            ),
                            child: Text(
                              "Voraussetzung für:",
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 32.0),
                            child: Column(children: widget.commingUp),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () async {
                  const url = 'https://paypal.com/ncp/payment/UXHHNB4MWUGQS';
                  if (await canLaunch(url)) {
                    await launch(url);
                  } else {
                    throw 'Konnte PayPal nicht öffnen';
                  }
                },
                icon: const Icon(Icons.paypal),
                iconSize: 48,
              ),
              SizedBox(width: 80,)
            ],
          );
        },
      ),
    );
  }
}

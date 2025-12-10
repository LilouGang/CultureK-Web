// lib/ui/quiz_page/views/game_view.dart

import 'package:flutter/material.dart';
import '../widgets/answer_button.dart';
import '../widgets/explanation_panel.dart';

class GameView extends StatelessWidget {
  final Map<String, dynamic> questionData;
  final String diffLabel;
  final bool hasAnswered;
  final int? selectedAnswerIndex;
  final int? correctAnswerIndex;
  final Function(int, String, List<String>) onAnswer;
  final VoidCallback onNext;
  final VoidCallback onQuit;

  const GameView({
    super.key,
    required this.questionData,
    required this.diffLabel,
    required this.hasAnswered,
    this.selectedAnswerIndex,
    this.correctAnswerIndex,
    required this.onAnswer,
    required this.onNext,
    required this.onQuit,
  });

  @override
  Widget build(BuildContext context) {
    List<String> props = [];
    try { props = List<String>.from(questionData['propositions']); } catch(e) { props = ["Err"]; }

    // Extraction sécurisée des stats
    Map<String, dynamic> stats = {};
    if (questionData['answerStats'] != null && questionData['answerStats'] is Map) {
      stats = questionData['answerStats'];
    }
    
    int tAnswered = questionData['timesAnswered'] ?? 0;
    int tCorrect = questionData['timesCorrect'] ?? 0;
    String correctAns = questionData['reponse'] ?? "";

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // QUESTION GAUCHE
        Expanded(flex: 2, child: Column(
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              TextButton.icon(onPressed: onQuit, icon: const Icon(Icons.close), label: const Text("Quitter")),
              Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(20)), child: Text("Niveau $diffLabel", style: const TextStyle(fontWeight: FontWeight.bold))),
            ]),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 4))]),
              child: Text(questionData['question'] ?? "?", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, height: 1.3), textAlign: TextAlign.center),
            ),
            const SizedBox(height: 40),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 3.5, crossAxisSpacing: 20, mainAxisSpacing: 20),
                itemCount: props.length,
                itemBuilder: (ctx, idx) {
                  Color? bg = Colors.white; 
                  Color? txt = Colors.black87;
                  Color border = Colors.transparent;
                  
                  if (hasAnswered) {
                    if (idx == correctAnswerIndex) { bg = Colors.green.shade50; txt = Colors.green.shade800; border = Colors.green; }
                    else if (idx == selectedAnswerIndex) { bg = Colors.red.shade50; txt = Colors.red.shade800; border = Colors.red; }
                    else { bg = Colors.grey.shade50; txt = Colors.grey.shade400; }
                  }

                  return AnswerButton(
                    text: props[idx],
                    bgColor: bg, textColor: txt, borderColor: border,
                    onTap: hasAnswered ? null : () => onAnswer(idx, props[idx], props),
                  );
                },
              ),
            ),
          ],
        )),
        // EXPLICATION DROITE
        if (hasAnswered) Expanded(child: ExplanationPanel(
          isCorrect: selectedAnswerIndex == correctAnswerIndex,
          text: questionData['explication'],
          onNext: onNext,
          // NOUVEAUX PARAMÈTRES PASSÉS ICI :
          answerStats: stats,
          timesAnswered: tAnswered,
          timesCorrect: tCorrect,
          allPropositions: props,
          correctAnswer: correctAns,
        ))
      ],
    );
  }
}
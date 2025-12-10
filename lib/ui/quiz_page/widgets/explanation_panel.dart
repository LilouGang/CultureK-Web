import 'package:flutter/material.dart';

class ExplanationPanel extends StatelessWidget {
  final bool isCorrect;
  final String? text;
  final VoidCallback onNext;
  
  // NOUVEAU : On reçoit toutes les infos pour les stats
  final Map<String, dynamic> answerStats; // Map<String, int>
  final int timesAnswered;
  final int timesCorrect;
  final List<String> allPropositions;
  final String correctAnswer;

  const ExplanationPanel({
    super.key, 
    required this.isCorrect, 
    this.text, 
    required this.onNext,
    required this.answerStats,
    required this.timesAnswered,
    required this.timesCorrect,
    required this.allPropositions,
    required this.correctAnswer,
  });

  @override
  Widget build(BuildContext context) {
    // Calcul du taux de réussite global de la question
    final double globalSuccessRate = timesAnswered > 0 
        ? (timesCorrect / timesAnswered) 
        : 0.0;

    return Container(
      margin: const EdgeInsets.only(left: 30),
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(24), 
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header Résultat
          Row(children: [
            Icon(isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded, color: isCorrect ? Colors.green : Colors.red, size: 36),
            const SizedBox(width: 12),
            Text(isCorrect ? "Excellent !" : "Oups...", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isCorrect ? Colors.green : Colors.red)),
            const Spacer(),
            // Badge taux de réussite global
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
              child: Text("${(globalSuccessRate * 100).toInt()}% des joueurs ont réussi", style: TextStyle(color: Colors.blue.shade800, fontWeight: FontWeight.bold, fontSize: 12)),
            )
          ]),
          
          const Divider(height: 30),
          
          // 2. Stats Communautaires (Barres de progression)
          const Text("Ce que les autres ont répondu :", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 16),
          ...allPropositions.map((prop) {
            // Récupération sécurisée du nombre de votes
            int votes = 0;
            if (answerStats.containsKey(prop)) {
              votes = answerStats[prop] is int ? answerStats[prop] : int.tryParse(answerStats[prop].toString()) ?? 0;
            }
            
            // Calcul pourcentage
            double percent = timesAnswered > 0 ? (votes / timesAnswered) : 0.0;
            
            // Couleur de la barre : Vert pour la bonne réponse, Gris pour les autres
            bool isTheCorrectAnswer = prop == correctAnswer;
            Color barColor = isTheCorrectAnswer ? Colors.green : Colors.grey.shade300;
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Text(prop, style: TextStyle(fontSize: 13, color: Colors.grey.shade800, fontWeight: isTheCorrectAnswer ? FontWeight.bold : FontWeight.normal), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 6,
                    child: Stack(
                      children: [
                        // Fond gris clair
                        Container(height: 8, decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(4))),
                        // Barre de progression
                        FractionallySizedBox(
                          widthFactor: percent.clamp(0.0, 1.0), // Sécurité
                          child: Container(height: 8, decoration: BoxDecoration(color: barColor, borderRadius: BorderRadius.circular(4))),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 35,
                    child: Text("${(percent * 100).toInt()}%", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ),
                ],
              ),
            );
          }).toList(),

          const Divider(height: 30),

          // 3. Explication Texte
          const Text("Explication :", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Expanded(child: SingleChildScrollView(child: Text(text ?? "Pas d'explication disponible.", style: TextStyle(fontSize: 16, height: 1.5, color: Colors.grey[800])))),
          
          const SizedBox(height: 20),
          
          // 4. Bouton Suivant
          SizedBox(width: double.infinity, height: 56, child: ElevatedButton(onPressed: onNext, style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), child: const Text("Suivant", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))))
        ],
      ),
    );
  }
}
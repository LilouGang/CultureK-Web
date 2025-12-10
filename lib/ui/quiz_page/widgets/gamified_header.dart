// lib/ui/quiz_page/widgets/gamified_header.dart

import 'package:flutter/material.dart';
import '../../../data/data_manager.dart';

class GamifiedHeader extends StatelessWidget {
  final UserProfile user;
  const GamifiedHeader({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.blueAccent.shade700, Colors.blueAccent.shade400]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Row(
        children: [
          // Cercle de progression
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 80, height: 80,
                child: CircularProgressIndicator(
                  value: user.successRate,
                  strokeWidth: 8,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation(Colors.white),
                ),
              ),
              Text("${(user.successRate * 100).toInt()}%", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          const SizedBox(width: 24),
          // Textes d'encouragement
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Bon retour, ${user.username} !", style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text("Tu as répondu à ${user.totalAnswers} questions.", style: const TextStyle(color: Colors.white70)),
            ],
          ),
          const Spacer(),
          // Stats rapides
          _StatBadge(icon: Icons.check_circle, value: "${user.totalCorrectAnswers}", label: "Bonnes rép."),
          const SizedBox(width: 16),
          _StatBadge(icon: Icons.local_fire_department, value: "3", label: "Série (Mock)"),
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final IconData icon; final String value; final String label;
  const _StatBadge({required this.icon, required this.value, required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(12)),
      child: Row(children: [Icon(icon, color: Colors.white, size: 20), const SizedBox(width: 8), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10))])]),
    );
  }
}
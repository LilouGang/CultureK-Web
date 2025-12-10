import 'package:flutter/material.dart';
import '../../../data/data_manager.dart'; 

class ProfileHeader extends StatelessWidget {
  final UserProfile user;
  const ProfileHeader({super.key, required this.user});

  // Petite fonction pour formater la date sans package externe
  String _formatDate(DateTime? date) {
    if (date == null) return "Récemment";
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.blue.shade800, Colors.blue.shade500]),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.blue.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))]
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            child: Text(
              user.username.isNotEmpty ? user.username[0].toUpperCase() : '?',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue.shade800)
            ),
          ),
          const SizedBox(width: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user.username, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 4),
              Text(
                user.hasFakeEmail ? "Compte invité" : user.email,
                style: const TextStyle(fontSize: 16, color: Colors.white70)
              ),
              const SizedBox(height: 8),
              // NOUVEAU : Affichage de la date d'inscription
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.calendar_month_rounded, color: Colors.white70, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      "Membre depuis le ${_formatDate(user.createdAt)}",
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
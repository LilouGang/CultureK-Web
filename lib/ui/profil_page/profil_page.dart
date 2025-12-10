// lib/ui/profil_page/profil_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/data_manager.dart';
import 'user_dashboard_view.dart';
import 'guest_auth_view.dart';

class ProfilPage extends StatelessWidget {
  const ProfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    // On écoute le DataManager pour savoir si l'utilisateur change
    final user = context.watch<DataManager>().currentUser;
    final isGuest = user.id == "guest";

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            child: isGuest
                ? const GuestAuthView() // Affiche la vue Invité
                : const UserDashboardView(), // Affiche la vue Utilisateur
          ),
        ),
      ),
    );
  }
}
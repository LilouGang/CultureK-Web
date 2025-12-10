// lib/ui/profil_page/user_dashboard_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/data_manager.dart';
import 'widgets/profile_header.dart';
import 'widgets/profile_informations.dart';
import 'widgets/profile_actions.dart';

class UserDashboardView extends StatelessWidget {
  const UserDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    // On récupère l'utilisateur. 'watch' reconstruira si le nom d'utilisateur change.
    final user = context.watch<DataManager>().currentUser;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Widget 1: L'en-tête avec l'avatar et le nom
        ProfileHeader(user: user),
        
        const SizedBox(height: 40),
        
        // Widget 2: Le formulaire d'informations (qui gère son propre état)
        const ProfileInformations(),
        
        const Spacer(),
        
        // Widget 3: Le bouton de déconnexion
        const ProfileActions(),
      ],
    );
  }
}
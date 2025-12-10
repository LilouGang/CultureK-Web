import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/data_manager.dart';

class ProfileActions extends StatefulWidget {
  const ProfileActions({super.key});

  @override
  State<ProfileActions> createState() => _ProfileActionsState();
}

class _ProfileActionsState extends State<ProfileActions> {
  bool _isHovered = false; // État pour le survol

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: OutlinedButton.icon(
          onPressed: () => context.read<DataManager>().signOut(),
          icon: Icon(Icons.logout, color: _isHovered ? Colors.white : Colors.red),
          label: Text(
            "Se déconnecter", 
            style: TextStyle(
              color: _isHovered ? Colors.white : Colors.red, 
              fontWeight: FontWeight.bold
            )
          ),
          style: OutlinedButton.styleFrom(
            // NOUVEAU : Changement de couleur au survol
            backgroundColor: _isHovered ? Colors.red : Colors.transparent,
            side: const BorderSide(color: Colors.red, width: 2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            // Animation douce
            animationDuration: const Duration(milliseconds: 200),
          ),
        ),
      ),
    );
  }
}
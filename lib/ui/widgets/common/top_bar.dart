// lib/ui/widgets/common/top_bar.dart
import 'dart:ui';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    // BackdropFilter sert à faire l'effet "verre flouté" (Glassmorphism)
    // Très utilisé sur les interfaces desktop modernes (macOS/Windows 11)
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
        child: AppBar(
          title: Text(title),
          centerTitle: true,
          actions: actions,
          // Utilisation de .withValues comme demandé par la dernière version de Flutter
          backgroundColor: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.85),
          elevation: 0,
          scrolledUnderElevation: 2.0,
          surfaceTintColor: Colors.transparent,
          // J'ai supprimé SystemUiOverlayStyle ici
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
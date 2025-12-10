// lib/ui/quiz_page/views/difficulty_view.dart

import 'package:flutter/material.dart';
import '../../../data/data_manager.dart';
import '../widgets/diff_card.dart';
import '../widgets/breadcrumb.dart';

class DifficultyView extends StatelessWidget {
  final ThemeInfo theme;
  final SubThemeInfo subTheme;
  final Function(String, int, int) onSelectDifficulty;
  final VoidCallback onBack;

  const DifficultyView({super.key, required this.theme, required this.subTheme, required this.onSelectDifficulty, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Breadcrumb(text: "Catégories > ${theme.name} > ${subTheme.name}", onBack: onBack),
        const SizedBox(height: 40),
        const Center(child: Text("Choisis ton défi", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold))),
        const SizedBox(height: 40),
        Center(
          child: Wrap(
            spacing: 30, runSpacing: 30,
            children: [
              DiffCard("FACILE", Colors.green, "Niv. 1-3", () => onSelectDifficulty("Facile", 1, 3)),
              DiffCard("MOYEN", Colors.orange, "Niv. 4-6", () => onSelectDifficulty("Moyen", 4, 6)),
              DiffCard("DIFFICILE", Colors.red, "Niv. 7-8", () => onSelectDifficulty("Difficile", 7, 8)),
              DiffCard("EXTRÊME", Colors.purple, "Niv. 9-10", () => onSelectDifficulty("Impossible", 9, 10)),
            ],
          ),
        )
      ],
    );
  }
}
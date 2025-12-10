// lib/ui/quiz_page/views/themes_view.dart

import 'package:flutter/material.dart';
import '../../../data/data_manager.dart';
import '../widgets/modern_card.dart';

class ThemesView extends StatelessWidget {
  final List<ThemeInfo> themes;
  final Function(ThemeInfo) onSelectTheme;

  const ThemesView({super.key, required this.themes, required this.onSelectTheme});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Explorer les catégories", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 20),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 250, childAspectRatio: 1.2, crossAxisSpacing: 20, mainAxisSpacing: 20
            ),
            itemCount: themes.length,
            itemBuilder: (ctx, index) {
              final t = themes[index];
              return ModernCard(
                title: t.name,
                subtitle: "Découvrir",
                icon: Icons.category_rounded,
                color: Colors.white,
                onTap: () => onSelectTheme(t),
              );
            },
          ),
        ),
      ],
    );
  }
}
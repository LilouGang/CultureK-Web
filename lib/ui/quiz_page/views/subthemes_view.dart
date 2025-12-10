// lib/ui/quiz_page/views/subthemes_view.dart

import 'package:flutter/material.dart';
import '../../../data/data_manager.dart';
import '../widgets/modern_card.dart'; // ModernListCard est dans ce fichier
import '../widgets/breadcrumb.dart';

class SubthemesView extends StatelessWidget {
  final ThemeInfo theme;
  final List<SubThemeInfo> subThemes;
  final Function(SubThemeInfo) onSelectSubtheme;
  final VoidCallback onBack;

  const SubthemesView({super.key, required this.theme, required this.subThemes, required this.onSelectSubtheme, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Breadcrumb(text: "Catégories > ${theme.name}", onBack: onBack),
        const SizedBox(height: 20),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 300, childAspectRatio: 3, crossAxisSpacing: 20, mainAxisSpacing: 20
            ),
            itemCount: subThemes.length,
            itemBuilder: (ctx, index) {
              final st = subThemes[index];
              return ModernListCard(
                title: st.name,
                onTap: () => onSelectSubtheme(st),
              );
            },
          ),
        ),
      ],
    );
  }
}
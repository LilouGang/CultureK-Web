import 'package:flutter/material.dart';
import '../../../data/data_manager.dart';

// --- 1. VUE SÉLECTION THÈME ---
class ThemeSelectionView extends StatelessWidget {
  final List<ThemeInfo> themes;
  final Map<String, double> progressMap;
  final Function(ThemeInfo) onSelect;

  const ThemeSelectionView({
    super.key, 
    required this.themes, 
    required this.progressMap, 
    required this.onSelect
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _HeaderTitle(title: "EXPLORATION", subtitle: "Choisissez une catégorie pour commencer."),
        const SizedBox(height: 50),
        
        Wrap(
          spacing: 24,
          runSpacing: 30,
          alignment: WrapAlignment.center,
          children: themes.map((t) {
            double prog = progressMap[t.name] ?? 0.0;

            return SizedBox(
              width: 220,
              height: 180,
              child: _SelectionCard(
                title: t.name,
                subtitle: "JOUER",
                icon: _getIconForTheme(t.name),
                color: _getColorForTheme(t.name),
                progress: prog, 
                onTap: () => onSelect(t),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 50),
      ],
    );
  }
}

// --- 2. VUE SÉLECTION SOUS-THÈME ---
class SubThemeSelectionView extends StatelessWidget {
  final ThemeInfo theme;
  final List<SubThemeInfo> subThemes;
  final Map<String, double> progressMap; // <--- NOUVEAU
  final Function(SubThemeInfo) onSelect;
  final VoidCallback onBack;

  const SubThemeSelectionView({
    super.key, 
    required this.theme, 
    required this.subThemes, 
    required this.progressMap, // <---
    required this.onSelect, 
    required this.onBack
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center, 
          children: [
            IconButton(onPressed: onBack, icon: const Icon(Icons.arrow_back_rounded, color: Colors.blueGrey)), 
            const SizedBox(width: 12), 
            Expanded(child: _HeaderTitle(title: theme.name.toUpperCase(), subtitle: "Sélectionnez un sujet spécifique."))
          ],
        ),
        const SizedBox(height: 50),
        
        Wrap(
          spacing: 20,
          runSpacing: 20,
          alignment: WrapAlignment.center,
          children: subThemes.map((st) {
            double prog = progressMap[st.name] ?? 0.0; // Récup progrès sous-thème

            return SizedBox(
              width: 280,
              height: 80,
              child: _ListSelectionCard(
                title: st.name,
                color: _getColorForTheme(theme.name),
                progress: prog, // <--- TRANSMISSION
                onTap: () => onSelect(st),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// --- 3. VUE SÉLECTION DIFFICULTÉ (DESIGN PACKS AVEC REMPLISSAGE) ---
class DifficultySelectionView extends StatelessWidget {
  final ThemeInfo theme;
  final SubThemeInfo subTheme;
  // Callback modifié pour inclure le numéro de pack
  final Function(String label, int min, int max, int packIndex) onSelect;
  // Fonction pour récupérer le progrès
  final double Function(int min, int max, int packIndex) progressCalculator;
  final VoidCallback onBack;

  const DifficultySelectionView({
    super.key, 
    required this.theme, 
    required this.subTheme, 
    required this.onSelect,
    required this.progressCalculator, // <--- REÇU DEPUIS QUIZPAGE
    required this.onBack
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(onPressed: onBack, icon: const Icon(Icons.arrow_back_rounded, color: Colors.blueGrey)),
            const SizedBox(width: 12),
            Expanded(child: _HeaderTitle(title: subTheme.name.toUpperCase(), subtitle: "Choisis ton pack de questions.")),
          ],
        ),
        const SizedBox(height: 60),
        
        Wrap(
          spacing: 40,
          runSpacing: 40,
          alignment: WrapAlignment.center,
          children: [
            _DifficultySection(
              label: "FACILE", color: Colors.green, min: 1, max: 3,
              progressCalc: progressCalculator, onSelect: onSelect
            ),
            _DifficultySection(
              label: "MOYEN", color: Colors.orange, min: 4, max: 6,
              progressCalc: progressCalculator, onSelect: onSelect
            ),
            _DifficultySection(
              label: "DIFFICILE", color: Colors.red, min: 7, max: 8,
              progressCalc: progressCalculator, onSelect: onSelect
            ),
            _DifficultySection(
              label: "EXTRÊME", color: Colors.purple, min: 9, max: 10,
              progressCalc: progressCalculator, onSelect: onSelect
            ),
          ],
        )
      ],
    );
  }
}

// --- SECTION DE DIFFICULTÉ ---
class _DifficultySection extends StatelessWidget {
  final String label;
  final Color color;
  final int min, max;
  final double Function(int, int, int) progressCalc;
  final Function(String, int, int, int) onSelect;

  const _DifficultySection({
    required this.label, required this.color, required this.min, required this.max,
    required this.progressCalc, required this.onSelect
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 340,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 12),
            child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 13)),
          ),
          Row(
            children: [
              Expanded(child: _PackCard(packNumber: 1, color: color, progress: progressCalc(min, max, 1), onTap: () => onSelect(label, min, max, 1))),
              const SizedBox(width: 16),
              Expanded(child: _PackCard(packNumber: 2, color: color, progress: progressCalc(min, max, 2), onTap: () => onSelect(label, min, max, 2))),
            ],
          )
        ],
      ),
    );
  }
}

// --- CARTE PACK "MINIMALISTE & PRO" ---
class _PackCard extends StatefulWidget {
  final int packNumber;
  final Color color;
  final double progress; // 0.0 à 1.0
  final VoidCallback onTap;

  const _PackCard({required this.packNumber, required this.color, required this.progress, required this.onTap});

  @override
  State<_PackCard> createState() => _PackCardState();
}

class _PackCardState extends State<_PackCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 160,
          
          // Animation de zoom
          transform: _hover ? Matrix4.identity().scaled(1.05) : Matrix4.identity(),
          
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            // Ombre portée (Néon boosté au survol)
            boxShadow: [
              BoxShadow(
                // On augmente l'opacité et le spread pour un effet néon plus "glowing"
                color: _hover ? widget.color.withOpacity(0.6) : Colors.black.withOpacity(0.05),
                blurRadius: _hover ? 35 : 10,
                spreadRadius: _hover ? 1 : 0, 
                offset: const Offset(0, 5),
              )
            ],
          ),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              // 1. COUCHE DE FOND ET REMPLISSAGE
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  children: [
                    // Fond global
                    Container(color: widget.color.withOpacity(0.2)),

                    // Remplissage
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: FractionallySizedBox(
                        heightFactor: widget.progress,
                        widthFactor: 1.0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: widget.color,
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter, end: Alignment.topCenter,
                              colors: [widget.color, widget.color.withOpacity(0.85)],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 2. TEXTE
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.packNumber.toString().padLeft(2, '0'),
                      style: TextStyle(
                        fontSize: 36, 
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 1.5,
                        shadows: [
                          Shadow(color: Colors.black.withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2)),
                          Shadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 0)),
                        ]
                      ),
                    ),
                    
                    if (widget.progress > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          "${(widget.progress * 10).toInt()} / 10",
                          style: TextStyle(
                            fontSize: 13, 
                            fontWeight: FontWeight.w900, 
                            color: Colors.white,
                            letterSpacing: 1.0,
                            shadows: [Shadow(color: Colors.black.withOpacity(0.5), blurRadius: 6, offset: const Offset(0, 2))]
                          ),
                        ),
                      )
                  ],
                ),
              ),

              // 3. BORDURE CORRECTIVE (Le fix du flash noir est ici)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    // FIX : On anime l'opacité de la couleur, pas la couleur elle-même
                    color: widget.color.withOpacity(_hover ? 1.0 : 0.0), 
                    width: 2.0 // Bordure plus fine (était à 3)
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- WIDGETS LOCAUX ---

class _HeaderTitle extends StatelessWidget {
  final String title;
  final String subtitle;
  const _HeaderTitle({required this.title, required this.subtitle});
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.blueGrey.shade400, letterSpacing: 2.0)), const SizedBox(height: 4), Text(subtitle, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF1E293B)))]);
  }
}

// CARTE THÈME AVEC CERCLE
class _SelectionCard extends StatefulWidget {
  final String title; final String subtitle; final IconData icon; final Color color; final double progress; final VoidCallback onTap;
  const _SelectionCard({required this.title, required this.subtitle, required this.icon, required this.color, required this.progress, required this.onTap});
  @override
  State<_SelectionCard> createState() => _SelectionCardState();
}
class _SelectionCardState extends State<_SelectionCard> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          transform: _hover ? Matrix4.identity().scaled(1.05) : Matrix4.identity(),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _hover ? widget.color.withOpacity(0.8) : Colors.transparent, width: 2),
            boxShadow: [BoxShadow(color: _hover ? widget.color.withOpacity(0.4) : Colors.black.withOpacity(0.05), blurRadius: _hover ? 30 : 20, spreadRadius: _hover ? 2 : 0, offset: const Offset(0, 10))],
          ),
          child: Stack(
            children: [
              Positioned(
                top: 16, right: 16,
                child: SizedBox(width: 28, height: 28, child: CircularProgressIndicator(value: widget.progress, backgroundColor: Colors.grey.shade100, color: widget.color, strokeWidth: 3.5, strokeCap: StrokeCap.round)),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedContainer(duration: const Duration(milliseconds: 200), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: _hover ? widget.color : widget.color.withOpacity(0.1), shape: BoxShape.circle, boxShadow: _hover ? [BoxShadow(color: widget.color.withOpacity(0.5), blurRadius: 15)] : []), child: Icon(widget.icon, color: _hover ? Colors.white : widget.color, size: 36)),
                    const SizedBox(height: 16),
                    SizedBox(width: double.infinity, child: Text(widget.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// CARTE LISTE AVEC BARRE DE PROGRESSION
class _ListSelectionCard extends StatefulWidget {
  final String title; 
  final Color color; 
  final double progress; // <---
  final VoidCallback onTap;
  
  const _ListSelectionCard({required this.title, required this.color, required this.progress, required this.onTap});
  
  @override
  State<_ListSelectionCard> createState() => _ListSelectionCardState();
}
class _ListSelectionCardState extends State<_ListSelectionCard> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: Colors.white, 
            borderRadius: BorderRadius.circular(16), 
            border: Border.all(color: _hover ? widget.color : Colors.grey.shade200, width: _hover ? 2 : 1), 
            boxShadow: [if (_hover) BoxShadow(color: widget.color.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 4))]
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                // Barre de progression en bas
                if (widget.progress > 0)
                  Positioned(
                    bottom: 0, left: 0, right: 0, height: 4,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(widthFactor: widget.progress, child: Container(color: widget.color)),
                    ),
                  ),
                
                // Contenu
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _hover ? widget.color : const Color(0xFF1E293B)), overflow: TextOverflow.ellipsis),
                            if (widget.progress > 0)
                              Text("${(widget.progress * 100).toInt()}% complété", style: TextStyle(fontSize: 10, color: widget.color.withOpacity(0.8), fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_rounded, color: _hover ? widget.color : Colors.grey.shade300, size: 18)
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DifficultyCard extends StatefulWidget {
  final String title; final Color color; final String subtitle; final VoidCallback onTap;
  const _DifficultyCard(this.title, this.color, this.subtitle, this.onTap);
  @override
  State<_DifficultyCard> createState() => _DifficultyCardState();
}
class _DifficultyCardState extends State<_DifficultyCard> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 200, height: 160,
          decoration: BoxDecoration(color: _hover ? widget.color : Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: _hover ? widget.color.withOpacity(0.5) : Colors.black.withOpacity(0.05), blurRadius: 30, offset: const Offset(0, 10))]),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(widget.title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: _hover ? Colors.white : widget.color)), const SizedBox(height: 8), Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), decoration: BoxDecoration(color: _hover ? Colors.white24 : widget.color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)), child: Text(widget.subtitle, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _hover ? Colors.white : widget.color)))]),
        ),
      ),
    );
  }
}

Color _getColorForTheme(String theme) {
  final Map<String, Color> themeColors = {'Animaux': const Color(0xFFF97316), 'Art': const Color(0xFFEC4899), 'Divers': const Color(0xFF64748B), 'Divertissement': const Color(0xFF8B5CF6), 'Géographie': const Color(0xFF0EA5E9), 'Histoire': const Color(0xFFEAB308), 'Nature': const Color(0xFF22C55E), 'Science': const Color(0xFF06B6D4), 'Société': const Color(0xFFF43F5E), 'Technologie': const Color(0xFF3B82F6), 'Test': const Color(0xFF9CA3AF)};
  return themeColors[theme] ?? Colors.blueAccent;
}

IconData _getIconForTheme(String theme) {
  final Map<String, IconData> themeIcons = {'Animaux': Icons.pets_rounded, 'Art': Icons.palette_rounded, 'Divers': Icons.extension_rounded, 'Divertissement': Icons.movie_filter_rounded, 'Géographie': Icons.public_rounded, 'Histoire': Icons.history_edu_rounded, 'Nature': Icons.eco_rounded, 'Science': Icons.science_rounded, 'Société': Icons.groups_rounded, 'Technologie': Icons.memory_rounded, 'Test': Icons.bug_report_rounded};
  return themeIcons[theme] ?? Icons.category_rounded;
}
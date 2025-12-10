import 'package:flutter/material.dart';
import '../data/data_manager.dart';
import 'quiz_page/quiz_page.dart';
import 'profil_page/profil_page.dart';
import 'stats_page/stats_page.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  // État de la sidebar
  bool _isSidebarCollapsed = false;
  // Page actuelle (0 = Catégories/Jeu, 1 = Stats, 2 = Profil, 3 = Contact)
  int _selectedIndex = 0;

  // Pour forcer la sélection d'un thème depuis le menu
  ThemeInfo? _forcedThemeSelection;

  void _onMenuSelect(int index) {
    setState(() {
      _selectedIndex = index;
      _forcedThemeSelection = null; // Reset si on change d'onglet
    });
  }

  void _onThemeDirectSelect(ThemeInfo theme) {
    setState(() {
      _selectedIndex = 0; // On force l'onglet Jeu
      _forcedThemeSelection = theme;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // --- SIDEBAR ANIMÉE ---
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: _isSidebarCollapsed ? 80 : 280,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(4, 0))
              ],
            ),
            child: Column(
              children: [
                // Header Sidebar (Logo + Toggle)
                _buildSidebarHeader(),
                const Divider(height: 1),
                
                // Menu Items
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    children: [
                      _SidebarItem(
                        icon: Icons.grid_view_rounded,
                        label: "Catégories",
                        isCollapsed: _isSidebarCollapsed,
                        isActive: _selectedIndex == 0,
                        onTap: () => _onMenuSelect(0),
                      ),
                      
                      // Liste des thèmes (seulement si déployé et onglet catégories actif)
                      if (!_isSidebarCollapsed)
                        ...DataManager.instance.themes.map((t) => _ThemeSubItem(
                          label: t.name,
                          onTap: () => _onThemeDirectSelect(t),
                        )),

                      _SidebarItem(
                        icon: Icons.bar_chart_rounded,
                        label: "Statistiques",
                        isCollapsed: _isSidebarCollapsed,
                        isActive: _selectedIndex == 1,
                        onTap: () => _onMenuSelect(1),
                      ),
                      _SidebarItem(
                        icon: Icons.person_rounded,
                        label: "Profil",
                        isCollapsed: _isSidebarCollapsed,
                        isActive: _selectedIndex == 2,
                        onTap: () => _onMenuSelect(2),
                      ),
                      _SidebarItem(
                        icon: Icons.mail_outline_rounded,
                        label: "Contact",
                        isCollapsed: _isSidebarCollapsed,
                        isActive: _selectedIndex == 3,
                        onTap: () => _onMenuSelect(3),
                      ),
                    ],
                  ),
                ),
                
                // Footer (User info simplifiée)
                _buildSidebarFooter(),
              ],
            ),
          ),

          // --- CONTENU PRINCIPAL ---
          Expanded(
            child: Container(
              color: const Color(0xFFF8F9FE), // Gris très clair moderne
              child: _buildPageContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarHeader() {
    return SizedBox(
      height: 80,
      child: Row(
        mainAxisAlignment: _isSidebarCollapsed ? MainAxisAlignment.center : MainAxisAlignment.spaceBetween,
        children: [
          if (!_isSidebarCollapsed)
            const Padding(
              padding: EdgeInsets.only(left: 24),
              child: Text("CultureK", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w800, fontSize: 24, color: Colors.blueAccent)),
            ),
          IconButton(
            icon: Icon(_isSidebarCollapsed ? Icons.keyboard_double_arrow_right : Icons.keyboard_double_arrow_left, color: Colors.grey),
            onPressed: () => setState(() => _isSidebarCollapsed = !_isSidebarCollapsed),
          ),
          if (!_isSidebarCollapsed) const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildSidebarFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey.shade50,
      child: _isSidebarCollapsed 
        ? const CircleAvatar(backgroundColor: Colors.blue, child: Icon(Icons.person, color: Colors.white))
        : Row(
            children: [
              const CircleAvatar(backgroundColor: Colors.blue, child: Icon(Icons.person, color: Colors.white)),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Invité", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text("Niveau 1", style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              )
            ],
          ),
    );
  }

  Widget _buildPageContent() {
    // Si on a cliqué sur un thème précis dans la sidebar, on le passe à la QuizPage
    if (_selectedIndex == 0) {
      return QuizPage(initialTheme: _forcedThemeSelection);
    }
    if (_selectedIndex == 1)  return const StatsPage();
    
    // --- ICI LE CHANGEMENT ---
    if (_selectedIndex == 2) return const ProfilPage(); // On appelle la nouvelle page !
    
    return const Center(child: Text("Page Contact (À venir)"));
  }
}

// --- WIDGETS INTERNES ---

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isCollapsed;
  final bool isActive;
  final VoidCallback onTap;

  const _SidebarItem({required this.icon, required this.label, required this.isCollapsed, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 50,
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: isActive ? Colors.blueAccent.withValues(alpha: 0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
            children: [
              if (!isCollapsed) const SizedBox(width: 16),
              Icon(icon, color: isActive ? Colors.blueAccent : Colors.grey[600], size: 22),
              if (!isCollapsed) ...[
                const SizedBox(width: 16),
                Text(label, style: TextStyle(color: isActive ? Colors.blueAccent : Colors.grey[700], fontWeight: isActive ? FontWeight.w600 : FontWeight.normal)),
              ]
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeSubItem extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _ThemeSubItem({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(left: 54, top: 8, bottom: 8),
        child: Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart'; // Pour initialiser la locale FR
import '../../data/data_manager.dart';
import 'widgets/stat_card.dart';
import 'widgets/activity_chart.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  
  @override
  void initState() {
    super.initState();
    // Initialise le formattage de date en Français
    initializeDateFormatting('fr_FR', null);
  }

  @override
  Widget build(BuildContext context) {
    final dataManager = context.watch<DataManager>();
    final user = dataManager.currentUser;

    if (user.id == "guest") {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline_rounded, size: 60, color: Colors.grey[300]),
            const SizedBox(height: 20),
            const Text("Connecte-toi pour voir tes stats !", style: TextStyle(fontSize: 18, color: Colors.grey)),
          ],
        ),
      );
    }

    // Calculs des stats
    final bestWorst = user.getBestAndWorstThemes();
    final activityData = user.getLast7DaysActivity();
    
    // Calcul taux de complétion (Seen / Total DB)
    // Ici on utilise totalAnswers comme approximation de "Seen"
    double completionRate = 0.0;
    if (dataManager.totalQuestionsInDb > 0) {
      completionRate = (user.totalAnswers / dataManager.totalQuestionsInDb) * 100;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Tableau de bord", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text("Aperçu de tes performances", style: TextStyle(color: Colors.grey[600], fontSize: 16)),
          const SizedBox(height: 40),

          // GRILLE DE STATS FIXES
          LayoutBuilder(
            builder: (context, constraints) {
              // Responsive: 4 colonnes sur grand écran, 2 sur petit
              int crossAxisCount = constraints.maxWidth > 800 ? 4 : 2;
              return GridView.count(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.6,
                children: [
                  StatCard(
                    title: "Questions Vues",
                    value: "${user.totalAnswers}",
                    subtitle: "Sur ${dataManager.totalQuestionsInDb} disponibles",
                    icon: Icons.visibility_outlined,
                    color: Colors.blue,
                  ),
                  StatCard(
                    title: "Taux de réussite",
                    value: "${(user.successRate * 100).toStringAsFixed(1)}%",
                    icon: Icons.pie_chart_outline,
                    color: Colors.green,
                  ),
                  StatCard(
                    title: "Meilleur Thème",
                    value: bestWorst['best']!,
                    icon: Icons.emoji_events_outlined,
                    color: Colors.amber,
                  ),
                  StatCard(
                    title: "Progression Globale",
                    value: "${completionRate.toStringAsFixed(2)}%",
                    icon: Icons.rocket_launch_outlined,
                    color: Colors.purple,
                  ),
                ],
              );
            }
          ),

          const SizedBox(height: 30),

          // SECTION GRAPHIQUE + PIRE THÈME
          LayoutBuilder(
            builder: (context, constraints) {
              bool isWide = constraints.maxWidth > 900;
              return Flex(
                direction: isWide ? Axis.horizontal : Axis.vertical,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Graphique (Prend 2/3 de la largeur si wide)
                  Expanded(
                    flex: isWide ? 2 : 0,
                    child: ActivityChart(data: activityData),
                  ),
                  
                  SizedBox(width: isWide ? 30 : 0, height: isWide ? 0 : 30),

                  // Carte "Pire Thème" / Focus (Prend 1/3)
                  Expanded(
                    flex: isWide ? 1 : 0,
                    child: Container(
                      height: 300, // Hauteur fixe pour s'aligner avec le graph
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.orange.shade400, Colors.deepOrange.shade400]),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.warning_amber_rounded, color: Colors.white, size: 24),
                              SizedBox(width: 10),
                              Text("Zone d'effort", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                            ],
                          ),
                          const Spacer(),
                          const Text("Ton point faible :", style: TextStyle(color: Colors.white70)),
                          const SizedBox(height: 5),
                          Text(bestWorst['worst']!, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                          const SizedBox(height: 20),
                          const Text("Conseil :", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                          const Text("Concentre-toi sur ce thème lors de ta prochaine session pour équilibrer tes stats !", style: TextStyle(color: Colors.white, fontSize: 13, height: 1.4)),
                          const Spacer(),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }
          ),
        ],
      ),
    );
  }
}
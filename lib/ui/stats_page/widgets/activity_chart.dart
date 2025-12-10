import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ActivityChart extends StatelessWidget {
  final Map<DateTime, int> data; // Date -> Nombre de réponses

  const ActivityChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    // Trier les dates
    final sortedDates = data.keys.toList()..sort();
    
    // Trouver le max pour l'échelle Y (min 5 pour éviter un graph plat)
    double maxY = 5.0;
    for(var v in data.values) { if(v > maxY) maxY = v.toDouble(); }
    // On ajoute une petite marge en haut (20%)
    maxY = maxY * 1.2;

    // Création des spots
    List<BarChartGroupData> barGroups = [];
    int index = 0;
    for (var date in sortedDates) {
      barGroups.add(
        BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: data[date]!.toDouble(),
              color: Colors.blueAccent,
              width: 16,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
              backDrawRodData: BackgroundBarChartRodData(show: true, toY: maxY, color: Colors.grey.shade50),
            ),
          ],
        ),
      );
      index++;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Activité (7 derniers jours)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
          AspectRatio(
            aspectRatio: 1.7, // Format rectangulaire
            child: BarChart(
              BarChartData(
                maxY: maxY,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) => Colors.blueAccent,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${rod.toY.toInt()} Q.',
                        const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        if (value.toInt() >= sortedDates.length) return const SizedBox();
                        final date = sortedDates[value.toInt()];
                        // Affiche le jour (L, M, M...)
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            DateFormat('E', 'fr_FR').format(date).substring(0, 1).toUpperCase(),
                            style: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.bold),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      maxIncluded: false, // Ne pas afficher le dernier trait en haut
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const SizedBox();
                        return Text(value.toInt().toString(), style: TextStyle(color: Colors.grey[300], fontSize: 10));
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true, 
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.shade100, strokeWidth: 1),
                ),
                barGroups: barGroups,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
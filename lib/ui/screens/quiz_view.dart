// lib/ui/screens/quiz_view.dart
import 'package:flutter/material.dart';
import '../../data/services/data_manager.dart';
import '../widgets/quiz/answer_card.dart';

class QuizView extends StatefulWidget {
  const QuizView({super.key});

  @override
  State<QuizView> createState() => _QuizViewState();
}

class _QuizViewState extends State<QuizView> {
  Future<void>? _loadingFuture;

  @override
  void initState() {
    super.initState();
    _loadingFuture = DataManager.instance.loadAllData();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loadingFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // --- AFFICHAGE DE L'ERREUR ---
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  "Erreur de chargement",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.red),
                ),
                const SizedBox(height: 8),
                Text(
                  "${snapshot.error}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
          );
        }

        final themes = DataManager.instance.themes;

        if (themes.isEmpty) {
          return const Center(child: Text("La base de données est vide (Collection 'ThemesStyles')."));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Thèmes disponibles (${themes.length})",
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
            ),
            const SizedBox(height: 40),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 2.5,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                ),
                itemCount: themes.length,
                itemBuilder: (context, index) {
                  return AnswerCard(
                    answer: themes[index].name, 
                    index: index,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
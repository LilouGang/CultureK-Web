//lib/ui/screens/home_screen.dart

import 'package:flutter/material.dart';
import '../widgets/common/side_menu.dart';
import 'quiz_view.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // ZONE 1 : Le Menu (Flex 2 = prend 2 parts de l'espace)
          // Au lieu de SizedBox(width: 250), on utilise Expanded avec flex
          const Expanded(
            flex: 2, 
            child: SideMenu(),
          ),
          
          // ZONE 2 : Le Contenu (Flex 8 = prend 8 parts de l'espace)
          // Soit un ratio de 20% / 80%
          Expanded(
            flex: 8,
            child: Padding(
              // Padding en pourcentage de l'écran (via MediaQuery) pour rester responsive
              padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
              child: const QuizView(),
            ),
          ),
        ],
      ),
    );
  }
}
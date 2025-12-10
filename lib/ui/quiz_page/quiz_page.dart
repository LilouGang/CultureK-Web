// lib/ui/quiz_page/quiz_page.dart

import 'dart:math';
import 'package:flutter/material.dart';
import '../../data/data_manager.dart';

// On importe les différentes vues que cette page va afficher
import 'views/themes_view.dart';
import 'views/subthemes_view.dart';
import 'views/difficulty_view.dart';
import 'views/game_view.dart';

// On importe les widgets réutilisables
import 'widgets/gamified_header.dart';

class QuizPage extends StatefulWidget {
  final ThemeInfo? initialTheme;
  const QuizPage({super.key, this.initialTheme});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  // --- GESTION DU CHARGEMENT ---
  late Future<void> _loadDataFuture;

  // --- ÉTATS DE NAVIGATION ---
  ThemeInfo? _selectedTheme;
  SubThemeInfo? _selectedSubTheme;
  Map<String, dynamic>? _currentQuestion;
  
  // --- ÉTATS DE JEU ---
  List<Map<String, dynamic>> _allQuestions = [];
  bool _isLoadingSubdata = false;
  bool _hasAnswered = false;
  int? _selectedAnswerIndex;
  int? _correctAnswerIndex;
  String _diffLabel = "";
  int _minLvl = 0; int _maxLvl = 0;

  // --- GESTION DES MISES À JOUR DE L'UTILISATEUR ---
  void _update() => setState(() {});

  @override
  void initState() {
    super.initState();
    // On écoute les changements sur l'instance du DataManager (ex: connexion/déconnexion)
    DataManager.instance.addListener(_update);
    
    // On lance le chargement des données et on stocke l'opération dans notre Future
    _loadDataFuture = DataManager.instance.loadAllData();
    
    // Si la page a été ouverte avec un thème présélectionné
    if (widget.initialTheme != null) {
      _selectedTheme = widget.initialTheme;
    }
  }

  @override
  void dispose() {
    DataManager.instance.removeListener(_update);
    super.dispose();
  }

  @override
  void didUpdateWidget(QuizPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Gère le cas où le thème initial change depuis l'extérieur
    if (widget.initialTheme != oldWidget.initialTheme && widget.initialTheme != null) {
      _reset();
      setState(() => _selectedTheme = widget.initialTheme);
    }
  }

  // --- LOGIQUE DE NAVIGATION ET DE JEU ---

  Future<void> _selectSubTheme(SubThemeInfo st) async {
    setState(() { _selectedSubTheme = st; _isLoadingSubdata = true; });
    
    print("--- Sélection du sous-thème : ${st.name} ---");
    final qs = await DataManager.instance.getQuestions(st.parentTheme, st.name);
    
    // --- DEBUG ---
    print("Nombre de questions récupérées pour ce sous-thème : ${qs.length}");
    if (qs.isNotEmpty) {
      print("Exemple de première question récupérée : ${qs.first}");
    }
    
    if(mounted) setState(() { _allQuestions = qs; _isLoadingSubdata = false; });
  }

  void _nextQuestion() {
    print("--- Recherche d'une question pour le niveau '$_diffLabel' (min: $_minLvl, max: $_maxLvl) ---");
    print("Nombre total de questions en mémoire pour ce sous-thème : ${_allQuestions.length}");

    final filtered = _allQuestions.where((q) {
      // --- DEBUG ---
      final raw = q['difficulty'];
      print("Analyse de la question : ${q['question']?.substring(0, 15)}... | Champ 'difficulty' trouvé : '$raw' (type: ${raw.runtimeType})");
      
      int lvl = 0;
      if (raw is int) lvl = raw;
      if (raw is String) lvl = int.tryParse(raw) ?? 0;
      
      final bool matches = lvl >= _minLvl && lvl <= _maxLvl;
      if (matches) {
        print("==> MATCH ! La difficulté $lvl est dans l'intervalle [$_minLvl, $_maxLvl].");
      }
      return matches;
    }).toList();

    print("Nombre de questions trouvées pour ce niveau de difficulté : ${filtered.length}");

    if (filtered.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Pas de questions pour ce niveau !")));
      return;
    }
    
    setState(() {
      _currentQuestion = filtered[Random().nextInt(filtered.length)];
      _hasAnswered = false;
      _selectedAnswerIndex = null;
      _correctAnswerIndex = null;
    });
  }

  void _selectDifficulty(String label, int min, int max) {
    _diffLabel = label; _minLvl = min; _maxLvl = max;
    _nextQuestion();
  }

  void _checkAnswer(int index, String clickedText, List<String> allProps) {
    if (_hasAnswered) return;
    
    final correctText = _currentQuestion!['reponse']?.toString() ?? "";
    int correctIdx = allProps.indexOf(correctText);
    
    // Sécurité trimming
    if (correctIdx == -1) {
       correctIdx = allProps.indexWhere((p) => p.trim() == correctText.trim());
    }
    if (correctIdx == -1) correctIdx = 0;

    String qId = _currentQuestion!['id'] ?? ""; 
    
    // 1. Envoi à Firestore (Sauvegarde)
    DataManager.instance.addAnswer(index == correctIdx, qId, clickedText);

    // 2. Mise à jour LOCALE pour l'affichage immédiat des barres
    // On clone la map actuelle pour pouvoir la modifier
    Map<String, dynamic> newStats = Map<String, dynamic>.from(_currentQuestion!['answerStats'] ?? {});
    int currentCount = 0;
    
    if (newStats[clickedText] != null) {
      // On gère le cas où c'est un int ou un double
      currentCount = int.tryParse(newStats[clickedText].toString()) ?? 0;
    }
    newStats[clickedText] = currentCount + 1;

    int newTimesAnswered = (_currentQuestion!['timesAnswered'] ?? 0) + 1;
    int newTimesCorrect = (_currentQuestion!['timesCorrect'] ?? 0) + (index == correctIdx ? 1 : 0);

    // On met à jour l'état local
    setState(() {
      _hasAnswered = true;
      _selectedAnswerIndex = index;
      _correctAnswerIndex = correctIdx;
      
      // On injecte les nouvelles stats dans la question en cours
      _currentQuestion!['answerStats'] = newStats;
      _currentQuestion!['timesAnswered'] = newTimesAnswered;
      _currentQuestion!['timesCorrect'] = newTimesCorrect;
    });
  }

  void _reset() {
    setState(() {
      _currentQuestion = null;
      _selectedSubTheme = null;
      _allQuestions = [];
      _selectedTheme = null;
    });
  }

  void _backOneStep() {
    setState(() {
      if (_currentQuestion != null) {_currentQuestion = null; }
      else if (_selectedSubTheme != null) { _selectedSubTheme = null; _allQuestions = []; }
      else if (_selectedTheme != null) {_selectedTheme = null; }
    });
  }

  // --- INTERFACE ---

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _loadDataFuture,
      builder: (ctx, snap) {
        // Tant que les données de base (thèmes/sous-thèmes) ne sont pas prêtes, on attend
        if (!DataManager.instance.isReady || snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snap.hasError) {
          return Center(child: Text("Erreur de chargement des données : ${snap.error}"));
        }

        // Une fois les données prêtes, on construit l'interface
        final dataManager = DataManager.instance;

        return Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_currentQuestion == null) GamifiedHeader(user: dataManager.currentUser),
              const SizedBox(height: 30),
              
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  child: _buildCurrentContent(dataManager),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCurrentContent(DataManager dataManager) {
    // La clé est essentielle pour que AnimatedSwitcher détecte un changement de widget
    if (_currentQuestion != null) {
      return GameView(
        key: ValueKey(_currentQuestion!['question']),
        questionData: _currentQuestion!,
        diffLabel: _diffLabel,
        hasAnswered: _hasAnswered,
        selectedAnswerIndex: _selectedAnswerIndex,
        correctAnswerIndex: _correctAnswerIndex,
        onAnswer: _checkAnswer,
        onNext: _nextQuestion,
        onQuit: _reset,
      );
    }
    if (_selectedSubTheme != null) {
      return _isLoadingSubdata 
        ? const Center(child: CircularProgressIndicator()) 
        : DifficultyView(
            key: ValueKey(_selectedSubTheme!.name),
            theme: _selectedTheme!,
            subTheme: _selectedSubTheme!,
            onSelectDifficulty: _selectDifficulty,
            onBack: _backOneStep,
          );
    }
    if (_selectedTheme != null) {
      return SubthemesView(
        key: ValueKey(_selectedTheme!.name),
        theme: _selectedTheme!,
        subThemes: dataManager.getSubThemesFor(_selectedTheme!.name),
        onSelectSubtheme: _selectSubTheme,
        onBack: _backOneStep,
      );
    }
    return ThemesView(
      key: const ValueKey('themes_view'),
      themes: dataManager.themes,
      onSelectTheme: (t) => setState(() => _selectedTheme = t),
    );
  }
}
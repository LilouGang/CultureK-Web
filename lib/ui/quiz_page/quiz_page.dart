import 'dart:math';
import 'package:flutter/material.dart';
import '../../data/data_manager.dart';
import 'views/quiz_selection_views.dart';
import 'views/quiz_game_view.dart';

class QuizPage extends StatefulWidget {
  final ThemeInfo? initialTheme;
  const QuizPage({super.key, this.initialTheme});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  // --- ÉTATS ---
  late Future<void> _loadDataFuture;
  List<Map<String, dynamic>> _currentSubThemeQuestionsForStats = [];
  
  // Navigation State
  ThemeInfo? _selectedTheme;
  SubThemeInfo? _selectedSubTheme;
  String? _diffLabel;
  int _minLvl = 0; 
  int _maxLvl = 0;
  
  // Game State
  Map<String, dynamic>? _currentQuestion;
  List<Map<String, dynamic>> _allQuestions = [];
  bool _isLoadingGame = false;
  
  // Answer State
  bool _hasAnswered = false;
  int? _selectedAnswerIndex;
  int? _correctAnswerIndex;

  @override
  void initState() {
    super.initState();
    _loadDataFuture = DataManager.instance.loadAllData();
    if (widget.initialTheme != null) {
      _selectedTheme = widget.initialTheme;
    }
  }

  // --- LOGIQUE DE NAVIGATION ---

  void _onSelectTheme(ThemeInfo theme) {
    setState(() => _selectedTheme = theme);
  }

  Future<void> _onSelectSubTheme(SubThemeInfo subTheme) async {
    setState(() {
      _selectedSubTheme = subTheme;
      _isLoadingGame = true; // On affiche un petit chargement le temps de récupérer les IDs
    });

    // On charge toutes les questions de ce sous-thème pour pouvoir calculer les packs
    final qs = await DataManager.instance.getQuestions(_selectedTheme!.name, subTheme.name);
    
    if (mounted) {
      setState(() {
        _currentSubThemeQuestionsForStats = qs;
        _isLoadingGame = false;
      });
    }
  }

  // Calcule le % de progression d'un pack (0.0 à 1.0)
  // packIndex : 1 (premier pack de 10) ou 2 (deuxième pack de 10)
  double _calculatePackProgress(int minDiff, int maxDiff, int packIndex) {
    if (_currentSubThemeQuestionsForStats.isEmpty) return 0.0;

    // 1. Filtrer par difficulté
    final questionsOfLevel = _currentSubThemeQuestionsForStats.where((q) {
      int lvl = int.tryParse(q['difficulty'].toString()) ?? 0;
      return lvl >= minDiff && lvl <= maxDiff;
    }).toList();

    // 2. Trier par ID alphabétique (pour que les packs soient toujours les mêmes)
    questionsOfLevel.sort((a, b) => (a['id'] ?? '').compareTo(b['id'] ?? ''));

    // 3. Déterminer la tranche (Pack 1: 0-9, Pack 2: 10-19)
    int startIndex = (packIndex - 1) * 10;
    int endIndex = startIndex + 10;

    // Sécurité si moins de questions que prévu
    if (startIndex >= questionsOfLevel.length) return 0.0;
    if (endIndex > questionsOfLevel.length) endIndex = questionsOfLevel.length;

    // 4. Extraire les questions du pack
    final packQuestions = questionsOfLevel.sublist(startIndex, endIndex);
    if (packQuestions.isEmpty) return 0.0;

    // 5. Compter combien sont validées dans le UserProfile
    final userIds = DataManager.instance.currentUser.answeredQuestionIds;
    int validatedCount = 0;
    
    for (var q in packQuestions) {
      if (userIds.contains(q['id'])) {
        validatedCount++;
      }
    }

    return validatedCount / packQuestions.length; // Ex: 5/10 = 0.5
  }

  Future<void> _onSelectDifficulty(String label, int min, int max, int packIndex) async {
    // Note : packIndex (1 ou 2) sert à filtrer le bon chunk de questions
    
    setState(() {
      _diffLabel = "$label - Pack $packIndex";
      _minLvl = min;
      _maxLvl = max;
    });

    // 1. Filtrer la liste déjà chargée par difficulté
    final questionsOfLevel = _currentSubThemeQuestionsForStats.where((q) {
      int lvl = int.tryParse(q['difficulty'].toString()) ?? 0;
      return lvl >= _minLvl && lvl <= _maxLvl;
    }).toList();

    // 2. Trier par ID
    questionsOfLevel.sort((a, b) => (a['id'] ?? '').compareTo(b['id'] ?? ''));

    // 3. Sélectionner le Pack (10 questions)
    int startIndex = (packIndex - 1) * 10;
    int endIndex = startIndex + 10;
    
    if (startIndex >= questionsOfLevel.length) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ce pack est vide pour l'instant !"), backgroundColor: Colors.orange));
       return;
    }
    if (endIndex > questionsOfLevel.length) endIndex = questionsOfLevel.length;

    final packQuestions = questionsOfLevel.sublist(startIndex, endIndex);

    if (mounted) {
      setState(() {
        _allQuestions = packQuestions;
        _nextQuestion();
      });
    }
  }

  void _nextQuestion() {
    setState(() {
      _currentQuestion = _allQuestions[Random().nextInt(_allQuestions.length)];
      _hasAnswered = false;
      _selectedAnswerIndex = null;
      _correctAnswerIndex = null;
    });
  }

  void _onAnswer(int index, String text, List<String> props) {
    if (_hasAnswered) return;

    final correctText = _currentQuestion!['reponse']?.toString() ?? "";
    int correctIdx = props.indexWhere((p) => p.trim() == correctText.trim());
    if (correctIdx == -1) correctIdx = 0; 

    DataManager.instance.addAnswer(
      index == correctIdx, 
      _currentQuestion!['id'] ?? "", 
      text, 
      _selectedTheme!.name
    );

    Map<String, dynamic> newStats = Map.from(_currentQuestion!['answerStats'] ?? {});
    newStats[text] = (int.tryParse(newStats[text].toString()) ?? 0) + 1;
    
    setState(() {
      _hasAnswered = true;
      _selectedAnswerIndex = index;
      _correctAnswerIndex = correctIdx;
      _currentQuestion!['answerStats'] = newStats;
      _currentQuestion!['timesAnswered'] = (_currentQuestion!['timesAnswered'] ?? 0) + 1;
      if (index == correctIdx) {
        _currentQuestion!['timesCorrect'] = (_currentQuestion!['timesCorrect'] ?? 0) + 1;
      }
    });
  }

  void _onBack() {
    setState(() {
      if (_currentQuestion != null) {
        _currentQuestion = null;
        _allQuestions = [];
      } else if (_selectedSubTheme != null) {
        _selectedSubTheme = null;
      } else if (_selectedTheme != null) {
        _selectedTheme = null;
      }
    });
  }

  void _onQuitGame() {
    setState(() {
      _currentQuestion = null;
      _allQuestions = [];
    });
  }

  // --- CALCULS DE PROGRESSION ---

  Map<String, double> _calculateThemeProgressMap() {
    final user = DataManager.instance.currentUser;
    Map<String, double> progressMap = {};
    Map<String, int> playerScores = {};

    user.scores.forEach((key, value) {
      String mainTheme = key.contains('-') ? key.split('-')[0].trim() : key;
      int points = 0;
      
      if (value is Map) {
        final valMap = value as Map<dynamic, dynamic>; 
        points = (valMap['dynamicScore'] as num?)?.toInt() ?? 0;
      } else      points = value.toInt();
    

      playerScores[mainTheme] = (playerScores[mainTheme] ?? 0) + points;
    });

    playerScores.forEach((theme, score) {
      int totalQuestionsAvailable = DataManager.instance.countTotalQuestionsForTheme(theme);
      if (totalQuestionsAvailable == 0) totalQuestionsAvailable = 1;
      double percent = score / totalQuestionsAvailable;
      if (percent > 1.0) percent = 1.0; 
      progressMap[theme] = percent;
    });

    return progressMap;
  }

  // NOUVEAU : Calcul pour les sous-thèmes
  Map<String, double> _calculateSubThemeProgressMap() {
    final user = DataManager.instance.currentUser;
    Map<String, double> progressMap = {};
    
    user.scores.forEach((key, value) {
      // key = "Theme-SousTheme"
      if (!key.contains('-')) return;

      int points = 0;
      if (value is Map) {
        final valMap = value as Map<dynamic, dynamic>;
        points = (valMap['dynamicScore'] as num?)?.toInt() ?? 0;
      } else      points = value.toInt();
    

      try {
        String themeName = key.split('-')[0];
        String subThemeName = key.split('-')[1];
        
        // On récupère le total précis via DataManager
        int total = DataManager.instance.countTotalQuestionsForSubTheme(themeName, subThemeName);
        if (total == 0) total = 1;

        double percent = points / total;
        if (percent > 1.0) percent = 1.0;
        
        // On stocke par nom de sous-thème
        progressMap[subThemeName] = percent; 
      } catch (e) {
        // Ignore parsing errors
      }
    });

    return progressMap;
  }

  // --- RENDU ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _QuizPatternPainter(),
            ),
          ),

          FutureBuilder(
            future: _loadDataFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (_currentQuestion != null) {
                return QuizGameView(
                  key: ValueKey(_currentQuestion!['id']),
                  questionData: _currentQuestion!,
                  difficultyLabel: _diffLabel!,
                  hasAnswered: _hasAnswered,
                  selectedAnswerIndex: _selectedAnswerIndex,
                  correctAnswerIndex: _correctAnswerIndex,
                  onAnswer: _onAnswer,
                  onNext: _nextQuestion,
                  onQuit: _onQuitGame,
                );
              }

              if (_isLoadingGame) {
                return const Center(child: CircularProgressIndicator());
              }

              final progressMap = _calculateThemeProgressMap();
              final subThemeProgressMap = _calculateSubThemeProgressMap(); // <--- On calcule ici

              return ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1000), 
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          layoutBuilder: (currentChild, previousChildren) {
                            return Stack(
                              alignment: Alignment.topCenter,
                              children: [
                                ...previousChildren,
                                if (currentChild != null) currentChild,
                              ],
                            );
                          },
                          // On passe les deux maps
                          child: _buildSelectionView(progressMap, subThemeProgressMap),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionView(Map<String, double> progressMap, Map<String, double> subThemeProgressMap) {
    if (_selectedSubTheme != null) {
      return DifficultySelectionView(
        theme: _selectedTheme!,
        subTheme: _selectedSubTheme!,
        // On passe notre fonction de calcul
        progressCalculator: _calculatePackProgress, 
        // On met à jour la signature du callback pour inclure le numéro de pack
        onSelect: (label, min, max, packNum) => _onSelectDifficulty(label, min, max, packNum),
        onBack: _onBack,
      );
    }
    if (_selectedTheme != null) {
      return SubThemeSelectionView(
        theme: _selectedTheme!,
        subThemes: DataManager.instance.getSubThemesFor(_selectedTheme!.name),
        progressMap: subThemeProgressMap, // <--- Transmission
        onSelect: _onSelectSubTheme,
        onBack: _onBack,
      );
    }
    return ThemeSelectionView(
      themes: DataManager.instance.themes,
      progressMap: progressMap,
      onSelect: _onSelectTheme,
    );
  }
}

class _QuizPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paintStroke = Paint()
      ..color = Colors.blueGrey.withOpacity(0.06)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final Paint paintFill = Paint()
      ..color = Colors.blueGrey.withOpacity(0.06)
      ..style = PaintingStyle.fill;

    const double gridSize = 50.0;

    final int cols = (size.width / gridSize).ceil();
    final int rows = (size.height / gridSize).ceil();

    for (int i = 0; i < cols; i++) {
      for (int j = 0; j < rows; j++) {
        final double x = i * gridSize;
        final double y = j * gridSize;
        final Offset center = Offset(x + gridSize / 2, y + gridSize / 2);

        final int hash = ((i * 13) ^ (j * 7) + (i * j)).abs();
        final int shapeType = hash % 7; 

        switch (shapeType) {
          case 0: 
          case 1: 
            const double s = 4.0;
            canvas.drawLine(center.translate(-s, 0), center.translate(s, 0), paintStroke);
            canvas.drawLine(center.translate(0, -s), center.translate(0, s), paintStroke);
            break;
          case 2:
          case 3:
            canvas.drawCircle(center, 1.5, paintFill);
            break;
          case 4:
            canvas.drawCircle(center, 3.0, paintStroke);
            break;
          case 5:
            const double s = 3.0;
            canvas.drawLine(center.translate(-s, s), center.translate(s, -s), paintStroke);
            break;
          default:
            break;
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
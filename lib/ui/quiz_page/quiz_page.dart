import 'package:flutter/material.dart';
import '../../data/data_manager.dart';
import 'views/quiz_selection_views.dart'; // Assure-toi que ce fichier existe
import 'views/quiz_game_view.dart'; // Le fichier que nous avons perfectionné

class QuizPage extends StatefulWidget {
  final ThemeInfo? initialTheme;
  const QuizPage({super.key, this.initialTheme});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  // --- ÉTATS GLOBAUX ---
  late Future<void> _loadDataFuture;
  List<Map<String, dynamic>> _currentSubThemeQuestionsForStats = [];
  
  // Navigation State
  ThemeInfo? _selectedTheme;
  SubThemeInfo? _selectedSubTheme;
  String? _diffLabel;
  int _minLvl = 0; 
  int _maxLvl = 0;
  
  // --- ÉTAT DU JEU EN COURS ---
  List<Map<String, dynamic>> _gameQuestions = []; // La liste des 10 questions du pack
  int _currentQuestionIndex = 0;
  Map<String, dynamic>? _currentQuestionData;
  bool _isGameOver = false;
  int _score = 0;
  bool _isLoadingGame = false;
  
  // Answer State (Question actuelle)
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
      _isLoadingGame = true; 
    });

    // On charge toutes les questions pour calculer les stats des packs
    final qs = await DataManager.instance.getQuestions(_selectedTheme!.name, subTheme.name);
    
    if (mounted) {
      setState(() {
        _currentSubThemeQuestionsForStats = qs;
        _isLoadingGame = false;
      });
    }
  }

  // --- LOGIQUE DES PACKS ---

  // Calcule le % de progression d'un pack (0.0 à 1.0) pour l'affichage des boutons
  double _calculatePackProgress(int minDiff, int maxDiff, int packIndex) {
    if (_currentSubThemeQuestionsForStats.isEmpty) return 0.0;

    // 1. Filtrer par difficulté
    final questionsOfLevel = _currentSubThemeQuestionsForStats.where((q) {
      int lvl = int.tryParse(q['difficulty'].toString()) ?? 0;
      return lvl >= minDiff && lvl <= maxDiff;
    }).toList();

    // 2. Trier par ID (Crucial pour la consistance des packs)
    questionsOfLevel.sort((a, b) => (a['id'] ?? '').compareTo(b['id'] ?? ''));

    // 3. Déterminer la tranche
    int startIndex = (packIndex - 1) * 10;
    int endIndex = startIndex + 10;

    if (startIndex >= questionsOfLevel.length) return 0.0;
    if (endIndex > questionsOfLevel.length) endIndex = questionsOfLevel.length;

    // 4. Extraire le pack théorique
    final packQuestions = questionsOfLevel.sublist(startIndex, endIndex);
    if (packQuestions.isEmpty) return 0.0;

    // 5. Compter les validées
    final userIds = DataManager.instance.currentUser.answeredQuestions;
    int validatedCount = 0;
    for (var q in packQuestions) {
      if (userIds.contains(q['id'])) validatedCount++;
    }

    return validatedCount / packQuestions.length; 
  }

  // Lance le jeu avec un pack spécifique
  Future<void> _onSelectDifficulty(String label, int min, int max, int packIndex) async {
    setState(() {
      _diffLabel = "$label - Pack $packIndex";
      _minLvl = min;
      _maxLvl = max;
      _isLoadingGame = true;
    });

    // 1. On récupère et filtre
    final questionsOfLevel = _currentSubThemeQuestionsForStats.where((q) {
      int lvl = int.tryParse(q['difficulty'].toString()) ?? 0;
      return lvl >= _minLvl && lvl <= _maxLvl;
    }).toList();

    // 2. On trie par ID pour avoir toujours le même lot pour ce pack
    questionsOfLevel.sort((a, b) => (a['id'] ?? '').compareTo(b['id'] ?? ''));

    // 3. On coupe la part du gâteau (le pack de 10)
    int startIndex = (packIndex - 1) * 10;
    int endIndex = startIndex + 10;
    
    if (startIndex >= questionsOfLevel.length) {
       setState(() => _isLoadingGame = false);
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ce pack est vide !"), backgroundColor: Colors.orange));
       return;
    }
    if (endIndex > questionsOfLevel.length) endIndex = questionsOfLevel.length;

    List<Map<String, dynamic>> selectedPack = questionsOfLevel.sublist(startIndex, endIndex);

    // 4. ON MÉLANGE LE PACK POUR LE JEU (Gameplay aléatoire mais contenu fixe)
    selectedPack.shuffle();

    if (mounted) {
      setState(() {
        _gameQuestions = selectedPack;
        _currentQuestionIndex = 0;
        _score = 0;
        _isGameOver = false;
        
        // Initialisation de la première question
        if (_gameQuestions.isNotEmpty) {
          _currentQuestionData = _gameQuestions[0];
        }
        
        _hasAnswered = false;
        _selectedAnswerIndex = null;
        _correctAnswerIndex = null;
        _isLoadingGame = false;
      });
    }
  }

  // --- LOGIQUE DU JEU ---

  void _nextQuestion() {
    if (_currentQuestionIndex < _gameQuestions.length - 1) {
      // Question suivante
      setState(() {
        _currentQuestionIndex++;
        _currentQuestionData = _gameQuestions[_currentQuestionIndex];
        _hasAnswered = false;
        _selectedAnswerIndex = null;
        _correctAnswerIndex = null;
      });
    } else {
      // Fin du jeu
      setState(() {
        _isGameOver = true;
      });
    }
  }

  void _onAnswer(int index, String text, List<String> props) {
    if (_hasAnswered) return;

    final correctText = _currentQuestionData!['reponse']?.toString() ?? "";
    // On trouve l'index correct dans la liste originale des propositions
    int correctIdx = props.indexWhere((p) => p.trim() == correctText.trim());
    if (correctIdx == -1) correctIdx = 0; 

    bool isCorrect = (index == correctIdx);

    // Sauvegarde BDD
    DataManager.instance.addAnswer(
      isCorrect, 
      _currentQuestionData!['id'] ?? "", 
      text, 
      _selectedTheme!.name
    );

    // Mise à jour stats locales pour affichage immédiat
    Map<String, dynamic> newStats = Map.from(_currentQuestionData!['answerStats'] ?? {});
    newStats[text] = (int.tryParse(newStats[text].toString()) ?? 0) + 1;
    
    setState(() {
      _hasAnswered = true;
      _selectedAnswerIndex = index;
      _correctAnswerIndex = correctIdx;
      if (isCorrect) _score++; // On incrémente le score de la session
      
      _currentQuestionData!['answerStats'] = newStats;
      _currentQuestionData!['timesAnswered'] = (_currentQuestionData!['timesAnswered'] ?? 0) + 1;
      if (isCorrect) {
        _currentQuestionData!['timesCorrect'] = (_currentQuestionData!['timesCorrect'] ?? 0) + 1;
      }
    });
  }

  void _onBack() {
    setState(() {
      if (_currentQuestionData != null || _isGameOver) {
        // Retour depuis le jeu vers la sélection de difficulté
        _currentQuestionData = null;
        _gameQuestions = [];
        _isGameOver = false;
      } else if (_selectedSubTheme != null) {
        _selectedSubTheme = null;
      } else if (_selectedTheme != null) {
        _selectedTheme = null;
      }
    });
  }

  void _onQuitGame() {
    setState(() {
      _currentQuestionData = null;
      _gameQuestions = [];
      _isGameOver = false;
    });
  }

  // --- CALCULS DE PROGRESSION GLOBALE ---

  Map<String, double> _calculateThemeProgressMap() {
    // ... (Ton code existant inchangé) ...
    final user = DataManager.instance.currentUser;
    Map<String, double> progressMap = {};
    Map<String, int> playerScores = {};
    user.scores.forEach((key, value) {
      String mainTheme = key.contains('-') ? key.split('-')[0].trim() : key;
      int points = (value is Map) ? ((value as Map)['dynamicScore'] as num?)?.toInt() ?? 0 : (value as num).toInt();
      playerScores[mainTheme] = (playerScores[mainTheme] ?? 0) + points;
    });
    playerScores.forEach((theme, score) {
      int total = DataManager.instance.countTotalQuestionsForTheme(theme);
      if (total == 0) total = 1;
      progressMap[theme] = (score / total).clamp(0.0, 1.0);
    });
    return progressMap;
  }

  Map<String, double> _calculateSubThemeProgressMap() {
    // ... (Ton code existant inchangé) ...
    final user = DataManager.instance.currentUser;
    Map<String, double> progressMap = {};
    user.scores.forEach((key, value) {
      if (!key.contains('-')) return;
      int points = (value is Map) ? ((value as Map)['dynamicScore'] as num?)?.toInt() ?? 0 : (value as num).toInt();
      try {
        String themeName = key.split('-')[0];
        String subThemeName = key.split('-')[1];
        int total = DataManager.instance.countTotalQuestionsForSubTheme(themeName, subThemeName);
        if (total == 0) total = 1;
        progressMap[subThemeName] = (points / total).clamp(0.0, 1.0);
      } catch (e) { }
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

              // CONDITION 1 : Le jeu est en cours OU le jeu est fini (Ecran de fin)
              if (_currentQuestionData != null || _isGameOver) {
                return QuizGameView(
                  // Clé unique pour forcer le rebuild si la question change
                  key: _isGameOver ? const ValueKey('GameOver') : ValueKey(_currentQuestionData!['id']),
                  questionData: _isGameOver ? null : _currentQuestionData,
                  difficultyLabel: _diffLabel ?? "",
                  hasAnswered: _hasAnswered,
                  selectedAnswerIndex: _selectedAnswerIndex,
                  correctAnswerIndex: _correctAnswerIndex,
                  onAnswer: _onAnswer,
                  onNext: _nextQuestion,
                  onQuit: _onQuitGame,
                  // Paramètres de fin
                  isGameOver: _isGameOver,
                  score: _score,
                  totalQuestions: _gameQuestions.length,
                  questionsHistory: _gameQuestions
                );
              }

              if (_isLoadingGame) {
                return const Center(child: CircularProgressIndicator());
              }

              // CONDITION 2 : Navigation (Thèmes / Sous-Thèmes / Packs)
              final progressMap = _calculateThemeProgressMap();
              final subThemeProgressMap = _calculateSubThemeProgressMap();

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
        progressCalculator: _calculatePackProgress, 
        onSelect: (label, min, max, packNum) => _onSelectDifficulty(label, min, max, packNum),
        onBack: _onBack,
      );
    }
    if (_selectedTheme != null) {
      return SubThemeSelectionView(
        theme: _selectedTheme!,
        subThemes: DataManager.instance.getSubThemesFor(_selectedTheme!.name),
        progressMap: subThemeProgressMap,
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
      ..color = Colors.blueGrey.withOpacity(0.2)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final Paint paintFill = Paint()
      ..color = Colors.blueGrey.withOpacity(0.2)
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
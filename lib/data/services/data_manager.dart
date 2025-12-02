// lib/data/services/data_manager.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/theme_info.dart';
import '../models/sub_theme_info.dart';

class DataManager with ChangeNotifier {
  DataManager._privateConstructor();
  static final DataManager instance = DataManager._privateConstructor();

  bool _isReady = false;
  bool get isReady => _isReady;

  List<ThemeInfo> themes = [];
  List<SubThemeInfo> subThemes = [];

  Future<void> loadAllData() async {
    // Si déjà chargé, on ne fait rien
    if (_isReady) return;

    try {
      // Appel Firestore
      final responses = await Future.wait([
        FirebaseFirestore.instance.collection('ThemesStyles').get(),
        FirebaseFirestore.instance.collection('SousThemesStyles').get(),
      ]);

      final themesSnapshot = responses[0];
      final subThemesSnapshot = responses[1];

      themes = themesSnapshot.docs
          .map((doc) => ThemeInfo.fromFirestore(doc.data()))
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));
        
      subThemes = subThemesSnapshot.docs
          .map((doc) => SubThemeInfo.fromFirestore(doc.data()))
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));
      
      _isReady = true;
      notifyListeners();

    } catch (e) {
      debugPrint("ERREUR CRITIQUE DATA MANAGER : $e");
      // IMPORTANT : On renvoie l'erreur pour que l'interface puisse l'afficher !
      rethrow; 
    }
  }
}
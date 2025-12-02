// lib/main.dart
import 'package:culturek/data/services/data_manager.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'ui/screens/home_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // --- NOUVELLE LOGIQUE D'INITIALISATION ---
  
  // 2. Charger les variables d'environnement depuis le fichier .env
  await dotenv.load(fileName: ".env");

  // 3. Initialiser Firebase manuellement avec ces variables
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: dotenv.env['FIREBASE_API_KEY']!,
      authDomain: dotenv.env['FIREBASE_AUTH_DOMAIN']!,
      projectId: dotenv.env['FIREBASE_PROJECT_ID']!,
      storageBucket: dotenv.env['FIREBASE_STORAGE_BUCKET']!,
      messagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID']!,
      appId: dotenv.env['FIREBASE_APP_ID']!,
      measurementId: dotenv.env['FIREBASE_MEASUREMENT_ID']!,
    ),
  );
  
  // On ne charge plus les données ici, le SplashScreen le fait.
  // await DataManager.instance.loadAllData();
  
  runApp(
    ChangeNotifierProvider(
      create: (context) => DataManager.instance,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CultureK Web',
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
        // On optimise la typographie pour les écrans larges par défaut
        visualDensity: VisualDensity.comfortable, 
      ),
      home: const HomeScreen(),
    );
  }
}
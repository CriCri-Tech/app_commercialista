import 'package:flutter/material.dart';
// IMPORTA IL PACCHETTO CORE DI FIREBASE
import 'package:firebase_core/firebase_core.dart'; 

import 'presentazione/schermate/dashboard_page.dart'; 


void main() async {
  // Assicura che i canali nativi di Flutter siano pronti
  WidgetsFlutterBinding.ensureInitialized();

  // INIZIALIZZA FIREBASE PRIMA DI FAR PARTIRE L'APP
  await Firebase.initializeApp();

  // Quando firebase è pronto fa partire l'applicazione
  runApp(const MiaApp());
}

class MiaApp extends StatelessWidget {
  const MiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nexa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E3A8A)),
        useMaterial3: true,
      ),
      home: const RegistrazionePage(), 
    );
  }
}
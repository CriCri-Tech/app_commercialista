import 'package:flutter/material.dart';
// IMPORTA IL PACCHETTO CORE DI FIREBASE
import 'package:firebase_core/firebase_core.dart'; 

// IMPORTA LA NUOVA LANDING PAGE
// Nota: adatta questo percorso in base a dove hai salvato il file landing_page.dart
import 'presentazione/schermate/welcome_page.dart'; 

void main() async {
  // Assicura che i canali nativi di Flutter siano pronti
  WidgetsFlutterBinding.ensureInitialized();

  // INIZIALIZZA FIREBASE PRIMA DI FAR PARTIRE L'APP
  await Firebase.initializeApp();

  // Quando Firebase è pronto fa partire l'applicazione
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
      //Imposta la WelcomePage come prima schermata all'avvio
      home: const WelcomePage(), 
    );
  }
}
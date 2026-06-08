import 'package:flutter/material.dart';
// 1. IMPORTA LA TUA PAGINA
import '/presentazione/schermate/dashboard_page.dart'; 

void main() {
  // Il punto di partenza assoluto dell'applicazione
  runApp(const MiaApp());
}

class MiaApp extends StatelessWidget {
  const MiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nexa',
      debugShowCheckedModeBanner: false, // Rimuove la striscia rossa "Debug" in alto a destra sul telefono
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E3A8A)),
        useMaterial3: true, // Attiva il design Material 3 (consigliato)
      ),
      // 2. IMPOSTA LA TUA PAGINA COME SCHERMATA INIZIALE
      home: const RegistrazionePage(), 
    );
  }
}
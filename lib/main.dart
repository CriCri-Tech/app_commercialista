import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; 
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'presentazione/schermate/welcome_page.dart'; 
import 'presentazione/schermate/nexa_home_page.dart'; // Importa la tua home principale

void main() async {
  // 1. Assicura che i widget di Flutter siano pronti prima di eseguire codice asincrono
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. Inizializza Firebase
  await Firebase.initializeApp();
  
  // 3. Controlla lo stato di SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final bool ricordamiAttivo = prefs.getBool('ricordami') ?? false;
  
  // 4. Verifica se l'utente è attualmente autenticato su Firebase
  final userCorrente = FirebaseAuth.instance.currentUser;

  // Se "Ricordami" è vero E c'è un utente registrato su Firebase, andiamo alla Home.
  // Altrimenti mostriamo la WelcomePage.
  final bool vaiDirettamenteAllaHome = ricordamiAttivo && userCorrente != null;

  runApp(MiaApp(schermataIniziale: vaiDirettamenteAllaHome ? const NexaHomePage() : const WelcomePage()));
}

class MiaApp extends StatelessWidget {
  final Widget schermataIniziale;

  // Passiamo la schermata decisa nel main attraverso il costruttore
  const MiaApp({super.key, required this.schermataIniziale});

  @override
  Widget build(BuildContext context) {
    const Color nexaBlue = Color(0xFF1E3A8A);

    return MaterialApp(
      title: 'Nexa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: nexaBlue),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey.shade50, 
        
        appBarTheme: const AppBarTheme(
          backgroundColor: nexaBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
        ),

        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(color: nexaBlue, width: 2),
          ),
          prefixIconColor: nexaBlue.withOpacity(0.7),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: nexaBlue,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(55), 
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: nexaBlue,
            minimumSize: const Size.fromHeight(55),
            side: const BorderSide(color: nexaBlue, width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      // Applica la schermata dinamica calcolata all'avvio
      home: schermataIniziale, 
    );
  }
}
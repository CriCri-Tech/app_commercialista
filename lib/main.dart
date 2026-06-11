import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; 
import 'presentazione/schermate/welcome_page.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MiaApp());
}

class MiaApp extends StatelessWidget {
  const MiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Definiamo il colore brand principale
    const Color nexaBlue = Color(0xFF1E3A8A);

    return MaterialApp(
      title: 'Nexa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: nexaBlue),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey.shade50, // Uno sfondo leggermente grigio fa risaltare le card bianche
        
        // Stile globale per la barra superiore (AppBar)
        appBarTheme: const AppBarTheme(
          backgroundColor: nexaBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
        ),

        // Stile globale per i campi di testo (TextField / TextFormField)
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

        // Stile globale per i bottoni primari (ElevatedButton)
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: nexaBlue,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(55), // Altezza standard
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        // Stile globale per i bottoni secondari (OutlinedButton)
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
      home: const WelcomePage(), 
    );
  }
}
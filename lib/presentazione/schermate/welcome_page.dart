import 'package:flutter/material.dart';
// Importa la pagina di accesso
import 'log_in_page.dart';
// Importa la pagina di registrazione
import 'sign_up_page.dart'; 


class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Imposta lo sfondo di tutta la pagina al blu del tuo brand
      backgroundColor: const Color(0xFF1E3A8A),
      
      // SafeArea evita che l'interfaccia finisca sotto la barra di stato o la notch del telefono
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Titolo / Logo dell'app
                const Text(
                  'NEXA',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 4.0, // Dà un po' di spazio tra le lettere per un effetto più elegante
                  ),
                ),
                
                // Sottotitolo opzionale
                const SizedBox(height: 16),
                const Text(
                  'Benvenuto. Inizia da qui.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                
                const SizedBox(height: 80), // Spazio prima dei pulsanti

                // Pulsante ACCEDI 
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white, // Sfondo bianco
                    foregroundColor: const Color(0xFF1E3A8A), // Testo blu
                    minimumSize: const Size.fromHeight(55), // Pulsante alto 55 pixel e largo tutta la pagina
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), // Bordi leggermente arrotondati
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    // Naviga verso la pagina di login.
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                    
                  },
                  child: const Text('Accedi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                
                const SizedBox(height: 20), // Spazio tra i due pulsanti

                // Pulsante REGISTRATI 
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white, // Testo bianco
                    side: const BorderSide(color: Colors.white, width: 2), // Bordo bianco 
                    minimumSize: const Size.fromHeight(55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    // Naviga verso la pagina di registrazione.
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegistrazionePage(), 
                      ),
                    );
                  },
                  child: const Text('Registrati', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
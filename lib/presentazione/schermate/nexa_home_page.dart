import 'package:flutter/material.dart';
import 'package:nexa/servizi/autenticazione.dart';
import 'profilo_page.dart';
import 'welcome_page.dart';

class NexaHomePage extends StatelessWidget {


  const NexaHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Sfondo completamente blu
      backgroundColor: const Color(0xFF1E3A8A),
      
      // AppBar trasparente per far risaltare lo sfondo e ospitare il menu
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0, 
        iconTheme: const IconThemeData(color: Colors.white), // Colore dell'icona del menu
      ),
      
      // Il Drawer crea in automatico l'icona del menu in alto a sinistra
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF1E3A8A), // Intestazione del menu blu
              ),
              child: Text(
                'Menu Nexa',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            // Elemento del menu: Profilo (esempio)
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profilo'),
              onTap: () {
                Navigator.pop(context); // Chiude la tendina
                // Navigazione alla pagina profilo
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfiloPage()),
                );
              },
            ),
            // Elemento del menu: Logout
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Disconnettiti', style: TextStyle(color: Colors.red)),
              onTap: () async {
                // Esegue il logout su Firebase
                await Autenticazione().effettuaLogout();
                
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WelcomePage(), 
                    ),
                    (Route<dynamic> route) => false,
                  );
                }
              },
            ),
          ],
        ),
      ),
      
      // Scritta NEXA al centro dello schermo
      body: const Center(
        child: Text(
          'NEXA',
          style: TextStyle(
            fontSize: 64, // Scritta molto grande
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 8.0, // Spazio elegante tra le lettere
          ),
        ),
      ),
    );
  }
}
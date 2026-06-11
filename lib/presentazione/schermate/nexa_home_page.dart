import 'package:flutter/material.dart';
import 'package:nexa/servizi/autenticazione.dart';
import 'profilo_page.dart';
import 'welcome_page.dart';
import 'studio_connection_page.dart'; 

class NexaHomePage extends StatelessWidget {
  const NexaHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E3A8A),
      
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0, 
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Assegna Studio', 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
        ),
        centerTitle: true,
      ),
      
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF1E3A8A),
              ),
              child: Text(
                'Menu Nexa',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profilo'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfiloPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Disconnettiti', style: TextStyle(color: Colors.red)),
              onTap: () async {
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
      
      // Renderizza il container del form nel body
      body: const AssegnaStudioPage(),
    );
  }
}
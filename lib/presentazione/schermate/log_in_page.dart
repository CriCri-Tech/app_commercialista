import 'package:flutter/material.dart';
// Importa la pagina principale dove "atterrerà" l'utente dopo il login
import 'nexa_home_page.dart'; 
// Importa il servizio di autenticazione
import 'package:nexa/servizi/autenticazione.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controller per leggere i dati inseriti
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Variabile per gestire la rotellina di caricamento del login
  bool _isLoading = false;

  // Istanza del "motore" di autenticazione
  final Autenticazione _authServizio = Autenticazione();

  @override
  void dispose() {
    // Rilascio della memoria quando la pagina viene chiusa
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accedi', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1E3A8A),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),
            
            // Titolo
            const Text(
              'Bentornato!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3A8A),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Inserisci le tue credenziali per continuare.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 48),

            // Campo Input: Email
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // Campo Input: Password
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock_outline),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 40),

            // PULSANTE DI LOGIN (RF-01)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(55),
                backgroundColor: const Color(0xFF1E3A8A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _isLoading
                  ? null
                  : () async {
                      String email = _emailController.text.trim();
                      String password = _passwordController.text.trim();

                      // Validazione Locale dei campi di testo prima di avviare il caricamento
                      if (email.isEmpty || password.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Inserisci sia l\'email che la password.'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                        return;// Interrompe l'esecuzione della funzione se i campi non sono validi
                      }

                      setState(() {
                        _isLoading = true;
                      });

                      try {
                        // CHIAMATA AL METODO DEL RF-01
                        await _authServizio.effettuaLogin(email, password);

                        if (context.mounted) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NexaHomePage(),
                            ),
                            (Route<dynamic> route) => false,
                          );
                        }
                      } catch (errore) {
                        String messaggioErrore = errore.toString().replaceAll('Exception: ', '');
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(messaggioErrore),
                              backgroundColor: Colors.red.shade700,
                              duration: const Duration(seconds: 4),
                            ),
                          );
                        }
                      } finally {
                        if (mounted) {
                          setState(() {
                            _isLoading = false;
                          });
                        }
                      }
                    },
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Text(
                      'Accedi',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
            ),
            
            const SizedBox(height: 24),
            
            // PULSANTE RECUPERO PASSWORD (RF-03)
            TextButton(
              onPressed: () async {
                String email = _emailController.text.trim();
                
                // Controllo che l'utente abbia inserito almeno l'email
                if (email.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Inserisci la tua email nel campo sopra per recuperare la password.'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                try {
                  // CHIAMATA AL METODO DEL RF-03
                  String risultato = await _authServizio.recuperaPassword(email);
                  
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(risultato), backgroundColor: Colors.green),
                    );
                  }
                } catch (errore) {
                  String messaggioErrore = errore.toString().replaceAll('Exception: ', '');
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(messaggioErrore), backgroundColor: Colors.red.shade700),
                    );
                  }
                }
              },
              child: const Text(
                'Hai dimenticato la password?',
                style: TextStyle(color: Color(0xFF1E3A8A), fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
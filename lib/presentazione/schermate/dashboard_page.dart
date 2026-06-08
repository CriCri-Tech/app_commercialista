import 'package:flutter/material.dart';
import 'package:nexa/servizi/autenticazione.dart';

class RegistrazionePage extends StatefulWidget {
  const RegistrazionePage({super.key});

  @override
  State<RegistrazionePage> createState() => _RegistrazionePageState();
}

class _RegistrazionePageState extends State<RegistrazionePage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _cognomeController = TextEditingController();

  final Autenticazione _authServizio = Autenticazione();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nomeController.dispose();
    _cognomeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrazione Nuovo Utente'),
        backgroundColor: const Color(0xFF1E3A8A),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [

            // Campo Nome

            TextField(
              controller: _nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Campo Cognome

            TextField(
              controller: _cognomeController,
              decoration: const InputDecoration(
                labelText: 'Cognome',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),


            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Campo Password

            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),


            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: const Color(0xFF1E3A8A),
              ),
              child: const Text('Registrati', style: TextStyle(color: Colors.white)),
              onPressed: () async {
                String emailInserita = _emailController.text.trim();
                String passwordInserita = _passwordController.text.trim();
                String nomeInserito = _nomeController.text.trim();
                String cognomeInserito = _cognomeController.text.trim();


                // Validazione locale immediata
                if (emailInserita.isEmpty || passwordInserita.isEmpty || nomeInserito.isEmpty || cognomeInserito.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tutti i campi sono obbligatori.'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                try {
                  // Chiamata asincrona al servizio esterno
                  await _authServizio.effettuaRegistrazione(
                    email: emailInserita,
                    password: passwordInserita,
                    nome: nomeInserito,
                    cognome: cognomeInserito,
                    dataDiNascita: DateTime.now(), 
                  );

                  // 1. MESSAGGIO DI SUCCESSO A VIDEO
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Utente registrato con successo!'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 2),
                      ),
                    );
                    
                    
                  }
                  
                } catch (errore) {
                  // 2. MESSAGGIO DI ERRORE 
                  // Pulisco la stringa "Exception: " che Dart aggiunge automaticamente davanti all'errore
                  String messaggioPulito = errore.toString().replaceAll('Exception: ', '');

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(messaggioPulito),
                        backgroundColor: Colors.red.shade700,
                        duration: const Duration(seconds: 4),
                      ),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
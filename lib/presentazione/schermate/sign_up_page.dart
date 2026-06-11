import 'package:flutter/material.dart';
import 'nexa_home_page.dart';
import 'package:nexa/servizi/autenticazione.dart';

class RegistrazionePage extends StatefulWidget {
  const RegistrazionePage({super.key});

  @override
  State<RegistrazionePage> createState() => _RegistrazionePageState();
}

class _RegistrazionePageState extends State<RegistrazionePage> {
  final _nomeController = TextEditingController();
  final _cognomeController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confermaPasswordController = TextEditingController();

  DateTime? _dataDiNascita;
  bool _isLoading = false;
  final Autenticazione _authServizio = Autenticazione();

  @override
  void dispose() {
    _nomeController.dispose();
    _cognomeController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confermaPasswordController.dispose();
    super.dispose();
  }

  Future<void> _selezionaDataDiNascita(BuildContext context) async {
    final DateTime? dataSelezionata = await showDatePicker(
      context: context,
      initialDate: DateTime(1990, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (dataSelezionata != null && dataSelezionata != _dataDiNascita) {
      setState(() => _dataDiNascita = dataSelezionata);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrazione Nuovo Utente')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _nomeController, decoration: const InputDecoration(labelText: 'Nome*')),
            const SizedBox(height: 16),
            TextField(controller: _cognomeController, decoration: const InputDecoration(labelText: 'Cognome*')),
            const SizedBox(height: 16),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Nome Utente (Opzionale)', hintText: 'Default: nome.cognome'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email*'),
            ),
            const SizedBox(height: 16),
            TextField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(labelText: 'Password*')),
            const SizedBox(height: 16),
            TextField(controller: _confermaPasswordController, obscureText: true, decoration: const InputDecoration(labelText: 'Conferma Password*')),
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _dataDiNascita == null
                        ? 'Seleziona Data di Nascita*'
                        : 'Data: ${_dataDiNascita!.day}/${_dataDiNascita!.month}/${_dataDiNascita!.year}',
                    style: TextStyle(fontSize: 16, color: _dataDiNascita == null ? Colors.grey.shade700 : Colors.black),
                  ),
                  ElevatedButton(
                    onPressed: () => _selezionaDataDiNascita(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade200,
                      foregroundColor: Colors.black,
                      minimumSize: const Size(100, 45),
                    ),
                    child: const Text('Scegli'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            ElevatedButton(
              onPressed: _isLoading ? null : _eseguiRegistrazione,
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                    )
                  : const Text('Registrati', style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _eseguiRegistrazione() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String confermaPassword = _confermaPasswordController.text.trim();
    String nome = _nomeController.text.trim();
    String cognome = _cognomeController.text.trim();
    String username = _usernameController.text.trim();

    if (username.isEmpty && nome.isNotEmpty && cognome.isNotEmpty) {
      username = "${nome.toLowerCase()}.${cognome.toLowerCase()}";
    }

    if (email.isEmpty || password.isEmpty || confermaPassword.isEmpty || nome.isEmpty || cognome.isEmpty || _dataDiNascita == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Compilare tutti i campi obbligatori.'), backgroundColor: Colors.orange),
      );
      return;
    }

    if (password != confermaPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Le password inserite non coincidono.'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authServizio.effettuaRegistrazione(
        email: email,
        password: password,
        nome: nome,
        cognome: cognome,
        username: username,
        dataDiNascita: _dataDiNascita!,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Utente "$username" registrato con successo!'), backgroundColor: Colors.green),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const NexaHomePage()),
        );
      }
    } catch (errore) {
      String messaggioPulito = errore.toString().replaceAll('Exception: ', '');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(messaggioPulito), backgroundColor: Colors.red.shade700),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
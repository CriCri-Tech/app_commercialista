import 'package:flutter/material.dart';
import 'package:nexa/servizi/autenticazione.dart';

class ProfiloPage extends StatefulWidget {
  const ProfiloPage({super.key});

  @override
  State<ProfiloPage> createState() => _ProfiloPageState();
}

class _ProfiloPageState extends State<ProfiloPage> {
  final Autenticazione _auth = Autenticazione();
  
  final _nomeController = TextEditingController();
  final _cognomeController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _studioIdController = TextEditingController();
  
  final _vecchiaPasswordController = TextEditingController();
  final _nuovaPasswordController = TextEditingController();
  final _confermaPasswordController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _caricaDati();
  }

  Future<void> _caricaDati() async {
    try {
      final dati = await _auth.ottieniDatiUtente();
      if (dati != null) {
        _nomeController.text = dati['nome'] ?? '';
        _cognomeController.text = dati['cognome'] ?? '';
        _usernameController.text = dati['username'] ?? '';
        _emailController.text = dati['email'] ?? '';
        _studioIdController.text = dati['studioId'] ?? '';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Errore nel caricamento dati")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Modifica Profilo')),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Dati Personali", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
                const SizedBox(height: 16),
                TextField(controller: _nomeController, decoration: const InputDecoration(labelText: 'Nome')),
                const SizedBox(height: 16),
                TextField(controller: _cognomeController, decoration: const InputDecoration(labelText: 'Cognome')),
                const SizedBox(height: 16),
                TextField(controller: _usernameController, decoration: const InputDecoration(labelText: 'Nome Utente')),
                const SizedBox(height: 16),
                TextField(
                  controller: _studioIdController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: "Codice studio di appartenenza",
                    fillColor: Colors.grey.shade200,
                    filled: true
                  ),
                ),
                const SizedBox(height: 16),
                TextField(controller: _emailController, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email')),
                
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: Divider(),
                ),

                const Text("Cambia Password", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
                const SizedBox(height: 8),
                const Text("Lascia i campi vuoti se non vuoi cambiare la password.", style: TextStyle(fontSize: 14, color: Colors.grey)),
                const SizedBox(height: 16),
                
                TextField(controller: _vecchiaPasswordController, obscureText: true, decoration: const InputDecoration(labelText: 'Password Attuale')),
                const SizedBox(height: 16),
                TextField(controller: _nuovaPasswordController, obscureText: true, decoration: const InputDecoration(labelText: 'Nuova Password')),
                const SizedBox(height: 16),
                TextField(controller: _confermaPasswordController, obscureText: true, decoration: const InputDecoration(labelText: 'Conferma Nuova Password')),
                const SizedBox(height: 32),
                
                ElevatedButton(
                  onPressed: _isSaving ? null : _salvaModifiche,
                  child: _isSaving 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Salva Modifiche', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
    );
  }

  Future<void> _salvaModifiche() async {
    setState(() => _isSaving = true);
    
    try {
      await _auth.aggiornaDatiUtente(
        nome: _nomeController.text.trim(),
        cognome: _cognomeController.text.trim(),
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
      );

      String vecchiaPass = _vecchiaPasswordController.text.trim();
      String nuovaPass = _nuovaPasswordController.text.trim();
      String confermaPass = _confermaPasswordController.text.trim();

      if (vecchiaPass.isNotEmpty || nuovaPass.isNotEmpty || confermaPass.isNotEmpty) {
        if (vecchiaPass.isEmpty) throw Exception("Inserire la password attuale.");
        if (nuovaPass.length < 6) throw Exception("La nuova password deve contenere almeno 6 caratteri.");
        if (nuovaPass != confermaPass) throw Exception("Le password non coincidono.");

        await _auth.aggiornaPasswordConVerifica(vecchiaPass, nuovaPass);

        _vecchiaPasswordController.clear();
        _nuovaPasswordController.clear();
        _confermaPasswordController.clear();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profilo aggiornato con successo!"), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      String msg = e.toString().contains("requires-recent-login") 
          ? "Effettuare nuovamente il login per poter modificare l'indirizzo email." 
          : e.toString().replaceAll("Exception: ", "");
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../servizi/gestione_studio.dart'; 
import 'dashboard_page.dart'; // Importazione per il reindirizzamento post-assegnazione

class AssegnaStudioPage extends StatefulWidget {
  const AssegnaStudioPage({super.key});

  @override
  State<AssegnaStudioPage> createState() => _AssegnaStudioPageState();
}

class _AssegnaStudioPageState extends State<AssegnaStudioPage> {
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _pivaController = TextEditingController();
  
  bool _isLoading = false; 
  final GestioneStudioService _studioService = GestioneStudioService(); 

  @override
  void dispose() {
    _nomeController.dispose();
    _pivaController.dispose();
    super.dispose();
  }

  void _pulisciCampi() {
    _nomeController.clear();
    _pivaController.clear();
    _formKey.currentState?.reset();
  }

  Future<void> _salvaAssegnazione() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final nomeStudio = _nomeController.text.trim();
        final partitaIva = _pivaController.text.trim();

        final user = FirebaseAuth.instance.currentUser;
        if (user == null) throw Exception("Utente non autenticato.");

        final codiceInvito = await _studioService.creaStudio(
          nomeStudio, 
          partitaIva, 
          user.uid
        );

        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false, 
            builder: (context) => AlertDialog(
              title: Text(
                'Studio Creato!', 
                style: TextStyle(color: Theme.of(context).colorScheme.primary)
              ),
              content: Text(
                'Lo studio "$nomeStudio" è stato assegnato.\n\nFornire questo codice ai collaboratori per l\'accesso:\n\n$codiceInvito',
                style: const TextStyle(fontSize: 16),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Chiusura Dialog
                    _pulisciCampi(); // Reset form
                    
                    // Reindirizzamento alla Dashboard eliminando lo stack precedente
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const DashboardPage()),
                      (Route<dynamic> route) => false,
                    );
                  },
                  child: const Text('OK'), // Stile ereditato dal ThemeData globale
                ),
              ],
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Errore: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Contenitore principale inserito nel body della NexaHomePage
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32.0),
          topRight: Radius.circular(32.0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Identificazione Studio',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nomeController,
                enabled: !_isLoading,
                decoration: const InputDecoration(
                  labelText: 'Nome Studio / Ragione Sociale *',
                  prefixIcon: Icon(Icons.business),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Inserire la ragione sociale dello studio.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _pivaController,
                enabled: !_isLoading,
                keyboardType: TextInputType.number,
                maxLength: 11,
                decoration: const InputDecoration(
                  labelText: 'Partita IVA *',
                  prefixIcon: Icon(Icons.numbers),
                  hintText: 'Es. 01234567890',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Inserire la Partita IVA.';
                  }
                  if (value.length != 11 || !RegExp(r'^[0-9]+$').hasMatch(value)) {
                    return 'La Partita IVA deve coincidere con il formato standard a 11 cifre.';
                  }
                  return null;
                },
              ),
              const Spacer(),
              
              _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _pulisciCampi,
                          child: const Text('Pulisci', style: TextStyle(fontSize: 16)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _salvaAssegnazione,
                          child: const Text('Assegna', style: TextStyle(fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
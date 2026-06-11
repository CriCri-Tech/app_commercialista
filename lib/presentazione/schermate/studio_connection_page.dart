import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../servizi/gestione_studio.dart'; 

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

  // Svuota gli input correnti
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
              title: const Text('Studio Creato!', style: TextStyle(color: Color(0xFF1E3A8A))),
              content: Text(
                'Lo studio "$nomeStudio" è stato assegnato.\n\nFornisci questo codice ai collaboratori per farli accedere:\n\n$codiceInvito',
                style: const TextStyle(fontSize: 16),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _pulisciCampi();
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A8A)),
                  child: const Text('OK', style: TextStyle(color: Colors.white)),
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
              const Text(
                'Identificazione Studio',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A8A),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nomeController,
                enabled: !_isLoading,
                decoration: const InputDecoration(
                  labelText: 'Nome Studio / Ragione Sociale *',
                  border: OutlineInputBorder(),
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
                  border: OutlineInputBorder(),
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
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF1E3A8A)))
                : Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _pulisciCampi,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(color: Color(0xFF1E3A8A)),
                          ),
                          child: const Text(
                            'Pulisci',
                            style: TextStyle(color: Color(0xFF1E3A8A), fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _salvaAssegnazione,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E3A8A),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text(
                            'Assegna',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
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
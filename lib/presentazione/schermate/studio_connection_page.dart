import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../servizi/gestione_studio.dart'; 
import 'dashboard_page.dart'; 

class AssegnaStudioPage extends StatefulWidget {
  const AssegnaStudioPage({super.key});

  @override
  State<AssegnaStudioPage> createState() => _AssegnaStudioPageState();
}

class _AssegnaStudioPageState extends State<AssegnaStudioPage> {
  // Chiavi globali distinte per i due Form
  final _formCreaKey = GlobalKey<FormState>();
  final _formAccediKey = GlobalKey<FormState>();
  
  // Controller per la creazione dello studio
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _pivaController = TextEditingController();
  
  // Controller per l'accesso tramite codice invito
  final TextEditingController _codiceInvitoController = TextEditingController();
  
  bool _isLoading = false; 
  bool _ricordami = false; 
  final GestioneStudioService _studioService = GestioneStudioService(); 

  @override
  void initState() {
    super.initState();
    _caricaPreferenzeRicordami();
  }

  // Recupera il codice invito salvato se la spunta era attiva
  Future<void> _caricaPreferenzeRicordami() async {
    final prefs = await SharedPreferences.getInstance();
    bool attivo = prefs.getBool('ricordami_codice_studio') ?? false;
    if (attivo) {
      String? codiceSalvato = prefs.getString('codice_invito_salvato');
      if (codiceSalvato != null) {
        setState(() {
          _ricordami = true;
          _codiceInvitoController.text = codiceSalvato;
        });
      }
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _pivaController.dispose();
    _codiceInvitoController.dispose();
    super.dispose();
  }

  void _pulisciCampiCrea() {
    _nomeController.clear();
    _pivaController.clear();
    _formCreaKey.currentState?.reset();
  }

  void _pulisciCampiAccedi() {
    _codiceInvitoController.clear();
    _formAccediKey.currentState?.reset();
  }

  // Navigazione centralizzata post-successo
  void _vaiAllaDashboard() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const DashboardPage()),
      (Route<dynamic> route) => false,
    );
  }

  // LOGICA 1: Creazione nuovo studio
  Future<void> _salvaAssegnazione() async {
    if (_formCreaKey.currentState!.validate()) {
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
                    Navigator.pop(context); // Chiude il Dialog
                    _pulisciCampiCrea();
                    _vaiAllaDashboard();
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      } catch (e) {
        _mostraErrore(e.toString());
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  // LOGICA 2: Accesso a studio esistente tramite codice invito
  Future<void> _accediConCodice() async {
    if (_formAccediKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final codiceInvito = _codiceInvitoController.text.trim().toUpperCase();

        final user = FirebaseAuth.instance.currentUser;
        if (user == null) throw Exception("Utente non autenticato.");

        await _studioService.accediAStudio(codiceInvito, user.uid);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('ricordami_codice_studio', _ricordami);
        if (_ricordami) {
          await prefs.setString('codice_invito_salvato', codiceInvito);
        } else {
          await prefs.remove('codice_invito_salvato');
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Accesso allo studio effettuato con successo!'),
              backgroundColor: Colors.green,
            ),
          );
          _pulisciCampiAccedi();
          _vaiAllaDashboard();
        }
      } catch (e) {
        _mostraErrore(e.toString());
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  void _mostraErrore(String messaggio) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(messaggio),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32.0),
            topRight: Radius.circular(32.0),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 16),
            TabBar(
              labelColor: theme.colorScheme.primary,
              unselectedLabelColor: Colors.grey,
              indicatorColor: theme.colorScheme.primary,
              tabs: const [
                Tab(icon: Icon(Icons.add_business), text: "Crea Studio"),
                Tab(icon: Icon(Icons.group_add), text: "Accedi a Studio"),
              ],
            ),
            
            Expanded(
              child: TabBarView(
                children: [
                  // SCHEDA 1: Creazione Studio
                  Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Form(
                      key: _formCreaKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Anagrafica Nuovo Studio',
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
                              counterText: "",
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
                                      onPressed: _pulisciCampiCrea,
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
                  
                  // SCHEDA 2: Accedi con Codice Invito Collaboratore
                  Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Form(
                      key: _formAccediKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Unisciti come Collaboratore',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Inserisci il codice di invito alfanumerico di 6 cifre fornito dall\'amministratore del tuo studio.',
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: _codiceInvitoController,
                            enabled: !_isLoading,
                            maxLength: 6, 
                            textCapitalization: TextCapitalization.characters, 
                            decoration: const InputDecoration(
                              labelText: 'Codice Invito *',
                              prefixIcon: Icon(Icons.vpn_key),
                              hintText: 'Es. AB12XY',
                              counterText: "", 
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Inserire il codice di invito.';
                              }
                              if (value.trim().length != 6) {
                                return 'Il codice deve essere composto esattamente da 6 caratteri.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          Row(
                            children: [
                              SizedBox(
                                height: 24,
                                width: 24,
                                child: Checkbox(
                                  value: _ricordami,
                                  onChanged: (bool? nuovoValore) {
                                    setState(() {
                                      _ricordami = nuovoValore ?? false;
                                    });
                                  },
                                  activeColor: theme.colorScheme.primary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _ricordami = !_ricordami;
                                  });
                                },
                                child: const Text(
                                  'Ricorda questo codice',
                                  style: TextStyle(fontSize: 14, color: Colors.black87),
                                ),
                              ),
                            ],
                          ),
                          
                          const Spacer(),
                          _isLoading 
                            ? const Center(child: CircularProgressIndicator())
                            : Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: _pulisciCampiAccedi,
                                      child: const Text('Pulisci', style: TextStyle(fontSize: 16)),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: _accediConCodice,
                                      child: const Text('Accedi', style: TextStyle(fontSize: 16)),
                                    ),
                                  ),
                                ],
                              ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
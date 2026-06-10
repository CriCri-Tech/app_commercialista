import 'package:flutter/material.dart';
import 'nexa_home_page.dart';

// Import del servizio custom incaricato di gestire la logica di autenticazione/registrazione
import 'package:nexa/servizi/autenticazione.dart';

// Pagina di registrazione per un nuovo utente.
// Utilizza uno StatefulWidget per gestire lo stato dinamico dei moduli e della data di nascita.
class RegistrazionePage extends StatefulWidget {
  const RegistrazionePage({
    super.key
  });

  @override
  State < RegistrazionePage > createState() => _RegistrazionePageState();
}

class _RegistrazionePageState extends State < RegistrazionePage > {
  // Controller associati ai rispettivi campi di input per leggerne il testo e gestirne il focus
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _cognomeController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confermaPasswordController = TextEditingController();

  // Variabile di stato per memorizzare la data di nascita selezionata dall'utente
  DateTime ? _dataDiNascita;

  bool _isLoading = false;

  // Istanza del servizio che si occuperà della chiamata API o Firebase per la registrazione
  final Autenticazione _authServizio = Autenticazione();

  @override
  void dispose() {
    // Rilascio esplicito dei controller per evitare memory leak quando la pagina viene rimossa
    _nomeController.dispose();
    _cognomeController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confermaPasswordController.dispose();
    super.dispose();
  }

  // Mostra un DatePicker nativo per la selezione della data di nascita.
  Future < void > _selezionaDataDiNascita(BuildContext context) async {
    final DateTime ? dataSelezionata = await showDatePicker(
      context: context,
      initialDate: DateTime(1990, 1, 1), // Data di partenza suggerita all'apertura
      firstDate: DateTime(1900), // Limite inferiore selezionabile
      lastDate: DateTime.now(), // Limite superiore (non si può selezionare una data futura)
      builder: (context, child) {
        // Personalizzazione del tema del DatePicker per allinearlo alla palette dell'app
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1E3A8A), // Colore primario del picker 
            ),
          ),
          child: child!,
        );
      },
    );

    // Se l'utente ha effettivamente scelto una data e questa è diversa da quella precedente, aggiorno lo stato
    if (dataSelezionata != null && dataSelezionata != _dataDiNascita) {
      setState(() {
        _dataDiNascita = dataSelezionata;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrazione Nuovo Utente', style: TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFF1E3A8A),
            iconTheme: const IconThemeData(color: Colors.white),
      ),
      // SingleChildScrollView evita l'errore di pixel overflow quando compare la tastiera a schermo
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Campo Input: Nome
              TextField(
                controller: _nomeController,
                decoration: const InputDecoration(labelText: 'Nome', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),

                // Campo Input: Cognome
                TextField(
                  controller: _cognomeController,
                  decoration: const InputDecoration(labelText: 'Cognome', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),

                  // Campo Input: Username 
                  TextField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Nome Utente (Opzionale)',
                      hintText: 'Nome di default: nome.cognome',
                      border: OutlineInputBorder()
                    ),
                  ),
                  const SizedBox(height: 16),

                    // Campo Input: Email (con ottimizzazione del tipo di tastiera)
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),

                      // Campo Input: Password (mascherato per sicurezza)
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 16),

                        // Campo Input: Conferma Password (mascherato per sicurezza)
                        TextField(
                          controller: _confermaPasswordController,
                          obscureText: true,
                          decoration: const InputDecoration(labelText: 'Conferma Password', border: OutlineInputBorder()),
                        ),
                        const SizedBox(height: 16),

                        // Box per la selezione della Data di Nascita
                        Container(
                          padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Testo dinamico: mostra un invito alla selezione o la data formattata in base allo stato
                                Text(
                                  _dataDiNascita == null ?
                                  'Seleziona Data di Nascita' :
                                  'Data: ${_dataDiNascita!.day}/${_dataDiNascita!.month}/${_dataDiNascita!.year}',
                                  style: TextStyle(fontSize: 16, color: _dataDiNascita == null ? Colors.grey.shade700 : Colors.black),
                                ),
                                ElevatedButton(
                                  onPressed: () => _selezionaDataDiNascita(context),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade200),
                                  child: const Text('Scegli', style: TextStyle(color: Colors.black)),
                                ),
                              ],
                            ),
                        ),
                        const SizedBox(height: 32),

                          // Pulsante di Invio Modulo
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(50), // Pulsante a tutta larghezza
                                backgroundColor: const Color(0xFF1E3A8A),
                            ),

                            // DISABILITAZIONE AUTOMATICA
                            // Se _isLoading è true, passo null così il bottone non è cliccabile
                            onPressed: _isLoading ?
                            null :
                            () async {
                              // Preparazione e rimozione spazi accidentali dai campi di testo
                              String emailInserita = _emailController.text.trim();
                              String passwordInserita = _passwordController.text.trim();
                              String confermaPasswordInserita = _confermaPasswordController.text.trim();
                              String nomeInserito = _nomeController.text.trim();
                              String cognomeInserito = _cognomeController.text.trim();
                              String usernameInserito = _usernameController.text.trim();

                              if (usernameInserito.isEmpty && nomeInserito.isNotEmpty && cognomeInserito.isNotEmpty) {
                                usernameInserito = "${nomeInserito.toLowerCase()}.${cognomeInserito.toLowerCase()}";
                              }

                              // Validazione Locale dei campi di testo prima di avviare il caricamento
                              if (emailInserita.isEmpty || passwordInserita.isEmpty || confermaPasswordInserita.isEmpty || nomeInserito.isEmpty || cognomeInserito.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Tutti i campi obbligatori evono essere compilati.'), backgroundColor: Colors.orange),
                                );
                                return; // Interrompo l'esecuzione della funzione se la validazione fallisce
                              }

                              if (passwordInserita != confermaPasswordInserita) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Le password inserite non coincidono.'), backgroundColor: Colors.orange),
                                );
                                return; // Interrompo l'esecuzione della funzione se le password non coincidono
                              }

                              if (_dataDiNascita == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Per favore, seleziona la data di nascita.'), backgroundColor: Colors.orange),
                                );
                                return; // Interrompo l'esecuzione della funzione se la validazione fallisce
                              }

                              // Inizio Caricamento - disabilito il bottone 
                              // Accendo la rotellina solo se i controlli locali sono passati
                              setState(() {
                                _isLoading = true;
                              });

                              // Chiamata al Server
                              try {
                                await _authServizio.effettuaRegistrazione(
                                  email: emailInserita,
                                  password: passwordInserita,
                                  nome: nomeInserito,
                                  cognome: cognomeInserito,
                                  username: usernameInserito,
                                  dataDiNascita: _dataDiNascita!,
                                );

                                // Successo
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Utente "$usernameInserito" registrato con successo!'),
                                      backgroundColor: Colors.green,
                                      duration: const Duration(seconds: 3),
                                    ),
                                  );
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                      const NexaHomePage(),
                                    ),
                                  );
                                }
                              } catch (errore) {
                                // Errore (Es. email già in uso, password debole, problemi di connessione, ecc.)
                                debugPrint("\n\nERRORE BLOCCO REGISTRAZIONE: $errore \n\n");

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
                              } finally {
                                // Fine Caricamento 
                                // Controllo "mounted" perché se la registrazione va a buon fine, 
                                // il Navigator.pushReplacement distrugge questo widget.
                                // Fare un setState su un widget distrutto causerebbe un errore.
                                if (mounted) {
                                  setState(() {
                                    _isLoading = false;
                                  });
                                }
                              }
                            },

                            // GESTIONE DELLA UI DEL PULSANTE IN BASE ALLO STATO DI CARICAMENTO
                            child: _isLoading ?
                            const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            ): const Text(
                              'Registrati',
                              style: TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ),
            ],
          ),
      ),
    );
  }
}
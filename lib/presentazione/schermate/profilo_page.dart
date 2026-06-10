import 'package:flutter/material.dart';
import 'package:nexa/servizi/autenticazione.dart';

class ProfiloPage extends StatefulWidget {
  const ProfiloPage({super.key});

  @override
  State<ProfiloPage> createState() => _ProfiloPageState();
}

class _ProfiloPageState extends State<ProfiloPage> {
  // Porto dentro il nostro servizio di auth
  final Autenticazione _auth = Autenticazione();
  
  // Controller per le info personali
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _cognomeController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  
  // Controller dedicati esclusivamente al cambio password
  final TextEditingController _vecchiaPasswordController = TextEditingController();
  final TextEditingController _nuovaPasswordController = TextEditingController();
  final TextEditingController _confermaPasswordController = TextEditingController();

  // Parte a true così mostriamo subito la rotellina mentre peschiamo i dati
  bool _isLoading = true;
  // Serve a disabilitare il pulsante salva per evitare doppi tap ansiosi
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _caricaDati();
  }

  Future<void> _caricaDati() async {
    try {
      // Vado a leggere la mappa con i dati da Firestore
      final dati = await _auth.ottieniDatiUtente();
      
      if (dati != null) {
        // Assegno i valori ai controller. Uso ?? '' per evitare che crashi se un campo è null sul database
        _nomeController.text = dati['nome'] ?? '';
        _cognomeController.text = dati['cognome'] ?? '';
        _usernameController.text = dati['username'] ?? '';
        _emailController.text = dati['email'] ?? '';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Errore nel caricamento dati")),
      );
    } finally {
      // Che sia andata bene o male, fermo il caricamento iniziale
      setState(() => _isLoading = false);
    }
  }

  Future<void> _salvaModifiche() async {
    // Faccio partire la rotellina sul bottone
    setState(() => _isSaving = true);
    
    try {
      // Aggiorno prima i dati anagrafici di base (trim toglie gli spazi inutili all'inizio e alla fine)
      await _auth.aggiornaDatiUtente(
        nome: _nomeController.text.trim(),
        cognome: _cognomeController.text.trim(),
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
      );

      // Prendo i testi delle password per comodità
      String vecchiaPass = _vecchiaPasswordController.text.trim();
      String nuovaPass = _nuovaPasswordController.text.trim();
      String confermaPass = _confermaPasswordController.text.trim();

      //  Controllo se l'utente ha intenzione di cambiare la password (ha scritto in almeno uno dei campi)
      if (vecchiaPass.isNotEmpty || nuovaPass.isNotEmpty || confermaPass.isNotEmpty) {
        
        // Faccio un po' di controlli incrociati prima di scomodare il server
        if (vecchiaPass.isEmpty) {
          throw Exception("Devi inserire la tua password attuale per poterne scegliere una nuova.");
        }
        if (nuovaPass.length < 6) {
          throw Exception("La nuova password deve avere almeno 6 caratteri.");
        }
        if (nuovaPass != confermaPass) {
          throw Exception("La nuova password e la sua conferma non combaciano. Riprova.");
        }

        // Se passo i controlli, chiamo il metodo magico che ri-autentica e aggiorna
        await _auth.aggiornaPasswordConVerifica(vecchiaPass, nuovaPass);

        // Se è andato tutto liscio, svuoto i campi password per pulizia
        _vecchiaPasswordController.clear();
        _nuovaPasswordController.clear();
        _confermaPasswordController.clear();
      }

      // Se arrivo qui senza che il blocco catch mi abbia fermato, è un successo su tutta la linea
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profilo aggiornato con successo!"), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      // Ripulisco l'errore da all'utente
      String msg = e.toString().contains("requires-recent-login") 
          ? "Per questioni di sicurezza, devi ricaricare l'app (fare logout e login) prima di poter cambiare l'email." 
          : e.toString().replaceAll("Exception: ", "");
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red),
      );
    } finally {
      // Rendo di nuovo cliccabile il bottone
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifica Profilo', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1E3A8A),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      // Se sto caricando mostro solo la rotella al centro, altrimenti piazzo tutto il form
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Allineo i titoli a sinistra
              children: [
                // --- SEZIONE DATI PERSONALI ---
                const Text("Dati Personali", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
                const SizedBox(height: 16),
                TextField(
                  controller: _nomeController,
                  decoration: const InputDecoration(labelText: 'Nome', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _cognomeController,
                  decoration: const InputDecoration(labelText: 'Cognome', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(labelText: 'Nome Utente', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                ),
                
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: Divider(), // Una riga divisoria per fare ordine visivo
                ),

                // --- SEZIONE CAMBIO PASSWORD ---
                const Text("Cambia Password", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
                const SizedBox(height: 8),
                const Text("Lascia i campi vuoti se non vuoi cambiare la password.", style: TextStyle(fontSize: 14, color: Colors.grey)),
                const SizedBox(height: 16),
                
                TextField(
                  controller: _vecchiaPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password Attuale', 
                    border: OutlineInputBorder()
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _nuovaPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Nuova Password', 
                    border: OutlineInputBorder()
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _confermaPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Conferma Nuova Password', 
                    border: OutlineInputBorder()
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // PULSANTONE DI SALVATAGGIO
                ElevatedButton(
                  // Se sto salvando disabilito il bottone passando null
                  onPressed: _isSaving ? null : _salvaModifiche,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A8A),
                    minimumSize: const Size.fromHeight(50),
                  ),
                  // Scambio tra rotellina di caricamento e testo in base allo stato
                  child: _isSaving 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Salva Modifiche', style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ],
            ),
          ),
    );
  }
}
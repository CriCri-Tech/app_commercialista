import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../modelli/scadenza.dart';
import '../../modelli/cliente.dart';
import '../../servizi/gestione_scadenze.dart';
import '../../servizi/gestione_clienti.dart';
import '../../servizi/autenticazione.dart';
import '../../servizi/scansione_documenti.dart'; 
import '../../servizi/gestione_documenti.dart';

// Importazione dei widget dialog esterni
import 'widget/aggiungi_cliente_dialog.dart';
import 'widget/selezione_cliente_dialog.dart';
import 'widget/aggiungi_scadenza_dialog.dart'; 

import 'document_page.dart';
import 'anagrafica_clienti_page.dart'; 
import 'cerca_documenti_page.dart';
import 'profilo_page.dart';
import 'welcome_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String? _studioId;
  bool _isLoading = true;
  DateTime _dataSelezionata = DateTime.now();
  
  // Lista dei giorni del calendario e variabile per tracciare il mese visibile
  late List<DateTime> _giorniCalendario;
  String _meseCorrente = "";
  
  late ScrollController _scrollCalendario;

  final ServizioScadenze _servizioScadenze = ServizioScadenze();
  final ServizioClienti _servizioClienti = ServizioClienti();
  final DocumentService _servizioDocumenti = DocumentService();

  @override
  void initState() {
    super.initState();
    _recuperaStudioId();
    _inizializzaGiorniCalendario();
  }

  // Genera i giorni (60 precedenti, 305 successivi) e imposta la posizione di scroll iniziale su "Oggi"
  void _inizializzaGiorniCalendario() {
    final oggi = DateTime.now();
    final dataInizio = oggi.subtract(const Duration(days: 60));
    
    _giorniCalendario = List.generate(365, (index) => dataInizio.add(Duration(days: index)));
    _meseCorrente = _ottieniNomeMese(oggi.month);
    
    // 60 giorni precedenti * 68 pixel (60px larghezza + 8px margine) posiziona l'elenco esattamente su "Oggi"
    _scrollCalendario = ScrollController(initialScrollOffset: 60 * 68.0);
  }

  @override
  void dispose() {
    _scrollCalendario.dispose();
    super.dispose();
  }

  // Recupera lo studioId dell'utente autenticato
  Future<void> _recuperaStudioId() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance.collection('utenti').doc(user.uid).get();
        if (doc.exists && doc.data() != null) {
          setState(() {
            _studioId = doc.data()!['studioId'];
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint("Errore recupero studioId: $e");
    }
  }

  // Dialog di conferma Logout
  Future<void> _mostraDialogConfermaLogout(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Conferma Disconnessione'),
          content: const Text('Si desidera veramente effettuare il logout dall\'applicazione?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Annulla'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                Navigator.pop(dialogContext); 
                await Autenticazione().effettuaLogout();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const WelcomePage()),
                    (Route<dynamic> route) => false,
                  );
                }
              },
              child: const Text('Disconnettiti'),
            ),
          ],
        );
      },
    );
  }

  // ==========================================
  // METODO 1: DIALOG VISUALIZZA DETTAGLI
  // ==========================================
  void _mostraDettagliScadenza(BuildContext context, Scadenza scadenza) {
    final dataF = "${scadenza.dueDate.day.toString().padLeft(2, '0')}/${scadenza.dueDate.month.toString().padLeft(2, '0')}/${scadenza.dueDate.year}";
    final oraF = "${scadenza.dueDate.hour.toString().padLeft(2, '0')}:${scadenza.dueDate.minute.toString().padLeft(2, '0')}";

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: Color(0xFF1E3A8A)),
            SizedBox(width: 10),
            Text('Dettagli Scadenza', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(TextSpan(children: [const TextSpan(text: 'Tipo Scadenza: ', style: TextStyle(fontWeight: FontWeight.bold)), TextSpan(text: scadenza.type)])),
            const SizedBox(height: 10),
            Text.rich(TextSpan(children: [const TextSpan(text: 'Data: ', style: TextStyle(fontWeight: FontWeight.bold)), TextSpan(text: dataF)])),
            const SizedBox(height: 10),
            Text.rich(TextSpan(children: [const TextSpan(text: 'Ora: ', style: TextStyle(fontWeight: FontWeight.bold)), TextSpan(text: oraF)])),
            const SizedBox(height: 10),
            Text.rich(TextSpan(children: [const TextSpan(text: 'Stato attuale: ', style: TextStyle(fontWeight: FontWeight.bold)), TextSpan(text: scadenza.status)])),
            const SizedBox(height: 10),
            Text.rich(TextSpan(children: [const TextSpan(text: 'ID Cliente collegato: ', style: TextStyle(fontWeight: FontWeight.bold)), TextSpan(text: scadenza.clientId.isEmpty ? 'Scadenza generica di studio' : scadenza.clientId)])),
            const SizedBox(height: 10),
            Text.rich(TextSpan(children: [const TextSpan(text: 'Assegnata a (ID Operatore): ', style: TextStyle(fontWeight: FontWeight.bold)), TextSpan(text: scadenza.assignedTo.isEmpty ? 'Nessuno' : scadenza.assignedTo)])),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Chiudi', style: TextStyle(color: Color(0xFF1E3A8A), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Studio'),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF1E3A8A)),
              child: Text('Menu Nexa', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profilo'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfiloPage()));
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.document_scanner),
              title: const Text('Scansiona Documenti'),
              onTap: () async {
                Navigator.pop(context);
                try {
                  final scanner = ScansioneDocumenti();
                  final filePdf = await scanner.avviaScannerECollezionaPdf();
                  if (filePdf != null) {
                    if (!context.mounted) return;
                    final idClienteSelezionato = await mostraDialogSelezioneCliente(
                      context: context,
                      studioId: _studioId!,
                      servizioClienti: _servizioClienti,
                    );
                    if (idClienteSelezionato != null && idClienteSelezionato.isNotEmpty) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Caricamento in corso...')));
                      final urlDownload = await scanner.caricaPdfSuStorage(filePdf, idClienteSelezionato, _studioId!);
                      if (urlDownload != null && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Documento assegnato e caricato con successo!')));
                      }
                    }
                  }
                } catch (e) {
                  if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Errore durante la scansione: $e')));
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.folder_shared), 
              title: const Text('Cerca Documenti'),
              onTap: () {
                Navigator.pop(context); 
                Navigator.push(context, MaterialPageRoute(builder: (context) => CercaDocumentiPage(studioId: _studioId!, documentService: _servizioDocumenti)));
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text('Aggiungi Cliente'),
              onTap: () {
                Navigator.pop(context); 
                mostraDialogAggiungiCliente(context: context, studioId: _studioId!, servizioClienti: _servizioClienti);
              },       
            ),
            ListTile(
              leading: const Icon(Icons.person_search),
              title: const Text('Cerca e Modifica Clienti'),
              onTap: () {
                Navigator.pop(context); 
                Navigator.push(context, MaterialPageRoute(builder: (context) => AnagraficaClientiPage(studioId: _studioId!, servizioClienti: _servizioClienti)));
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Disconnettiti', style: TextStyle(color: Colors.red)),
              onTap: () => _mostraDialogConfermaLogout(context),
            ),
          ],
        ),
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _studioId == null || _studioId!.isEmpty
              ? const Center(child: Text("Nessuno studio associato a questo account."))
              : _buildDashboardContent(),
    );
  }

  Widget _buildDashboardContent() {
    String dataFormattata = "${_dataSelezionata.day.toString().padLeft(2, '0')}/${_dataSelezionata.month.toString().padLeft(2, '0')}/${_dataSelezionata.year}";

    return RefreshIndicator(
      onRefresh: _recuperaStudioId,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCalendarioAnnualeDinamico(),
            const SizedBox(height: 24),
            
            // TITOLO DINAMICO CON BOTTONE + DI AGGIUNTA
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Scadenze del $dataFormattata", 
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Color(0xFF1E3A8A), size: 28),
                  onPressed: () {
                    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
                    // Richiamo al file esterno e passaggio dell'id utente loggato obbligatorio per 'assignedTo'
                    mostraDialogAggiungiScadenza(
                      context: context,
                      studioId: _studioId!,
                      utenteId: currentUserId,
                      servizioScadenze: _servizioScadenze,
                      servizioClienti: _servizioClienti,
                    );
                  },
                  tooltip: 'Aggiungi Scadenza',
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            _buildSezioneScadenze(),
            const Padding(padding: EdgeInsets.symmetric(vertical: 16.0), child: Divider()),
            const Text("Clienti Attivi e Documenti", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
            const SizedBox(height: 12),
            _buildSezioneClienti(),
          ],
        ),
      ),
    );
  }

  // Widget Calendario con ascoltatore dello scroll per variare il mese in cima in tempo reale
  Widget _buildCalendarioAnnualeDinamico() {
    final oggi = DateTime.now();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
          child: Text(
            _meseCorrente,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A), letterSpacing: 0.5),
          ),
        ),
        SizedBox(
          height: 80,
          child: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification notification) {
              if (notification is ScrollUpdateNotification) {
                double offset = _scrollCalendario.offset;
                int indiceVisibile = (offset / 68.0).floor().clamp(0, _giorniCalendario.length - 1);
                DateTime dataCorrenteInBordo = _giorniCalendario[indiceVisibile];
                String nomeMeseRilevato = _ottieniNomeMese(dataCorrenteInBordo.month);
                
                if (_meseCorrente != nomeMeseRilevato) {
                  setState(() {
                    _meseCorrente = nomeMeseRilevato;
                  });
                }
              }
              return true;
            },
            child: ListView.builder(
              controller: _scrollCalendario,
              scrollDirection: Axis.horizontal,
              itemCount: _giorniCalendario.length,
              itemBuilder: (context, index) {
                final data = _giorniCalendario[index];
                final isOggi = data.day == oggi.day && data.month == oggi.month && data.year == oggi.year;
                final isSelezionata = data.day == _dataSelezionata.day && data.month == _dataSelezionata.month && data.year == _dataSelezionata.year;

                return GestureDetector(
                  onTap: () => setState(() => _dataSelezionata = data),
                  child: Container(
                    width: 60,
                    margin: const EdgeInsets.only(right: 8.0),
                    decoration: BoxDecoration(
                      color: isSelezionata ? const Color(0xFF1E3A8A) : (isOggi ? Colors.blue.shade100 : Colors.white),
                      border: Border.all(color: isSelezionata ? const Color(0xFF1E3A8A) : Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_ottieniGiornoSettimana(data.weekday), style: TextStyle(color: isSelezionata ? Colors.white : Colors.grey.shade600, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(data.day.toString(), style: TextStyle(color: isSelezionata ? Colors.white : Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // METODO 2: SEZIONE LISTA DELLE SCADENZE
  // ==========================================
  Widget _buildSezioneScadenze() {
    return StreamBuilder<List<Scadenza>>(
      stream: _servizioScadenze.ottieniScadenzePerData(_studioId!, _dataSelezionata),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          debugPrint("❌ ERRORE FIRESTORE SCADENZE: ${snapshot.error}");
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
              "Errore di caricamento: ${snapshot.error}",
              style: const TextStyle(color: Colors.red, fontSize: 13),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Text("Nessuna scadenza programmata per questo giorno.", style: TextStyle(color: Colors.grey)),
          );
        }

        final scadenze = snapshot.data!;

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: scadenze.length,
          itemBuilder: (context, index) {
            final scadenza = scadenze[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              elevation: 0,
              shape: RoundedRectangleBorder(side: BorderSide(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(8)),
              child: ListTile(
                leading: const Icon(Icons.event_note, color: Colors.orange),
                title: Text(scadenza.type, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("Stato: ${scadenza.status}"),
                
                // Trailing integrato con Orario e tasto info per i dettagli
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "${scadenza.dueDate.hour.toString().padLeft(2, '0')}:${scadenza.dueDate.minute.toString().padLeft(2, '0')}",
                      style: const TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                    const SizedBox(width: 6),
                    IconButton(
                      icon: const Icon(Icons.info_outline, color: Color(0xFF1E3A8A), size: 22),
                      onPressed: () => _mostraDettagliScadenza(context, scadenza), 
                      tooltip: 'Mostra dettagli scadenza',
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSezioneClienti() {
    return StreamBuilder<List<Cliente>>(
      stream: _servizioClienti.ottieniClienti(_studioId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.isEmpty) return const Text("Nessun cliente registrato nello studio.", style: TextStyle(color: Colors.grey));

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final cliente = snapshot.data![index];
            return Card(
              elevation: 0,
              shape: RoundedRectangleBorder(side: BorderSide(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(8)),
              child: ListTile(
                leading: const CircleAvatar(backgroundColor: Color(0xFF1E3A8A), child: Icon(Icons.business, color: Colors.white, size: 20)),
                title: Text(cliente.companyName, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("P.IVA: ${cliente.vatNumber}"),
                trailing: IconButton(
                  icon: const Icon(Icons.folder_shared, color: Color(0xFF1E3A8A)),
                  onPressed: () {
                    if (cliente.id != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DocumentiClientePage(
                            idCliente: cliente.id!,
                            nomeCliente: cliente.companyName,
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Impossibile aprire i documenti: ID cliente mancante.'))
                      );
                    }
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _ottieniGiornoSettimana(int weekday) {
    const giorni = ['Lun', 'Mar', 'Mer', 'Gio', 'Ven', 'Sab', 'Dom'];
    return giorni[weekday - 1];
  }

  String _ottieniNomeMese(int month) {
    const mesi = [
      'Gennaio', 'Febbraio', 'Marzo', 'Aprile', 'Maggio', 'Giugno',
      'Luglio', 'Agosto', 'Settembre', 'Ottobre', 'Novembre', 'Dicembre'
    ];
    return mesi[month - 1];
  }
}
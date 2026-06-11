import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../modelli/scadenza.dart';
import '../../modelli/cliente.dart';
import '../../servizi/gestione_scadenze.dart';
import '../../servizi/gestione_clienti.dart';
import '../../servizi/autenticazione.dart';

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

  final ServizioScadenze _servizioScadenze = ServizioScadenze();
  final ServizioClienti _servizioClienti = ServizioClienti();

  @override
  void initState() {
    super.initState();
    _recuperaStudioId();
  }

  // Inizializzazione dati e recupero identificativo studio
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

  // Interfaccia di conferma per l'azione di logout
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
              decoration: BoxDecoration(
                color: Color(0xFF1E3A8A),
              ),
              child: Text(
                'Menu Nexa',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profilo'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfiloPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.document_scanner),
              title: const Text('Scansiona Documenti'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.search),
              title: const Text('Cerca Documenti'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_search),
              title: const Text('Cerca Clienti'),
              onTap: () {
                Navigator.pop(context);
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
    return RefreshIndicator(
      onRefresh: _recuperaStudioId,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCalendarioSettimanale(),
            const SizedBox(height: 24),
            const Text("Scadenze Imminenti", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
            const SizedBox(height: 12),
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

  Widget _buildCalendarioSettimanale() {
    final oggi = DateTime.now();
    final giorni = List.generate(7, (index) => oggi.subtract(Duration(days: 3 - index)));

    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: giorni.length,
        itemBuilder: (context, index) {
          final data = giorni[index];
          final isOggi = data.day == oggi.day && data.month == oggi.month && data.year == oggi.year;
          final isSelezionata = data.day == _dataSelezionata.day && data.month == _dataSelezionata.month;

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
    );
  }

  Widget _buildSezioneScadenze() {
    return StreamBuilder<List<Scadenza>>(
      stream: _servizioScadenze.ottieniScadenzeOdierne(_studioId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.isEmpty) return const Text("Nessuna scadenza in programma per oggi.", style: TextStyle(color: Colors.grey));

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final scadenza = snapshot.data![index];
            return Card(
              elevation: 0,
              shape: RoundedRectangleBorder(side: BorderSide(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(8)),
              child: ListTile(
                leading: const Icon(Icons.event_note, color: Colors.orange),
                title: Text(scadenza.type, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("Stato: ${scadenza.status}"),
                trailing: Text("${scadenza.dueDate.hour}:${scadenza.dueDate.minute.toString().padLeft(2, '0')}"),
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
                  onPressed: () {},
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
}
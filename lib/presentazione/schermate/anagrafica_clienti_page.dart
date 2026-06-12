import 'package:flutter/material.dart';
import '../../modelli/cliente.dart';
import '../../servizi/gestione_clienti.dart'; 
import 'widget/dialog_page.dart'; 

class AnagraficaClientiPage extends StatefulWidget {
  final String studioId;
  final ServizioClienti servizioClienti;

  const AnagraficaClientiPage({
    super.key,
    required this.studioId,
    required this.servizioClienti,
  });

  @override
  State<AnagraficaClientiPage> createState() => _AnagraficaClientiPageState();
}

class _AnagraficaClientiPageState extends State<AnagraficaClientiPage> {
  final TextEditingController _searchController = TextEditingController();
  String _queryRicerca = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Funzione di supporto per confermare l'eliminazione
  Future<void> _confermaEliminazione(BuildContext context, Cliente cliente) async {
    final conferma = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Elimina Cliente'),
        content: Text('Sei sicuro di voler eliminare ${cliente.companyName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Elimina', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (conferma == true && mounted) {
      try {
        await widget.servizioClienti.eliminaCliente(cliente.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cliente eliminato con successo')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Errore durante l\'eliminazione: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anagrafica Clienti'),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Barra di ricerca superiore
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cerca cliente per nome azienda...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF1E3A8A)),
                suffixIcon: _queryRicerca.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _queryRicerca = "");
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF1E3A8A), width: 2),
                ),
              ),
              onChanged: (valore) {
                setState(() {
                  _queryRicerca = valore.trim();
                });
              },
            ),
          ),
          
          // Lista Clienti filtrata o totale in Real-Time
          Expanded(
            child: StreamBuilder<List<Cliente>>(
              stream: _queryRicerca.isEmpty
                  ? widget.servizioClienti.ottieniClienti(widget.studioId)
                  : widget.servizioClienti.ricercaClienti(_queryRicerca, widget.studioId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'Nessun cliente trovato.',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  );
                }

                final clienti = snapshot.data!;

                return ListView.builder(
                  itemCount: clienti.length,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemBuilder: (context, index) {
                    final cliente = clienti[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFF1E3A8A),
                          child: Icon(Icons.business, color: Colors.white),
                        ),
                        title: Text(
                          cliente.companyName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('P.IVA: ${cliente.vatNumber}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Tasto Modifica
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.amber),
                              onPressed: () {
                                // Qui puoi aprire il tuo dialog di modifica passando il cliente
                                // Esempio: mostraDialogModificaCliente(context, cliente);
                              },
                            ),
                            // Tasto Elimina
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _confermaEliminazione(context, cliente),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      // Bottone rapido per aggiungere un cliente direttamente da questa schermata
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1E3A8A),
        child: const Icon(Icons.person_add, color: Colors.white),
        onPressed: () {
          // Riutilizza la funzione globale che hai già nel progetto
          mostraDialogAggiungiCliente(
            context: context,
            studioId: widget.studioId,
            servizioClienti: widget.servizioClienti,
          );
        },
      ),
    );
  }
}
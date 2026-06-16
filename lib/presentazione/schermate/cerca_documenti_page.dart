import 'package:flutter/material.dart';
import '../../modelli/documento.dart'; 
import '../../servizi/gestione_documenti.dart'; 

class CercaDocumentiPage extends StatefulWidget {
  final String studioId;
  final DocumentService documentService;

  const CercaDocumentiPage({
    super.key,
    required this.studioId,
    required this.documentService,
  });

  @override
  State<CercaDocumentiPage> createState() => _CercaDocumentiPageState();
}

class _CercaDocumentiPageState extends State<CercaDocumentiPage> {
  final TextEditingController _searchController = TextEditingController();
  String _queryRicerca = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Funzione di supporto per confermare ed eliminare il file fisico + metadati
  Future<void> _confermaEliminazione(BuildContext context, Documento documento) async {
    final conferma = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Elimina Documento'),
        content: Text('Sei sicuro di voler eliminare definitivamente il file "${documento.fileName}" associato a ${documento.nomeCliente}?'),
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
        // Richiamo al metodo del tuo DocumentService per cancellare sia da Storage che da Firestore
        await widget.documentService.eliminaDocumento(documento.id, documento.storagePath);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Documento eliminato con successo')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Errore durante l\'eliminazione: ${e.toString().replaceAll("Exception: ", "")}')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Archivio Documenti'),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Barra di ricerca superiore per Azienda Cliente
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cerca documento per nome azienda cliente...',
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
          
          // Lista dei Documenti filtrata in Real-Time tramite StreamBuilder
          Expanded(
            child: StreamBuilder<List<Documento>>(
              // Passiamo la query (anche vuota) al tuo metodo ottimizzato con il carattere speciale \uf8ff
              stream: widget.documentService.ricercaDocumentiPerAzienda(_queryRicerca, widget.studioId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text("Errore di caricamento: ${snapshot.error}"),
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'Nessun documento trovato.',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  );
                }

                final documenti = snapshot.data!;

                return ListView.builder(
                  itemCount: documenti.length,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemBuilder: (context, index) {
                    final documento = documenti[index];
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
                          child: Icon(Icons.description, color: Colors.white),
                        ),
                        title: Text(
                          documento.fileName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text('Cliente: ${documento.nomeCliente}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Icona per aprire o scaricare il file tramite il suo URL remoto
                            IconButton(
                              icon: const Icon(Icons.open_in_new, color: Colors.blue),
                              onPressed: () {
                                debugPrint("Apertura URL: ${documento.fileUrl}");
                              },
                            ),
                            // Icona per eliminare file e metadati (collegata alla funzione sopra)
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _confermaEliminazione(context, documento),
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
    );
  }
}
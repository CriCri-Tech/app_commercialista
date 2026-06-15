import 'package:flutter/material.dart';
import '../../../servizi/gestione_clienti.dart';
import '../../../modelli/cliente.dart'; 

Future<String?> mostraDialogSelezioneCliente({
  required BuildContext context,
  required String studioId,
  required ServizioClienti servizioClienti,
}) async {
  return showDialog<String>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text('Seleziona Cliente'),
        content: SizedBox(
          width: double.maxFinite,
          child: StreamBuilder<List<Cliente>>(
            stream: servizioClienti.ottieniClienti(studioId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  )
                );
              }
              
              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text("Errore durante il caricamento dei dati: ${snapshot.error}"),
                  )
                );
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text("Nessun cliente disponibile al momento."),
                  ),
                );
              }

              final clienti = snapshot.data!;
              
              return ListView.builder(
                shrinkWrap: true,
                itemCount: clienti.length,
                itemBuilder: (context, index) {
                  final cliente = clienti[index];
                  return ListTile(
                    leading: const Icon(Icons.business, color: Color(0xFF1E3A8A)),
                    title: Text(cliente.companyName),
                    subtitle: Text('P.IVA: ${cliente.vatNumber}'),
                    onTap: () {
                      Navigator.pop(dialogContext, cliente.id!); 
                    },
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, null),
            child: const Text('Annulla'),
          ),
        ],
      );
    },
  );
}
import 'package:flutter/material.dart';
import '../../../modelli/scadenza.dart';
import '../../../servizi/gestione_scadenze.dart';

// Mostra un dialog di conferma per eliminare una scadenza.
Future<void> mostraDialogConfermaEliminazione({
  required BuildContext context,
  required Scadenza scadenza,
  required ServizioScadenze servizioScadenze,
}) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 10),
            Text('Elimina Scadenza'),
          ],
        ),
        content: Text(
          'Sei sicuro di voler eliminare la scadenza "${scadenza.type}"?\n\nQuesta operazione non è reversibile.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annulla', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(dialogContext); // Chiude il dialog preventivamente
              
              try {
                if (scadenza.id != null) {
                  await servizioScadenze.eliminaScadenza(scadenza.id!); 
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Scadenza eliminata con successo.'), 
                        backgroundColor: Colors.green
                      ),
                    );
                  }
                } else {
                  throw Exception("L'ID della scadenza è nullo.");
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Errore durante l\'eliminazione: $e'), 
                      backgroundColor: Colors.red
                    ),
                  );
                }
              }
            },
            child: const Text('Elimina'),
          ),
        ],
      );
    },
  );
}
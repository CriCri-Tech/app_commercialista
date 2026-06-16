import 'package:flutter/material.dart';
import '../../../modelli/scadenza.dart';
import '../../../servizi/gestione_scadenze.dart';

/// Mostra una finestra di dialogo globale per confermare il completamento di una scadenza.
Future<void> mostraDialogConfermaCompletamento({
  required BuildContext context,
  required Scadenza scadenza,
  required ServizioScadenze servizioScadenze,
}) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // Impedisce la chiusura toccando fuori dal pop-up
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.green),
            SizedBox(width: 10),
            Text(
              'Conferma Completamento', 
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        content: Text('Si desidera veramente contrassegnare la scadenza "${scadenza.type}" come completata?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annulla', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              // Chiude immediatamente la finestra di dialogo usando il contesto del dialog
              Navigator.pop(dialogContext); 
              
              try {
                // Esegue l'aggiornamento sul database dello studio
                await servizioScadenze.segnaComeCompletata(scadenza.id!);
                
                // Mostra il feedback visivo all'utente se il contesto è ancora valido
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Scadenza contrassegnata come completata.')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Errore nel completamento: $e')),
                  );
                }
              }
            },
            child: const Text('Conferma'),
          ),
        ],
      );
    },
  );
}
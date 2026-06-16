import 'package:flutter/material.dart';
import '../../../modelli/scadenza.dart'; 
import '../../../servizi/gestione_scadenze.dart';
import '../../../servizi/gestione_clienti.dart';
import 'selezione_cliente_dialog.dart'; 

Future<void> mostraDialogAggiungiScadenza({
  required BuildContext context,
  required String studioId,
  required String utenteId, // <-- AGGIUNTO
  required ServizioScadenze servizioScadenze,
  required ServizioClienti servizioClienti,
}) async {
  final formKey = GlobalKey<FormState>();
  final tipoController = TextEditingController();
  
  DateTime dataScelta = DateTime.now();
  TimeOfDay oraScelta = TimeOfDay.now();
  String? idClienteScadenza;

  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      return StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text('Aggiungi Nuova Scadenza'),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: tipoController,
                      decoration: const InputDecoration(
                        labelText: 'Titolo / Tipo Scadenza *',
                        prefixIcon: Icon(Icons.event_note),
                        hintText: 'Es. Deposito Bilancio',
                      ),
                      validator: (value) => (value == null || value.trim().isEmpty) ? 'Inserire il titolo' : null,
                    ),
                    const SizedBox(height: 16),
                    
                    Card(
                      elevation: 0,
                      color: Colors.grey.shade100,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      child: ListTile(
                        leading: Icon(
                          idClienteScadenza == null ? Icons.person_add_outlined : Icons.person, 
                          color: const Color(0xFF1E3A8A)
                        ),
                        title: Text(
                          idClienteScadenza == null ? 'Associa a un cliente' : 'Cliente collegato correttamente',
                          style: TextStyle(
                            fontSize: 14, 
                            fontWeight: idClienteScadenza == null ? FontWeight.normal : FontWeight.bold
                          ),
                        ),
                        subtitle: idClienteScadenza == null 
                            ? const Text('Scadenza generica di studio', style: TextStyle(fontSize: 12))
                            : Text('ID: $idClienteScadenza', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        trailing: idClienteScadenza != null
                            ? IconButton(
                                icon: const Icon(Icons.clear, color: Colors.red, size: 20),
                                onPressed: () {
                                  setStateDialog(() => idClienteScadenza = null);
                                },
                              )
                            : const Icon(Icons.arrow_forward_ios, size: 14),
                        onTap: () async {
                          final idSelezionato = await mostraDialogSelezioneCliente(
                            context: context,
                            studioId: studioId,
                            servizioClienti: servizioClienti,
                          );
                          if (idSelezionato != null) {
                            setStateDialog(() => idClienteScadenza = idSelezionato);
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.calendar_today, size: 16),
                            label: Text("${dataScelta.day}/${dataScelta.month}/${dataScelta.year}"),
                            onPressed: () async {
                              final dataSelezionata = await showDatePicker(
                                context: context,
                                initialDate: dataScelta,
                                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                                lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                              );
                              if (dataSelezionata != null) {
                                setStateDialog(() => dataScelta = dataSelezionata);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.access_time, size: 16),
                            label: Text(oraScelta.format(context)),
                            onPressed: () async {
                              final oraSelezionata = await showTimePicker(
                                context: context,
                                initialTime: oraScelta,
                              );
                              if (oraSelezionata != null) {
                                setStateDialog(() => oraScelta = oraSelezionata);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Annulla'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A8A), 
                  foregroundColor: Colors.white
                ),
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    try {
                      final finalDateTime = DateTime(
                        dataScelta.year,
                        dataScelta.month,
                        dataScelta.day,
                        oraScelta.hour,
                        oraScelta.minute,
                      );

                      final nuovaScadenza = Scadenza(
                        id: null, // Si genera in automatico in Firestore
                        studioId: studioId,
                        clientId: idClienteScadenza ?? '', 
                        type: tipoController.text.trim(),
                        status: 'In attesa', 
                        dueDate: finalDateTime,
                        assignedTo: utenteId, // <-- AGGIUNTO: assegna all'ID loggato
                      );

                      await servizioScadenze.aggiungiScadenza(nuovaScadenza);

                      if (context.mounted) {
                        Navigator.pop(dialogContext); 
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Scadenza salvata correttamente!'), 
                            backgroundColor: Colors.green
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Errore durante il salvataggio: $e'), 
                            backgroundColor: Colors.red
                          ),
                        );
                      }
                    }
                  }
                },
                child: const Text('Salva'),
              ),
            ],
          );
        }
      );
    },
  );
}
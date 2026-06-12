import 'package:flutter/material.dart';

import '../../../servizi/gestione_clienti.dart';
import '../../../modelli/cliente.dart'; 

Future<void> mostraDialogAggiungiCliente({
  required BuildContext context,
  required String studioId,
  required ServizioClienti servizioClienti,
}) async {
  // Inizializzazione dei controller per l'acquisizione dei dati anagrafici
  final nomeController = TextEditingController();
  final nomeECognomeController = TextEditingController();
  final pIvaController = TextEditingController();
  final taxCodeController = TextEditingController();
  final pecController = TextEditingController();
  final sdiCodeController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();
  
  final formKey = GlobalKey<FormState>();

  return showDialog(
    context: context,
    barrierDismissible: false, 
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text('Aggiungi Nuovo Cliente'),
        // L'implementazione di SingleChildScrollView garantisce la corretta navigazione del modulo anche su schermi ridotti
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Acquisizione della Ragione Sociale
                TextFormField(
                  controller: nomeController,
                  decoration: const InputDecoration(
                    labelText: 'Ragione Sociale',
                    prefixIcon: Icon(Icons.business),
                  ),
                  validator: (valore) => (valore == null || valore.trim().isEmpty) ? 'Campo obbligatorio' : null,
                ),
                const SizedBox(height: 10),

                // Acquisizione del Nome e Cognome
                TextFormField(
                  controller: nomeECognomeController,
                  decoration: const InputDecoration(
                    labelText: 'Nome e Cognome*',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (valore) => (valore == null || valore.trim().isEmpty) ? 'Campo obbligatorio' : null,
                ),
                const SizedBox(height: 10),

                // Acquisizione della Partita IVA (Controllo 11 caratteri numerici)
                TextFormField(
                  controller: pIvaController,
                  decoration: const InputDecoration(
                    labelText: 'Partita IVA*',
                    prefixIcon: Icon(Icons.numbers),
                  ),
                  validator: (valore) {
                    if (valore == null || valore.trim().isEmpty) return 'Campo obbligatorio';
                    final pIva = valore.trim();
                    if (pIva.length != 11) return 'La Partita IVA deve avere 11 cifre';
                    if (!RegExp(r'^[0-9]+$').hasMatch(pIva)) return 'Formato non valido (solo numeri)';
                    return null;
                  },
                ),
                const SizedBox(height: 10),

                // Acquisizione del Codice Fiscale (Controllo 11 o 16 caratteri)
                TextFormField(
                  controller: taxCodeController,
                  decoration: const InputDecoration(
                    labelText: 'Codice Fiscale',
                    prefixIcon: Icon(Icons.badge),
                  ),
                  validator: (valore) {
                    if (valore != null && valore.trim().isNotEmpty) {
                      final cf = valore.trim();
                      if (cf.length != 11 && cf.length != 16) {
                        return 'Il C.F. deve avere 11 o 16 caratteri';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),

                // Acquisizione dell'Indirizzo PEC (Formato Email)
                TextFormField(
                  controller: pecController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Indirizzo PEC',
                    prefixIcon: Icon(Icons.mark_email_read),
                  ),
                  validator: (valore) {
                    if (valore != null && valore.trim().isNotEmpty) {
                      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                      if (!emailRegex.hasMatch(valore.trim())) {
                        return 'Inserisci un indirizzo PEC valido';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),

                // Acquisizione del Codice Destinatario (SDI)
                TextFormField(
                  controller: sdiCodeController,
                  decoration: const InputDecoration(
                    labelText: 'Codice Destinatario (SDI)',
                    prefixIcon: Icon(Icons.confirmation_number),
                  ),
                ),
                const SizedBox(height: 10),

                // Acquisizione del Recapito Telefonico (Lunghezza e formattazione base)
                TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Telefono',
                    prefixIcon: Icon(Icons.phone),
                  ),
                  validator: (valore) {
                    if (valore != null && valore.trim().isNotEmpty) {
                      final telefono = valore.trim();
                      if (telefono.length < 8) return 'Numero troppo corto';
                      // Ammette numeri, spazi e il prefisso +
                      if (!RegExp(r'^[+0-9\s]+$').hasMatch(telefono)) {
                        return 'Formato non valido';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),

                // Acquisizione dell'Indirizzo Email Standard (Formato Email)
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator: (valore) {
                    if (valore != null && valore.trim().isNotEmpty) {
                      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                      if (!emailRegex.hasMatch(valore.trim())) {
                        return 'Inserisci un indirizzo email valido';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),

                // Acquisizione dell'Indirizzo e della Città
                TextFormField(
                  controller: addressController,
                  decoration: const InputDecoration(
                    labelText: 'Indirizzo e Città',
                    prefixIcon: Icon(Icons.location_on),
                  ),
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
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                try {
                  // Istanziazione del modello Cliente mediante i valori forniti dall'utente
                  final nuovoCliente = Cliente(
                    id: null, // L'identificativo univoco verrà generato automaticamente da Firestore
                    studioId: studioId,
                    companyName: nomeController.text.trim(),
                    nomeECognome: nomeECognomeController.text.trim(),
                    vatNumber: pIvaController.text.trim(),
                    taxCode: taxCodeController.text.trim(),
                    pec: pecController.text.trim(),
                    sdiCode: sdiCodeController.text.trim(),
                    phone: phoneController.text.trim(),
                    email: emailController.text.trim(),
                    address: addressController.text.trim(),
                    createdAt: DateTime.now(), // Registrazione della marca temporale corrente
                  );

                  await servizioClienti.aggiungiCliente(nuovoCliente);

                  if (context.mounted) {
                    Navigator.pop(dialogContext); // Chiusura della finestra di dialogo
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Cliente aggiunto con successo!'))
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Si è verificato un errore durante il salvataggio: $e'))
                    );
                  }
                }
              }
            },
            child: const Text('Salva'),
          ),
        ],
      );
    },
  );
}

// Presenta una finestra di dialogo per consentire la selezione di un cliente.
// Restituisce l'identificativo del cliente scelto, oppure null in caso di annullamento dell'operazione.

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
              
              // Gestione dello stato di attesa durante il recupero iniziale delle informazioni
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  )
                );
              }
              
              // Intercettazione e notifica di eventuali anomalie di comunicazione con il database
              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text("Errore durante il caricamento dei dati: ${snapshot.error}"),
                  )
                );
              }

              // Verifica dell'effettiva disponibilità di dati, accertando che il flusso informativo sia stabile
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text("Nessun cliente disponibile al momento."),
                  ),
                );
              }

              // Generazione della lista dei clienti a seguito dell'esito positivo dei controlli preliminari
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
                      // Conclude la selezione restituendo l'identificativo univoco del cliente designato
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
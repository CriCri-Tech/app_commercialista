import 'package:flutter/material.dart';
import '../../../servizi/gestione_clienti.dart';
import '../../../modelli/cliente.dart'; 

Future<void> mostraDialogAggiungiCliente({
  required BuildContext context,
  required String studioId,
  required ServizioClienti servizioClienti,
}) async {
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
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nomeController,
                  decoration: const InputDecoration(
                    labelText: 'Ragione Sociale',
                    prefixIcon: Icon(Icons.business),
                  ),
                  validator: (valore) => (valore == null || valore.trim().isEmpty) ? 'Campo obbligatorio' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: nomeECognomeController,
                  decoration: const InputDecoration(
                    labelText: 'Nome e Cognome*',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (valore) => (valore == null || valore.trim().isEmpty) ? 'Campo obbligatorio' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: pIvaController,
                  maxLength: 11,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Partita IVA*',
                    prefixIcon: Icon(Icons.numbers),
                    counterText: "",
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
                TextFormField(
                  controller: taxCodeController,
                  maxLength: 16,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    labelText: 'Codice Fiscale',
                    prefixIcon: Icon(Icons.badge),
                    counterText: "",
                  ),
                  validator: (valore) {
                    if (valore != null && valore.trim().isNotEmpty && valore.trim().length != 16) {
                      return 'Il C.F. deve avere 16 caratteri';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
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
                TextFormField(
                  controller: sdiCodeController,
                  maxLength: 7,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    labelText: 'Codice Destinatario (SDI)',
                    prefixIcon: Icon(Icons.confirmation_number),
                    counterText: "",
                  ),
                  validator: (valore) {
                    if (valore != null && valore.trim().isNotEmpty && valore.trim().length != 7) {
                      return 'Il codice SDI deve essere di 7 caratteri';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: phoneController,
                  maxLength: 10,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Telefono',
                    prefixIcon: Icon(Icons.phone),
                    counterText: "",
                  ),
                  validator: (valore) {
                    if (valore != null && valore.trim().isNotEmpty) {
                      final telefono = valore.trim();
                      if (telefono.length < 8) return 'Numero troppo corto';
                      if (!RegExp(r'^[+0-9\s]+$').hasMatch(telefono)) {
                        return 'Formato non valido';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
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
                  final nuovoCliente = Cliente(
                    id: null, 
                    studioId: studioId,
                    companyName: nomeController.text.trim(),
                    nomeECognome: nomeECognomeController.text.trim(),
                    vatNumber: pIvaController.text.trim(),
                    taxCode: taxCodeController.text.trim().toUpperCase(),
                    pec: pecController.text.trim(),
                    sdiCode: sdiCodeController.text.trim().toUpperCase(),
                    phone: phoneController.text.trim(),
                    email: emailController.text.trim(),
                    address: addressController.text.trim(),
                    createdAt: DateTime.now(), 
                  );

                  await servizioClienti.aggiungiCliente(nuovoCliente);

                  if (context.mounted) {
                    Navigator.pop(dialogContext); 
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
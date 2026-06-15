import 'package:flutter/material.dart';
import '../../../servizi/gestione_clienti.dart';
import '../../../modelli/cliente.dart'; 

Future<void> mostraDialogModificaCliente({
  required BuildContext context,
  required Cliente cliente,
  required ServizioClienti servizioClienti,
}) async {
  final nomeController = TextEditingController(text: cliente.companyName);
  final nomeECognomeController = TextEditingController(text: cliente.nomeECognome);
  final pIvaController = TextEditingController(text: cliente.vatNumber);
  final taxCodeController = TextEditingController(text: cliente.taxCode);
  final pecController = TextEditingController(text: cliente.pec);
  final sdiCodeController = TextEditingController(text: cliente.sdiCode);
  final phoneController = TextEditingController(text: cliente.phone);
  final emailController = TextEditingController(text: cliente.email);
  final addressController = TextEditingController(text: cliente.address);
  
  final formKey = GlobalKey<FormState>();

  return showDialog(
    context: context,
    barrierDismissible: false, 
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text('Modifica Cliente'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nomeController,
                  decoration: const InputDecoration(labelText: 'Ragione Sociale', prefixIcon: Icon(Icons.business)),
                  validator: (valore) => (valore == null || valore.trim().isEmpty) ? 'Campo obbligatorio' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: nomeECognomeController,
                  decoration: const InputDecoration(labelText: 'Nome e Cognome*', prefixIcon: Icon(Icons.person)),
                  validator: (valore) => (valore == null || valore.trim().isEmpty) ? 'Campo obbligatorio' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: pIvaController,
                  maxLength: 11,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Partita IVA*', prefixIcon: Icon(Icons.numbers), counterText: ""),
                  validator: (valore) {
                    if (valore == null || valore.trim().isEmpty) return 'Campo obbligatorio';
                    final pIva = valore.trim();
                    if (pIva.length != 11) return 'La Partita IVA deve avere 11 cifre';
                    if (!RegExp(r'^[0-9]+$').hasMatch(pIva)) return 'Formato non valido';
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: taxCodeController,
                  maxLength: 16,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(labelText: 'Codice Fiscale', prefixIcon: Icon(Icons.badge), counterText: ""),
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
                  decoration: const InputDecoration(labelText: 'Indirizzo PEC', prefixIcon: Icon(Icons.mark_email_read)),
                  validator: (valore) {
                    if (valore != null && valore.trim().isNotEmpty) {
                      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                      if (!emailRegex.hasMatch(valore.trim())) return 'Inserisci una PEC valida';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: sdiCodeController,
                  maxLength: 7,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(labelText: 'Codice Destinatario (SDI)', prefixIcon: Icon(Icons.confirmation_number), counterText: ""),
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
                  decoration: const InputDecoration(labelText: 'Telefono', prefixIcon: Icon(Icons.phone), counterText: ""),
                  validator: (valore) {
                    if (valore != null && valore.trim().isNotEmpty) {
                      if (valore.trim().length < 8) return 'Numero troppo corto';
                      if (!RegExp(r'^[+0-9\s]+$').hasMatch(valore.trim())) return 'Formato non valido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email)),
                  validator: (valore) {
                    if (valore != null && valore.trim().isNotEmpty) {
                      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                      if (!emailRegex.hasMatch(valore.trim())) return 'Inserisci un\'email valida';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: 'Indirizzo e Città', prefixIcon: Icon(Icons.location_on)),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Annulla')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A8A), foregroundColor: Colors.white),
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                try {
                  final clienteAggiornato = Cliente(
                    id: cliente.id, 
                    studioId: cliente.studioId,
                    companyName: nomeController.text.trim(),
                    nomeECognome: nomeECognomeController.text.trim(),
                    vatNumber: pIvaController.text.trim(),
                    taxCode: taxCodeController.text.trim().toUpperCase(),
                    pec: pecController.text.trim(),
                    sdiCode: sdiCodeController.text.trim().toUpperCase(),
                    phone: phoneController.text.trim(),
                    email: emailController.text.trim(),
                    address: addressController.text.trim(),
                    createdAt: cliente.createdAt, 
                  );

                  await servizioClienti.modificaCliente(clienteAggiornato);

                  if (context.mounted) {
                    Navigator.pop(dialogContext); 
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cliente aggiornato con successo!')));
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Errore durante la modifica: $e')));
                  }
                }
              }
            },
            child: const Text('Aggiorna'),
          ),
        ],
      );
    },
  );
}
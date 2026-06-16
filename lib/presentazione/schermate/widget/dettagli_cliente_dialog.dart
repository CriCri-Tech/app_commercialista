import 'package:flutter/material.dart';
import '../../../modelli/cliente.dart';

// Mostra una finestra di dialogo contenente TUTTE le informazioni anagrafiche del cliente.
Future<void> mostraDialogDettagliCliente({
  required BuildContext context,
  required Cliente cliente,
}) async {
  // Formattazione della data di creazione in formato GG/MM/AAAA
  final dataCreazione = "${cliente.createdAt.day.toString().padLeft(2, '0')}/${cliente.createdAt.month.toString().padLeft(2, '0')}/${cliente.createdAt.year}";

  return showDialog<void>(
    context: context,
    barrierDismissible: true, 
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.business, color: Color(0xFF1E3A8A), size: 28),
            SizedBox(width: 12),
            Text(
              'Anagrafica Completa',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF1E3A8A)),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSezioneTitolo('DATI GENERALI'),
                _buildRigaDettaglio('Ragione Sociale / Azienda:', cliente.companyName),
                _buildRigaDettaglio('Referente (Nome e Cognome):', cliente.nomeECognome),
                _buildRigaDettaglio('Partita IVA:', cliente.vatNumber),
                _buildRigaDettaglio('Codice Fiscale:', cliente.taxCode),
                
                const SizedBox(height: 12),
                _buildSezioneTitolo('CONTATTI'),
                _buildRigaDettaglio('Email:', cliente.email),
                _buildRigaDettaglio('PEC:', cliente.pec),
                _buildRigaDettaglio('Telefono:', cliente.phone),

                const SizedBox(height: 12),
                _buildSezioneTitolo('FATTURAZIONE E SEDE'),
                _buildRigaDettaglio('Indirizzo Sede:', cliente.address),
                _buildRigaDettaglio('Codice Univoco (SDI):', cliente.sdiCode),

                const SizedBox(height: 12),
                _buildSezioneTitolo('INFO DI SISTEMA'),
                _buildRigaDettaglio('ID Cliente (Firestore):', cliente.id ?? 'Nessun ID generato'),
                _buildRigaDettaglio('ID Studio Associato:', cliente.studioId),
                _buildRigaDettaglio('Data Registrazione:', dataCreazione),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'Chiudi',
              style: TextStyle(color: Color(0xFF1E3A8A), fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      );
    },
  );
}

// Widget helper per dividere la grafica in blocchi logici eleganti
Widget _buildSezioneTitolo(String titolo) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titolo,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
            letterSpacing: 1.0,
          ),
        ),
        const Divider(height: 4, thickness: 1),
        const SizedBox(height: 6),
      ],
    ),
  );
}

// Widget helper per stampare in grassetto l'etichetta e normale il rispettivo valore
Widget _buildRigaDettaglio(String label, String? valore) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '$label ',
            style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87, fontSize: 14),
          ),
          TextSpan(
            text: (valore == null || valore.trim().isEmpty) ? 'Non inserito' : valore,
            style: const TextStyle(fontWeight: FontWeight.normal, color: Colors.black54, fontSize: 14),
          ),
        ],
      ),
    ),
  );
}
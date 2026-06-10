import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// L'UNICA FUNZIONE PER IL CARICAMENTO E L'ASSOCIAZIONE DEI DOCUMENTI (RF-08)
Future<void> eseguiSelezioneEUploadDocumento({
  required BuildContext context,
  required String idCliente,       
  required String nomeCliente,     
  required String idCaricatoDa,    
  required String nomeCaricatoDa,  
}) async {
  
  try {
    // --- 1. SELEZIONE DEL FILE DAL DISPOSITIVO ---
    // Sintassi statica diretta per azzerare i conflitti di versione
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.any,
      allowMultiple: false, 
    );

    // Gestione sicura del controllo null
    if (result == null || result.files.isEmpty || result.files.single.path == null) {
      debugPrint("RF-08 - Selezione del file annullata dall'utente.");
      return;
    }

    // Mostriamo un indicatore di caricamento bloccante
    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );
    }

    // Recuperiamo il percorso del file selezionato e il suo nome originario
    File file = File(result.files.single.path!);
    String nomeFile = result.files.single.name;
    
    // Creiamo un timestamp per rendere il nome del file univoco
    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    String nomeFileUnivoco = "${timestamp}_$nomeFile";

    // --- 2. UPLOAD SU FIREBASE STORAGE ---
    Reference storageRef = FirebaseStorage.instance
        .ref()
        .child('clienti')
        .child(idCliente)
        .child('documenti')
        .child(nomeFileUnivoco);

    UploadTask uploadTask = storageRef.putFile(file);
    TaskSnapshot snapshotTask = await uploadTask;
    
    String downloadUrl = await snapshotTask.ref.getDownloadURL();
    debugPrint("RF-08 - File caricato con successo su Storage. URL: $downloadUrl");

    // --- 3. SALVATAGGIO METADATI SU CLOUD FIRESTORE ---
    final Map<String, dynamic> datiDocumento = {
      'nomeFile': nomeFile,
      'urlDownload': downloadUrl,
      'idCliente': idCliente,
      'nomeCliente': nomeCliente,
      'caricatoDaId': idCaricatoDa,
      'caricatoDaNome': nomeCaricatoDa,
      'dimensioneBytes': result.files.single.size,
      'dataCaricamento': FieldValue.serverTimestamp(),
    };

    DocumentReference documentoRef = await FirebaseFirestore.instance
        .collection('documents')
        .add(datiDocumento);
        
    debugPrint("RF-08 - Metadati del documento salvati su Firestore con ID: ${documentoRef.id}");

    // --- 4. INTEGRAZIONE CON IL MODULO NOTIFICHE PUSH (RF-10) ---
    final mappaNotificaPush = {
      'notification': {
        'title': '📄 Nuovo Documento Ricevuto',
        'body': '$nomeCaricatoDa ha caricato il file "$nomeFile" nella scheda del cliente $nomeCliente.',
      },
      'data': {
        'type': 'documento',
        'referenceId': idCliente, 
      }
    };
    debugPrint("RF-10 - Payload pronto per l'invio al team dello studio: $mappaNotificaPush");

    // --- 5. CHIUSURA DEL LOADING E POPUP DI SUCCESSO ---
    if (context.mounted) {
      Navigator.pop(context); // Rimuove il loader circolare
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('📄 File "$nomeFile" caricato e associato correttamente!')),
      );
    }

  } catch (errore) {
    debugPrint("Errore durante l'esecuzione del modulo RF-08: $errore");
    if (context.mounted) {
      Navigator.pop(context); // Rimuove il loader circolare
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Errore durante il caricamento del file: $errore')),
      );
    }
  }
}
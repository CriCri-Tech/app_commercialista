import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Metodo che gestisce il caricamento del documento sul cloud e la relativa notifica.
Future<void> eseguiSelezioneEUploadDocumento({
  required String idCliente,
  required String nomeCliente,
  required String idCaricatoDa,
  required String nomeCaricatoDa,
  required String studioId,
}) async {
  try {
    // Selezione del file tramite l'interfaccia nativa del dispositivo.
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
    );

    // Interruzione del processo se la selezione viene annullata.
    if (result == null || result.files.isEmpty || result.files.single.path == null) {
      debugPrint("Selezione del file annullata.");
      return;
    }

    File file = File(result.files.single.path!);
    String nomeFile = result.files.single.name;

    // Generazione di un nome univoco tramite timestamp per evitare sovrascritture su cloud.
    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    String nomeFileUnivoco = "${timestamp}_$nomeFile";

    // Definizione del percorso di destinazione su Firebase Storage, strutturato per cliente.
    Reference storageRef = FirebaseStorage.instance
        .ref()
        .child('studi')
        .child(studioId)
        .child('clienti')
        .child(idCliente)
        .child('documenti')
        .child(nomeFileUnivoco);

    // Esecuzione dell'upload e attesa del completamento.
    UploadTask uploadTask = storageRef.putFile(file);
    TaskSnapshot snapshotTask = await uploadTask;

    // Recupero dell'URL di download generato da Firebase per accedere al documento.
    String downloadUrl = await snapshotTask.ref.getDownloadURL();
    debugPrint("File caricato con successo su Storage. URL: $downloadUrl");

    // Preparazione dei dati del documento per la registrazione nel database.
    final Map<String, dynamic> datiDocumento = {
      'nomeFile': nomeFile,
      'urlDownload': downloadUrl,
      'idCliente': idCliente,
      'studioId': studioId,
      'nomeCliente': nomeCliente,
      'caricatoDaId': idCaricatoDa,
      'caricatoDaNome': nomeCaricatoDa,
      'dimensioneBytes': result.files.single.size,
      'dataCaricamento': FieldValue.serverTimestamp(),
    };

    // Inserimento del record nella collezione dedicata.
    DocumentReference documentoRef = await FirebaseFirestore.instance
        .collection('documents')
        .add(datiDocumento);

    debugPrint("Metadati del documento salvati su Firestore con ID: ${documentoRef.id}");

    // Strutturazione del payload necessario per l'invio della notifica al team.
    final mappaNotificaPush = {
      'notification': {
        'title': 'Nuovo Documento Ricevuto',
        'body': '$nomeCaricatoDa ha caricato il file "$nomeFile" nella scheda del cliente $nomeCliente.',
      },
      'data': {
        'type': 'documento',
        'referenceId': idCliente,
      }
    };
    debugPrint("Payload per la notifica pronto: $mappaNotificaPush");

  } catch (errore) {
    // Gestione degli errori durante l'esecuzione dell'operazione.
    debugPrint("Errore durante l'esecuzione del modulo: $errore");
    
    // Rilancio dell'eccezione per permettere alla UI di intercettarla e mostrare un avviso all'utente.
    throw Exception('Caricamento fallito: $errore');
  }
}
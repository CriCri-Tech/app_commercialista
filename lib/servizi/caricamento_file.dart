import 'dart:io';
import 'package:flutter/foundation.dart'; // Necessario per debugPrint e Uint8List
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Funzione dedicata alla selezione di un documento dal dispositivo,
/// al suo caricamento su Firebase Storage e al salvataggio dei relativi
/// dati su Firestore. Prepara anche il payload per le notifiche.
Future<void> eseguiSelezioneEUploadDocumento({
  required String idCliente,       
  required String nomeCliente,     
  required String idCaricatoDa,    
  required String nomeCaricatoDa,  
  required String studioId,
}) async {
  try {
    // MODIFICA 1: Aggiunto withData: true per caricare i byte in memoria 
    // e aggirare i blocchi di sicurezza delle cartelle su Android/iOS.
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom, // Limitato ai PDF come richiesto dai tuoi test
      allowedExtensions: ['pdf'],
      allowMultiple: false, 
      withData: true, 
    );

    // Verifica per interrompere il processo se l'utente chiude il selettore
    // senza aver scelto alcun file.
    if (result == null || result.files.isEmpty) {
      debugPrint("Selezione del file annullata dall'utente.");
      return;
    }

    // MODIFICA 2: Estrazione dei byte invece del percorso locale
    Uint8List? fileBytes = result.files.single.bytes;
    String nomeFile = result.files.single.name;
    
    // Fallback di sicurezza: se withData fallisce, proviamo a leggere dal percorso
    if (fileBytes == null) {
      if (result.files.single.path != null) {
         File file = File(result.files.single.path!);
         fileBytes = await file.readAsBytes();
      } else {
         throw Exception("Impossibile leggere il contenuto del file. Permessi negati dal dispositivo.");
      }
    }

    // Creazione di un timestamp per garantire che il nome del file sia univoco.
    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    String nomeFileUnivoco = "${timestamp}_$nomeFile";

    // Definizione del percorso di archiviazione su Firebase Storage.
    Reference storageRef = FirebaseStorage.instance
        .ref()
        .child('studi')
        .child(studioId)
        .child('clienti')
        .child(idCliente)
        .child('documenti')
        .child(nomeFileUnivoco);

    // MODIFICA 3: Avvio del caricamento fisico usando putData invece di putFile
    UploadTask uploadTask = storageRef.putData(fileBytes);
    TaskSnapshot snapshotTask = await uploadTask;
    
    // Recupero dell'indirizzo web generato per accedere al file appena caricato.
    String downloadUrl = await snapshotTask.ref.getDownloadURL();
    debugPrint("File caricato con successo su Storage. URL: $downloadUrl");

    // Preparazione dei dati informativi del documento da salvare su Firestore.
    final Map<String, dynamic> datiDocumento = {
      'nomeFile': nomeFile,
      'urlDownload': downloadUrl,
      'idCliente': idCliente,
      'nomeCliente': nomeCliente,
      'caricatoDaId': idCaricatoDa,
      'caricatoDaNome': nomeCaricatoDa,
      'studioId': studioId,
      'dimensioneBytes': result.files.single.size,
      'dataCaricamento': FieldValue.serverTimestamp(),
    };

    // Creazione del nuovo record all'interno della collezione dei documenti.
    DocumentReference documentoRef = await FirebaseFirestore.instance
        .collection('documents')
        .add(datiDocumento);
        
    debugPrint("Metadati del documento salvati su Firestore con ID: ${documentoRef.id}");

    // Strutturazione del contenuto per l'eventuale invio di notifiche push al team.
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
    debugPrint("Payload per l'invio della notifica pronto: $mappaNotificaPush");

  } catch (errore) {
    debugPrint("Errore durante il processo di caricamento: $errore");
    
    // Rilancio dell'errore verso l'esterno in modo che l'interfaccia utente
    // possa intercettarlo e mostrare il relativo messaggio all'utente.
    throw Exception("Errore durante il caricamento del file: $errore");
  }
}
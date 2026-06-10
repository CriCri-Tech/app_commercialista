import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// L'UNICA FUNZIONE PER IL CARICAMENTO E L'ASSOCIAZIONE DEI DOCUMENTI (RF-08)
/// Gestisce l'apertura del selettore file del telefono, esegue l'upload sul cloud,
/// ne mappa i dati su Firestore e aggancia la notifica push (RF-10).
Future<void> eseguiSelezioneEUploadDocumento({
  required BuildContext context,
  required String idCliente,       // ID del cliente a cui associare il file (da RF-06)
  required String nomeCliente,     // Ragione sociale del cliente per i log e le notifiche
  required String idCaricatoDa,    // ID dell'utente loggato che sta facendo l'upload (da RF-01)
  required String nomeCaricatoDa,  // Nome del professionista che carica (es: "Dott. Rossi")
}) async {
  
  try {
    // --- 1. SELEZIONE DEL FILE DAL DISPOSITIVO ---
    // Apre la finestra nativa di Android/iOS per selezionare un file (PDF, immagini, Excel, ecc.)
    // Utilizziamo il metodo statico diretto che è il più compatibile con le varie versioni del pacchetto.
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.any,    // Consente la scelta di qualsiasi formato di documento utile allo studio
      allowMultiple: false, // Upload singolo per mantenere l'associazione pulita e mirata
    );

    // Gestione di sicurezza: se l'utente ci ripensa e preme "Annulla", interrompiamo la funzione
    if (result == null || result.files.isEmpty || result.files.single.path == null) {
      debugPrint("RF-08 - Selezione del file annullata dall'utente.");
      return;
    }

    // Mostriamo un indicatore visivo di caricamento (loader) bloccante per evitare click multipli
    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false, // Impedisce di chiudere il caricamento cliccando fuori
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );
    }

    // Trasformiamo il percorso locale in un oggetto File per poterlo manipolare e inviare
    File file = File(result.files.single.path!);
    String nomeFile = result.files.single.name; // Nome originale del file scelto
    
    // Generiamo una stringa temporale (timestamp) per rendere il nome del file unico sul cloud.
    // In questo modo, se carichi due volte un file chiamato "Fattura.pdf", non sovrascriverai il vecchio.
    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    String nomeFileUnivoco = "${timestamp}_$nomeFile";

    // --- 2. UPLOAD SU FIREBASE STORAGE ---
    // Organizziamo i file all'interno dei server di archiviazione (Firebase Storage).
    // Creiamo una struttura a cartelle dinamica divisa per ID Cliente:
    // Percorso finale: clienti/ID_CLIENTE_CORRENTE/documenti/TIMESTAMP_nomefile.pdf
    Reference storageRef = FirebaseStorage.instance
        .ref()
        .child('clienti')
        .child(idCliente)
        .child('documenti')
        .child(nomeFileUnivoco);

    // Lanciamo il processo di caricamento (Upload Task) e attendiamo che si concluda
    UploadTask uploadTask = storageRef.putFile(file);
    TaskSnapshot snapshotTask = await uploadTask;
    
    // Una volta completato, recuperiamo l'URL pubblico cifrato generato da Firebase.
    // Questo link servirà in futuro all'app per far scaricare o vedere il documento nella scheda cliente.
    String downloadUrl = await snapshotTask.ref.getDownloadURL();
    debugPrint("RF-08 - File caricato con successo su Storage. URL: $downloadUrl");

    // --- 3. SALVATAGGIO METADATI SU CLOUD FIRESTORE ---
    // Non basta caricare il file: dobbiamo registrare le informazioni nel database testuale (Firestore)
    // per visualizzarlo all'interno delle liste dell'applicazione dello studio.
    final Map<String, dynamic> datiDocumento = {
      'nomeFile': nomeFile,
      'urlDownload': downloadUrl,   // Il link di download che abbiamo recuperato dallo Storage
      'idCliente': idCliente,       // Puntatore fondamentale alla scheda del cliente (RF-06)
      'nomeCliente': nomeCliente,   // Per mostrare la ragione sociale nella UI dei file recenti (RF-05)
      'caricatoDaId': idCaricatoDa, // ID di chi ha eseguito l'azione (da RF-01)
      'caricatoDaNome': nomeCaricatoDa,
      'dimensioneBytes': result.files.single.size, // Utile se si vuole mostrare il peso del file (es: 2 MB)
      'dataCaricamento': FieldValue.serverTimestamp(), // Data e ora presi direttamente dal server
    };

    // Aggiungiamo la mappa come nuovo record nella collezione 'documents'
    DocumentReference documentoRef = await FirebaseFirestore.instance
        .collection('documents')
        .add(datiDocumento);
        
    debugPrint("RF-08 - Metadati del documento salvati su Firestore con ID: ${documentoRef.id}");

    // --- 4. INTEGRAZIONE CON IL MODULO NOTIFICHE PUSH (RF-10) ---
    // Quando viene caricato un nuovo file, il backend o una Cloud Function deve avvisare il team.
    // Prepariamo la struttura dati (payload JSON) che servirà per scatenare l'avviso.
    final mappaNotificaPush = {
      'notification': {
        'title': '📄 Nuovo Documento Ricevuto',
        'body': '$nomeCaricatoDa ha caricato il file "$nomeFile" nella scheda del cliente $nomeCliente.',
      },
      'data': {
        'type': 'documento',
        'referenceId': idCliente, // Al click sulla notifica, lo smart routing porterà l'utente alla scheda di questo cliente
      }
    };
    debugPrint("RF-10 - Payload pronto per l'invio al team dello studio: $mappaNotificaPush");

    // --- 5. CHIUSURA DEL LOADING E POPUP DI SUCCESSO ---
    if (context.mounted) {
      Navigator.pop(context); // Rimuove dallo schermo il cerchio di caricamento (loader)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('📄 File "$nomeFile" caricato e associato correttamente!')),
      );
    }

  } catch (errore) {
    // Gestione degli imprevisti (es: assenza di connessione internet o file troppo pesante)
    debugPrint("Errore durante l'esecuzione del modulo RF-08: $errore");
    if (context.mounted) {
      Navigator.pop(context); // Chiude il loader per non lasciare l'app bloccata in caso di errore
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Errore durante il caricamento del file: $errore')),
      );
    }
  }
}
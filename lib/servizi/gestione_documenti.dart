import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import '../modelli/documento.dart';

class DocumentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Riferimento allo spazio di memoria del database per i documenti
  CollectionReference get _documentsCollection => _firestore.collection('documents');

  // Metodo che permette di aggiungere un documento
  Future<void> aggiungiDocumento({
    required String clientId,
    required String nomeCliente,
    required String studioId,
    required File file,
    required String fileName,
    required String uploaderId,
    required String uploaderName,
  }) async {
    try {
      // Creazione di un percorso univoco per il documento
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String storagePath = 'documents/$clientId/${timestamp}_$fileName';
      
      final Reference storageRef = _storage.ref().child(storagePath);

      // Upload del file fisico
      final UploadTask uploadTask = storageRef.putFile(file);
      final TaskSnapshot snapshot = await uploadTask;

      // URL per il download
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      // Salvataggio dei dati del documento su Firestore
      await _documentsCollection.add({
        'clientId': clientId,
        'studioId': studioId,
        'fileName': fileName,
        'fileUrl': downloadUrl,
        'storagePath': storagePath,
        'uploadedBy': uploaderId,
        'uploadDate': FieldValue.serverTimestamp(),
        'nomeCliente': nomeCliente,
      });

      // Creazione della base per la notifica 
      final mappaNotificaPush = {
        'notification': {
          'title': 'Nuovo Documento Ricevuto',
          'body': '$uploaderName ha caricato il file "$fileName" per il cliente $nomeCliente.'
        },
        'data': {
          'type': 'documento',
          'referenceId': clientId,
        },
        'studioId': studioId,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Inserimento della notifica nell'apposita collection per permetterne l'invio
      await _firestore.collection('notifications').add(mappaNotificaPush);

      debugPrint("Documento caricato e notifica inserita in coda con successo.");

    } catch (e) {
      throw Exception("Errore durante il caricamento del documento: $e");
    }
  }

  // Metodo per ricercare i documenti filtrando per il nome dell'azienda del cliente
  Stream<List<Documento>> ricercaDocumentiPerAzienda(String query, String studioId) {
    // Restituisce tutti i documenti che iniziano con la stringa inserita
    return _documentsCollection
        .where("studioId", isEqualTo: studioId)
        .where("nomeCliente", isGreaterThanOrEqualTo: query)
        .where("nomeCliente", isLessThan: query + '\uf8ff')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            // Converte ogni documento trovato in un oggetto 'Documento'
            return Documento.fromMap(doc.data() as Map<String, dynamic>, doc.id);
          }).toList();
        });
  }

  // Metodo che permette di eliminare dei documenti 
  Future<void> eliminaDocumento(String documentId, String storagePath) async {
    try {
      // Eliminazione del documento da Firebase Storage 
      final Reference storageRef = _storage.ref().child(storagePath);
      await storageRef.delete();

      // Eliminazione dei metadati da Firestore
      await _documentsCollection.doc(documentId).delete();
      
    } catch (e) {
      throw Exception("Errore durante l'eliminazione del documento: $e");
    }
  }
}
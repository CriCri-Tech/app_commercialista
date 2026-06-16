// Pacchetto per la sincronizzazione dei dati in tempo reale con Firebase Firestore
import "package:cloud_firestore/cloud_firestore.dart";

// Importazione del modello della classe Scadenza
import "../modelli/scadenza.dart";

// Pacchetto per l'utilizzo delle funzioni di debug del framework
import 'package:flutter/foundation.dart';

// Classe di servizio preposta alla gestione e persistenza delle scadenze sul database Cloud Firestore.
class ServizioScadenze {
  // Riferimento alla collezione 'deadlines' presente nel database Firebase
  final CollectionReference _scadenzeCollection = FirebaseFirestore.instance.collection('deadlines');

  // Inserisce una nuova scadenza all'interno della collezione Firestore.
  Future<void> aggiungiScadenza(Scadenza scadenza) async {
    try {
      await _scadenzeCollection.add(scadenza.toMap());
    } catch (e) {
      debugPrint("Errore durante l'aggiunta della scadenza: $e");
      rethrow;
    }
  }

  // Aggiorna i dati di una scadenza esistente sul database Firestore.
  Future<void> modificaScadenza(Scadenza scadenza) async {
    try {
      await _scadenzeCollection.doc(scadenza.id).update(scadenza.toMap());
    } catch (e) {
      debugPrint("Errore durante la modifica della scadenza: $e");
      rethrow;
    }
  }

  // Modifica lo stato di una scadenza impostandolo su 'completata'.
  Future<void> segnaComeCompletata(String scadenzaId) async {
    try {
      await _scadenzeCollection.doc(scadenzaId).update({
        'status': 'completata',
      });
    } catch (e) {
      debugPrint("Errore durante il completamento della scadenza: $e");
      rethrow;
    }
  }

  // Rimuove una scadenza dal database tramite il suo ID identificativo.
  // Solleva un'eccezione se la scadenza risulta essere già in stato 'scaduta'.
  Future<void> eliminaScadenza(String scadenzaId) async {
    try {
      // Controllo di sicurezza lato server/servizio prima di procedere all'eliminazione
      DocumentSnapshot doc = await _scadenzeCollection.doc(scadenzaId).get();
      if (doc.exists) {
        final dati = doc.data() as Map<String, dynamic>;
        if (dati['status'] == 'scaduta') {
          throw Exception("Procedura non consentita: impossibile eliminare una scadenza scaduta.");
        }
      }
      
      await _scadenzeCollection.doc(scadenzaId).delete();
    } catch (e) {
      debugPrint("Errore durante l'eliminazione della scadenza: $e");
      rethrow;
    }
  }

  // Restituisce lo Stream delle scadenze associate a un determinato cliente e studio.
  // Esegue un controllo automatico sullo stato temporale delle scadenze estratte.
  Stream<List<Scadenza>> ottieniScadenzePerCliente(String clientId, String studioId) {
    return _scadenzeCollection
        .where("studioId", isEqualTo: studioId)
        .where("clientId", isEqualTo: clientId)
        .orderBy("dueDate")
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final scadenza = Scadenza.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        _allineaStatoScadenzaInBackground(scadenza, doc.id);
        return scadenza;
      }).toList();
    });
  }

  // Restituisce lo Stream delle scadenze programmate per una specifica giornata del calendario.
  // Esegue un controllo automatico sullo stato temporale delle scadenze estratte.
  Stream<List<Scadenza>> ottieniScadenzePerData(String studioId, DateTime dataScelta) {
    DateTime inizioGiorno = DateTime(dataScelta.year, dataScelta.month, dataScelta.day);
    DateTime fineGiorno = DateTime(dataScelta.year, dataScelta.month, dataScelta.day, 23, 59, 59);

    return _scadenzeCollection
        .where("studioId", isEqualTo: studioId)
        .where("dueDate", isGreaterThanOrEqualTo: Timestamp.fromDate(inizioGiorno))
        .where("dueDate", isLessThanOrEqualTo: Timestamp.fromDate(fineGiorno))
        .orderBy("dueDate")
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final scadenza = Scadenza.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        _allineaStatoScadenzaInBackground(scadenza, doc.id);
        return scadenza;
      }).toList();
    });
  }

  // Restituisce lo Stream delle scadenze relative alla giornata odierna.
  // Esegue un controllo automatico sullo stato temporale delle scadenze estratte.
  Stream<List<Scadenza>> ottieniScadenzeOdierne(String studioId) {
    DateTime oggi = DateTime.now();
    DateTime inizioGiorno = DateTime(oggi.year, oggi.month, oggi.day);
    DateTime fineGiorno = DateTime(oggi.year, oggi.month, oggi.day, 23, 59, 59);

    return _scadenzeCollection
        .where("studioId", isEqualTo: studioId)
        .where("dueDate", isGreaterThanOrEqualTo: Timestamp.fromDate(inizioGiorno))
        .where("dueDate", isLessThanOrEqualTo: Timestamp.fromDate(fineGiorno))
        .orderBy("dueDate")
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final scadenza = Scadenza.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        _allineaStatoScadenzaInBackground(scadenza, doc.id);
        return scadenza;
      }).toList();
    });
  }

  // Funzione privata interna per validare e correggere lo stato della scadenza 
  // nel caso in cui il tempo limite sia superato ma l'entità risulti ancora aperta.
  void _allineaStatoScadenzaInBackground(Scadenza scadenza, String idDocumento) {
    if (scadenza.dueDate.isBefore(DateTime.now()) &&
        scadenza.status != 'scaduta' &&
        scadenza.status != 'completata') {
      _scadenzeCollection.doc(idDocumento).update({'status': 'scaduta'}).catchError((errore) {
        debugPrint("Impossibile aggiornare lo stato di scadenza per il documento $idDocumento: $errore");
      });
    }
  }
}
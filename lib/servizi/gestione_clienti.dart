// Pacchetto per la sincronizzazione dei dati in tempo reale con Firebase Firestore
import "package:cloud_firestore/cloud_firestore.dart";

// Importazione del modello della classe Cliente
import "../modelli/cliente.dart";

// Pacchetto per l'utilizzo delle funzioni di debug del framework
import 'package:flutter/foundation.dart';

// Classe di servizio preposta alla gestione e persistenza dei clienti sul database Cloud Firestore.
class ServizioClienti {
  // NOTA: Sincronizzato il nome della collezione con la Dashboard ('clienti')
  final CollectionReference _clientiCollection = FirebaseFirestore.instance.collection('clients');

  // Inserisce un nuovo cliente all'interno della collezione Firestore.
  Future<void> aggiungiCliente(Cliente cliente) async {
    try {
      // Converte l'oggetto Cliente in mappa e lo aggiunge al database.
      // NOTA: Assicurarsi che cliente.toMap() includa le chiavi per nome e cognome.
      await _clientiCollection.add(cliente.toMap());
    } catch (e) {
      debugPrint("Errore durante l'aggiunta del cliente: $e");
      rethrow;
    }
  }

  // Aggiorna i dati di un cliente esistente.
  // Richiede che l'oggetto Cliente abbia un ID valido e non nullo.
  Future<void> modificaCliente(Cliente cliente) async {
    try {
      // Controllo preventivo sulla validità dell'ID per evitare eccezioni di Null Safety
      if (cliente.id == null || cliente.id!.isEmpty) {
        throw Exception("Impossibile procedere alla modifica: ID cliente mancante o non valido.");
      }

      // Accede al documento specifico tramite ID forzato (!) e aggiorna i campi presenti nella mappa
      await _clientiCollection.doc(cliente.id!).update(cliente.toMap());
    } catch (e) {
      debugPrint("Errore durante la modifica del cliente: $e");
      rethrow;
    }
  }

  // Rimuove un cliente dal database tramite il suo ID identificativo.
  Future<void> eliminaCliente(String clienteId) async {
    try {
      if (clienteId.isEmpty) {
        throw Exception("Impossibile procedere all'eliminazione: ID cliente vuoto.");
      }
      await _clientiCollection.doc(clienteId).delete();
    } catch (e) {
      debugPrint("Errore durante l'eliminazione del cliente: $e");
      rethrow;
    }
  }

  // Restituisce lo Stream di tutti i clienti associati a uno specifico studio, ordinati per nome azienda.
  Stream<List<Cliente>> ottieniClienti(String studioId) {
    return _clientiCollection
        .where("studioId", isEqualTo: studioId)
        .orderBy("companyName")
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Cliente.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // Esegue una ricerca in tempo reale dei clienti il cui nome azienda inizia con la stringa di query.
  Stream<List<Cliente>> ricercaClienti(String query, String studioId) {
    return _clientiCollection
        .where("studioId", isEqualTo: studioId)
        .where("companyName", isGreaterThanOrEqualTo: query)
        .where("companyName", isLessThan: query + 'z')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Cliente.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }
}
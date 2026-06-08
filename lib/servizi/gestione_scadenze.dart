// Pacchetto che permette di sinctronizzare i dati tra l'app e il database in tempo reale
import "package:cloud_firestore/cloud_firestore.dart";

// Importazione della classe Scadenza dalla cartella lib/modelli
import "../modelli/scadenza.dart";

// Pacchetto che permette il debugPrint
import 'package:flutter/foundation.dart';

// Classe che rappresenta il servizio di gestione delle scadenze
class ServizioScadenze{
  // Riferimento all'area di memoria del database dedicata alle scadenze
  final CollectionReference _scadenzeCollection = FirebaseFirestore.instance.collection('deadlines');

  // Metodo per aggiungere una scadenza al database
  Future <void> aggiungiScadenza(Scadenza scadenza) async{
    try{
      // Dopo aver convertito l'oggetto Scadenza in una mappa, lo aggiunge alla collezione 'deadlines' del database
      await _scadenzeCollection.add(scadenza.toMap());
    } catch(e){
      debugPrint("Errore durante l'aggiunta della scadenza: \$e");
      rethrow;
    }
  }

  // Metodo per modificare una scadenza esistente
  Future <void> modificaScadenza(Scadenza scadenza) async{
    try{
      // Accede al documento della scadenza tramite il suo ID e aggiorna i suoi dati con quelli forniti
      await _scadenzeCollection.doc(scadenza.id).update(scadenza.toMap());
    } catch(e){
      debugPrint("Errore durante la modifica della scadenza: \$e");
      rethrow;
    }
  }

  // Metodo per eliminare una scadenza dal database
  Future <void> eliminaScadenza(String scadenzaId) async{
    try{
      // Accede al documento della scadenza tramite il suo ID e lo elimina dalla collezione deadlines
      await _scadenzeCollection.doc(scadenzaId).delete();
    } catch(e){
      debugPrint("Errore durante l'eliminazione della scadenza: \$e");
      rethrow;
    }
  }

  // Metodo per recuperare le scadenze di un cliente specifico dal database
  Stream<List<Scadenza>> ottieniScadenzePerCliente(String clientId) {
    // Accede alla collection delle scadenze su Firestore, filtra per clientId e le ordina per data di scadenza
    // Rimane in ascolto in tempo reale di qualsiasi modifica sul database
    // Trasforma i dati grezzi di Firebase in una lista di istanze della classe Scadenza
    return _scadenzeCollection
      .where("clientId", isEqualTo: clientId)
      .orderBy("dueDate")
      .snapshots()
      .map((snapshot){
        return snapshot.docs.map((doc){
          return Scadenza.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        }).toList();
      });
  }

  // Metodo per ottenere le scadenze odierne
  Stream<List<Scadenza>> ottieniScadenzeOdierne() {
    DateTime oggi = DateTime.now();
    DateTime inizioGiorno = DateTime(oggi.year, oggi.month, oggi.day);
    DateTime fineGiorno = DateTime(oggi.year, oggi.month, oggi.day, 23, 59, 59);

    // Accede alla collection delle scadenze su Firestore, filtra per data di scadenza odierna
    // Rimane in ascolto in tempo reale di qualsiasi modifica sul database
    // Trasforma i dati grezzi di Firebase in una lista di istanze della classe Scadenza
    return _scadenzeCollection
      .where("dueDate", isGreaterThanOrEqualTo: Timestamp.fromDate(inizioGiorno))
      .where("dueDate", isLessThanOrEqualTo: Timestamp.fromDate(fineGiorno))
      .orderBy("dueDate")
      .snapshots()
      .map((snapshot){
        return snapshot.docs.map((doc){
          return Scadenza.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        }).toList();
      });
  }
}
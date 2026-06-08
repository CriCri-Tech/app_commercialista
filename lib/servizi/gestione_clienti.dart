// Pacchetto che permette di sinctronizzare i dati tra l'app e il database in tempo reale
import "package:cloud_firestore/cloud_firestore.dart";
// Importazione della classe Cliente dalla cartella lib/modelli
import "../modelli/cliente.dart";
// Pacchetto che permette il debugPrint
import 'package:flutter/foundation.dart';

class ServizioClienti{
  // Riferimento all'area di memoria del database dedicata ai clienti
  final CollectionReference _clientiCollection = FirebaseFirestore.instance.collection('clients');

  // Metodo per aggiungere un cliente al database
  Future<void> aggiungiCliente(Cliente cliente) async {
    try{
      // Dopo aver convertito l'oggetto Cliente in una mappa, lo aggiunge alla collezione 'clients' del database
      await _clientiCollection.add(cliente.toMap());
    } catch(e){
      debugPrint("Errore durante l'aggiunta del cliente: \$e");
      rethrow;
    }
  }

  // Metodo per modificare un cliente esistente
  Future<void> modificaCliente(Cliente cliente) async {
    try{
      // Accede al documento del cliente tramite il suo ID e aggiorna i suoi dati con quelli forniti
      await _clientiCollection.doc(cliente.id).update(cliente.toMap());
    } catch(e){
      debugPrint("Errore durante la modifica del cliente: \$e");
      rethrow;
    }
  }

  // Metodo per eliminare un cliente dal database
  Future <void> eliminaCliente(String clienteId) async {
    try{
      // Accede al documento del cliente tramite il suo ID e lo elimina dalla collezione clients
      await _clientiCollection.doc(clienteId).delete();
    } catch(e){
      debugPrint("Errore durante l'eliminazione del cliente: \$e");
      rethrow;
    }
  }


  // Metodo per recuperare tutti i clienti dal database
  Stream<List<Cliente>> ottieniClienti() {
    // Accede alla collection dei clienti su Firestore e li ordina per nome azienda
    // Rimane in ascolto in tempo reale di qualsiasi modifica sul database
    // Trasforma i dati grezzi di Firebase in una lista di istanze della classe Cliente
    return _clientiCollection
      .orderBy("companyName")
      .snapshots()
      .map((snapshot){
        return snapshot.docs.map((doc){
          return Cliente.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        }).toList();
      });
  }

  // Metodo per ricercare un cliente tramite il nome dell'azienda
  Stream<List<Cliente>> ricercaClienti(String query) {
    // Filtra la collection dei clienti su Firestore cercando quelli il cui nome inizia con il testo inserito,
    // ascolta le modifiche in tempo reale e converte ogni documento trovato in un oggetto 'Cliente' inserito in una lista
    return _clientiCollection
      .where("companyName", isGreaterThanOrEqualTo: query)
      .where("companyName", isLessThan: query + 'z')
      .snapshots()
      .map((snapshot){
        return snapshot.docs.map((doc){
          return Cliente.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        }).toList();
      });
  }
}
// Pacchetto che permette di sinctronizzare i dati tra l'app e il database in tempo reale
import "package:cloud_firestore/cloud_firestore.dart";

// Classe che rappresenta la scadenza
class Scadenza{
  String? id; // ID della scadenza
  String studioId; // ID dello studio associato alla scadenza
  String clientId; // ID del cliente associato alla scadenza
  String type; 
  DateTime dueDate; // Data di scadenza
  String status; // Stato della scadenza
  String assignedTo; // ID dell'utente a cui è assegnata la scadenza

  // Metodo costruttore
  Scadenza({
    this.id,
    required this.studioId,
    required this.clientId,
    required this.type,
    required this.dueDate,
    required this.status,
    required this.assignedTo,
  });

  // Metodo per convertire un documento Firestore in un oggetto Scadenza
  factory Scadenza.fromMap(Map<String, dynamic> data, String documentId){
    return Scadenza(
      id: documentId,
      studioId: data["studioId"] ?? '',
      clientId: data["clientId"] ?? '',
      type: data["type"] ?? '',
      dueDate: (data["dueDate"] as Timestamp).toDate(),
      status: data["status"] ?? 'pending', // Valore predefinito se lo stato non è specificato
      assignedTo: data["assignedTo"] ?? '',
    );
  }

  // Metodo per convertire una scadenza in una mappa da salvare su Firestore
  Map<String, dynamic> toMap(){
    return {
      "studioId": studioId,
      "clientId": clientId,
      "type": type,
      "dueDate": Timestamp.fromDate(dueDate),
      "status": status,
      "assignedTo": assignedTo,
    };
  }
}
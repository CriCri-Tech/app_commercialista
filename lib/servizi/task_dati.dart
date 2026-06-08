import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  final String id;
  final String titolo;
  final String descrizione;
  final String clienteId;      // ID del cliente associato (RF-06)
  final String clienteNome;    // Nome memorizzato per evitare letture extra
  final String assegnatoAId;   // UID dell'utente incaricato (RF-04)
  final String assegnatoANome; // Nome dell'utente incaricato
  final bool completato;
  final DateTime dataCreazione;

  TaskModel({
    required this.id,
    required this.titolo,
    required this.descrizione,
    required this.clienteId,
    required this.clienteNome,
    required this.assegnatoAId,
    required this.assegnatoANome,
    required this.completato,
    required this.dataCreazione,
  });

  //Converte i dati di Firestore in un oggetto Dart
  factory TaskModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return TaskModel(
      id: doc.id,
      titolo: data['titolo'] ?? '',
      descrizione: data['descrizione'] ?? '',
      clienteId: data['clienteId'] ?? '',
      clienteNome: data['clienteNome'] ?? '',
      assegnatoAId: data['assegnatoAId'] ?? '',
      assegnatoANome: data['assegnatoANome'] ?? '',
      completato: data['completato'] ?? false,
      dataCreazione: (data['dataCreazione'] as Timestamp).toDate(),
    );
  }

  //Converte l'oggetto Dart in una mappa per Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'titolo': titolo,
      'descrizione': descrizione,
      'clienteId': clienteId,
      'clienteNome': clienteNome,
      'assegnatoAId': assegnatoAId,
      'assegnatoANome': assegnatoANome,
      'completato': completato,
      'dataCreazione': Timestamp.fromDate(dataCreazione),
    };
  }
}
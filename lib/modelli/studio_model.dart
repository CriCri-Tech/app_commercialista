import 'package:cloud_firestore/cloud_firestore.dart';

class StudioModel {
  final String id;
  final String nome;
  final String partitaIva;   // <-- Aggiunto per collegarlo alla UI
  final String codiceInvito; 
  final String adminId;      
  final List<String> membri; 
  final DateTime dataCreazione;

  StudioModel({
    required this.id,
    required this.nome,
    required this.partitaIva, // <-- Aggiunto
    required this.codiceInvito,
    required this.adminId,
    required this.membri,
    required this.dataCreazione,
  });

  factory StudioModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return StudioModel(
      id: doc.id,
      nome: data['nome'] ?? '',
      partitaIva: data['partitaIva'] ?? '', // <-- Aggiunto
      codiceInvito: data['codiceInvito'] ?? '',
      adminId: data['adminId'] ?? '',
      membri: List<String>.from(data['membri'] ?? []),
      dataCreazione: (data['dataCreazione'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'nome': nome,
      'partitaIva': partitaIva, // <-- Aggiunto
      'codiceInvito': codiceInvito,
      'adminId': adminId,
      'membri': membri,
      'dataCreazione': Timestamp.fromDate(dataCreazione),
    };
  }
}
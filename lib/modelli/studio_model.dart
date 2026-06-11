import 'package:cloud_firestore/cloud_firestore.dart';

class StudioModel {
  final String id;
  final String nome;
  final String codiceInvito; // Codice generato per far accedere i collaboratori
  final String adminId;      // L'UID di chi ha creato lo studio
  final List<String> membri; // Lista degli UID degli utenti che fanno parte dello studio
  final DateTime dataCreazione;

  StudioModel({
    required this.id,
    required this.nome,
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
      codiceInvito: data['codiceInvito'] ?? '',
      adminId: data['adminId'] ?? '',
      membri: List<String>.from(data['membri'] ?? []),
      dataCreazione: (data['dataCreazione'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'nome': nome,
      'codiceInvito': codiceInvito,
      'adminId': adminId,
      'membri': membri,
      'dataCreazione': Timestamp.fromDate(dataCreazione),
    };
  }
}
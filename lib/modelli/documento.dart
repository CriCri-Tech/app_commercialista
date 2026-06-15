import 'package:cloud_firestore/cloud_firestore.dart';

// Classe che rappresenta il singolo documento
class Documento {
  final String id;
  final String clientId;
  final String studioId;
  final String fileName;
  final String fileUrl;
  final String storagePath;
  final String uploadedBy;
  final String nomeCliente;
  final DateTime? uploadDate;

  // Metodo costruttore
  Documento({
    required this.id,
    required this.clientId,
    required this.studioId,
    required this.fileName,
    required this.fileUrl,
    required this.storagePath,
    required this.uploadedBy,
    required this.nomeCliente,
    this.uploadDate,
  });

  // Metodo che permette di convertire da mappa a documento
  factory Documento.fromMap(Map<String, dynamic> map, String documentId) {
    return Documento(
      id: documentId,
      clientId: map['clientId'] ?? '',
      studioId: map['studioId'] ?? '',
      fileName: map['fileName'] ?? '',
      fileUrl: map['fileUrl'] ?? '',
      storagePath: map['storagePath'] ?? '',
      uploadedBy: map['uploadedBy'] ?? '',
      nomeCliente: map['nomeCliente'] ?? '',
      uploadDate: map['uploadDate'] != null 
          ? (map['uploadDate'] as Timestamp).toDate() 
          : null,
    );
  }
}
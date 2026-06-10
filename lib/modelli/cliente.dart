// Pacchetto che permette di sinctronizzare i dati tra l'app e il database in tempo reale
import "package:cloud_firestore/cloud_firestore.dart";

// Classe che rappresenta il singolo cliente
class Cliente {
  String? id; // ID univoco del cliente
  String companyName; // Nome dell'azienda
  String studioId; // ID dello studio associato al cliente 
  String vatNumber; // Partita IVA
  String taxCode; // Codice fiscale
  String pec;
  String sdiCode;
  String phone;
  String email;
  String address;
  DateTime createdAt; // Data di creazione del cliente

  // Metodo costruttore
  Cliente({
    this.id,
    required this.studioId,
    required this.companyName,
    required this.vatNumber,
    required this.taxCode,
    required this.pec,
    required this.sdiCode,
    required this.phone,
    required this.email,
    required this.address,
    required this.createdAt, 
  });

  // Metodo per convertire un documento Firestore in un oggetto Cliente
  factory Cliente.fromMap(Map<String, dynamic> data, String documentId) {
    return Cliente(
      id: documentId,
      studioId: data['studioId'] ?? '',
      companyName: data['companyName'] ?? '',
      vatNumber: data['vatNumber'] ?? '',
      taxCode: data['taxCode'] ?? '',
      pec: data['pec'] ?? '',
      sdiCode: data['sdiCode'] ?? '',
      phone: data['phone'] ?? '',
      email: data['email'] ?? '',
      address: data['address'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  // Metodo per convertire un oggetto Cliente in una mappa da salvare su Firestore
  Map<String, dynamic> toMap() {
    return {
      'studioId': studioId,
      'companyName': companyName,
      'vatNumber': vatNumber,
      'taxCode': taxCode,
      'pec': pec,
      'sdiCode': sdiCode,
      'phone': phone,
      'email': email,
      'address': address,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
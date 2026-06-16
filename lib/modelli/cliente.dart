// Pacchetto necessario per la gestione dei timestamp e la sincronizzazione con Cloud Firestore
import "package:cloud_firestore/cloud_firestore.dart";

/// Classe modello che rappresenta l'entità di un singolo Cliente all'interno del sistema.
class Cliente {
  String? id;            // Identificativo univoco del documento all'interno di Firestore
  String companyName;    // Ragione sociale o nome dell'azienda del cliente
  String nomeECognome;   // Nome e cognome del referente o del titolare
  String studioId;       // Identificativo dello studio professionale associato al cliente
  String vatNumber;      // Partita IVA del cliente
  String taxCode;        // Codice Fiscale del cliente
  String pec;            // Indirizzo di Posta Elettronica Certificata
  String sdiCode;        // Codice destinatario SDI per la fatturazione elettronica
  String phone;          // Recapito telefonico
  String email;          // Indirizzo email ordinario
  String address;        // Indirizzo della sede legale o operativa
  DateTime createdAt;    // Data e ora di censimento del cliente nel sistema

  /// Costruttore standard per l'inizializzazione di tutti i campi dell'istanza Cliente.
  Cliente({
    this.id,
    required this.studioId,
    required this.companyName,
    required this.nomeECognome,
    required this.vatNumber,
    required this.taxCode,
    required this.pec,
    required this.sdiCode,
    required this.phone,
    required this.email,
    required this.address,
    required this.createdAt, 
  });

  /// Metodo factory per convertire una mappa di dati grezzi proveniente da Firestore
  /// in una istanza tipizzata della classe [Cliente].
  factory Cliente.fromMap(Map<String, dynamic> data, String documentId) {
    return Cliente(
      id: documentId,
      studioId: data['studioId'] ?? '',
      companyName: data['companyName'] ?? '',
      nomeECognome: data['nomeECognome'] ?? '',
      vatNumber: data['vatNumber'] ?? '',
      taxCode: data['taxCode'] ?? '',
      pec: data['pec'] ?? '',
      sdiCode: data['sdiCode'] ?? '',
      phone: data['phone'] ?? '',
      email: data['email'] ?? '',
      address: data['address'] ?? '',
      // Gestione del casting sicuro da Timestamp di Firestore a DateTime di Dart
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate() 
          : DateTime.now(),
    );
  }

  /// Converte l'istanza corrente della classe [Cliente] in una mappa [Map]
  /// di coppie chiave/valore pronta per essere salvata o aggiornata su Cloud Firestore.
  Map<String, dynamic> toMap() {
    return {
      'studioId': studioId,
      'companyName': companyName,
      'nomeECognome': nomeECognome, 
      'vatNumber': vatNumber,
      'taxCode': taxCode,
      'pec': pec,
      'sdiCode': sdiCode,
      'phone': phone,
      'email': email,
      'address': address,
      // Conversione dell'oggetto DateTime nel rispettivo Timestamp nativo di Firebase
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
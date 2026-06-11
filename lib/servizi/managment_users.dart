import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfiloService {
  //Gestisce l'autenticazione
  final FirebaseAuth _auth = FirebaseAuth.instance;
  //database per gestire i dati del profilo
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Ottiene l'ID dell'utente corrente
  String? get currentUid => _auth.currentUser?.uid;

  // Stream per ascoltare i dati del profilo in tempo reale
  Stream<DocumentSnapshot> get profiloStream {
    if (currentUid != null) {
      return _firestore.collection('utenti').doc(currentUid).snapshots();
    }
    throw Exception("Utente non autenticato");
  }

  // Aggiorna i dati del profilo su Firestore
  Future<void> aggiornaProfilo({
    required String nome,
    required String cognome,
    required String telefono,
  }) async {
    if (currentUid == null) return;

    await _firestore.collection('utenti').doc(currentUid).update({
      'nome': nome,
      'cognome': cognome,
      'telefono': telefono,
      'lastUpdate': FieldValue.serverTimestamp(),
    });
  }

  // Metodo per recuperare in tempo reale tutti gli utenti dello stesso studio 
  Stream<QuerySnapshot> ottieniUtentiPerStudio(String studioId) {
    return _firestore
        .collection('utenti')
        .where('studioId', isEqualTo: studioId)
        .snapshots();
  }
}
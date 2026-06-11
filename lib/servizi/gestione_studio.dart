import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import '../modelli/studio_model.dart';

class GestioneStudioService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //Metodo per creare un nuovo studio
  Future<String> creaStudio(String nomeStudio, String utenteCreatoreId) async {
    try {
      //Genera un codice di invito univoco di 6 caratteri alfanumerici
      String codiceInvito = _generaCodiceInvito();

      //Crea l'oggetto Studio
      StudioModel nuovoStudio = StudioModel(
        id: '', // L'ID verrà generato automaticamente da Firestore
        nome: nomeStudio,
        codiceInvito: codiceInvito,
        adminId: utenteCreatoreId,
        membri: [utenteCreatoreId], // Il creatore è il primo membro
        dataCreazione: DateTime.now(),
      );

      // Salva lo studio nella collezione 'studi'
      DocumentReference docRef = await _firestore.collection('studi').add(nuovoStudio.toFirestore());

      // Aggiorna il profilo dell'utente creatore per legarlo allo studio
      await _firestore.collection('utenti').doc(utenteCreatoreId).update({
        'studioId': docRef.id,
        'ruolo': 'admin', // chi crea lo studio diventa automaticamente admin
      });

      // Ritorna il codice di invito da mostrare a schermo
      return codiceInvito; 
    } catch (e) {
      throw Exception("Errore durante la creazione dello studio: $e");
    }
  }

  // Metodo per accedere a uno studio esistente tramite codice di invito
  Future<void> accediAStudio(String codiceInvito, String utenteId) async {
    try {
      // Cerca lo studio che ha questo codice di invito
      QuerySnapshot query = await _firestore
          .collection('studi')
          .where('codiceInvito', isEqualTo: codiceInvito)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        throw Exception("Codice invito non valido o studio inesistente.");
      }

      // Prende l'ID dello studio trovato
      String studioId = query.docs.first.id;

      // Aggiunge l'utente all'array dei membri dello studio
      await _firestore.collection('studi').doc(studioId).update({
        'membri': FieldValue.arrayUnion([utenteId])
      });

      // Aggiorna il profilo dell'utente per legarlo allo studio
      await _firestore.collection('utenti').doc(utenteId).update({
        'studioId': studioId,
        // Aggiunge un ruolo 'default' per gli utenti che accedono tramite codice
        'ruolo': 'User'
      });
      
    } catch (e) {
      throw Exception("Errore durante l'accesso allo studio: $e");
    }
  }

  // Funzione di supportoper generare il codice casuale
  String _generaCodiceInvito() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random rnd = Random();
    return String.fromCharCodes(Iterable.generate(
        6, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
  }
}
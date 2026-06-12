import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
// Sostituisci con il percorso corretto del tuo modello
import '../modelli/studio_model.dart'; 

class GestioneStudioService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Metodo per creare un nuovo studio (AGGIORNATO con Partita IVA)
  Future<String> creaStudio(String nomeStudio, String partitaIva, String utenteCreatoreId) async {
    try {
      // Genera un codice di invito univoco di 6 caratteri alfanumerici
      String codiceInvito = _generaCodiceInvito();

      // Crea l'oggetto Studio
      StudioModel nuovoStudio = StudioModel(
        id: '', // L'ID verrà generato automaticamente da Firestore
        nome: nomeStudio,
        partitaIva: partitaIva, // <-- Aggiunto
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
      // Ricerca dello studio tramite il codice di invito
      QuerySnapshot query = await _firestore
          .collection('studi')
          .where('codiceInvito', isEqualTo: codiceInvito)
          .limit(1)
          .get();

      // Verifica dell'esistenza dello studio
      if (query.docs.isEmpty) {
        throw Exception("Codice invito non valido o studio inesistente.");
      }

      String studioId = query.docs.first.id;

      // Aggiunge l'utente alla lista dei membri dello studio, impostandogli anche il ruolo di default
      await _firestore.collection('studi').doc(studioId).update({
        'membri': FieldValue.arrayUnion([utenteId])
      });

      await _firestore.collection('utenti').doc(utenteId).update({
        'studioId': studioId,
        'ruolo': 'User'
      });
      
    } catch (e) {
      throw Exception("Errore durante l'accesso allo studio: $e");
    }
  }

  // Funzione di supporto per generare il codice casuale
  String _generaCodiceInvito() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random rnd = Random();
    return String.fromCharCodes(Iterable.generate(
        6, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
  }
}
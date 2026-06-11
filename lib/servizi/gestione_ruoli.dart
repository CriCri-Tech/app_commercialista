// Pacchetto che permette di connettersi al cloud di Firestore
import 'package:cloud_firestore/cloud_firestore.dart';
// Libreria che permette operazioni matematiche avanzati
import 'dart:math';

class GestioneRuoli {
  // Riferimento al database
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Metodo privato per verificare che l'utente che esegue l'azione 
  // sia effettivamente un admin e appartenga allo studio specifico.
  Future<void> _verificaPermessiAdmin(String adminId, String studioId) async {
    // Recupera il documento dell'utente
    DocumentSnapshot userDoc = await _firestore.collection('utenti').doc(adminId).get();
    
    // Se l'utente non esiste, lancia un messaggio di erore
    if (!userDoc.exists) {
      throw Exception("Utente amministratore non trovato.");
    }
    
    // Salva i dati dell'utente come una mappa chiave valore
    var userData = userDoc.data() as Map<String, dynamic>;
    
    // If che permette di verificare che l'utente che sta effettuando le operazioni sia effettivamente un admin
    if (userData['ruolo']?.toLowerCase() != 'admin' || userData['studioId'] != studioId) {
      throw Exception("Accesso negato: non hai i permessi di amministratore per questo studio.");
    }
  }

  // Metodo per cambiare il ruolo di un utente dello studio
  Future<void> cambiaRuoloUtente({
    required String adminId,
    required String studioId,
    required String utenteId,
    required String nuovoRuolo,
  }) async {
    await _verificaPermessiAdmin(adminId, studioId);

    if (adminId == utenteId) {
      throw Exception("Operazione non consentita: non puoi modificare il tuo stesso ruolo.");
    }

    // Validazione basata unicamente sui due ruoli previsti
    String ruoloNormalizzato = nuovoRuolo.toLowerCase();
    if (ruoloNormalizzato != 'admin' && ruoloNormalizzato != 'user') {
      throw Exception("Ruolo non valido. I ruoli consentiti sono esclusivamente 'admin' e 'user'.");
    }

    await _firestore.collection('utenti').doc(utenteId).update({
      'ruolo': ruoloNormalizzato,
    });
  }

  // Metodo per kickare un membro dello studio (il membro viene "cacciato" dallo studio, ma si può riunire)
  Future<void> kickUtente({
    required String adminId,
    required String studioId,
    required String utenteDaRimuovereId,
  }) async {
    await _verificaPermessiAdmin(adminId, studioId);

    if (adminId == utenteDaRimuovereId) {
      throw Exception("Operazione non consentita: non puoi auto-escluderti dallo studio.");
    }

    // Rimuove l'ID dell'utente dalla lista dei membri attivi dello studio
    await _firestore.collection('studi').doc(studioId).update({
      'membri': FieldValue.arrayRemove([utenteDaRimuovereId])
    });

    // Scollega lo studio dall'utente e si assicura che il suo ruolo torni 'user' standard
    await _firestore.collection('utenti').doc(utenteDaRimuovereId).update({
      'studioId': FieldValue.delete(),
      'ruolo': 'user', 
    });
  }

  // Metodo per bannare un membro dello studio (il membro viene "cacciato" e non può più riunirsi)
  Future<void> bannaUtente({
    required String adminId,
    required String studioId,
    required String utenteDaBannareId,
  }) async {
    await _verificaPermessiAdmin(adminId, studioId);

    if (adminId == utenteDaBannareId) {
      throw Exception("Operazione non consentita: non puoi bannare te stesso.");
    }

    // Rimuove dai membri e aggiunge contemporaneamente l'ID al vettore 'utentiBannati' nello studio
    await _firestore.collection('studi').doc(studioId).update({
      'membri': FieldValue.arrayRemove([utenteDaBannareId]),
      'utentiBannati': FieldValue.arrayUnion([utenteDaBannareId]) 
    });

    // Resetta l'associazione dello studio sul profilo dell'utente bannato
    await _firestore.collection('utenti').doc(utenteDaBannareId).update({
      'studioId': FieldValue.delete(),
      'ruolo': 'user', // Rimane un utente base del sistema, ma non associato a questo studio
    });
  }

  // Metodo per cambiare il codice di invito dello studio, rendendo invalido quello precedente
  Future<String> cambiaCodiceInvito({
    required String adminId,
    required String studioId,
  }) async {
    await _verificaPermessiAdmin(adminId, studioId);

    String nuovoCodice = _generaCodiceInvito();

    await _firestore.collection('studi').doc(studioId).update({
      'codiceInvito': nuovoCodice,
    });

    return nuovoCodice;
  }

  /// Funzione di supporto alfanumerica per la generazione casuale del codice
  String _generaCodiceInvito() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random rnd = Random();
    return String.fromCharCodes(Iterable.generate(
        6, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
  }
}
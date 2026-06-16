import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Classe dedicata all'interazione con Firebase Authentication e Cloud Firestore.
class Autenticazione {
  // Istanza principale di Firebase Authentication.
  final FirebaseAuth _istanza = FirebaseAuth.instance;

  // Istanza principale di Cloud Firestore.
  final FirebaseFirestore _database = FirebaseFirestore.instance;

  // Recupera l'utente attualmente autenticato nel sistema.
  User? get utenteCorrente => _istanza.currentUser;

  // Fornisce uno stream continuo per monitorare i cambiamenti di stato dell'autenticazione.
  Stream<User?> get statoAutenticazione => _istanza.authStateChanges();

  // RF-00 SIGN UP (Registrazione)
  Future<UserCredential> effettuaRegistrazione({
    required String email,
    required String password,
    required String nome,
    required String cognome,
    required String username,
    required DateTime dataDiNascita,
    String ruolo = 'utente',
  }) async {
    try {
      UserCredential credenziali = await _istanza.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? nuovoUtente = credenziali.user;

      if (nuovoUtente != null) {
        await nuovoUtente.updateDisplayName("$nome $cognome");

        await _database.collection('utenti').doc(nuovoUtente.uid).set({
          'nome': nome,
          'cognome': cognome,
          'username': username, 
          'email': email,
          'dataDiNascita': dataDiNascita.toIso8601String(),
          'ruolo': ruolo,
          'dataCreazione': FieldValue.serverTimestamp(),
        });
      }
      
      return credenziali;
      
    } on FirebaseAuthException catch (errore) {
      if (errore.code == 'weak-password') {
        throw Exception('La password fornita non soddisfa i requisiti minimi di sicurezza (minimo 6 caratteri).');
      } else if (errore.code == 'email-already-in-use') {
        throw Exception('Risulta già un account registrato con l\'indirizzo email fornito.');
      } else if (errore.code == 'invalid-email') {
        throw Exception('Il formato dell\'indirizzo email inserito non è valido.');
      } else {
        throw Exception('Si è verificato un errore durante la registrazione: ${errore.message}');
      }
    } catch (errore) {
      throw Exception('Errore di sistema imprevisto durante il salvataggio dei dati del profilo.');
    }
  }

  // RF-01 LOGIN
  Future<UserCredential> effettuaLogin(String emailUtente, String passwordUtente, {bool ricordami = false}) async {
    try {
      UserCredential credenziali = await _istanza.signInWithEmailAndPassword(
        email: emailUtente, 
        password: passwordUtente,
      );

      // Gestione del Ricordami al login andato a buon fine
      await impostaRicordami(ricordami, email: emailUtente);

      return credenziali;
    } on FirebaseAuthException catch (errore) {
      if (errore.code == 'user-not-found' || errore.code == 'invalid-email') {
        throw Exception('Non è stato individuato alcun account associato a questa email.');
      } else if (errore.code == 'wrong-password' || errore.code == 'invalid-credential') {
        throw Exception('Le credenziali fornite (email o password) risultano errate.');
      } else {
        throw Exception('Errore di sistema durante il tentativo di accesso: ${errore.message}');
      }
    } catch (errore) {
      throw Exception('Impossibile completare la procedura di login. Si prega di verificare la connessione di rete.');
    }
  }

  // RF-02 LOGOUT
  Future<String> effettuaLogout() async {
    try {
      await _istanza.signOut();
      
      // Quando l'utente effettua il logout volontario resettiamo lo stato automatico
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('ricordami', false);
      
      return "Disconnessione effettuata con successo.";
    } catch (errore) {
      throw Exception('Impossibile completare la disconnessione al momento. Si prega di riprovare.');
    }
  }

  // RF-03 RECUPERO PASSWORD
  Future<String> recuperaPassword(String emailUtente) async {
    try {
      await _istanza.sendPasswordResetEmail(email: emailUtente);
      return "Istruzioni per il recupero inviate con successo all'indirizzo: $emailUtente";
    } on FirebaseAuthException catch (errore) {
      if (errore.code == 'user-not-found') {
        throw Exception('Non risulta alcun utente registrato con l\'indirizzo email specificato.');
      } else if (errore.code == 'invalid-email') {
        throw Exception('Il formato dell\'indirizzo email fornito non è valido.');
      } else {
        throw Exception('Errore di sistema durante l\'invio della richiesta: ${errore.message}');
      }
    } catch (errore) {
      throw Exception('Impossibile processare la richiesta di recupero. Riprovare successivamente.');
    }
  }

  // METODI PER LA GESTIONE DEL PROFILO
  Future<Map<String, dynamic>?> ottieniDatiUtente() async {
    User? user = _istanza.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await _database.collection('utenti').doc(user.uid).get();
      return doc.data() as Map<String, dynamic>?;
    }
    return null;
  }

  Future<void> aggiornaDatiUtente({
    required String nome,
    required String cognome,
    required String username,
    required String email,
  }) async {
    User? user = _istanza.currentUser;
    if (user == null) throw Exception("Nessuna sessione utente attiva riscontrata.");

    if (email != user.email) {
      await user.verifyBeforeUpdateEmail(email);
    }

    await _database.collection('utenti').doc(user.uid).update({
      'nome': nome,
      'cognome': cognome,
      'username': username,
      'email': email,
    });

    await user.updateDisplayName("$nome $cognome");
  }

  Future<void> aggiornaPasswordConVerifica(String vecchiaPassword, String nuovaPassword) async {
    User? user = _istanza.currentUser;
    
    if (user == null || user.email == null) {
      throw Exception("Nessuna sessione utente attiva o indirizzo email non disponibile.");
    }

    try {
      AuthCredential credenziali = EmailAuthProvider.credential(
        email: user.email!, 
        password: vecchiaPassword
      );

      await user.reauthenticateWithCredential(credenziali);
      await user.updatePassword(nuovaPassword);
      
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-credential' || e.code == 'wrong-password') {
        throw Exception("La password di sicurezza attuale inserita non risulta corretta.");
      }
      throw Exception("Errore durante l'aggiornamento della password: ${e.message}");
    }
  }

  // FUNZIONI DI SUPPORTO PER SHERED PREFERENCES

  // Salva la scelta dell'utente (se ha spuntato "Ricordami" o no)
  Future<void> impostaRicordami(bool valore, {String? email}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('ricordami', valore);
    
    if (valore && email != null) {
      await prefs.setString('email_salvata', email);
    } else {
      await prefs.remove('email_salvata');
    }
  }

  // Controlla se al riavvio dell'app la funzione "Ricordami" era attiva
  Future<bool> isRicordamiAttivo() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('ricordami') ?? false; 
  }

  // Recupera l'email salvata per metterla nel TextField del login
  Future<String?> getEmailSalvata() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('email_salvata');
  }
}
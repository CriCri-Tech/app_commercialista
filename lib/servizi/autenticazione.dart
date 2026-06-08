import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Autenticazione {
  // Istanze di autenticazione di Firebase
  final FirebaseAuth _istanza = FirebaseAuth.instance;

  // Lettura dell'utente tramite un getter
  User? get utenteCorrente => _istanza.currentUser;

  // Database
  final FirebaseFirestore _database = FirebaseFirestore.instance;

  // Stato dell'autenticazione
  Stream<User?> get statoAutenticazione => _istanza.authStateChanges();

  // RF-00 SIGN IN
  Future < UserCredential ? > effettuaRegistrazione({
      // Dati richiesti per la registrazione
      required String email,
      required String password,
      required String nome,
      required String cognome,
      required DateTime dataDiNascita,
      String ruolo = 'utente' // Valore predefinito per il ruolo (può essere 'utente' o 'amministratore')
    }

  ) async {
    try {
      // Tenta la creazione dell'account su Firebase Auth
      UserCredential credenziali = await _istanza.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? nuovoUtente = credenziali.user;

      if (nuovoUtente != null) {
        // Aggiorna il profilo dell'utente con Nome e Cognome
        await nuovoUtente.updateDisplayName("$nome $cognome");

        // Salva i dati anagrafici e di ruolo nel database        
        // Creazione di un documento con ID uguale all'UID dell'utente per una facile associazione tra Auth e Firestore
        await _database.collection('utenti').doc(nuovoUtente.uid).set({
            'nome': nome,
            'cognome': cognome,
            'email': email,
            // Conversione della data di nascita come stringa
            'dataDiNascita': dataDiNascita.toIso8601String(),
            'ruolo': ruolo,
            // Salvataggio della data di creazione dell'account 
            'dataCreazione': FieldValue.serverTimestamp(),
          }

        );

        debugPrint("Registrazione completata. Utente: ${nuovoUtente.email} | Ruolo: $ruolo");
      }
      return credenziali;
    }
    on FirebaseAuthException catch (errore) {
      // Gestione degli errori specifici di Firebase Auth
      if (errore.code == 'weak-password') {
        throw Exception('La password fornita è troppo debole (minimo 6 caratteri).');
      } else if (errore.code == 'email-already-in-use') {
        throw Exception('Esiste già un account registrato con questa email.');
      } else if (errore.code == 'invalid-email') {
        throw Exception('Il formato dell\'email non è valido.');
      } else {
        throw Exception('Errore durante la registrazione: ${errore.message}');
      }
    } catch (errore) {
      throw Exception('Errore imprevisto durante il salvataggio dei dati del profilo.');
    }
  }

  
  // RF-01 LOGIN
  
  Future<UserCredential> effettuaLogin(String emailUtente, String passwordUtente) async {
    try {
      // Legge email e password e tenta di effettuare il login con Firebase Authentication
      UserCredential credenziali = await _istanza.signInWithEmailAndPassword(email: emailUtente, password: passwordUtente);
      debugPrint("Login effettuato con successo: ${credenziali.user?.email}"); //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      return credenziali;
    }
    on FirebaseAuthException catch (errore) {
      // Errore nel caso in cui l'email non è registrata o è inserita male
      if (errore.code == 'user-not-found' || errore.code == 'invalid-email') {
        throw Exception('Nessun account trovato con questa email.');
      } else if (errore.code == 'wrong-password' || errore.code == 'invalid-credential') {
        throw Exception('La password o l\'email inserita è errata.');
      } else {
        throw Exception('Errore durante il tentativo di accesso: ${errore.message}');
      }
    } catch (errore) {
      throw Exception('Impossibile completare il login. Controlla la tua connessione.');
    }
  }

  
  // RF-02 LOGOUT
  
  Future<String> effettuaLogout() async {
    try {
      // Effettua il logout dell'utente corrente
      await _istanza.signOut();
      debugPrint("Logout effettuato con successo."); //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    } catch (errore) {
      throw Exception('Impossibile effettuare il logout in questo momento. Riprova.');
    }
  }

  
  // RF-03 RECUPERO PASSWORD
  
  Future<String> recuperaPassword(String emailUtente) async {
    try {
      // Invia un'email all'utente con un link sicuro generato da Firebase per reimpostare la password.
      await _istanza.sendPasswordResetEmail(email: emailUtente);
      debugPrint("Email di recupero inviata a: $emailUtente"); // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    }
    on FirebaseAuthException catch (errore) {
      // Gestione di eventuali errori durante l'invio dell'email di recupero
      debugPrint("Errore durante l'invio dell'email di recupero: ${errore.message}"); //!!!!!!!!!!!!!!!!!!!!!!!!!!!
      rethrow;
    }
  }
}
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
      // Tenta la creazione dell'account su Firebase Auth
      UserCredential credenziali = await _istanza.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? nuovoUtente = credenziali.user;

      if (nuovoUtente != null) {
        // Aggiorna il profilo dell'utente con Nome e Cognome
        await nuovoUtente.updateDisplayName("$nome $cognome");

        // Salva i dati anagrafici, il ruolo e l'username su Cloud Firestore
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
      
      // Ritorniamo le credenziali alla UI per confermare il successo
      return credenziali;
      
    } on FirebaseAuthException catch (errore) {
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
      UserCredential credenziali = await _istanza.signInWithEmailAndPassword(
        email: emailUtente, 
        password: passwordUtente,
      );
      return credenziali;
    } on FirebaseAuthException catch (errore) {
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
      await _istanza.signOut();
      return "Disconnessione effettuata con successo.";
    } catch (errore) {
      throw Exception('Impossibile effettuare il logout in questo momento. Riprova.');
    }
  }

  // RF-03 RECUPERO PASSWORD
  Future<String> recuperaPassword(String emailUtente) async {
    try {
      await _istanza.sendPasswordResetEmail(email: emailUtente);
      return "Email di recupero inviata con successo a: $emailUtente";
    } on FirebaseAuthException catch (errore) {
      if (errore.code == 'user-not-found') {
        throw Exception('Nessun utente registrato con questa email.');
      } else if (errore.code == 'invalid-email') {
        throw Exception('Il formato dell\'indirizzo email inserito non è valido.');
      } else {
        throw Exception('Errore durante l\'invio: ${errore.message}');
      }
    } catch (errore) {
      throw Exception('Impossibile inviare l\'email di recupero. Riprova più tardi.');
    }
  }

  // METODI PER GESTIONE PROFILO:
  // Ottiene i dati completi dell'utente da Firestore
  Future<Map<String, dynamic>?> ottieniDatiUtente() async {
    User? user = _istanza.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await _database.collection('utenti').doc(user.uid).get();
      return doc.data() as Map<String, dynamic>?;
    }
    return null;
  }

  // Aggiorna i dati anagrafici su Firestore e il DisplayName su Auth
  Future<void> aggiornaDatiUtente({
    required String nome,
    required String cognome,
    required String username,
    required String email,
  }) async {
    User? user = _istanza.currentUser;
    if (user == null) throw Exception("Utente non connesso");

    // Se l'email è cambiata, aggiorna su Firebase Auth
    if (email != user.email) {
      await user.verifyBeforeUpdateEmail(email);
    }

    // Aggiorna Firestore
    await _database.collection('utenti').doc(user.uid).update({
      'nome': nome,
      'cognome': cognome,
      'username': username,
      'email': email,
    });

    // Aggiorna DisplayName su Auth
    await user.updateDisplayName("$nome $cognome");
  }

  // Aggiorna la password ma prima chiede a Firebase se la vecchia è corretta
  Future<void> aggiornaPasswordConVerifica(String vecchiaPassword, String nuovaPassword) async {
    User? user = _istanza.currentUser;
    // Se per qualche motivo non ho l'utente o la sua email, blocco tutto
    if (user == null || user.email == null) throw Exception("Utente non connesso");

    try {
      // Creo le credenziali mescolando la sua email attuale e la password vecchia che ha appena digitato
      AuthCredential credenziali = EmailAuthProvider.credential(
        email: user.email!, 
        password: vecchiaPassword
      );

      // Ri-autentico l'utente. Se la password vecchia è sbagliata, Firebase lancia un errore qui
      await user.reauthenticateWithCredential(credenziali);

      // Se il codice arriva qui, significa che la vecchia password era giusta dunque via libera per la nuova
      await user.updatePassword(nuovaPassword);
      
    } on FirebaseAuthException catch (e) {
      // Intercetto gli errori specifici di password errata per dare un messaggio più chiaro in italiano
      if (e.code == 'invalid-credential' || e.code == 'wrong-password') {
        throw Exception("La vecchia password inserita non è corretta.");
      }
      // Se è un altro errore, lo rimando su così com'è
      throw Exception(e.message);
    }
  }
}
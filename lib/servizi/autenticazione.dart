import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class Autenticazione {
  // Istanze di autenticazione di Firebase
  final FirebaseAuth _istanza = FirebaseAuth.instance;

  // Lettura dell'utente tramite un getter (può essere null se non c'è un utente autenticato)
  User ? get utenteCorrente => _istanza.currentUser;

  // Database
  final FirebaseFirestore _database = FirebaseFirestore.instance;

  // Stato dell'autenticazione (può essere null se non c'è un utente autenticato)
  Stream < User ? > get statoAutenticazione => _istanza.authStateChanges();

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
      // Crea l'utente nel sistema di Autenticazione (credenziali sicure)
      UserCredential credenziali = await _istanza.createUserWithEmailAndPassword(email: email,password: password,);

      // Variabile che contiene il nuovo utente
      User ? nuovoUtente = credenziali.user;

      if (nuovoUtente != null) {
        // Aggiorna il nome di base in Auth
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
        debugPrint('La password fornita è troppo debole (minimo 6 caratteri).');
      } else if (errore.code == 'email-already-in-use') {
        debugPrint('Esiste già un account registrato con questa email.');
      } else if (errore.code == 'invalid-email') {
        debugPrint('Il formato dell\'email non è valido.');
      } else {
        // Errore generico per altri casi 
        debugPrint('Errore durante la registrazione: ${errore.message}');
      }
      rethrow;
    } catch (errore) {
      // Cattura qualsiasi altro errore (es. problemi di connessione al database)
      debugPrint('Errore imprevisto durante la registrazione: $errore');
      rethrow;
    }
  }

  // RF-01 LOGIN
  Future < UserCredential ? > effettuaLogin(String emailUtente, String passwordUtente) async {
    try {
      // Legge email e password e tenta di effettuare il login con Firebase Authentication
      UserCredential credenziali = await _istanza.signInWithEmailAndPassword(email: emailUtente, password: passwordUtente);
      debugPrint("Login effettuato con successo: ${credenziali.user?.email}"); //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      return credenziali;
    }
    on FirebaseAuthException catch (errore) {
      // Errore nel caso in cui l'email non è registrata o è inserita male
      if (errore.code == 'user-not-found' || errore.code == 'invalid-email') {
        debugPrint('Nessun account trovato con questa email.'); // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      }
      // Errore nel caso in cui la password è errata
      else if (errore.code == 'wrong-password' || errore.code == 'invalid-credential') {
        debugPrint('La password o l\'email inserita è errata.'); //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      } else {
        debugPrint('Errore durante il login: ${errore.message}'); //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      }
      rethrow; // Rilancia l'errore per poterlo mostrare nella UI
    }
  }

  // RF-02 LOGOUT
  Future < void > effettuaLogout() async {
    try {
      // Effettua il logout dell'utente corrente
      await _istanza.signOut();
      debugPrint("Logout effettuato con successo."); //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    } catch (errore) {
      // Gestione di eventuali errori durante il logout
      debugPrint("Errore imprevisto durante il logout: $errore"); //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      rethrow;
    }
  }

  // RF-03 RECUPERO PASSWORD
  Future < void > recuperaPassword(String emailUtente) async {
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
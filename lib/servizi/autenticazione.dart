import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

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
          'username': username, // <-- Salva l'username inserito o predefinito
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
}
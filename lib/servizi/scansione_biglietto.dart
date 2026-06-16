import 'dart:io';
// Pacchetto che permette di scattare/selezionare delle foto dal dispositivo
import 'package:image_picker/image_picker.dart';
// Pacchetto che permette il riconoscimento di testo dalle immagini
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
// Pacchetto che permette di collegarsi al cloud di Firestore
import 'package:cloud_firestore/cloud_firestore.dart';

class ServizioScansioneBiglietto {
  // Apertura dei flussi che permettono la selezione dell'immagine e il riconoscimento del testo
  final ImagePicker _picker = ImagePicker();
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  // Collegamento al database
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Metodo per effettuare una foto al bigliettino da visita
  Future<File?> scattaFoto() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      return File(photo.path);
    }
    return null;
  }

  // Metodo per estrarre il testo ed analizzarlo
  Future<Map<String, dynamic>?> elaboraBiglietto(File imageFile) async {
    try {
      // Conversione dell'immagine nel formato accettato dal lettore, e avvia l'OCR
      final inputImage = InputImage.fromFile(imageFile);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      
      // Recupero del blocco di testo scansionato
      String testoEstratto = recognizedText.text;

      // Divisione del testo in campi singoli
      String email = _estraiEmail(testoEstratto);
      String telefono = _estraiTelefono(testoEstratto);
      String pIva = _estraiPartitaIva(testoEstratto);
      String nomeAzienda = _estraiNomeAzienda(testoEstratto); // Spesso è la riga con font più grande o la prima

      // Mappa dei dati recuperati
      return {
        // I campi vuoti devono essere inseriti dall'utente nella schermata successiva
        'companyName': nomeAzienda,
        'vatNumber': pIva,
        'taxCode': '', 
        'pec': '', 
        'sdiCode': '',
        'phone': telefono,
        'email': email,
        'address': '', 
        'createdAt': FieldValue.serverTimestamp(),
      };
    } catch (e) {
      // Caso di errore durante la lettura OCF del testo
      print("Errore durante l'elaborazione OCR: $e");
      return null;
    }
  }

  // Metodo per salvare il cliente su Firebase, associandolo allo studio corretto
  Future<bool> salvaNuovoCliente(Map<String, dynamic> datiCliente, String studioId) async {
    try {
      // Aggiunta dallo studioId ai dati del cliente, permettendo di salvarlo nel luogo giusto del database
      datiCliente['studioId'] = studioId;

      // 2. Aggiunge un nuovo documento alla collection 'clients' specificata nel FRD
      await _firestore.collection('clients').add(datiCliente);
      
      return true;
    } catch (e) {
      print("Errore nel salvataggio su Firestore: $e");
      return false;
    }
  }

  // Metodi che permettono di estrarre i vari parametri
  String _estraiEmail(String text) {
    RegExp emailRegex = RegExp(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}');
    var match = emailRegex.firstMatch(text);
    return match != null ? match.group(0)! : '';
  }

  String _estraiTelefono(String text) {
    // Cerca numeri di cellulare e fissi italiani standard
    RegExp phoneRegex = RegExp(r'(\+39|0039)?\s?(3\d{2}[\s-]?\d{6,7}|0\d{1,3}[\s-]?\d{5,8})');
    var match = phoneRegex.firstMatch(text);
    return match != null ? match.group(0)! : '';
  }

  String _estraiPartitaIva(String text) {
    // Cerca una sequenza esatta di 11 numeri (P.IVA standard)
    RegExp pIvaRegex = RegExp(r'\b[0-9]{11}\b');
    var match = pIvaRegex.firstMatch(text);
    return match != null ? match.group(0)! : '';
  }

  String _estraiNomeAzienda(String text) {
    // Semplificazione: prende la prima riga di testo che spesso sul biglietto è il nome dell'azienda o del professionista.
    List<String> righe = text.split('\n');
    for (String riga in righe) {
      if (riga.trim().isNotEmpty && riga.trim().length > 2) {
        return riga.trim();
      }
    }
    return '';
  }

  // Chiusura delle risorse
  void dispose() {
    _textRecognizer.close();
  }
}
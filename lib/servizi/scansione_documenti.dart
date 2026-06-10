// Questo set di librerie permette all'app di scansionare un documento cartaceo tramite fotocamera, 
// convertirlo e impaginarlo in un file PDF, e infine salvarlo online sul cloud di Firebase Storage.
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ScansioneDocumenti{
  // Riferimento all'istanza di Firebase Storage per gestire l'upload dei file PDF generati
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Avvia lo Scanner per acquisire un documento cartaceo tramite la fotocamera, con funzione di ritaglio automatico
  Future<File?> avviaScannerECollezionaPdf() async {
    try{
      List<String>? percorsiImmagini = await CunningDocumentScanner.getPictures();
      if(percorsiImmagini == null || percorsiImmagini.isEmpty){
        return null; // Nessuna immagine acquisita
      }

      // Crea un nuovo documento PDF vuoto
      final pdf = pw.Document();

      // Conversione delle pagine in un documento PDF finale
      for (var percorso in percorsiImmagini) {
        // Crea un riferimento al file fisico all'immagine acquisita
        final immagineFile = File(percorso);
        // Legge l'immagine e la trasforma in dati binari
        final immagineBytes = await immagineFile.readAsBytes();
        // Converte i dati in un formato compatibile con il PDF
        final immaginePdf = pw.MemoryImage(immagineBytes);

        // Aggiunge ognuna delle pagine al pdf
        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            build: (pw.Context context) {
              return pw.Center(
                child: pw.Image(immaginePdf, fit: pw.BoxFit.contain),
              );
            },
          )
        );
      }

      // Salvataggio del file nella cache del dispositivo
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final filePdf = File("${directory.path}/documento_$timestamp.pdf");
      await filePdf.writeAsBytes(await pdf.save());
      return filePdf;
    } catch(e){
      debugPrint("Errore durante la scansione o la creazione del PDF: $e");
      return null;
    }
  }

  // Metodo per caricare il file PDF generato su Firebase Storage nella cartella del cliente specificato
  Future<String?> caricaPdfSuStorage(File filePdf, String clientId) async {
    try{
      // Estrazione del nome del file dal percorso completo
      final nomeFile = filePdf.path.split("/").last;

      // Destinazione del file
      final storageRef = _storage.ref().child('clients/$clientId/documents/$nomeFile');

      // Upload del file PDF su Firebase Storage
      final uploadTask = await storageRef.putFile(filePdf);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      // Pulizia della cache
      if (await filePdf.exists()) {
        await filePdf.delete();
      }

      return downloadUrl; // Ritorna l'URL del file caricato su Firebase Storage
    } catch(e){
      debugPrint("Errore durante l'upload del PDF su Firebase Storage: $e");
      return null;
    }
  }
}
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class DocumentiClientePage extends StatelessWidget {
  final String idCliente;
  final String nomeCliente;

  const DocumentiClientePage({
    super.key,
    required this.idCliente,
    required this.nomeCliente,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Documenti - $nomeCliente'),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Recupera i documenti della raccolta 'documents' filtrati per idCliente
        stream: FirebaseFirestore.instance
            .collection('documents')
            .where('idCliente', isEqualTo: idCliente)
            .orderBy('dataCaricamento', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder_open, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'Nessun documento caricato per questo cliente.',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final dati = doc.data() as Map<String, dynamic>;

              final String nomeFile = dati['nomeFile'] ?? 'Documento senza nome';
              final String urlDownload = dati['urlDownload'] ?? '';
              final Timestamp? dataCaricamento = dati['dataCaricamento'] as Timestamp?;
              
              // Calcolo della dimensione leggibile (KB o MB)
              final int? byteSize = dati['dimensioneBytes'] as int?;
              String dimensioneTesto = '';
              if (byteSize != null) {
                dimensioneTesto = byteSize > 1024 * 1024
                    ? '${(byteSize / (1024 * 1024)).toStringAsFixed(2)} MB'
                    : '${(byteSize / 1024).toStringAsFixed(1)} KB';
              }

              // Formattazione data base
              String dataTesto = '';
              if (dataCaricamento != null) {
                final d = dataCaricamento.toDate();
                dataTesto = '${d.day}/${d.month}/${d.year} ${d.hour}:${d.minute.toString().padLeft(2, '0')}';
              }

              return Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 12.0),
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: const Icon(Icons.picture_as_pdf, color: Colors.red, size: 36),
                  title: Text(
                    nomeFile,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    '$dataTesto ${dimensioneTesto.isNotEmpty ? "• $dimensioneTesto" : ""}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: const Icon(Icons.open_in_new, color: Color(0xFF1E3A8A)),
                  onTap: () async {
                    if (urlDownload.isNotEmpty) {
                      final Uri url = Uri.parse(urlDownload);
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url, mode: LaunchMode.externalApplication);
                      } else {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Impossibile aprire il file PDF.'))
                          );
                        }
                      }
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
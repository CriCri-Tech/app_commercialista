import 'package:cloud_firestore/cloud_firestore.dart';
import '../servizi/task_dati.dart';

class TaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //Recupera in tempo reale tutti i task dello studio (Ordinati dal più recente)
  Stream<List<TaskModel>> get tuttiITaskStream {
    return _firestore
        .collection('task')
        .orderBy('dataCreazione', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TaskModel.fromFirestore(doc))
            .toList());
  }

  //Ottiene in tempo reale solo le attività di un determinato utente
  Stream<List<TaskModel>> getTaskAssegnatiA(String utenteId) {
    return _firestore
        .collection('task')
        .where('assegnatoAId', isEqualTo: utenteId)
        .orderBy('dataCreazione', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TaskModel.fromFirestore(doc))
            .toList());
  }

  //Ottiene i task legati a una specifica scheda cliente (Utile per RF-06)
  Stream<List<TaskModel>> getTaskPerCliente(String clienteId) {
    return _firestore
        .collection('task')
        .where('clienteId', isEqualTo: clienteId)
        .orderBy('dataCreazione', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TaskModel.fromFirestore(doc))
            .toList());
  }

  //Logica di persistenza per registrare un nuovo Task
  Future<void> creaTask(TaskModel task) async {
    await _firestore.collection('task').add(task.toFirestore());
  }

  //Modifica solo il booleano di completamento (Tracciamento stato)
  Future<void> aggiornaStatoTask(String taskId, bool isCompletato) async {
    await _firestore.collection('task').doc(taskId).update({
      'completato': isCompletato,
    });
  }

  //Rimuove un'attività dal database
  Future<void> eliminaTask(String taskId) async {
    await _firestore.collection('task').doc(taskId).delete();
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/medication.dart';

class FirestoreService {
  final CollectionReference meds =
      FirebaseFirestore.instance.collection('medications');

  Stream<List<Medication>> getMedications() {
    return meds.orderBy('time').snapshots().map((snapshot) => snapshot.docs
        .map((doc) => Medication.fromMap(doc.id, doc.data() as Map<String, dynamic>))
        .toList());
  }

  Future<void> addMedication(Medication med) {
    return meds.add(med.toMap());
  }

  Future<void> deleteMedication(String id) {
    return meds.doc(id).delete();
  }
}
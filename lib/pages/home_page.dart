import 'package:flutter/material.dart';
import '../models/medication.dart';
import '../services/firestore_service.dart';
import '../widgets/medication_tile.dart';
import 'add_medication_page.dart';

class HomePage extends StatelessWidget {
  final service = FirestoreService();

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text("Medications")),
        body: StreamBuilder<List<Medication>>(
          stream: service.getMedications(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final meds = snapshot.data!;
              return ListView.builder(
                itemCount: meds.length,
                itemBuilder: (context, index) =>
                    MedicationTile(med: meds[index], onDelete: () => service.deleteMedication(meds[index].id)),
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => AddMedicationPage())),
        ),
      );
}
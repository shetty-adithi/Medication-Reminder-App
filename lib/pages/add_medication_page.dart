import 'package:flutter/material.dart';
import '../models/medication.dart';
import '../services/firestore_service.dart';

class AddMedicationPage extends StatefulWidget {
  @override
  State<AddMedicationPage> createState() => _AddMedicationPageState();
}

class _AddMedicationPageState extends State<AddMedicationPage> {
  final _nameController = TextEditingController();
  DateTime? _selectedTime;
  final _service = FirestoreService();

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text("Add Medication")),
        body: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(controller: _nameController, decoration: InputDecoration(labelText: 'Medication Name')),
              SizedBox(height: 16),
              ElevatedButton(
                  onPressed: () async {
                    final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                    if (time != null) {
                      final now = DateTime.now();
                      setState(() {
                        _selectedTime = DateTime(now.year, now.month, now.day, time.hour, time.minute);
                      });
                    }
                  },
                  child: Text("Pick Time")),
              SizedBox(height: 16),
              ElevatedButton(
                  onPressed: () {
                    if (_nameController.text.isNotEmpty && _selectedTime != null) {
                      final med = Medication(id: '', name: _nameController.text, time: _selectedTime!);
                      _service.addMedication(med).then((_) => Navigator.pop(context));
                    }
                  },
                  child: Text("Add")),
            ],
          ),
        ),
      );
}
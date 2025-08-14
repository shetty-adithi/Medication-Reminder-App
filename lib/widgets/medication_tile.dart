import 'package:flutter/material.dart';
import '../models/medication.dart';
import 'package:intl/intl.dart';

class MedicationTile extends StatelessWidget {
  final Medication med;
  final VoidCallback onDelete;

  MedicationTile({required this.med, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(med.name),
      subtitle: Text(DateFormat('hh:mm a').format(med.time)),
      trailing: IconButton(icon: Icon(Icons.delete), onPressed: onDelete),
    );
  }
}
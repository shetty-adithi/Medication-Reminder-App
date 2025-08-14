import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

// Replace these with your actual Firebase Web config
const firebaseConfig = {
  'apiKey': 'AIzaSy…',
  'authDomain': 'medication-reminder-app-411dc.firebaseapp.com',
  'projectId': 'medication-reminder-app-411dc',
  'storageBucket': 'medication-reminder-app-411dc.appspot.com',
  'messagingSenderId': '1078392951398',
  'appId': '1:1078392951398:web:3bebc14ce6f5edd4f953a7',
};

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: firebaseConfig['apiKey']!,
      authDomain: firebaseConfig['authDomain']!,
      projectId: firebaseConfig['projectId']!,
      storageBucket: firebaseConfig['storageBucket']!,
      messagingSenderId: firebaseConfig['messagingSenderId']!,
      appId: firebaseConfig['appId']!,
    ),
  );
  runApp(MedicationReminderApp());
}

class Medication {
  String id, name, dosage;
  TimeOfDay time;
  bool taken;
  Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.time,
    this.taken = false,
  });
}

class MedicationReminderApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medication Reminder',
      theme: ThemeData(primarySwatch: Colors.yellow),
      home: MedicationHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MedicationHomePage extends StatefulWidget {
  @override
  _MedicationHomePageState createState() => _MedicationHomePageState();
}

class _MedicationHomePageState extends State<MedicationHomePage> {
  final _db = FirebaseFirestore.instance;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(minutes: 1), (_) => _checkReminders());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _checkReminders() async {
    var now = TimeOfDay.now();
    var snap = await _db
        .collection('medications')
        .where('timeHour', isEqualTo: now.hour)
        .where('timeMinute', isEqualTo: now.minute)
        .where('taken', isEqualTo: false)
        .get();
    for (var doc in snap.docs) {
      _showReminderDialog(
        Medication(
          id: doc.id,
          name: doc['name'],
          dosage: doc['dosage'],
          time: TimeOfDay(hour: doc['timeHour'], minute: doc['timeMinute']),
        ),
      );
    }
  }

  void _showReminderDialog(Medication med) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Reminder"),
        content: Text("Take ${med.name} (${med.dosage})"),
        actions: [
          TextButton(
            onPressed: () {
              _db.collection('medications').doc(med.id).update({'taken': true});
              Navigator.pop(context);
            },
            child: Text("Taken"),
          ),
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text("Skip")),
        ],
      ),
    );
  }

  Future<void> _addOrEditMedication({Medication? med}) async {
    final nameCtl = TextEditingController(text: med?.name);
    final doseCtl = TextEditingController(text: med?.dosage);
    TimeOfDay selTime = med?.time ?? TimeOfDay.now();

    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
          builder: (c, st) => AlertDialog(
                title: Text(med == null ? "Add Medication" : "Edit Medication"),
                content: Column(mainAxisSize: MainAxisSize.min, children: [
                  TextField(
                      controller: nameCtl,
                      decoration: InputDecoration(labelText: 'Name')),
                  TextField(
                      controller: doseCtl,
                      decoration: InputDecoration(labelText: 'Dosage')),
                  SizedBox(height: 8),
                  ElevatedButton(
                      onPressed: () async {
                        final picked = await showTimePicker(
                            context: c, initialTime: selTime);
                        if (picked != null) st(() => selTime = picked);
                      },
                      child: Text("Time: ${selTime.format(c)}")),
                ]),
                actions: [
                  TextButton(
                    onPressed: () async {
                      final name = nameCtl.text.trim();
                      final dose = doseCtl.text.trim();
                      if (name.isEmpty || dose.isEmpty) return;
                      final data = {
                        'name': name,
                        'dosage': dose,
                        'timeHour': selTime.hour,
                        'timeMinute': selTime.minute,
                        'taken': false,
                      };
                      if (med == null)
                        await _db.collection('medications').add(data);
                      else
                        await _db
                            .collection('medications')
                            .doc(med.id)
                            .update(data);
                      Navigator.pop(c);
                    },
                    child: Text(med == null ? "Add" : "Update"),
                  ),
                ],
              )),
    );
  }

  void _deleteMedication(Medication med) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Delete ${med.name}?"),
        actions: [
          TextButton(
            onPressed: () {
              _db.collection('medications').doc(med.id).delete();
              Navigator.pop(context);
            },
            child: Text("Delete", style: TextStyle(color: Colors.red)),
          ),
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text("Cancel")),
        ],
      ),
    );
  }

  @override
  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Medication Reminder",
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _addOrEditMedication(),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color.fromARGB(255, 104, 196, 226),
              const Color.fromARGB(255, 225, 92, 92),
              const Color.fromARGB(255, 63, 154, 140),
            ],
          ),
        ),
        child: SafeArea(
          child: StreamBuilder<QuerySnapshot>(
            stream: _db.collection('medications').snapshots(),
            builder: (_, snap) {
              if (!snap.hasData)
                return Center(child: CircularProgressIndicator());
              final meds = snap.data!.docs
                  .map((doc) => Medication(
                        id: doc.id,
                        name: doc['name'],
                        dosage: doc['dosage'],
                        time: TimeOfDay(
                            hour: doc['timeHour'], minute: doc['timeMinute']),
                        taken: doc['taken'] ?? false,
                      ))
                  .toList();
              if (meds.isEmpty)
                return Center(
                    child: Text("No medications added.",
                        style: TextStyle(color: Colors.white)));
              return ListView.builder(
                itemCount: meds.length,
                itemBuilder: (_, i) {
                  final med = meds[i];
                  final now = TimeOfDay.now();
                  final medMinutes = med.time.hour * 60 + med.time.minute;
                  final nowMinutes = now.hour * 60 + now.minute;
                  final minutesDiff = medMinutes - nowMinutes;

                  Icon? alertIcon;
                  if (!med.taken) {
                    if (minutesDiff == 0) {
                      alertIcon = Icon(Icons.notifications_active,
                          color: Colors.red); // Due now
                    } else if (minutesDiff > 0 && minutesDiff <= 5) {
                      alertIcon = Icon(Icons.notifications_active,
                          color: Colors.amber); // Coming soon
                    }
                  }

                  return Card(
                    margin: EdgeInsets.all(8),
                    color: Colors.white.withOpacity(0.9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: alertIcon,
                      title: Text(
                        "${med.name} (${med.dosage})",
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          decoration: med.taken
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          color: med.taken ? Colors.grey : Colors.black,
                        ),
                      ),
                      subtitle: Text(
                        "Time: ${med.time.format(ctx)}",
                        style: TextStyle(fontSize: 14),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () => _addOrEditMedication(med: med),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => _deleteMedication(med),
                          ),
                          IconButton(
                            icon: Icon(
                              med.taken
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              color: med.taken ? Colors.green : null,
                            ),
                            onPressed: () => _db
                                .collection('medications')
                                .doc(med.id)
                                .update({'taken': !med.taken}),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

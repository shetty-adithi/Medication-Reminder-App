class Medication {
  final String id;
  final String name;
  final DateTime time;

  Medication({required this.id, required this.name, required this.time});

  factory Medication.fromMap(String id, Map<String, dynamic> data) {
    return Medication(
      id: id,
      name: data['name'],
      time: DateTime.parse(data['time']),
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'time': time.toIso8601String(),
      };
}
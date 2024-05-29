// Create Class that represents mqttdata
class Student {
  final String ticketNumber;
  final String studentNumber;

  Student({required this.ticketNumber, required this.studentNumber});

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      ticketNumber: map['ticketNumber'],
      studentNumber: map['studentNumber'],
    );
  }
}

// Create Class that represents mqttdata
class Student {
  final String ticketNumber;
  final String studentNumber;
  final String question;
  final String name;

  Student(
      {required this.ticketNumber,
      required this.studentNumber,
      required this.question,
      required this.name});

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      ticketNumber: map['ticketNumber'],
      studentNumber: map['studentNumber'],
      question: map['question'],
      name: map['name'],
    );
  }
}

import "package:class_question_queue/models/student.dart";

// Create Class that represents mqttdata
class MQTTData {
  final String messageType;
  final List<Student>? queue;
  final String? studentNumber;
  final String? currentStudentNumber;
  final String? currentName;
  final String? currentTicketNumber;
  final String? currentQuestion;
  final bool? awayFromDesk;

  MQTTData(
      {required this.messageType,
      this.queue,
      this.studentNumber,
      this.currentStudentNumber,
      this.currentName,
      this.currentTicketNumber,
      this.currentQuestion,
      this.awayFromDesk});

  factory MQTTData.fromMap(Map<String, dynamic> map) {
    var queueFromMap = map['queue'] == null ? [] : map['queue'] as List;
    List<Student> queueList =
        queueFromMap.map((item) => Student.fromMap(item)).toList();

    return MQTTData(
        messageType: map['messageType'],
        queue: queueList,
        studentNumber: map['studentNumber'],
        currentStudentNumber: map['currentStudentNumber'],
        currentName: map['currentName'],
        currentTicketNumber: map['currentTicketNumber'],
        currentQuestion: map['currentQuestion'],
        awayFromDesk: map['awayFromDesk']);
  }

  Student? findStudentByNumber(String? studentNumber) {
    if (studentNumber == currentStudentNumber) {
      return Student(
          ticketNumber: currentTicketNumber!,
          studentNumber: studentNumber!,
          question: currentQuestion!,
          name: currentName!);
    }
    if (queue == null) return null;
    for (Student student in queue!) {
      if (student.studentNumber == studentNumber) {
        return student;
      }
    }
    return null;
  }

  String? findStudentIndexByNumber(String? studentNumber) {
    if (queue == null) return null;
    for (int i = 0; i < queue!.length; i++) {
      if (queue![i].studentNumber == studentNumber) {
        return (i + 1).toString();
      }
    }
    return null;
  }
}

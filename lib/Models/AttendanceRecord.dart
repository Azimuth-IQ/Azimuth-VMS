import 'package:firebase_database/firebase_database.dart';

enum AttendanceCheckType {
  DEPARTURE, // Check 1: On bus/gathering point
  ARRIVAL, // Check 2: On location arrival
}

class AttendanceRecord {
  String id;
  String userId; // Phone number
  String eventId;
  String shiftId;
  AttendanceCheckType checkType;
  String timestamp; // ISO8601 string
  String checkedBy; // Phone number of admin/team leader who performed check
  bool present; // true if present, false if absent

  AttendanceRecord({
    required this.id,
    required this.userId,
    required this.eventId,
    required this.shiftId,
    required this.checkType,
    required this.timestamp,
    required this.checkedBy,
    required this.present,
  });

  // Convert to JSON for Firebase
  Map<String, dynamic> toJson() {
    return {'id': id, 'userId': userId, 'eventId': eventId, 'shiftId': shiftId, 'checkType': checkType.name, 'timestamp': timestamp, 'checkedBy': checkedBy, 'present': present};
  }

  // Create from Firebase DataSnapshot
  factory AttendanceRecord.fromDataSnapshot(DataSnapshot snapshot) {
    return AttendanceRecord(
      id: snapshot.child('id').value?.toString() ?? '',
      userId: snapshot.child('userId').value?.toString() ?? '',
      eventId: snapshot.child('eventId').value?.toString() ?? '',
      shiftId: snapshot.child('shiftId').value?.toString() ?? '',
      checkType: AttendanceCheckType.values.firstWhere((e) => e.name == snapshot.child('checkType').value?.toString(), orElse: () => AttendanceCheckType.DEPARTURE),
      timestamp: snapshot.child('timestamp').value?.toString() ?? '',
      checkedBy: snapshot.child('checkedBy').value?.toString() ?? '',
      present: snapshot.child('present').value == true,
    );
  }

  // Copy with method for updates
  AttendanceRecord copyWith({String? id, String? userId, String? eventId, String? shiftId, AttendanceCheckType? checkType, String? timestamp, String? checkedBy, bool? present}) {
    return AttendanceRecord(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      eventId: eventId ?? this.eventId,
      shiftId: shiftId ?? this.shiftId,
      checkType: checkType ?? this.checkType,
      timestamp: timestamp ?? this.timestamp,
      checkedBy: checkedBy ?? this.checkedBy,
      present: present ?? this.present,
    );
  }
}

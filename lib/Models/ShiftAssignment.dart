import 'package:firebase_database/firebase_database.dart';

enum ShiftAssignmentStatus {
  ASSIGNED,
  EXCUSED, // Leave approved but assignment preserved
  COMPLETED,
}

class ShiftAssignment {
  String id;
  String volunteerId; // Phone number
  String shiftId;
  String eventId;
  ShiftAssignmentStatus status;
  String? sublocationId; // Optional sublocation assignment
  String assignedBy; // Phone number of who assigned
  String timestamp; // ISO8601 string

  ShiftAssignment({
    required this.id,
    required this.volunteerId,
    required this.shiftId,
    required this.eventId,
    required this.status,
    this.sublocationId,
    required this.assignedBy,
    required this.timestamp,
  });

  // Convert to JSON for Firebase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'volunteerId': volunteerId,
      'shiftId': shiftId,
      'eventId': eventId,
      'status': status.name,
      'sublocationId': sublocationId,
      'assignedBy': assignedBy,
      'timestamp': timestamp,
    };
  }

  // Create from Firebase DataSnapshot
  factory ShiftAssignment.fromDataSnapshot(DataSnapshot snapshot) {
    return ShiftAssignment(
      id: snapshot.child('id').value?.toString() ?? '',
      volunteerId: snapshot.child('volunteerId').value?.toString() ?? '',
      shiftId: snapshot.child('shiftId').value?.toString() ?? '',
      eventId: snapshot.child('eventId').value?.toString() ?? '',
      status: ShiftAssignmentStatus.values.firstWhere((e) => e.name == snapshot.child('status').value?.toString(), orElse: () => ShiftAssignmentStatus.ASSIGNED),
      sublocationId: snapshot.child('sublocationId').value?.toString(),
      assignedBy: snapshot.child('assignedBy').value?.toString() ?? '',
      timestamp: snapshot.child('timestamp').value?.toString() ?? '',
    );
  }

  // Copy with method for updates
  ShiftAssignment copyWith({
    String? id,
    String? volunteerId,
    String? shiftId,
    String? eventId,
    ShiftAssignmentStatus? status,
    String? sublocationId,
    String? assignedBy,
    String? timestamp,
  }) {
    return ShiftAssignment(
      id: id ?? this.id,
      volunteerId: volunteerId ?? this.volunteerId,
      shiftId: shiftId ?? this.shiftId,
      eventId: eventId ?? this.eventId,
      status: status ?? this.status,
      sublocationId: sublocationId ?? this.sublocationId,
      assignedBy: assignedBy ?? this.assignedBy,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

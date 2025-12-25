import 'package:firebase_database/firebase_database.dart';

enum LeaveRequestStatus { PENDING, APPROVED, REJECTED }

class LeaveRequest {
  String id;
  String volunteerId; // Phone number
  String shiftId;
  String eventId;
  String reason;
  LeaveRequestStatus status;
  String requestedAt; // ISO8601 string
  String? reviewedBy; // Phone number of who approved/rejected
  String? reviewedAt; // ISO8601 string

  LeaveRequest({
    required this.id,
    required this.volunteerId,
    required this.shiftId,
    required this.eventId,
    required this.reason,
    required this.status,
    required this.requestedAt,
    this.reviewedBy,
    this.reviewedAt,
  });

  // Convert to JSON for Firebase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'volunteerId': volunteerId,
      'shiftId': shiftId,
      'eventId': eventId,
      'reason': reason,
      'status': status.name,
      'requestedAt': requestedAt,
      'reviewedBy': reviewedBy,
      'reviewedAt': reviewedAt,
    };
  }

  // Create from Firebase DataSnapshot
  factory LeaveRequest.fromDataSnapshot(DataSnapshot snapshot) {
    return LeaveRequest(
      id: snapshot.child('id').value?.toString() ?? '',
      volunteerId: snapshot.child('volunteerId').value?.toString() ?? '',
      shiftId: snapshot.child('shiftId').value?.toString() ?? '',
      eventId: snapshot.child('eventId').value?.toString() ?? '',
      reason: snapshot.child('reason').value?.toString() ?? '',
      status: LeaveRequestStatus.values.firstWhere((e) => e.name == snapshot.child('status').value?.toString(), orElse: () => LeaveRequestStatus.PENDING),
      requestedAt: snapshot.child('requestedAt').value?.toString() ?? '',
      reviewedBy: snapshot.child('reviewedBy').value?.toString(),
      reviewedAt: snapshot.child('reviewedAt').value?.toString(),
    );
  }

  // Copy with method for updates
  LeaveRequest copyWith({
    String? id,
    String? volunteerId,
    String? shiftId,
    String? eventId,
    String? reason,
    LeaveRequestStatus? status,
    String? requestedAt,
    String? reviewedBy,
    String? reviewedAt,
  }) {
    return LeaveRequest(
      id: id ?? this.id,
      volunteerId: volunteerId ?? this.volunteerId,
      shiftId: shiftId ?? this.shiftId,
      eventId: eventId ?? this.eventId,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      requestedAt: requestedAt ?? this.requestedAt,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      reviewedAt: reviewedAt ?? this.reviewedAt,
    );
  }
}

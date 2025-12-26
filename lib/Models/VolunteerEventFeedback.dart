import 'package:firebase_database/firebase_database.dart';

class VolunteerEventFeedback {
  String id;
  String volunteerId; // Phone number
  String volunteerName; // For display
  String eventId;
  String eventName; // For display
  String shiftId;
  
  // Rating categories (1-5 scale)
  int organizationRating;
  int logisticsRating;
  int communicationRating;
  int managementRating;
  
  // Open-ended feedback
  String message;
  
  String timestamp; // ISO8601 string

  VolunteerEventFeedback({
    required this.id,
    required this.volunteerId,
    required this.volunteerName,
    required this.eventId,
    required this.eventName,
    required this.shiftId,
    required this.organizationRating,
    required this.logisticsRating,
    required this.communicationRating,
    required this.managementRating,
    required this.message,
    required this.timestamp,
  });

  // Calculate average rating
  double get averageRating {
    return (organizationRating + logisticsRating + communicationRating + managementRating) / 4.0;
  }

  // Convert to JSON for Firebase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'volunteerId': volunteerId,
      'volunteerName': volunteerName,
      'eventId': eventId,
      'eventName': eventName,
      'shiftId': shiftId,
      'organizationRating': organizationRating,
      'logisticsRating': logisticsRating,
      'communicationRating': communicationRating,
      'managementRating': managementRating,
      'message': message,
      'timestamp': timestamp,
    };
  }

  // Create from Firebase DataSnapshot
  factory VolunteerEventFeedback.fromDataSnapshot(DataSnapshot snapshot) {
    return VolunteerEventFeedback(
      id: snapshot.child('id').value?.toString() ?? '',
      volunteerId: snapshot.child('volunteerId').value?.toString() ?? '',
      volunteerName: snapshot.child('volunteerName').value?.toString() ?? '',
      eventId: snapshot.child('eventId').value?.toString() ?? '',
      eventName: snapshot.child('eventName').value?.toString() ?? '',
      shiftId: snapshot.child('shiftId').value?.toString() ?? '',
      organizationRating: int.tryParse(snapshot.child('organizationRating').value?.toString() ?? '3') ?? 3,
      logisticsRating: int.tryParse(snapshot.child('logisticsRating').value?.toString() ?? '3') ?? 3,
      communicationRating: int.tryParse(snapshot.child('communicationRating').value?.toString() ?? '3') ?? 3,
      managementRating: int.tryParse(snapshot.child('managementRating').value?.toString() ?? '3') ?? 3,
      message: snapshot.child('message').value?.toString() ?? '',
      timestamp: snapshot.child('timestamp').value?.toString() ?? '',
    );
  }

  // Copy with method for updates
  VolunteerEventFeedback copyWith({
    String? id,
    String? volunteerId,
    String? volunteerName,
    String? eventId,
    String? eventName,
    String? shiftId,
    int? organizationRating,
    int? logisticsRating,
    int? communicationRating,
    int? managementRating,
    String? message,
    String? timestamp,
  }) {
    return VolunteerEventFeedback(
      id: id ?? this.id,
      volunteerId: volunteerId ?? this.volunteerId,
      volunteerName: volunteerName ?? this.volunteerName,
      eventId: eventId ?? this.eventId,
      eventName: eventName ?? this.eventName,
      shiftId: shiftId ?? this.shiftId,
      organizationRating: organizationRating ?? this.organizationRating,
      logisticsRating: logisticsRating ?? this.logisticsRating,
      communicationRating: communicationRating ?? this.communicationRating,
      managementRating: managementRating ?? this.managementRating,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

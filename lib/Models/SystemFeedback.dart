import 'package:firebase_database/firebase_database.dart';

enum FeedbackStatus { PENDING, IN_PROGRESS, RESOLVED, CLOSED }

class SystemFeedback {
  String id;
  String userId; // Phone number of user who submitted
  String userName; // Name for display
  String message;
  FeedbackStatus status;
  String timestamp; // ISO8601 string
  String? reviewedBy; // Phone number of admin who reviewed
  String? reviewedAt; // ISO8601 string
  String? resolutionNotes;

  SystemFeedback({
    required this.id,
    required this.userId,
    required this.userName,
    required this.message,
    required this.status,
    required this.timestamp,
    this.reviewedBy,
    this.reviewedAt,
    this.resolutionNotes,
  });

  // Convert to JSON for Firebase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'message': message,
      'status': status.name,
      'timestamp': timestamp,
      'reviewedBy': reviewedBy,
      'reviewedAt': reviewedAt,
      'resolutionNotes': resolutionNotes,
    };
  }

  // Create from Firebase DataSnapshot
  factory SystemFeedback.fromDataSnapshot(DataSnapshot snapshot) {
    return SystemFeedback(
      id: snapshot.child('id').value?.toString() ?? '',
      userId: snapshot.child('userId').value?.toString() ?? '',
      userName: snapshot.child('userName').value?.toString() ?? '',
      message: snapshot.child('message').value?.toString() ?? '',
      status: FeedbackStatus.values.firstWhere(
        (e) => e.name == snapshot.child('status').value?.toString(),
        orElse: () => FeedbackStatus.PENDING,
      ),
      timestamp: snapshot.child('timestamp').value?.toString() ?? '',
      reviewedBy: snapshot.child('reviewedBy').value?.toString(),
      reviewedAt: snapshot.child('reviewedAt').value?.toString(),
      resolutionNotes: snapshot.child('resolutionNotes').value?.toString(),
    );
  }

  // Copy with method for updates
  SystemFeedback copyWith({
    String? id,
    String? userId,
    String? userName,
    String? message,
    FeedbackStatus? status,
    String? timestamp,
    String? reviewedBy,
    String? reviewedAt,
    String? resolutionNotes,
  }) {
    return SystemFeedback(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      message: message ?? this.message,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      resolutionNotes: resolutionNotes ?? this.resolutionNotes,
    );
  }
}

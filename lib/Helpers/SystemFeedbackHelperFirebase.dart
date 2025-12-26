import 'package:azimuth_vms/Models/SystemFeedback.dart';
import 'package:firebase_database/firebase_database.dart';

class SystemFeedbackHelperFirebase {
  static final DatabaseReference _ref = FirebaseDatabase.instance.ref();

  // Create feedback
  static Future<void> CreateFeedback(SystemFeedback feedback) async {
    try {
      final feedbackRef = _ref.child('ihs/systemFeedback/${feedback.id}');
      await feedbackRef.set(feedback.toJson());
      print('System feedback created: ${feedback.id}');
    } catch (e) {
      print('Error creating system feedback: $e');
      rethrow;
    }
  }

  // Get feedback by ID
  static Future<SystemFeedback?> GetFeedbackById(String feedbackId) async {
    try {
      final snapshot = await _ref.child('ihs/systemFeedback/$feedbackId').get();
      
      if (!snapshot.exists) {
        return null;
      }
      
      return SystemFeedback.fromDataSnapshot(snapshot);
    } catch (e) {
      print('Error getting feedback: $e');
      return null;
    }
  }

  // Get all feedback
  static Future<List<SystemFeedback>> GetAllFeedback() async {
    try {
      final snapshot = await _ref.child('ihs/systemFeedback').get();
      
      if (!snapshot.exists) {
        return [];
      }
      
      List<SystemFeedback> feedbackList = [];
      for (DataSnapshot d1 in snapshot.children) {
        feedbackList.add(SystemFeedback.fromDataSnapshot(d1));
      }
      
      // Sort by timestamp (newest first)
      feedbackList.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      return feedbackList;
    } catch (e) {
      print('Error getting all feedback: $e');
      return [];
    }
  }

  // Get feedback by user
  static Future<List<SystemFeedback>> GetFeedbackByUser(String userId) async {
    try {
      final snapshot = await _ref.child('ihs/systemFeedback').get();
      
      if (!snapshot.exists) {
        return [];
      }
      
      List<SystemFeedback> feedbackList = [];
      for (DataSnapshot d1 in snapshot.children) {
        final feedback = SystemFeedback.fromDataSnapshot(d1);
        if (feedback.userId == userId) {
          feedbackList.add(feedback);
        }
      }
      
      // Sort by timestamp (newest first)
      feedbackList.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      return feedbackList;
    } catch (e) {
      print('Error getting user feedback: $e');
      return [];
    }
  }

  // Get feedback by status
  static Future<List<SystemFeedback>> GetFeedbackByStatus(FeedbackStatus status) async {
    try {
      final snapshot = await _ref.child('ihs/systemFeedback').get();
      
      if (!snapshot.exists) {
        return [];
      }
      
      List<SystemFeedback> feedbackList = [];
      for (DataSnapshot d1 in snapshot.children) {
        final feedback = SystemFeedback.fromDataSnapshot(d1);
        if (feedback.status == status) {
          feedbackList.add(feedback);
        }
      }
      
      // Sort by timestamp (newest first)
      feedbackList.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      return feedbackList;
    } catch (e) {
      print('Error getting feedback by status: $e');
      return [];
    }
  }

  // Update feedback
  static Future<void> UpdateFeedback(SystemFeedback feedback) async {
    try {
      final feedbackRef = _ref.child('ihs/systemFeedback/${feedback.id}');
      await feedbackRef.update(feedback.toJson());
      print('System feedback updated: ${feedback.id}');
    } catch (e) {
      print('Error updating system feedback: $e');
      rethrow;
    }
  }

  // Delete feedback
  static Future<void> DeleteFeedback(String feedbackId) async {
    try {
      await _ref.child('ihs/systemFeedback/$feedbackId').remove();
      print('System feedback deleted: $feedbackId');
    } catch (e) {
      print('Error deleting system feedback: $e');
      rethrow;
    }
  }

  // Stream all feedback (real-time)
  static Stream<List<SystemFeedback>> StreamAllFeedback() {
    return _ref.child('ihs/systemFeedback').onValue.map((event) {
      List<SystemFeedback> feedbackList = [];
      
      if (event.snapshot.exists) {
        for (DataSnapshot d1 in event.snapshot.children) {
          try {
            feedbackList.add(SystemFeedback.fromDataSnapshot(d1));
          } catch (e) {
            print('Error parsing feedback in stream: $e');
          }
        }
      }
      
      // Sort by timestamp (newest first)
      feedbackList.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      return feedbackList;
    });
  }

  // Stream pending feedback (real-time)
  static Stream<List<SystemFeedback>> StreamPendingFeedback() {
    return StreamAllFeedback().map((feedbackList) {
      return feedbackList.where((f) => f.status == FeedbackStatus.PENDING).toList();
    });
  }
}

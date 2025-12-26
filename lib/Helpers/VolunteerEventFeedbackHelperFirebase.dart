import 'package:azimuth_vms/Models/VolunteerEventFeedback.dart';
import 'package:firebase_database/firebase_database.dart';

class VolunteerEventFeedbackHelperFirebase {
  static final DatabaseReference _ref = FirebaseDatabase.instance.ref();

  // Create feedback
  static Future<void> CreateFeedback(VolunteerEventFeedback feedback) async {
    try {
      final feedbackRef = _ref.child('ihs/eventFeedback/${feedback.eventId}/${feedback.id}');
      await feedbackRef.set(feedback.toJson());
      print('Event feedback created: ${feedback.id}');
    } catch (e) {
      print('Error creating event feedback: $e');
      rethrow;
    }
  }

  // Get feedback by ID
  static Future<VolunteerEventFeedback?> GetFeedbackById(String eventId, String feedbackId) async {
    try {
      final snapshot = await _ref.child('ihs/eventFeedback/$eventId/$feedbackId').get();

      if (!snapshot.exists) {
        return null;
      }

      return VolunteerEventFeedback.fromDataSnapshot(snapshot);
    } catch (e) {
      print('Error getting event feedback: $e');
      return null;
    }
  }

  // Get all feedback for an event
  static Future<List<VolunteerEventFeedback>> GetFeedbackByEvent(String eventId) async {
    try {
      final snapshot = await _ref.child('ihs/eventFeedback/$eventId').get();

      if (!snapshot.exists) {
        return [];
      }

      List<VolunteerEventFeedback> feedbackList = [];
      for (DataSnapshot d1 in snapshot.children) {
        feedbackList.add(VolunteerEventFeedback.fromDataSnapshot(d1));
      }

      // Sort by timestamp (newest first)
      feedbackList.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return feedbackList;
    } catch (e) {
      print('Error getting feedback for event: $e');
      return [];
    }
  }

  // Get all feedback by volunteer
  static Future<List<VolunteerEventFeedback>> GetFeedbackByVolunteer(String volunteerId) async {
    try {
      final snapshot = await _ref.child('ihs/eventFeedback').get();

      if (!snapshot.exists) {
        return [];
      }

      List<VolunteerEventFeedback> feedbackList = [];
      for (DataSnapshot eventSnapshot in snapshot.children) {
        for (DataSnapshot feedbackSnapshot in eventSnapshot.children) {
          final feedback = VolunteerEventFeedback.fromDataSnapshot(feedbackSnapshot);
          if (feedback.volunteerId == volunteerId) {
            feedbackList.add(feedback);
          }
        }
      }

      // Sort by timestamp (newest first)
      feedbackList.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return feedbackList;
    } catch (e) {
      print('Error getting feedback by volunteer: $e');
      return [];
    }
  }

  // Get all feedback across all events
  static Future<List<VolunteerEventFeedback>> GetAllFeedback() async {
    try {
      final snapshot = await _ref.child('ihs/eventFeedback').get();

      if (!snapshot.exists) {
        return [];
      }

      List<VolunteerEventFeedback> feedbackList = [];
      for (DataSnapshot eventSnapshot in snapshot.children) {
        for (DataSnapshot feedbackSnapshot in eventSnapshot.children) {
          feedbackList.add(VolunteerEventFeedback.fromDataSnapshot(feedbackSnapshot));
        }
      }

      // Sort by timestamp (newest first)
      feedbackList.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return feedbackList;
    } catch (e) {
      print('Error getting all feedback: $e');
      return [];
    }
  }

  // Update feedback
  static Future<void> UpdateFeedback(VolunteerEventFeedback feedback) async {
    try {
      final feedbackRef = _ref.child('ihs/eventFeedback/${feedback.eventId}/${feedback.id}');
      await feedbackRef.update(feedback.toJson());
      print('Event feedback updated: ${feedback.id}');
    } catch (e) {
      print('Error updating event feedback: $e');
      rethrow;
    }
  }

  // Delete feedback
  static Future<void> DeleteFeedback(String eventId, String feedbackId) async {
    try {
      await _ref.child('ihs/eventFeedback/$eventId/$feedbackId').remove();
      print('Event feedback deleted: $feedbackId');
    } catch (e) {
      print('Error deleting event feedback: $e');
      rethrow;
    }
  }

  // Stream feedback for an event (real-time)
  static Stream<List<VolunteerEventFeedback>> StreamFeedbackByEvent(String eventId) {
    return _ref.child('ihs/eventFeedback/$eventId').onValue.map((event) {
      List<VolunteerEventFeedback> feedbackList = [];

      if (event.snapshot.exists) {
        for (DataSnapshot d1 in event.snapshot.children) {
          try {
            feedbackList.add(VolunteerEventFeedback.fromDataSnapshot(d1));
          } catch (e) {
            print('Error parsing event feedback in stream: $e');
          }
        }
      }

      // Sort by timestamp (newest first)
      feedbackList.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return feedbackList;
    });
  }

  // Stream all feedback (real-time)
  static Stream<List<VolunteerEventFeedback>> StreamAllFeedback() {
    return _ref.child('ihs/eventFeedback').onValue.map((event) {
      List<VolunteerEventFeedback> feedbackList = [];

      if (event.snapshot.exists) {
        for (DataSnapshot eventSnapshot in event.snapshot.children) {
          for (DataSnapshot feedbackSnapshot in eventSnapshot.children) {
            try {
              feedbackList.add(VolunteerEventFeedback.fromDataSnapshot(feedbackSnapshot));
            } catch (e) {
              print('Error parsing event feedback in stream: $e');
            }
          }
        }
      }

      // Sort by timestamp (newest first)
      feedbackList.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return feedbackList;
    });
  }

  // Calculate average ratings for an event
  static Future<Map<String, double>> GetEventAverageRatings(String eventId) async {
    try {
      final feedbackList = await GetFeedbackByEvent(eventId);

      if (feedbackList.isEmpty) {
        return {'organization': 0.0, 'logistics': 0.0, 'communication': 0.0, 'management': 0.0, 'overall': 0.0};
      }

      double orgTotal = 0, logTotal = 0, commTotal = 0, mgmtTotal = 0;
      for (var feedback in feedbackList) {
        orgTotal += feedback.organizationRating;
        logTotal += feedback.logisticsRating;
        commTotal += feedback.communicationRating;
        mgmtTotal += feedback.managementRating;
      }

      final count = feedbackList.length;
      return {
        'organization': orgTotal / count,
        'logistics': logTotal / count,
        'communication': commTotal / count,
        'management': mgmtTotal / count,
        'overall': (orgTotal + logTotal + commTotal + mgmtTotal) / (count * 4),
      };
    } catch (e) {
      print('Error calculating event average ratings: $e');
      return {'organization': 0.0, 'logistics': 0.0, 'communication': 0.0, 'management': 0.0, 'overall': 0.0};
    }
  }
}

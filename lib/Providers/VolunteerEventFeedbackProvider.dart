import 'dart:async';
import 'package:azimuth_vms/Helpers/VolunteerEventFeedbackHelperFirebase.dart';
import 'package:azimuth_vms/Models/VolunteerEventFeedback.dart';
import 'package:flutter/material.dart';

class VolunteerEventFeedbackProvider with ChangeNotifier {
  List<VolunteerEventFeedback> _allFeedback = [];
  Map<String, List<VolunteerEventFeedback>> _feedbackByEvent = {};
  StreamSubscription? _feedbackSubscription;
  bool _loading = false;

  // Getters
  List<VolunteerEventFeedback> get allFeedback => _allFeedback;
  Map<String, List<VolunteerEventFeedback>> get feedbackByEvent => _feedbackByEvent;
  bool get loading => _loading;

  // Start listening to all feedback (for admins)
  void startListening() {
    _loading = true;
    notifyListeners();

    _feedbackSubscription = VolunteerEventFeedbackHelperFirebase.StreamAllFeedback().listen(
      (feedbackList) {
        _allFeedback = feedbackList;

        // Group by event
        _feedbackByEvent.clear();
        for (var feedback in feedbackList) {
          if (!_feedbackByEvent.containsKey(feedback.eventId)) {
            _feedbackByEvent[feedback.eventId] = [];
          }
          _feedbackByEvent[feedback.eventId]!.add(feedback);
        }

        _loading = false;
        notifyListeners();
      },
      onError: (error) {
        print('Error streaming event feedback: $error');
        _loading = false;
        notifyListeners();
      },
    );
  }

  // Start listening to feedback for a specific event
  void startListeningToEvent(String eventId) {
    _loading = true;
    notifyListeners();

    _feedbackSubscription?.cancel();
    _feedbackSubscription = VolunteerEventFeedbackHelperFirebase.StreamFeedbackByEvent(eventId).listen(
      (feedbackList) {
        _feedbackByEvent[eventId] = feedbackList;
        _loading = false;
        notifyListeners();
      },
      onError: (error) {
        print('Error streaming event feedback: $error');
        _loading = false;
        notifyListeners();
      },
    );
  }

  // Stop listening
  void stopListening() {
    _feedbackSubscription?.cancel();
    _feedbackSubscription = null;
  }

  // Submit new feedback
  Future<void> submitFeedback({
    required String volunteerId,
    required String volunteerName,
    required String eventId,
    required String eventName,
    required String shiftId,
    required int organizationRating,
    required int logisticsRating,
    required int communicationRating,
    required int managementRating,
    required String message,
  }) async {
    try {
      final now = DateTime.now();
      final feedback = VolunteerEventFeedback(
        id: now.millisecondsSinceEpoch.toString(),
        volunteerId: volunteerId,
        volunteerName: volunteerName,
        eventId: eventId,
        eventName: eventName,
        shiftId: shiftId,
        organizationRating: organizationRating,
        logisticsRating: logisticsRating,
        communicationRating: communicationRating,
        managementRating: managementRating,
        message: message,
        timestamp: now.toIso8601String(),
      );

      await VolunteerEventFeedbackHelperFirebase.CreateFeedback(feedback);
      notifyListeners();
    } catch (e) {
      print('Error submitting event feedback: $e');
      rethrow;
    }
  }

  // Get average ratings for an event
  Future<Map<String, double>> getEventAverageRatings(String eventId) async {
    try {
      return await VolunteerEventFeedbackHelperFirebase.GetEventAverageRatings(eventId);
    } catch (e) {
      print('Error getting event average ratings: $e');
      return {'organization': 0.0, 'logistics': 0.0, 'communication': 0.0, 'management': 0.0, 'overall': 0.0};
    }
  }

  // Get feedback by volunteer
  Future<List<VolunteerEventFeedback>> getVolunteerFeedback(String volunteerId) async {
    try {
      return await VolunteerEventFeedbackHelperFirebase.GetFeedbackByVolunteer(volunteerId);
    } catch (e) {
      print('Error getting volunteer feedback: $e');
      return [];
    }
  }

  // Delete feedback
  Future<void> deleteFeedback(String eventId, String feedbackId) async {
    try {
      await VolunteerEventFeedbackHelperFirebase.DeleteFeedback(eventId, feedbackId);
      notifyListeners();
    } catch (e) {
      print('Error deleting event feedback: $e');
      rethrow;
    }
  }

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }
}

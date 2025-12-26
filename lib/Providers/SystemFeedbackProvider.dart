import 'dart:async';
import 'package:azimuth_vms/Helpers/SystemFeedbackHelperFirebase.dart';
import 'package:azimuth_vms/Models/SystemFeedback.dart';
import 'package:flutter/material.dart';

class SystemFeedbackProvider with ChangeNotifier {
  List<SystemFeedback> _allFeedback = [];
  StreamSubscription? _feedbackSubscription;
  bool _loading = false;

  // Getters
  List<SystemFeedback> get allFeedback => _allFeedback;
  bool get loading => _loading;

  List<SystemFeedback> get pendingFeedback => _allFeedback.where((f) => f.status == FeedbackStatus.PENDING).toList();

  List<SystemFeedback> get inProgressFeedback => _allFeedback.where((f) => f.status == FeedbackStatus.IN_PROGRESS).toList();

  List<SystemFeedback> get resolvedFeedback => _allFeedback.where((f) => f.status == FeedbackStatus.RESOLVED).toList();

  List<SystemFeedback> get closedFeedback => _allFeedback.where((f) => f.status == FeedbackStatus.CLOSED).toList();

  // Start listening to all feedback (for admins)
  void startListening() {
    _loading = true;
    notifyListeners();

    _feedbackSubscription = SystemFeedbackHelperFirebase.StreamAllFeedback().listen(
      (feedbackList) {
        _allFeedback = feedbackList;
        _loading = false;
        notifyListeners();
      },
      onError: (error) {
        print('Error streaming system feedback: $error');
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
  Future<void> submitFeedback({required String userId, required String userName, required String message}) async {
    try {
      final now = DateTime.now();
      final feedback = SystemFeedback(
        id: now.millisecondsSinceEpoch.toString(),
        userId: userId,
        userName: userName,
        message: message,
        status: FeedbackStatus.PENDING,
        timestamp: now.toIso8601String(),
      );

      await SystemFeedbackHelperFirebase.CreateFeedback(feedback);
      notifyListeners();
    } catch (e) {
      print('Error submitting feedback: $e');
      rethrow;
    }
  }

  // Update feedback status
  Future<void> updateFeedbackStatus({required SystemFeedback feedback, required FeedbackStatus newStatus, required String reviewedBy, String? resolutionNotes}) async {
    try {
      final updatedFeedback = feedback.copyWith(status: newStatus, reviewedBy: reviewedBy, reviewedAt: DateTime.now().toIso8601String(), resolutionNotes: resolutionNotes);

      await SystemFeedbackHelperFirebase.UpdateFeedback(updatedFeedback);
      notifyListeners();
    } catch (e) {
      print('Error updating feedback status: $e');
      rethrow;
    }
  }

  // Delete feedback
  Future<void> deleteFeedback(String feedbackId) async {
    try {
      await SystemFeedbackHelperFirebase.DeleteFeedback(feedbackId);
      notifyListeners();
    } catch (e) {
      print('Error deleting feedback: $e');
      rethrow;
    }
  }

  // Get feedback by user
  Future<List<SystemFeedback>> getUserFeedback(String userId) async {
    try {
      return await SystemFeedbackHelperFirebase.GetFeedbackByUser(userId);
    } catch (e) {
      print('Error getting user feedback: $e');
      return [];
    }
  }

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }
}

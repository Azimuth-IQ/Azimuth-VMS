import 'dart:async';
import 'package:azimuth_vms/Helpers/VolunteerRatingHelperFirebase.dart';
import 'package:azimuth_vms/Models/SystemUser.dart';
import 'package:azimuth_vms/Models/VolunteerRating.dart';
import 'package:azimuth_vms/Models/VolunteerRatingCriteria.dart';
import 'package:flutter/material.dart';

class VolunteerRatingProvider with ChangeNotifier {
  // Rating criteria
  List<VolunteerRatingCriteria> _ratingCriteria = [];
  bool _criteriaLoading = false;

  // Volunteers with ratings
  Map<SystemUser, VolunteerRating?> _volunteersWithRatings = {};
  StreamSubscription? _volunteersSubscription;
  bool _volunteersLoading = false;

  // Getters
  List<VolunteerRatingCriteria> get ratingCriteria => _ratingCriteria;
  bool get criteriaLoading => _criteriaLoading;
  Map<SystemUser, VolunteerRating?> get volunteersWithRatings => _volunteersWithRatings;
  bool get volunteersLoading => _volunteersLoading;

  // Initialize and load criteria
  Future<void> loadRatingCriteria() async {
    _criteriaLoading = true;
    notifyListeners();

    try {
      _ratingCriteria = await VolunteerRatingHelperFirebase.GetRatingCriteria();
    } catch (e) {
      print('Error loading rating criteria: $e');
    }

    _criteriaLoading = false;
    notifyListeners();
  }

  // Save rating criteria
  Future<void> saveRatingCriteria(List<VolunteerRatingCriteria> criteria) async {
    try {
      await VolunteerRatingHelperFirebase.SaveRatingCriteria(criteria);
      _ratingCriteria = criteria;
      notifyListeners();
    } catch (e) {
      print('Error saving rating criteria: $e');
      rethrow;
    }
  }

  // Add new criterion
  void addCriterion(String criterionName) {
    _ratingCriteria.add(VolunteerRatingCriteria(Criteria: criterionName));
    notifyListeners();
  }

  // Remove criterion
  void removeCriterion(int index) {
    if (index >= 0 && index < _ratingCriteria.length) {
      _ratingCriteria.removeAt(index);
      notifyListeners();
    }
  }

  // Update criterion
  void updateCriterion(int index, String newName) {
    if (index >= 0 && index < _ratingCriteria.length) {
      _ratingCriteria[index] = VolunteerRatingCriteria(Criteria: newName);
      notifyListeners();
    }
  }

  // Initialize default criteria if needed
  Future<void> initializeDefaultCriteria() async {
    try {
      await VolunteerRatingHelperFirebase.InitializeDefaultCriteria();
      await loadRatingCriteria();
    } catch (e) {
      print('Error initializing default criteria: $e');
    }
  }

  // Start listening to volunteers with ratings
  void startListeningToVolunteers() {
    print('📡 VolunteerRatingProvider: Starting to listen to volunteers...');
    _volunteersLoading = true;
    notifyListeners();

    _volunteersSubscription = VolunteerRatingHelperFirebase.StreamVolunteersWithRatings().listen(
      (data) {
        print('📡 VolunteerRatingProvider: Received data with ${data.length} volunteers');
        _volunteersWithRatings = data;
        _volunteersLoading = false;
        notifyListeners();
      },
      onError: (error) {
        print('❌ VolunteerRatingProvider: Error streaming volunteers with ratings: $error');
        _volunteersLoading = false;
        notifyListeners();
      },
    );
  }

  // Stop listening to volunteers
  void stopListeningToVolunteers() {
    _volunteersSubscription?.cancel();
    _volunteersSubscription = null;
  }

  // Save volunteer rating
  Future<void> saveVolunteerRating(String volunteerId, Map<VolunteerRatingCriteria, int> ratings, List<String> notes) async {
    try {
      final now = DateTime.now();
      final rating = VolunteerRating(
        id: now.millisecondsSinceEpoch.toString(),
        ratings: ratings,
        Date: '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
        Time: '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
        Notes: notes,
      );

      await VolunteerRatingHelperFirebase.SaveVolunteerRating(volunteerId, rating);

      // Also save to history for tracking
      await VolunteerRatingHelperFirebase.AddRatingHistory(volunteerId, rating);

      notifyListeners();
    } catch (e) {
      print('Error saving volunteer rating: $e');
      rethrow;
    }
  }

  // Get average score for a volunteer
  double getAverageScore(VolunteerRating? rating) {
    if (rating == null) return 0.0;
    return VolunteerRatingHelperFirebase.CalculateAverageScore(rating);
  }

  // Get rating history for a volunteer
  Future<List<VolunteerRating>> getRatingHistory(String volunteerId) async {
    try {
      return await VolunteerRatingHelperFirebase.GetRatingHistory(volunteerId);
    } catch (e) {
      print('Error getting rating history: $e');
      return [];
    }
  }

  // Get volunteers sorted by rating (highest first)
  List<MapEntry<SystemUser, VolunteerRating?>> getVolunteersSortedByRating() {
    var entries = _volunteersWithRatings.entries.toList();
    entries.sort((a, b) {
      double scoreA = getAverageScore(a.value);
      double scoreB = getAverageScore(b.value);
      return scoreB.compareTo(scoreA); // Descending order
    });
    return entries;
  }

  // Filter volunteers by role
  Map<SystemUser, VolunteerRating?> getVolunteersByRole(SystemUserRole role) {
    return Map.fromEntries(_volunteersWithRatings.entries.where((entry) => entry.key.role == role));
  }

  @override
  void dispose() {
    stopListeningToVolunteers();
    super.dispose();
  }
}

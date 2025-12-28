import 'package:azimuth_vms/Models/SystemUser.dart';
import 'package:azimuth_vms/Models/VolunteerRating.dart';
import 'package:azimuth_vms/Models/VolunteerRatingCriteria.dart';
import 'package:firebase_database/firebase_database.dart';

class VolunteerRatingHelperFirebase {
  static final DatabaseReference _ref = FirebaseDatabase.instance.ref();

  // ==================== RATING CRITERIA MANAGEMENT ====================

  // Create or update rating criteria
  static Future<void> SaveRatingCriteria(List<VolunteerRatingCriteria> criteria) async {
    try {
      final criteriaRef = _ref.child('ihs/ratingCriteria');

      // Clear existing criteria
      await criteriaRef.remove();

      // Save new criteria
      Map<String, dynamic> criteriaMap = {};
      for (int i = 0; i < criteria.length; i++) {
        criteriaMap[i.toString()] = criteria[i].toJson();
      }

      await criteriaRef.set(criteriaMap);
      print('Rating criteria saved successfully');
    } catch (e) {
      print('Error saving rating criteria: $e');
      rethrow;
    }
  }

  // Get all rating criteria
  static Future<List<VolunteerRatingCriteria>> GetRatingCriteria() async {
    try {
      final snapshot = await _ref.child('ihs/ratingCriteria').get();

      if (!snapshot.exists) {
        // Return default criteria if none exist
        return _getDefaultCriteria();
      }

      List<VolunteerRatingCriteria> criteria = [];
      for (DataSnapshot d1 in snapshot.children) {
        criteria.add(VolunteerRatingCriteria.fromDataSnapshot(d1));
      }

      return criteria;
    } catch (e) {
      print('Error getting rating criteria: $e');
      return _getDefaultCriteria();
    }
  }

  // Initialize default criteria
  static Future<void> InitializeDefaultCriteria() async {
    try {
      final existing = await GetRatingCriteria();
      if (existing.isEmpty) {
        await SaveRatingCriteria(_getDefaultCriteria());
        print('Default rating criteria initialized');
      }
    } catch (e) {
      print('Error initializing default criteria: $e');
    }
  }

  // Get default criteria list
  static List<VolunteerRatingCriteria> _getDefaultCriteria() {
    return [
      VolunteerRatingCriteria(Criteria: 'Adherence to the dress code'),
      VolunteerRatingCriteria(Criteria: 'Adherence to the location of the event'),
      VolunteerRatingCriteria(Criteria: 'Adherence to Instructions'),
      VolunteerRatingCriteria(Criteria: 'Presence Score'),
      VolunteerRatingCriteria(Criteria: 'Interaction with Visitors'),
      VolunteerRatingCriteria(Criteria: 'Active Cooperation with Other Employees'),
      VolunteerRatingCriteria(Criteria: 'Time Commitment'),
    ];
  }

  // ==================== VOLUNTEER RATING MANAGEMENT ====================

  // Create or update volunteer rating
  static Future<void> SaveVolunteerRating(String volunteerId, VolunteerRating rating) async {
    try {
      final userRef = _ref.child('ihs/systemusers/$volunteerId');

      // Save rating to user's volunteerRating field
      await userRef.child('volunteerRating').set(rating.toJson());

      print('Volunteer rating saved for $volunteerId');
    } catch (e) {
      print('Error saving volunteer rating: $e');
      rethrow;
    }
  }

  // Get volunteer rating
  static Future<VolunteerRating?> GetVolunteerRating(String volunteerId) async {
    try {
      final snapshot = await _ref.child('ihs/systemusers/$volunteerId/volunteerRating').get();

      if (!snapshot.exists) {
        return null;
      }

      return VolunteerRating.fromDataSnapshot(snapshot);
    } catch (e) {
      print('Error getting volunteer rating: $e');
      return null;
    }
  }

  // Calculate average score from ratings
  static double CalculateAverageScore(VolunteerRating rating) {
    if (rating.ratings.isEmpty) {
      return 0.0;
    }

    int total = 0;
    rating.ratings.forEach((criteria, score) {
      total += score;
    });

    return total / rating.ratings.length;
  }

  // Get all volunteers with their ratings
  static Future<Map<SystemUser, VolunteerRating?>> GetAllVolunteersWithRatings() async {
    try {
      final snapshot = await _ref.child('ihs/systemusers').get();

      Map<SystemUser, VolunteerRating?> result = {};

      for (DataSnapshot d1 in snapshot.children) {
        SystemUser user = SystemUser.fromDataSnapshot(d1);

        // Only include volunteers and team leaders
        if (user.role == SystemUserRole.VOLUNTEER || user.role == SystemUserRole.TEAMLEADER) {
          result[user] = user.volunteerRating;
        }
      }

      return result;
    } catch (e) {
      print('Error getting volunteers with ratings: $e');
      return {};
    }
  }

  // Stream all volunteers with ratings (for real-time updates)
  static Stream<Map<SystemUser, VolunteerRating?>> StreamVolunteersWithRatings() {
    return _ref.child('ihs/systemusers').onValue.map((event) {
      Map<SystemUser, VolunteerRating?> result = {};

      print('🔍 StreamVolunteersWithRatings: Snapshot exists: ${event.snapshot.exists}');

      if (event.snapshot.exists) {
        print('🔍 Total children in systemUsers: ${event.snapshot.children.length}');

        for (DataSnapshot d1 in event.snapshot.children) {
          try {
            SystemUser user = SystemUser.fromDataSnapshot(d1);
            print('🔍 Found user: ${user.name}, Role: ${user.role}, Phone: ${user.phone}');

            // Only include volunteers and team leaders
            if (user.role == SystemUserRole.VOLUNTEER || user.role == SystemUserRole.TEAMLEADER) {
              result[user] = user.volunteerRating;
              print('✅ Added user to result: ${user.name}');
            } else {
              print('⏭️  Skipped user ${user.name} - role is ${user.role}');
            }
          } catch (e) {
            print('❌ Error parsing user in stream: $e');
            print('   Snapshot key: ${d1.key}');
          }
        }
      }

      print('🔍 Final result count: ${result.length}');
      return result;
    });
  }

  // Add a rating record to history (optional - for tracking rating changes over time)
  static Future<void> AddRatingHistory(String volunteerId, VolunteerRating rating) async {
    try {
      final historyRef = _ref.child('ihs/ratingHistory/$volunteerId');
      final newHistoryRef = historyRef.push();

      await newHistoryRef.set(rating.toJson());

      print('Rating history added for $volunteerId');
    } catch (e) {
      print('Error adding rating history: $e');
      // Don't rethrow - this is optional functionality
    }
  }

  // Get rating history for a volunteer
  static Future<List<VolunteerRating>> GetRatingHistory(String volunteerId) async {
    try {
      final snapshot = await _ref.child('ihs/ratingHistory/$volunteerId').get();

      if (!snapshot.exists) {
        return [];
      }

      List<VolunteerRating> history = [];
      for (DataSnapshot d1 in snapshot.children) {
        history.add(VolunteerRating.fromDataSnapshot(d1));
      }

      // Sort by date and time (newest first)
      history.sort((a, b) {
        int dateCompare = b.Date.compareTo(a.Date);
        if (dateCompare != 0) return dateCompare;
        return b.Time.compareTo(a.Time);
      });

      return history;
    } catch (e) {
      print('Error getting rating history: $e');
      return [];
    }
  }
}

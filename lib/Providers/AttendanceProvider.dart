import 'dart:async';
import 'package:flutter/foundation.dart';
import '../Helpers/AttendanceHelperFirebase.dart';
import '../Models/AttendanceRecord.dart';

class AttendanceProvider with ChangeNotifier {
  final AttendanceHelperFirebase _helper = AttendanceHelperFirebase();

  Map<String, List<AttendanceRecord>> _recordsByUser = {};
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription? _streamSubscription;

  Map<String, List<AttendanceRecord>> get recordsByUser => _recordsByUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Get all users with their attendance records
  List<String> get userIds => _recordsByUser.keys.toList();

  // Get attendance records for a specific user
  List<AttendanceRecord> getRecordsForUser(String userId) {
    return _recordsByUser[userId] ?? [];
  }

  // Check if user has completed a specific check type
  bool hasCompletedCheck(String userId, AttendanceCheckType checkType) {
    final records = getRecordsForUser(userId);
    return records.any((r) => r.checkType == checkType && r.present);
  }

  // Get specific check record for a user on a specific date
  AttendanceRecord? getCheckRecord(String userId, AttendanceCheckType checkType, {DateTime? date}) {
    final records = getRecordsForUser(userId);
    final targetDate = date ?? DateTime.now();
    
    try {
      return records.firstWhere((r) {
        if (r.checkType != checkType) return false;
        
        final recordDate = DateTime.parse(r.timestamp);
        return recordDate.year == targetDate.year && 
               recordDate.month == targetDate.month && 
               recordDate.day == targetDate.day;
      });
    } catch (e) {
      return null;
    }
  }

  // Load attendance records for a specific event
  Future<void> loadRecordsByEvent(String eventId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _recordsByUser = await _helper.GetAttendanceRecordsByEvent(eventId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error loading attendance records: $e');
      _errorMessage = 'Error loading attendance records: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load attendance records for a specific user
  Future<void> loadRecordsByUser(String eventId, String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final records = await _helper.GetAttendanceRecordsByUser(eventId, userId);
      _recordsByUser = {userId: records};
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error loading attendance records: $e');
      _errorMessage = 'Error loading attendance records: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Start listening to attendance records for a specific event (real-time)
  void startListeningToEvent(String eventId) {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _streamSubscription?.cancel();
    _streamSubscription = _helper.StreamAttendanceRecordsByEvent(eventId).listen(
      (recordsByUser) {
        _recordsByUser = recordsByUser;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        print('Error streaming attendance records: $error');
        _errorMessage = 'Error streaming attendance records: $error';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // Start listening to attendance records for a specific user (real-time)
  void startListeningToUser(String eventId, String userId) {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _streamSubscription?.cancel();
    _streamSubscription = _helper.StreamAttendanceRecordsByUser(eventId, userId).listen(
      (records) {
        _recordsByUser = {userId: records};
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        print('Error streaming attendance records: $error');
        _errorMessage = 'Error streaming attendance records: $error';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // Stop listening to real-time updates
  void stopListening() {
    _streamSubscription?.cancel();
    _streamSubscription = null;
  }

  // Create a new attendance record
  void createRecord(AttendanceRecord record) {
    try {
      _helper.CreateAttendanceRecord(record);
      // Real-time listener will update the list automatically
    } catch (e) {
      print('Error creating attendance record: $e');
      _errorMessage = 'Error creating attendance record: $e';
      notifyListeners();
    }
  }

  // Update an existing attendance record
  void updateRecord(AttendanceRecord record) {
    try {
      _helper.UpdateAttendanceRecord(record);
      // Real-time listener will update the list automatically
    } catch (e) {
      print('Error updating attendance record: $e');
      _errorMessage = 'Error updating attendance record: $e';
      notifyListeners();
    }
  }

  // Delete an attendance record
  void deleteRecord(String eventId, String userId, String checkId) {
    try {
      _helper.DeleteAttendanceRecord(eventId, userId, checkId);
      // Real-time listener will update the list automatically
    } catch (e) {
      print('Error deleting attendance record: $e');
      _errorMessage = 'Error deleting attendance record: $e';
      notifyListeners();
    }
  }

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }
}

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../Helpers/ShiftAssignmentHelperFirebase.dart';
import '../Models/ShiftAssignment.dart';

class ShiftAssignmentProvider with ChangeNotifier {
  final ShiftAssignmentHelperFirebase _helper = ShiftAssignmentHelperFirebase();

  List<ShiftAssignment> _assignments = [];
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription? _streamSubscription;

  List<ShiftAssignment> get assignments => _assignments;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load assignments for a specific event
  Future<void> loadAssignmentsByEvent(String eventId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _assignments = await _helper.GetShiftAssignmentsByEvent(eventId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error loading shift assignments: $e');
      _errorMessage = 'Error loading shift assignments: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load assignments for a specific volunteer
  Future<void> loadAssignmentsByVolunteer(String volunteerId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _assignments = await _helper.GetShiftAssignmentsByVolunteer(volunteerId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error loading shift assignments: $e');
      _errorMessage = 'Error loading shift assignments: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Start listening to assignments for a specific event (real-time)
  void startListeningToEvent(String eventId) {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _streamSubscription?.cancel();
    _streamSubscription = _helper.StreamShiftAssignmentsByEvent(eventId).listen(
      (assignments) {
        _assignments = assignments;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        print('Error streaming shift assignments: $error');
        _errorMessage = 'Error streaming shift assignments: $error';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // Start listening to assignments for a specific volunteer (real-time)
  void startListeningToVolunteer(String volunteerId) {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _streamSubscription?.cancel();
    _streamSubscription = _helper.StreamShiftAssignmentsByVolunteer(volunteerId).listen(
      (assignments) {
        _assignments = assignments;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        print('Error streaming shift assignments: $error');
        _errorMessage = 'Error streaming shift assignments: $error';
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

  // Create a new assignment
  void createAssignment(ShiftAssignment assignment) {
    try {
      _helper.CreateShiftAssignment(assignment);
      // Real-time listener will update the list automatically
    } catch (e) {
      print('Error creating shift assignment: $e');
      _errorMessage = 'Error creating shift assignment: $e';
      notifyListeners();
    }
  }

  // Update an existing assignment
  void updateAssignment(ShiftAssignment assignment) {
    try {
      _helper.UpdateShiftAssignment(assignment);
      // Real-time listener will update the list automatically
    } catch (e) {
      print('Error updating shift assignment: $e');
      _errorMessage = 'Error updating shift assignment: $e';
      notifyListeners();
    }
  }

  // Delete an assignment
  void deleteAssignment(String eventId, String assignmentId) {
    try {
      _helper.DeleteShiftAssignment(eventId, assignmentId);
      // Real-time listener will update the list automatically
    } catch (e) {
      print('Error deleting shift assignment: $e');
      _errorMessage = 'Error deleting shift assignment: $e';
      notifyListeners();
    }
  }

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }
}

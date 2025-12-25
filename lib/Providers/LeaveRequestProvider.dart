import 'dart:async';
import 'package:flutter/foundation.dart';
import '../Helpers/LeaveRequestHelperFirebase.dart';
import '../Models/LeaveRequest.dart';

class LeaveRequestProvider with ChangeNotifier {
  final LeaveRequestHelperFirebase _helper = LeaveRequestHelperFirebase();

  List<LeaveRequest> _requests = [];
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription? _streamSubscription;

  List<LeaveRequest> get requests => _requests;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Get pending requests only
  List<LeaveRequest> get pendingRequests => _requests.where((r) => r.status == LeaveRequestStatus.PENDING).toList();

  // Load leave requests for a specific event
  Future<void> loadRequestsByEvent(String eventId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _requests = await _helper.GetLeaveRequestsByEvent(eventId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error loading leave requests: $e');
      _errorMessage = 'Error loading leave requests: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load leave requests for a specific volunteer
  Future<void> loadRequestsByVolunteer(String volunteerId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _requests = await _helper.GetLeaveRequestsByVolunteer(volunteerId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error loading leave requests: $e');
      _errorMessage = 'Error loading leave requests: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Start listening to leave requests for a specific event (real-time)
  void startListeningToEvent(String eventId) {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _streamSubscription?.cancel();
    _streamSubscription = _helper.StreamLeaveRequestsByEvent(eventId).listen(
      (requests) {
        _requests = requests;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        print('Error streaming leave requests: $error');
        _errorMessage = 'Error streaming leave requests: $error';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // Start listening to pending leave requests for a specific event (real-time)
  void startListeningToPendingRequests(String eventId) {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _streamSubscription?.cancel();
    _streamSubscription = _helper.StreamPendingLeaveRequestsByEvent(eventId).listen(
      (requests) {
        _requests = requests;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        print('Error streaming pending leave requests: $error');
        _errorMessage = 'Error streaming pending leave requests: $error';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // Start listening to leave requests for a specific volunteer (real-time)
  void startListeningToVolunteer(String volunteerId) {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _streamSubscription?.cancel();
    _streamSubscription = _helper.StreamLeaveRequestsByVolunteer(volunteerId).listen(
      (requests) {
        _requests = requests;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        print('Error streaming leave requests: $error');
        _errorMessage = 'Error streaming leave requests: $error';
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

  // Create a new leave request
  void createRequest(LeaveRequest request) {
    try {
      _helper.CreateLeaveRequest(request);
      // Real-time listener will update the list automatically
    } catch (e) {
      print('Error creating leave request: $e');
      _errorMessage = 'Error creating leave request: $e';
      notifyListeners();
    }
  }

  // Update an existing leave request
  void updateRequest(LeaveRequest request) {
    try {
      _helper.UpdateLeaveRequest(request);
      // Real-time listener will update the list automatically
    } catch (e) {
      print('Error updating leave request: $e');
      _errorMessage = 'Error updating leave request: $e';
      notifyListeners();
    }
  }

  // Delete a leave request
  void deleteRequest(String eventId, String requestId) {
    try {
      _helper.DeleteLeaveRequest(eventId, requestId);
      // Real-time listener will update the list automatically
    } catch (e) {
      print('Error deleting leave request: $e');
      _errorMessage = 'Error deleting leave request: $e';
      notifyListeners();
    }
  }

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }
}

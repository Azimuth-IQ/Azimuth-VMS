import 'package:firebase_database/firebase_database.dart';
import '../Models/LeaveRequest.dart';
import '../Static/FirebaseHelperStatics.dart';

class LeaveRequestHelperFirebase {
  DatabaseReference rootRef = FirebaseDatabase.instance.ref().child(FirebaseHelperStatics.AppRoot).child("events");

  // Create a new leave request
  void CreateLeaveRequest(LeaveRequest request) {
    rootRef.child(request.eventId).child("leave-requests").child(request.id).set(request.toJson());
  }

  // Get a specific leave request by ID
  Future<LeaveRequest?> GetLeaveRequestById(String eventId, String requestId) async {
    DataSnapshot snapshot = await rootRef.child(eventId).child("leave-requests").child(requestId).get();
    if (snapshot.exists) {
      return LeaveRequest.fromDataSnapshot(snapshot);
    }
    return null;
  }

  // Get all leave requests for a specific event
  Future<List<LeaveRequest>> GetLeaveRequestsByEvent(String eventId) async {
    DataSnapshot snapshot = await rootRef.child(eventId).child("leave-requests").get();
    List<LeaveRequest> requests = [];
    if (snapshot.exists) {
      for (DataSnapshot d1 in snapshot.children) {
        requests.add(LeaveRequest.fromDataSnapshot(d1));
      }
    }
    return requests;
  }

  // Get all leave requests for a specific volunteer
  Future<List<LeaveRequest>> GetLeaveRequestsByVolunteer(String volunteerId) async {
    List<LeaveRequest> requests = [];
    DataSnapshot eventsSnapshot = await rootRef.get();
    if (eventsSnapshot.exists) {
      for (DataSnapshot eventSnapshot in eventsSnapshot.children) {
        DataSnapshot requestsSnapshot = eventSnapshot.child("leave-requests");
        if (requestsSnapshot.exists) {
          for (DataSnapshot d1 in requestsSnapshot.children) {
            LeaveRequest request = LeaveRequest.fromDataSnapshot(d1);
            if (request.volunteerId == volunteerId) {
              requests.add(request);
            }
          }
        }
      }
    }
    return requests;
  }

  // Get pending leave requests for a specific event
  Future<List<LeaveRequest>> GetPendingLeaveRequestsByEvent(String eventId) async {
    DataSnapshot snapshot = await rootRef.child(eventId).child("leave-requests").get();
    List<LeaveRequest> requests = [];
    if (snapshot.exists) {
      for (DataSnapshot d1 in snapshot.children) {
        LeaveRequest request = LeaveRequest.fromDataSnapshot(d1);
        if (request.status == LeaveRequestStatus.PENDING) {
          requests.add(request);
        }
      }
    }
    return requests;
  }

  // Update an existing leave request
  void UpdateLeaveRequest(LeaveRequest request) {
    rootRef.child(request.eventId).child("leave-requests").child(request.id).update(request.toJson());
  }

  // Delete a leave request
  void DeleteLeaveRequest(String eventId, String requestId) {
    rootRef.child(eventId).child("leave-requests").child(requestId).remove();
  }

  // Listen to all leave requests for a specific event (real-time)
  Stream<List<LeaveRequest>> StreamLeaveRequestsByEvent(String eventId) {
    return rootRef.child(eventId).child("leave-requests").onValue.map((event) {
      List<LeaveRequest> requests = [];
      if (event.snapshot.exists) {
        for (DataSnapshot d1 in event.snapshot.children) {
          requests.add(LeaveRequest.fromDataSnapshot(d1));
        }
      }
      return requests;
    });
  }

  // Listen to pending leave requests for a specific event (real-time)
  Stream<List<LeaveRequest>> StreamPendingLeaveRequestsByEvent(String eventId) {
    return rootRef.child(eventId).child("leave-requests").onValue.map((event) {
      List<LeaveRequest> requests = [];
      if (event.snapshot.exists) {
        for (DataSnapshot d1 in event.snapshot.children) {
          LeaveRequest request = LeaveRequest.fromDataSnapshot(d1);
          if (request.status == LeaveRequestStatus.PENDING) {
            requests.add(request);
          }
        }
      }
      return requests;
    });
  }

  // Listen to leave requests for a specific volunteer across all events (real-time)
  Stream<List<LeaveRequest>> StreamLeaveRequestsByVolunteer(String volunteerId) {
    return rootRef.onValue.map((event) {
      List<LeaveRequest> requests = [];
      if (event.snapshot.exists) {
        for (DataSnapshot eventSnapshot in event.snapshot.children) {
          DataSnapshot requestsSnapshot = eventSnapshot.child("leave-requests");
          if (requestsSnapshot.exists) {
            for (DataSnapshot d1 in requestsSnapshot.children) {
              LeaveRequest request = LeaveRequest.fromDataSnapshot(d1);
              if (request.volunteerId == volunteerId) {
                requests.add(request);
              }
            }
          }
        }
      }
      return requests;
    });
  }
}

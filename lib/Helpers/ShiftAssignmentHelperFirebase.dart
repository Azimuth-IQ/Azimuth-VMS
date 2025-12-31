import 'package:firebase_database/firebase_database.dart';
import '../Models/ShiftAssignment.dart';
import '../Static/FirebaseHelperStatics.dart';

class ShiftAssignmentHelperFirebase {
  DatabaseReference rootRef = FirebaseDatabase.instance.ref().child(FirebaseHelperStatics.AppRoot).child("events");

  // Create a new shift assignment
  void CreateShiftAssignment(ShiftAssignment assignment) {
    rootRef.child(assignment.eventId).child("assignments").child(assignment.id).set(assignment.toJson());
  }

  // Get a specific shift assignment by ID
  Future<ShiftAssignment?> GetShiftAssignmentById(String eventId, String assignmentId) async {
    DataSnapshot snapshot = await rootRef.child(eventId).child("assignments").child(assignmentId).get();
    if (snapshot.exists) {
      return ShiftAssignment.fromDataSnapshot(snapshot);
    }
    return null;
  }

  // Get all shift assignments for a specific event
  Future<List<ShiftAssignment>> GetShiftAssignmentsByEvent(String eventId) async {
    DataSnapshot snapshot = await rootRef.child(eventId).child("assignments").get();
    List<ShiftAssignment> assignments = [];
    if (snapshot.exists) {
      for (DataSnapshot d1 in snapshot.children) {
        assignments.add(ShiftAssignment.fromDataSnapshot(d1));
      }
    }
    return assignments;
  }

  // Get all shift assignments for a specific volunteer
  Future<List<ShiftAssignment>> GetShiftAssignmentsByVolunteer(String volunteerId) async {
    // Note: This requires querying all events - consider optimizing with indexing
    List<ShiftAssignment> assignments = [];
    DataSnapshot eventsSnapshot = await rootRef.get();
    if (eventsSnapshot.exists) {
      for (DataSnapshot eventSnapshot in eventsSnapshot.children) {
        DataSnapshot assignmentsSnapshot = eventSnapshot.child("assignments");
        if (assignmentsSnapshot.exists) {
          for (DataSnapshot d1 in assignmentsSnapshot.children) {
            ShiftAssignment assignment = ShiftAssignment.fromDataSnapshot(d1);
            if (assignment.volunteerId == volunteerId) {
              assignments.add(assignment);
            }
          }
        }
      }
    }
    return assignments;
  }

  // Get all shift assignments across all events
  Future<List<ShiftAssignment>> GetAllShiftAssignments() async {
    List<ShiftAssignment> assignments = [];
    DataSnapshot eventsSnapshot = await rootRef.get();
    if (eventsSnapshot.exists) {
      for (DataSnapshot eventSnapshot in eventsSnapshot.children) {
        DataSnapshot assignmentsSnapshot = eventSnapshot.child("assignments");
        if (assignmentsSnapshot.exists) {
          for (DataSnapshot d1 in assignmentsSnapshot.children) {
            assignments.add(ShiftAssignment.fromDataSnapshot(d1));
          }
        }
      }
    }
    return assignments;
  }

  // Update an existing shift assignment
  void UpdateShiftAssignment(ShiftAssignment assignment) {
    rootRef.child(assignment.eventId).child("assignments").child(assignment.id).update(assignment.toJson());
  }

  // Delete a shift assignment
  void DeleteShiftAssignment(String eventId, String assignmentId) {
    rootRef.child(eventId).child("assignments").child(assignmentId).remove();
  }

  // Listen to all assignments for a specific event (real-time)
  Stream<List<ShiftAssignment>> StreamShiftAssignmentsByEvent(String eventId) {
    return rootRef.child(eventId).child("assignments").onValue.map((event) {
      List<ShiftAssignment> assignments = [];
      if (event.snapshot.exists) {
        for (DataSnapshot d1 in event.snapshot.children) {
          assignments.add(ShiftAssignment.fromDataSnapshot(d1));
        }
      }
      return assignments;
    });
  }

  // Listen to assignments for a specific volunteer across all events (real-time)
  Stream<List<ShiftAssignment>> StreamShiftAssignmentsByVolunteer(String volunteerId) {
    return rootRef.onValue.map((event) {
      List<ShiftAssignment> assignments = [];
      if (event.snapshot.exists) {
        for (DataSnapshot eventSnapshot in event.snapshot.children) {
          DataSnapshot assignmentsSnapshot = eventSnapshot.child("assignments");
          if (assignmentsSnapshot.exists) {
            for (DataSnapshot d1 in assignmentsSnapshot.children) {
              ShiftAssignment assignment = ShiftAssignment.fromDataSnapshot(d1);
              if (assignment.volunteerId == volunteerId) {
                assignments.add(assignment);
              }
            }
          }
        }
      }
      return assignments;
    });
  }
}

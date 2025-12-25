import 'package:firebase_database/firebase_database.dart';
import '../Models/AttendanceRecord.dart';
import '../Static/FirebaseHelperStatics.dart';

class AttendanceHelperFirebase {
  DatabaseReference rootRef = FirebaseDatabase.instance.ref().child(FirebaseHelperStatics.AppRoot).child("events");

  // Create a new attendance record
  void CreateAttendanceRecord(AttendanceRecord record) {
    rootRef.child(record.eventId).child("attendance").child(record.userId).child("checks").child(record.id).set(record.toJson());
  }

  // Get a specific attendance record
  Future<AttendanceRecord?> GetAttendanceRecordById(String eventId, String userId, String checkId) async {
    DataSnapshot snapshot = await rootRef.child(eventId).child("attendance").child(userId).child("checks").child(checkId).get();
    if (snapshot.exists) {
      return AttendanceRecord.fromDataSnapshot(snapshot);
    }
    return null;
  }

  // Get all attendance records for a specific user in an event
  Future<List<AttendanceRecord>> GetAttendanceRecordsByUser(String eventId, String userId) async {
    DataSnapshot snapshot = await rootRef.child(eventId).child("attendance").child(userId).child("checks").get();
    List<AttendanceRecord> records = [];
    if (snapshot.exists) {
      for (DataSnapshot d1 in snapshot.children) {
        records.add(AttendanceRecord.fromDataSnapshot(d1));
      }
    }
    return records;
  }

  // Get all attendance records for a specific event
  Future<Map<String, List<AttendanceRecord>>> GetAttendanceRecordsByEvent(String eventId) async {
    Map<String, List<AttendanceRecord>> recordsByUser = {};
    DataSnapshot snapshot = await rootRef.child(eventId).child("attendance").get();
    if (snapshot.exists) {
      for (DataSnapshot userSnapshot in snapshot.children) {
        String userId = userSnapshot.key ?? '';
        List<AttendanceRecord> userRecords = [];
        DataSnapshot checksSnapshot = userSnapshot.child("checks");
        if (checksSnapshot.exists) {
          for (DataSnapshot d1 in checksSnapshot.children) {
            userRecords.add(AttendanceRecord.fromDataSnapshot(d1));
          }
        }
        if (userRecords.isNotEmpty) {
          recordsByUser[userId] = userRecords;
        }
      }
    }
    return recordsByUser;
  }

  // Get specific check type for all users in an event
  Future<Map<String, AttendanceRecord?>> GetAttendanceByCheckType(String eventId, AttendanceCheckType checkType) async {
    Map<String, AttendanceRecord?> recordsByUser = {};
    DataSnapshot snapshot = await rootRef.child(eventId).child("attendance").get();
    if (snapshot.exists) {
      for (DataSnapshot userSnapshot in snapshot.children) {
        String userId = userSnapshot.key ?? '';
        DataSnapshot checksSnapshot = userSnapshot.child("checks");
        if (checksSnapshot.exists) {
          for (DataSnapshot d1 in checksSnapshot.children) {
            AttendanceRecord record = AttendanceRecord.fromDataSnapshot(d1);
            if (record.checkType == checkType) {
              recordsByUser[userId] = record;
              break; // Only get the first matching check type
            }
          }
        }
        // If user has no record for this check type, add null
        if (!recordsByUser.containsKey(userId)) {
          recordsByUser[userId] = null;
        }
      }
    }
    return recordsByUser;
  }

  // Update an existing attendance record
  void UpdateAttendanceRecord(AttendanceRecord record) {
    rootRef.child(record.eventId).child("attendance").child(record.userId).child("checks").child(record.id).update(record.toJson());
  }

  // Delete an attendance record
  void DeleteAttendanceRecord(String eventId, String userId, String checkId) {
    rootRef.child(eventId).child("attendance").child(userId).child("checks").child(checkId).remove();
  }

  // Listen to all attendance records for a specific event (real-time)
  Stream<Map<String, List<AttendanceRecord>>> StreamAttendanceRecordsByEvent(String eventId) {
    return rootRef.child(eventId).child("attendance").onValue.map((event) {
      Map<String, List<AttendanceRecord>> recordsByUser = {};
      if (event.snapshot.exists) {
        for (DataSnapshot userSnapshot in event.snapshot.children) {
          String userId = userSnapshot.key ?? '';
          List<AttendanceRecord> userRecords = [];
          DataSnapshot checksSnapshot = userSnapshot.child("checks");
          if (checksSnapshot.exists) {
            for (DataSnapshot d1 in checksSnapshot.children) {
              userRecords.add(AttendanceRecord.fromDataSnapshot(d1));
            }
          }
          if (userRecords.isNotEmpty) {
            recordsByUser[userId] = userRecords;
          }
        }
      }
      return recordsByUser;
    });
  }

  // Listen to attendance records for a specific user in an event (real-time)
  Stream<List<AttendanceRecord>> StreamAttendanceRecordsByUser(String eventId, String userId) {
    return rootRef.child(eventId).child("attendance").child(userId).child("checks").onValue.map((event) {
      List<AttendanceRecord> records = [];
      if (event.snapshot.exists) {
        for (DataSnapshot d1 in event.snapshot.children) {
          records.add(AttendanceRecord.fromDataSnapshot(d1));
        }
      }
      return records;
    });
  }
}

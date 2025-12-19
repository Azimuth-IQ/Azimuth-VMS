import 'package:azimuth_vms/Models/Event.dart';
import 'package:azimuth_vms/Static/FirebaseHelperStatics.dart';
import 'package:firebase_database/firebase_database.dart';

class EventHelperFirebase {
  //1- Root Reference
  DatabaseReference rootRef = FirebaseDatabase.instance.ref().child(FirebaseHelperStatics.AppRoot).child("events");

  //2- Basic CRUD
  //2.1- Create
  void CreateEvent(Event event) {
    rootRef.child(event.id).set(event.toJson());
  }

  //2.2- Read
  //2.2.1- By Id
  Future<Event?> GetEventById(String id) async {
    DataSnapshot snapshot = await rootRef.child(id).get();
    if (snapshot.exists) {
      return Event.fromDataSnapshot(snapshot);
    }
    return null;
  }

  //2.2.2- All Events
  Future<List<Event>> GetAllEvents() async {
    DataSnapshot snapshot = await rootRef.get();
    List<Event> events = [];
    if (snapshot.exists) {
      for (DataSnapshot d1 in snapshot.children) {
        events.add(Event.fromDataSnapshot(d1));
      }
    }
    return events;
  }

  //2.3- Update
  void UpdateEvent(Event event) {
    rootRef.child(event.id).update(event.toJson());
  }
}

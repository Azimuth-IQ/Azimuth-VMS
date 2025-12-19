import 'package:azimuth_vms/Models/Location.dart';
import 'package:azimuth_vms/Static/FirebaseHelperStatics.dart';
import 'package:firebase_database/firebase_database.dart';

class LocationHelperFirebase {
  DatabaseReference rootRef = FirebaseDatabase.instance.ref().child(FirebaseHelperStatics.AppRoot).child("locations");

  //Basic CRUD
  //1- Create
  void CreateLocation(Location location) {
    rootRef.child(location.id).set(location.toJson());
  }

  //2- Read
  //2.1- By ID
  Future<Location?> GetLocationById(String id) async {
    DataSnapshot snapshot = await rootRef.child(id).get();
    if (snapshot.exists) {
      return Location.fromDataSnapshot(snapshot);
    }
    return null;
  }

  //2.2- All Locations
  Future<List<Location>> GetAllLocations() async {
    DataSnapshot snapshot = await rootRef.get();
    List<Location> locations = [];
    if (snapshot.exists) {
      for (DataSnapshot d1 in snapshot.children) {
        print('Location snapshot key: ${d1.key}');
        locations.add(Location.fromDataSnapshot(d1));
      }
    }
    return locations;
  }

  //3- Update
  void UpdateLocation(Location location) {
    rootRef.child(location.id).update(location.toJson());
  }
}

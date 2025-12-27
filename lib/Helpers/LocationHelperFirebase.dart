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
        try {
          Location location = Location.fromDataSnapshot(d1);
          print('✓ Loaded location: ${location.name} (ID: ${location.id}) with ${location.subLocations?.length ?? 0} sublocations');
          locations.add(location);
        } catch (e) {
          print('✗ Error parsing location ${d1.key}: $e');
        }
      }
    }
    print('📍 Total locations loaded: ${locations.length}');
    return locations;
  }

  //3- Update
  void UpdateLocation(Location location) {
    rootRef.child(location.id).update(location.toJson());
  }

  //4- Archive/Unarchive
  Future<void> ArchiveLocation(String locationId) async {
    await rootRef.child(locationId).update({'archived': true});
  }

  Future<void> UnarchiveLocation(String locationId) async {
    await rootRef.child(locationId).update({'archived': false});
  }

  //5- Delete
  Future<void> DeleteLocation(String id) async {
    await rootRef.child(id).remove();
  }

  //6- Query Methods
  Future<List<Location>> GetActiveLocations() async {
    DataSnapshot snapshot = await rootRef.get();
    List<Location> locations = [];
    if (snapshot.exists) {
      for (DataSnapshot d1 in snapshot.children) {
        Location location = Location.fromDataSnapshot(d1);
        if (!location.archived) {
          locations.add(location);
        }
      }
    }
    return locations;
  }

  Future<List<Location>> GetArchivedLocations() async {
    DataSnapshot snapshot = await rootRef.get();
    List<Location> locations = [];
    if (snapshot.exists) {
      for (DataSnapshot d1 in snapshot.children) {
        Location location = Location.fromDataSnapshot(d1);
        if (location.archived) {
          locations.add(location);
        }
      }
    }
    return locations;
  }
}

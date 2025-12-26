import 'package:firebase_database/firebase_database.dart';

class Location {
  //1- Properties
  String id;
  String name;
  String description;
  String? imageUrl;
  String longitude;
  String latitude;
  List<Location>? subLocations;
  bool archived;

  //2- Constructor
  Location({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    required this.longitude,
    required this.latitude,
    this.subLocations,
    this.archived = false,
  });
  //3- To Json
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'longitude': longitude,
      'latitude': latitude,
      'archived': archived,
      'subLocations': subLocations?.map((loc) => loc.toJson()).toList(),
    };
  }

  //4- From Datasnapshot
  factory Location.fromDataSnapshot(DataSnapshot snapshot) {
    List<Location>? subLocations;

    // Check if subLocations child exists
    DataSnapshot subLocsSnapshot = snapshot.child('subLocations');
    if (subLocsSnapshot.exists) {
      subLocations = [];
      for (DataSnapshot d1 in subLocsSnapshot.children) {
        subLocations.add(Location.fromDataSnapshot(d1));
      }
    }

    return Location(
      id: snapshot.child('id').value as String,
      name: snapshot.child('name').value as String,
      description: snapshot.child('description').value as String,
      imageUrl: snapshot.child('imageUrl').value as String?,
      longitude: snapshot.child('longitude').value as String,
      latitude: snapshot.child('latitude').value as String,
      archived: snapshot.child('archived').value as bool? ?? false,
      subLocations: subLocations,
    );
  }
}

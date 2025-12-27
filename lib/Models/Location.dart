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
      int subLocIndex = 0;
      for (DataSnapshot d1 in subLocsSnapshot.children) {
        try {
          Location subLoc = Location.fromDataSnapshot(d1);
          subLocations.add(subLoc);
          subLocIndex++;
        } catch (e) {
          print('✗ Error parsing sublocation #$subLocIndex in ${snapshot.child('name').value}: $e');
        }
      }
      if (subLocations.isNotEmpty) {
        print('  ↳ Parsed ${subLocations.length} sublocations for ${snapshot.child('name').value}');
      }
    }

    String id = snapshot.child('id').value?.toString() ?? '';
    String name = snapshot.child('name').value?.toString() ?? 'Unknown';
    String description = snapshot.child('description').value?.toString() ?? '';
    String? imageUrl = snapshot.child('imageUrl').value?.toString();
    String longitude = snapshot.child('longitude').value?.toString() ?? '0';
    String latitude = snapshot.child('latitude').value?.toString() ?? '0';
    bool archived = snapshot.child('archived').value as bool? ?? false;

    return Location(
      id: id,
      name: name,
      description: description,
      imageUrl: imageUrl,
      longitude: longitude,
      latitude: latitude,
      archived: archived,
      subLocations: subLocations,
    );
  }
}

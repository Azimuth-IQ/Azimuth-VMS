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

  //2- Constructor
  Location({required this.id, required this.name, required this.description, this.imageUrl, required this.longitude, required this.latitude, this.subLocations});
  //3- To Json
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'longitude': longitude,
      'latitude': latitude,
      'subLocations': subLocations?.map((loc) => loc.toJson()).toList(),
    };
  }

  //4- From Datasnapshot
  factory Location.fromDataSnapshot(DataSnapshot snapshot) {
    Map<String, dynamic> data = Map<String, dynamic>.from(snapshot.value as Map);
    List<Location>? subLocations;
    if (data['subLocations'] != null) {
      subLocations = [];
      data['subLocations'].forEach((key, value) {
        subLocations!.add(Location.fromDataSnapshot(value));
      });
    }
    return Location(
      id: data['id'],
      name: data['name'],
      description: data['description'],
      imageUrl: data['imageUrl'],
      longitude: data['longitude'],
      latitude: data['latitude'],
      subLocations: subLocations,
    );
  }
}

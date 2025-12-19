import 'package:azimuth_vms/Helpers/LocationHelperFirebase.dart';
import 'package:azimuth_vms/Helpers/SystemUserHelperFirebase.dart';
import 'package:azimuth_vms/Models/Location.dart';
import 'package:azimuth_vms/Models/SystemUser.dart';
import 'package:firebase_database/firebase_database.dart';

class Seed {
  DatabaseReference rootRef = FirebaseDatabase.instance.ref().child("ihs").child("systemusers");
  // Seed model properties and methods go here
  // 1-Seed SystemUsers
  void seedSystemUsers() {
    //1- Admin
    SystemUser user1 = SystemUser(id: 'user1', name: 'Ahmed Saad Salih', phone: '07705371953', role: SystemUserRole.ADMIN);
    //2- Teamleader
    SystemUser user2 = SystemUser(id: 'user2', name: 'Teamleader One', phone: '07700000001', role: SystemUserRole.TEAMLEADER);
    //3- Volunteer
    SystemUser user3 = SystemUser(id: 'user3', name: 'Volunteer One', phone: '07700000002', role: SystemUserRole.VOLUNTEER);

    SystemUserHelperFirebase().CreateSystemUser(user1);
    SystemUserHelperFirebase().CreateSystemUser(user2);
    SystemUserHelperFirebase().CreateSystemUser(user3);
  }

  //2- Seed Locations
  void seedLocations() {
    Location subLocation1 = Location(id: "subloc1", name: "Sub Location One", description: "Description One", longitude: "", latitude: "");
    Location subLocation2 = Location(id: "subloc2", name: "Sub Location Two", description: "Description Two", longitude: "", latitude: "");
    Location location1 = Location(id: "loc1", name: "Location One", description: "Description One", longitude: "", latitude: "", subLocations: [subLocation1, subLocation2]);

    LocationHelperFirebase().CreateLocation(location1);
  }
}

import 'package:azimuth_vms/Models/VolunteerForm.dart';
import 'package:azimuth_vms/Models/VolunteerRating.dart';
import 'package:firebase_database/firebase_database.dart';

class SystemUser {
  //1- Variables
  String id;
  String name;
  String phone;
  SystemUserRole role;
  VolunteerForm? volunteerForm; // Nullable for non-volunteer roles
  VolunteerRating? volunteerRating; // Nullable for non-volunteer roles

  //2- Constructor
  SystemUser({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
    this.volunteerForm,
    this.volunteerRating,
  });

  //3- ToJson
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'role': role.toString().split('.').last,
      'volunteerForm': volunteerForm?.toJson(),
      'volunteerRating': volunteerRating?.toJson(),
    };
  }

  //4- From Datasnapshot
  factory SystemUser.fromDataSnapshot(DataSnapshot snapshot) {
    VolunteerForm? vForm;
    if (snapshot.child('volunteerForm').exists) {
      vForm = VolunteerForm.fromDataSnapshot(snapshot.child('volunteerForm'));
    }

    VolunteerRating? vRating;
    if (snapshot.child('volunteerRating').exists) {
      vRating = VolunteerRating.fromDataSnapshot(
        snapshot.child('volunteerRating'),
      );
    }

    return SystemUser(
      id: snapshot.key ?? '',
      name: snapshot.child('name').value.toString(),
      phone: snapshot.child('phone').value.toString(),
      role: SystemUserRole.values.firstWhere(
        (e) =>
            e.toString() ==
            'SystemUserRole.' + snapshot.child('role').value.toString(),
        orElse: () => SystemUserRole.VOLUNTEER,
      ),
      volunteerForm: vForm,
      volunteerRating: vRating,
    );
  }
}

enum SystemUserRole { VOLUNTEER, TEAMLEADER, ADMIN }

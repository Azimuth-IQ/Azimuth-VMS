import 'package:azimuth_vms/Models/SystemUser.dart';
import 'package:azimuth_vms/Static/FirebaseHelperStatics.dart';
import 'package:firebase_database/firebase_database.dart';

class SystemUserHelperFirebase {
  DatabaseReference rootRef = FirebaseDatabase.instance.ref().child(FirebaseHelperStatics.AppRoot).child("systemusers");

  //Basic CRUD
  //1- Create
  void CreateSystemUser(SystemUser user) {
    rootRef.child(user.phone).set(user.toJson());
  }

  //2- Read
  //2.1- By Phone
  Future<SystemUser?> GetSystemUserByPhone(String phone) async {
    DataSnapshot snapshot = await rootRef.child(phone).get();
    if (snapshot.exists) {
      return SystemUser.fromDataSnapshot(snapshot);
    }
    return null;
  }

  //2.2- All Users
  Future<List<SystemUser>> GetAllSystemUsers() async {
    DataSnapshot snapshot = await rootRef.get();
    List<SystemUser> users = [];
    if (snapshot.exists) {
      for (DataSnapshot d1 in snapshot.children) {
        users.add(SystemUser.fromDataSnapshot(d1));
      }
    }
    return users;
  }

  //3- Update
  void UpdateSystemUser(SystemUser user) {
    rootRef.child(user.phone).update(user.toJson());
  }
}

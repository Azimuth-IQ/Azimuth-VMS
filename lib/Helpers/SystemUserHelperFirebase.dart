import 'package:azimuth_vms/Models/SystemUser.dart';
import 'package:azimuth_vms/Static/FirebaseHelperStatics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class SystemUserHelperFirebase {
  DatabaseReference rootRef = FirebaseDatabase.instance.ref().child(FirebaseHelperStatics.AppRoot).child("systemusers");
  FirebaseAuth auth = FirebaseAuth.instance;

  //Basic CRUD
  //1- Create
  Future<void> CreateSystemUser(SystemUser user) async {
    await rootRef.child(user.phone).set(user.toJson());

    // Create Firebase Auth user so they can login
    try {
      await auth.createUserWithEmailAndPassword(email: "${user.phone}@azimuth-vms.com", password: user.password!);
      print('Firebase Auth created for user: ${user.phone} (${user.role})');
    } catch (e) {
      print('Error creating auth for user ${user.phone} (may already exist): $e');
    }
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

  //4- Archive/Unarchive
  Future<void> ArchiveSystemUser(String phone) async {
    await rootRef.child(phone).update({'archived': true});
  }

  Future<void> UnarchiveSystemUser(String phone) async {
    await rootRef.child(phone).update({'archived': false});
  }

  //5- Delete
  Future<void> DeleteSystemUser(String phone) async {
    await rootRef.child(phone).remove();
  }

  //6- Query Methods
  Future<List<SystemUser>> GetActiveUsers() async {
    DataSnapshot snapshot = await rootRef.get();
    List<SystemUser> users = [];
    if (snapshot.exists) {
      for (DataSnapshot d1 in snapshot.children) {
        SystemUser user = SystemUser.fromDataSnapshot(d1);
        if (!user.archived) {
          users.add(user);
        }
      }
    }
    return users;
  }

  Future<List<SystemUser>> GetArchivedUsers() async {
    DataSnapshot snapshot = await rootRef.get();
    List<SystemUser> users = [];
    if (snapshot.exists) {
      for (DataSnapshot d1 in snapshot.children) {
        SystemUser user = SystemUser.fromDataSnapshot(d1);
        if (user.archived) {
          users.add(user);
        }
      }
    }
    return users;
  }

  Future<List<SystemUser>> GetActiveUsersByRole(SystemUserRole role) async {
    DataSnapshot snapshot = await rootRef.get();
    List<SystemUser> users = [];
    if (snapshot.exists) {
      for (DataSnapshot d1 in snapshot.children) {
        SystemUser user = SystemUser.fromDataSnapshot(d1);
        if (user.role == role && !user.archived) {
          users.add(user);
        }
      }
    }
    return users;
  }
}

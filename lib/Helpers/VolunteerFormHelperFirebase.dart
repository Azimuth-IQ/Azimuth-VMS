import 'package:azimuth_vms/Models/VolunteerForm.dart';
import 'package:azimuth_vms/Static/FirebaseHelperStatics.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VolunteerFormHelperFirebase {
  //1- Root Reference
  DatabaseReference rootRef = FirebaseDatabase.instance.ref().child(FirebaseHelperStatics.AppRoot).child("forms");
  FirebaseAuth auth = FirebaseAuth.instance;

  //2- Basic CRUD
  //2.1- Create
  Future<void> CreateForm(VolunteerForm form) async {
    form.status = VolunteerFormStatus.Sent;
    await rootRef.child(form.mobileNumber!).set(form.toJson());

    // Create Firebase Auth user so volunteer can login
    try {
      await auth.createUserWithEmailAndPassword(
        email: "${form.mobileNumber}@azimuth-vms.com",
        password: form.mobileNumber!, // Use phone as default password
      );
      print('Firebase Auth created for volunteer: ${form.mobileNumber}');
    } catch (e) {
      print('Error creating auth for volunteer (may already exist): $e');
    }
  }

  //2.2- Read
  //2.2.1- By Mobile Number
  Future<VolunteerForm?> GetFormByMobileNumber(String mobileNumber) async {
    DataSnapshot snapshot = await rootRef.child(mobileNumber).get();
    if (snapshot.exists) {
      return VolunteerForm.fromDataSnapshot(snapshot);
    }
    return null;
  }

  //2.2.2- All Forms
  Future<List<VolunteerForm>> GetAllForms() async {
    DataSnapshot snapshot = await rootRef.get();
    List<VolunteerForm> forms = [];
    if (snapshot.exists) {
      for (DataSnapshot d1 in snapshot.children) {
        forms.add(VolunteerForm.fromDataSnapshot(d1));
      }
    }
    return forms;
  }

  //2.3- Update
  void UpdateForm(VolunteerForm form) {
    rootRef.child(form.mobileNumber!).update(form.toJson());
  }

  //2.4- Archive
  Future<void> ArchiveForm(String mobileNumber) async {
    await rootRef.child(mobileNumber).update({'archived': true});
  }

  //2.5- Unarchive
  Future<void> UnarchiveForm(String mobileNumber) async {
    await rootRef.child(mobileNumber).update({'archived': false});
  }

  //2.6- Delete
  Future<void> DeleteForm(String mobileNumber) async {
    await rootRef.child(mobileNumber).remove();
  }

  //2.7- Get Active Forms
  Future<List<VolunteerForm>> GetActiveForms() async {
    DataSnapshot snapshot = await rootRef.get();
    List<VolunteerForm> forms = [];
    if (snapshot.exists) {
      for (DataSnapshot d1 in snapshot.children) {
        final form = VolunteerForm.fromDataSnapshot(d1);
        if (!form.archived) {
          forms.add(form);
        }
      }
    }
    return forms;
  }

  //2.8- Get Archived Forms
  Future<List<VolunteerForm>> GetArchivedForms() async {
    DataSnapshot snapshot = await rootRef.get();
    List<VolunteerForm> forms = [];
    if (snapshot.exists) {
      for (DataSnapshot d1 in snapshot.children) {
        final form = VolunteerForm.fromDataSnapshot(d1);
        if (form.archived) {
          forms.add(form);
        }
      }
    }
    return forms;
  }
}

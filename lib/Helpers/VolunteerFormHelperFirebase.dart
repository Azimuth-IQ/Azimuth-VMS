import 'package:azimuth_vms/Models/VolunteerForm.dart';
import 'package:azimuth_vms/Static/FirebaseHelperStatics.dart';
import 'package:firebase_database/firebase_database.dart';

class VolunteerFormHelperFirebase {
  //1- Root Reference
  DatabaseReference rootRef = FirebaseDatabase.instance.ref().child(FirebaseHelperStatics.AppRoot).child("forms");

  //2- Basic CRUD
  //2.1- Create
  void CreateForm(VolunteerForm form) {
    form.status = VolunteerFormStatus.Sent;
    rootRef.child(form.mobileNumber!).set(form.toJson());
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
}

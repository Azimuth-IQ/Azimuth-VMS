//1- Adherence to the dress code
//2- Adherence to the location of the event
//3- Adherence to Instructions
//4- Presence Score
//5- Interaction with Visitors
//6- Active Cooperation with Other Employees
//7- Time Commitment

import 'package:firebase_database/firebase_database.dart';

class VolunteerRatingCriteria {
  //1- Variable
  String Criteria;

  //2- Constructor
  VolunteerRatingCriteria({required this.Criteria});

  //3- FromDataSnapshot
  factory VolunteerRatingCriteria.fromDataSnapshot(DataSnapshot snapshot) {
    return VolunteerRatingCriteria(Criteria: snapshot.child('Criteria').value.toString());
  }

  //4- ToJson
  Map<String, dynamic> toJson() {
    return {'Criteria': Criteria};
  }
}

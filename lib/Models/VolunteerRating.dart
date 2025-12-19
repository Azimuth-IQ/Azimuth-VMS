import 'package:azimuth_vms/Models/VolunteerRatingCriteria.dart';
import 'package:firebase_database/firebase_database.dart';

class VolunteerRating {
  //1- Variables
  String id;
  Map<VolunteerRatingCriteria, int> ratings; // Criteria and its rating (1-5)
  String Date; //formatted as YYYY-MM-DD
  String Time; //formatted as HH:mm
  List<String> Notes;

  //2- Constructor
  VolunteerRating({
    required this.id,
    required this.ratings,
    required this.Date,
    required this.Time,
    required this.Notes,
  });

  //3- From DataSnapshot
  factory VolunteerRating.fromDataSnapshot(DataSnapshot snapshot) {
    Map<VolunteerRatingCriteria, int> ratingsMap = {};
    Map<dynamic, dynamic> ratingsData =
        snapshot.child('ratings').value as Map<dynamic, dynamic>;
    ratingsData.forEach((key, value) {
      VolunteerRatingCriteria criteria = VolunteerRatingCriteria(
        Criteria: key.toString(),
      );
      ratingsMap[criteria] = int.parse(value.toString());
    });

    List<String> notesList = [];
    if (snapshot.child('Notes').value != null) {
      Map<dynamic, dynamic> notesData =
          snapshot.child('Notes').value as Map<dynamic, dynamic>;
      notesData.forEach((key, value) {
        notesList.add(value.toString());
      });
    }

    return VolunteerRating(
      id: snapshot.key ?? '',
      ratings: ratingsMap,
      Date: snapshot.child('Date').value.toString(),
      Time: snapshot.child('Time').value.toString(),
      Notes: notesList,
    );
  }

  //4- To JSON
  Map<String, dynamic> toJson() {
    Map<String, dynamic> ratingsJson = {};
    ratings.forEach((key, value) {
      ratingsJson[key.Criteria] = value;
    });

    return {
      'id': id,
      'ratings': ratingsJson,
      'Date': Date,
      'Time': Time,
      'Notes': Notes.asMap().map(
        (index, value) => MapEntry(index.toString(), value),
      ),
    };
  }
}

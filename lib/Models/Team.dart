import 'package:firebase_database/firebase_database.dart';

class Team {
  //1- Properties
  String id;
  String name;
  String teamLeaderId;
  List<String> memberIds;
  bool archived;

  //2- Constructor
  Team({required this.id, required this.name, required this.teamLeaderId, required this.memberIds, this.archived = false});

  //3- To Json
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'teamLeaderId': teamLeaderId, 'memberIds': memberIds, 'archived': archived};
  }

  //4- From DataSnapshot
  factory Team.fromDataSnapshot(DataSnapshot snapshot) {
    List<String> members = [];
    DataSnapshot membersSnapshot = snapshot.child('memberIds');
    if (membersSnapshot.exists) {
      for (DataSnapshot member in membersSnapshot.children) {
        if (member.value != null) {
          members.add(member.value as String);
        }
      }
    }

    return Team(
      id: snapshot.child('id').value?.toString() ?? '',
      name: snapshot.child('name').value?.toString() ?? '',
      teamLeaderId: snapshot.child('teamLeaderId').value?.toString() ?? '',
      archived: snapshot.child('archived').value as bool? ?? false,
      memberIds: members,
    );
  }
}

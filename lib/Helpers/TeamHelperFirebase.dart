import 'package:azimuth_vms/Models/Team.dart';
import 'package:azimuth_vms/Static/FirebaseHelperStatics.dart';
import 'package:firebase_database/firebase_database.dart';

class TeamHelperFirebase {
  //Root Reference
  DatabaseReference rootRef = FirebaseDatabase.instance.ref().child(FirebaseHelperStatics.AppRoot).child("teams");

  //Basic CRUD
  //1- Create
  void CreateTeam(Team team) {
    rootRef.child(team.id).set(team.toJson());
  }

  //2- Read
  //2.1- By Id
  Future<Team?> GetTeamById(String id) async {
    DataSnapshot snapshot = await rootRef.child(id).get();
    if (snapshot.exists) {
      return Team.fromDataSnapshot(snapshot);
    }
    return null;
  }

  //2.2- All Teams
  Future<List<Team>> GetAllTeams() async {
    DataSnapshot snapshot = await rootRef.get();
    List<Team> teams = [];
    if (snapshot.exists) {
      for (DataSnapshot d1 in snapshot.children) {
        teams.add(Team.fromDataSnapshot(d1));
      }
    }
    return teams;
  }

  //3- Update
  void UpdateTeam(Team team) {
    rootRef.child(team.id).update(team.toJson());
  }

  //4- Archive/Unarchive
  Future<void> ArchiveTeam(String teamId) async {
    await rootRef.child(teamId).update({'archived': true});
  }

  Future<void> UnarchiveTeam(String teamId) async {
    await rootRef.child(teamId).update({'archived': false});
  }

  //5- Delete
  Future<void> DeleteTeam(String id) async {
    await rootRef.child(id).remove();
  }

  //6- Query Methods
  Future<List<Team>> GetActiveTeams() async {
    DataSnapshot snapshot = await rootRef.get();
    List<Team> teams = [];
    if (snapshot.exists) {
      for (DataSnapshot d1 in snapshot.children) {
        Team team = Team.fromDataSnapshot(d1);
        if (!team.archived) {
          teams.add(team);
        }
      }
    }
    return teams;
  }

  Future<List<Team>> GetArchivedTeams() async {
    DataSnapshot snapshot = await rootRef.get();
    List<Team> teams = [];
    if (snapshot.exists) {
      for (DataSnapshot d1 in snapshot.children) {
        Team team = Team.fromDataSnapshot(d1);
        if (team.archived) {
          teams.add(team);
        }
      }
    }
    return teams;
  }
}

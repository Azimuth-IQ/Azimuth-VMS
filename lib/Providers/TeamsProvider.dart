import 'package:flutter/material.dart';
import 'package:azimuth_vms/Models/Team.dart';
import 'package:azimuth_vms/Models/SystemUser.dart';
import 'package:azimuth_vms/Helpers/TeamHelperFirebase.dart';
import 'package:azimuth_vms/Helpers/SystemUserHelperFirebase.dart';
import 'package:azimuth_vms/Helpers/NotificationHelperFirebase.dart';

class TeamsProvider with ChangeNotifier {
  final TeamHelperFirebase _teamHelper = TeamHelperFirebase();
  final NotificationHelperFirebase _notificationHelper = NotificationHelperFirebase();

  List<Team> _teams = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Team> get teams => _teams;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<Team> get activeTeams => _teams.where((team) => !team.archived).toList();
  List<Team> get archivedTeams => _teams.where((team) => team.archived).toList();

  Future<void> loadTeams() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _teams = await _teamHelper.GetAllTeams();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error loading teams: $e');
      _errorMessage = 'Error loading teams: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createTeam(Team team) async {
    _teamHelper.CreateTeam(team);

    // Send notification to all members about being added to team
    try {
      for (String memberId in team.memberIds) {
        _notificationHelper.sendAddedToTeamNotification(memberId, team.name);
      }
    } catch (e) {
      print('Error sending team member notifications: $e');
    }

    await loadTeams();
  }

  Future<void> updateTeam(Team team) async {
    // Get old team data to compare changes
    Team? oldTeam = _teams.where((t) => t.id == team.id).firstOrNull;

    _teamHelper.UpdateTeam(team);

    if (oldTeam != null) {
      try {
        // Check for team leader change
        if (oldTeam.teamLeaderId != team.teamLeaderId) {
          final SystemUserHelperFirebase userHelper = SystemUserHelperFirebase();
          final newLeader = await userHelper.GetSystemUserByPhone(team.teamLeaderId);

          if (newLeader != null) {
            _notificationHelper.sendTeamLeaderChangedNotification(team.memberIds, newLeader.name, team.name);
          }
        }

        // Check for added members
        final addedMembers = team.memberIds.where((id) => !oldTeam.memberIds.contains(id)).toList();
        for (String memberId in addedMembers) {
          _notificationHelper.sendAddedToTeamNotification(memberId, team.name);
        }

        // Check for removed members
        final removedMembers = oldTeam.memberIds.where((id) => !team.memberIds.contains(id)).toList();
        for (String memberId in removedMembers) {
          _notificationHelper.sendRemovedFromTeamNotification(memberId, team.name);
        }
      } catch (e) {
        print('Error sending team update notifications: $e');
      }
    }

    await loadTeams();
  }

  Future<void> archiveTeam(String teamId) async {
    try {
      await _teamHelper.ArchiveTeam(teamId);
      await loadTeams();
    } catch (e) {
      print('Error archiving team: $e');
      _errorMessage = 'Error archiving team: $e';
      notifyListeners();
    }
  }

  Future<void> unarchiveTeam(String teamId) async {
    try {
      await _teamHelper.UnarchiveTeam(teamId);
      await loadTeams();
    } catch (e) {
      print('Error unarchiving team: $e');
      _errorMessage = 'Error unarchiving team: $e';
      notifyListeners();
    }
  }

  Future<void> deleteTeam(String teamId) async {
    try {
      await _teamHelper.DeleteTeam(teamId);
      await loadTeams();
    } catch (e) {
      print('Error deleting team: $e');
      _errorMessage = 'Error deleting team: $e';
      notifyListeners();
    }
  }
}

class TeamFormProvider with ChangeNotifier {
  final SystemUserHelperFirebase _userHelper = SystemUserHelperFirebase();

  Team? _editingTeam;
  String _name = '';
  String _teamLeaderId = '';
  List<String> _memberIds = [];

  List<SystemUser> _allUsers = [];
  bool _loadingUsers = false;

  Team? get editingTeam => _editingTeam;
  String get name => _name;
  String get teamLeaderId => _teamLeaderId;
  List<String> get memberIds => _memberIds;
  List<SystemUser> get allUsers => _allUsers;
  bool get loadingUsers => _loadingUsers;

  List<SystemUser> get teamLeaders => _allUsers.where((u) => u.role == SystemUserRole.TEAMLEADER).toList();

  List<SystemUser> get volunteers => _allUsers.where((u) => u.role == SystemUserRole.VOLUNTEER).toList();

  Future<void> loadSystemUsers() async {
    _loadingUsers = true;
    notifyListeners();

    try {
      _allUsers = await _userHelper.GetAllSystemUsers();
      _loadingUsers = false;
      notifyListeners();
    } catch (e) {
      print('Error loading system users: $e');
      _loadingUsers = false;
      notifyListeners();
    }
  }

  void initializeForm(Team? team) async {
    _editingTeam = team;
    _name = team?.name ?? '';
    _teamLeaderId = team?.teamLeaderId ?? '';
    _memberIds = List.from(team?.memberIds ?? []);
    notifyListeners();

    await loadSystemUsers();
  }

  void updateName(String value) {
    _name = value;
    notifyListeners();
  }

  void updateTeamLeaderId(String value) {
    _teamLeaderId = value;
    notifyListeners();
  }

  void addMemberId(String memberId) {
    if (memberId.isNotEmpty && !_memberIds.contains(memberId)) {
      _memberIds.add(memberId);
      notifyListeners();
    }
  }

  void removeMemberId(int index) {
    _memberIds.removeAt(index);
    notifyListeners();
  }

  void reset() {
    _editingTeam = null;
    _name = '';
    _teamLeaderId = '';
    _memberIds = [];
    _allUsers = [];
    notifyListeners();
  }
}

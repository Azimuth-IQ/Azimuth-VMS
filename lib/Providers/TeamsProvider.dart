import 'package:flutter/material.dart';
import 'package:azimuth_vms/Models/Team.dart';
import 'package:azimuth_vms/Models/SystemUser.dart';
import 'package:azimuth_vms/Helpers/TeamHelperFirebase.dart';
import 'package:azimuth_vms/Helpers/SystemUserHelperFirebase.dart';

class TeamsProvider with ChangeNotifier {
  final TeamHelperFirebase _teamHelper = TeamHelperFirebase();

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

  void createTeam(Team team) {
    _teamHelper.CreateTeam(team);
    loadTeams();
  }

  void updateTeam(Team team) {
    _teamHelper.UpdateTeam(team);
    loadTeams();
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

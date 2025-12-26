import 'package:flutter/material.dart';
import 'package:azimuth_vms/Models/SystemUser.dart';
import 'package:azimuth_vms/Helpers/SystemUserHelperFirebase.dart';

class TeamLeadersProvider with ChangeNotifier {
  final SystemUserHelperFirebase _userHelper = SystemUserHelperFirebase();

  List<SystemUser> _teamLeaders = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<SystemUser> get teamLeaders => _teamLeaders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<SystemUser> get activeTeamLeaders => _teamLeaders.where((tl) => !tl.archived).toList();
  List<SystemUser> get archivedTeamLeaders => _teamLeaders.where((tl) => tl.archived).toList();

  Future<void> loadTeamLeaders() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final allUsers = await _userHelper.GetAllSystemUsers();
      _teamLeaders = allUsers.where((u) => u.role == SystemUserRole.TEAMLEADER).toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error loading team leaders: $e');
      _errorMessage = 'Error loading team leaders: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createTeamLeader(SystemUser teamLeader) async {
    try {
      await _userHelper.CreateSystemUser(teamLeader);
      await loadTeamLeaders();
    } catch (e) {
      print('Error creating team leader: $e');
      _errorMessage = 'Error creating team leader: $e';
      notifyListeners();
    }
  }

  void updateTeamLeader(SystemUser teamLeader) {
    _userHelper.UpdateSystemUser(teamLeader);
    loadTeamLeaders();
  }

  Future<void> archiveTeamLeader(String phone) async {
    try {
      await _userHelper.ArchiveSystemUser(phone);
      await loadTeamLeaders();
    } catch (e) {
      print('Error archiving team leader: $e');
      _errorMessage = 'Error archiving team leader: $e';
      notifyListeners();
    }
  }

  Future<void> unarchiveTeamLeader(String phone) async {
    try {
      await _userHelper.UnarchiveSystemUser(phone);
      await loadTeamLeaders();
    } catch (e) {
      print('Error unarchiving team leader: $e');
      _errorMessage = 'Error unarchiving team leader: $e';
      notifyListeners();
    }
  }

  Future<void> deleteTeamLeader(String phone) async {
    try {
      await _userHelper.DeleteSystemUser(phone);
      await loadTeamLeaders();
    } catch (e) {
      print('Error deleting team leader: $e');
      _errorMessage = 'Error deleting team leader: $e';
      notifyListeners();
    }
  }
}

class TeamLeaderFormProvider with ChangeNotifier {
  SystemUser? _editingTeamLeader;
  String _name = '';
  String _phone = '';

  SystemUser? get editingTeamLeader => _editingTeamLeader;
  String get name => _name;
  String get phone => _phone;

  void initializeForm(SystemUser? teamLeader) {
    _editingTeamLeader = teamLeader;
    _name = teamLeader?.name ?? '';
    _phone = teamLeader?.phone ?? '';
    notifyListeners();
  }

  void updateName(String value) {
    _name = value;
    notifyListeners();
  }

  void updatePhone(String value) {
    _phone = value;
    notifyListeners();
  }

  void reset() {
    _editingTeamLeader = null;
    _name = '';
    _phone = '';
    notifyListeners();
  }
}

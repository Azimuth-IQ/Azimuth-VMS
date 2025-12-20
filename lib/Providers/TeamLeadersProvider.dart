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

  void createTeamLeader(SystemUser teamLeader) {
    _userHelper.CreateSystemUser(teamLeader);
    loadTeamLeaders();
  }

  void updateTeamLeader(SystemUser teamLeader) {
    _userHelper.UpdateSystemUser(teamLeader);
    loadTeamLeaders();
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

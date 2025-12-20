import 'package:flutter/material.dart';
import 'package:azimuth_vms/Models/SystemUser.dart';
import 'package:azimuth_vms/Helpers/SystemUserHelperFirebase.dart';

class VolunteersProvider with ChangeNotifier {
  final SystemUserHelperFirebase _userHelper = SystemUserHelperFirebase();

  List<SystemUser> _volunteers = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<SystemUser> get volunteers => _volunteers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadVolunteers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final allUsers = await _userHelper.GetAllSystemUsers();
      _volunteers = allUsers.where((u) => u.role == SystemUserRole.VOLUNTEER).toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error loading volunteers: $e');
      _errorMessage = 'Error loading volunteers: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  void createVolunteer(SystemUser volunteer) {
    _userHelper.CreateSystemUser(volunteer);
    loadVolunteers();
  }

  void updateVolunteer(SystemUser volunteer) {
    _userHelper.UpdateSystemUser(volunteer);
    loadVolunteers();
  }
}

class VolunteerFormProvider with ChangeNotifier {
  SystemUser? _editingVolunteer;
  String _name = '';
  String _phone = '';

  SystemUser? get editingVolunteer => _editingVolunteer;
  String get name => _name;
  String get phone => _phone;

  void initializeForm(SystemUser? volunteer) {
    _editingVolunteer = volunteer;
    _name = volunteer?.name ?? '';
    _phone = volunteer?.phone ?? '';
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
    _editingVolunteer = null;
    _name = '';
    _phone = '';
    notifyListeners();
  }
}

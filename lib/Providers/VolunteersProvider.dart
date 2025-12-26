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

  List<SystemUser> get activeVolunteers => _volunteers.where((v) => !v.archived).toList();
  List<SystemUser> get archivedVolunteers => _volunteers.where((v) => v.archived).toList();

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

  Future<void> createVolunteer(SystemUser volunteer) async {
    try {
      await _userHelper.CreateSystemUser(volunteer);
      await loadVolunteers();
    } catch (e) {
      print('Error creating volunteer: $e');
      _errorMessage = 'Error creating volunteer: $e';
      notifyListeners();
    }
  }

  void updateVolunteer(SystemUser volunteer) {
    _userHelper.UpdateSystemUser(volunteer);
    loadVolunteers();
  }

  Future<void> archiveVolunteer(String phone) async {
    try {
      await _userHelper.ArchiveSystemUser(phone);
      await loadVolunteers();
    } catch (e) {
      print('Error archiving volunteer: $e');
      _errorMessage = 'Error archiving volunteer: $e';
      notifyListeners();
    }
  }

  Future<void> unarchiveVolunteer(String phone) async {
    try {
      await _userHelper.UnarchiveSystemUser(phone);
      await loadVolunteers();
    } catch (e) {
      print('Error unarchiving volunteer: $e');
      _errorMessage = 'Error unarchiving volunteer: $e';
      notifyListeners();
    }
  }

  Future<void> deleteVolunteer(String phone) async {
    try {
      await _userHelper.DeleteSystemUser(phone);
      await loadVolunteers();
    } catch (e) {
      print('Error deleting volunteer: $e');
      _errorMessage = 'Error deleting volunteer: $e';
      notifyListeners();
    }
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

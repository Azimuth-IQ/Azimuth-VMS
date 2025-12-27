import 'package:flutter/material.dart';
import 'package:azimuth_vms/Models/Event.dart';
import 'package:azimuth_vms/Models/Location.dart';
import 'package:azimuth_vms/Models/Team.dart';
import 'package:azimuth_vms/Models/SystemUser.dart';
import 'package:azimuth_vms/Helpers/EventHelperFirebase.dart';
import 'package:azimuth_vms/Helpers/LocationHelperFirebase.dart';
import 'package:azimuth_vms/Helpers/TeamHelperFirebase.dart';
import 'package:azimuth_vms/Helpers/SystemUserHelperFirebase.dart';
import 'package:uuid/uuid.dart';

class EventsProvider with ChangeNotifier {
  final EventHelperFirebase _eventHelper = EventHelperFirebase();
  final LocationHelperFirebase _locationHelper = LocationHelperFirebase();
  final TeamHelperFirebase _teamHelper = TeamHelperFirebase();
  final SystemUserHelperFirebase _userHelper = SystemUserHelperFirebase();

  List<Event> _events = [];
  List<Location> _locations = [];
  List<Team> _teams = [];
  List<SystemUser> _systemUsers = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Event> get events => _events;
  List<Location> get locations => _locations;
  List<Team> get teams => _teams;
  List<SystemUser> get systemUsers => _systemUsers;
  List<SystemUser> get teamLeaders => _systemUsers.where((u) => u.role == SystemUserRole.TEAMLEADER).toList();
  List<SystemUser> get volunteers => _systemUsers.where((u) => u.role == SystemUserRole.VOLUNTEER).toList();
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadEvents() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _events = await _eventHelper.GetAllEvents();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error loading events: $e');
      _errorMessage = 'Error loading events: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadLocations() async {
    try {
      print('🔄 Loading locations...');
      _locations = await _locationHelper.GetAllLocations();
      print('✅ Locations loaded: ${_locations.length} total');
      notifyListeners();
    } catch (e) {
      print('❌ Error loading locations: $e');
      _errorMessage = 'Error loading locations: $e';
      notifyListeners();
    }
  }

  Future<void> loadTeams() async {
    try {
      _teams = await _teamHelper.GetAllTeams();
      notifyListeners();
    } catch (e) {
      print('Error loading teams: $e');
    }
  }

  Future<void> loadSystemUsers() async {
    try {
      _systemUsers = await _userHelper.GetAllSystemUsers();
      notifyListeners();
    } catch (e) {
      print('Error loading system users: $e');
    }
  }

  void createEvent(Event event) {
    _eventHelper.CreateEvent(event);
    loadEvents();
  }

  void updateEvent(Event event) {
    _eventHelper.UpdateEvent(event);
    loadEvents();
  }

  // Archive/Unarchive
  Future<void> archiveEvent(String eventId) async {
    try {
      await _eventHelper.ArchiveEvent(eventId);
      await loadEvents();
    } catch (e) {
      print('Error archiving event: $e');
      rethrow;
    }
  }

  Future<void> unarchiveEvent(String eventId) async {
    try {
      await _eventHelper.UnarchiveEvent(eventId);
      await loadEvents();
    } catch (e) {
      print('Error unarchiving event: $e');
      rethrow;
    }
  }

  // Delete
  Future<void> deleteEvent(String eventId) async {
    try {
      await _eventHelper.DeleteEvent(eventId);
      await loadEvents();
    } catch (e) {
      print('Error deleting event: $e');
      rethrow;
    }
  }

  // Get active/archived events
  List<Event> get activeEvents => _events.where((e) => !e.archived).toList();
  List<Event> get archivedEvents => _events.where((e) => e.archived).toList();
}

class EventFormProvider with ChangeNotifier {
  Event? _editingEvent;
  String _name = '';
  String _description = '';
  String _startDate = '';
  String _endDate = '';
  bool _isRecurring = false;
  String _recurrenceType = RecurrenceType.NONE.name;
  String? _recurrenceEndDate;
  List<String> _weeklyDays = [];
  String? _monthlyDay;
  String? _yearlyDay;
  String? _yearlyMonth;
  PresenceCheckPermissions _presenceCheckPermissions = PresenceCheckPermissions.BOTH;
  List<EventShift> _shifts = [];

  Event? get editingEvent => _editingEvent;
  String get name => _name;
  String get description => _description;
  String get startDate => _startDate;
  String get endDate => _endDate;
  bool get isRecurring => _isRecurring;
  String get recurrenceType => _recurrenceType;
  String? get recurrenceEndDate => _recurrenceEndDate;
  List<String> get weeklyDays => _weeklyDays;
  String? get monthlyDay => _monthlyDay;
  String? get yearlyDay => _yearlyDay;
  String? get yearlyMonth => _yearlyMonth;
  PresenceCheckPermissions get presenceCheckPermissions => _presenceCheckPermissions;
  List<EventShift> get shifts => _shifts;

  void initializeForm(Event? event) {
    _editingEvent = event;
    _name = event?.name ?? '';
    _description = event?.description ?? '';
    _startDate = event?.startDate ?? '';
    _endDate = event?.endDate ?? '';
    _isRecurring = event?.isRecurring ?? false;
    _recurrenceType = event?.recurrenceType ?? RecurrenceType.NONE.name;
    _recurrenceEndDate = event?.recurrenceEndDate;
    _weeklyDays = event?.weeklyDays?.split(',') ?? [];
    _monthlyDay = event?.monthlyDay;
    _yearlyDay = event?.yearlyDay;
    _yearlyMonth = event?.yearlyMonth;
    _presenceCheckPermissions = event?.presenceCheckPermissions ?? PresenceCheckPermissions.BOTH;
    _shifts = List.from(event?.shifts ?? []);
    notifyListeners();
  }

  void updateName(String value) {
    _name = value;
    notifyListeners();
  }

  void updateDescription(String value) {
    _description = value;
    notifyListeners();
  }

  void updateStartDate(String value) {
    _startDate = value;
    notifyListeners();
  }

  void updateEndDate(String value) {
    _endDate = value;
    notifyListeners();
  }

  void updateIsRecurring(bool value) {
    _isRecurring = value;
    if (!value) {
      _recurrenceType = RecurrenceType.NONE.name;
      _weeklyDays = [];
      _monthlyDay = null;
      _yearlyDay = null;
      _yearlyMonth = null;
      _recurrenceEndDate = null;
    } else {
      // Set default recurrence type to DAILY when enabling recurring
      if (_recurrenceType == RecurrenceType.NONE.name) {
        _recurrenceType = RecurrenceType.DAILY.name;
      }
    }
    notifyListeners();
  }

  void updateRecurrenceType(String value) {
    _recurrenceType = value;
    // Clear fields not relevant to selected type
    _weeklyDays = [];
    _monthlyDay = null;
    _yearlyDay = null;
    _yearlyMonth = null;
    notifyListeners();
  }

  void updateRecurrenceEndDate(String? value) {
    _recurrenceEndDate = value;
    notifyListeners();
  }

  void updateWeeklyDays(List<String> value) {
    _weeklyDays = value;
    notifyListeners();
  }

  void toggleWeeklyDay(String day) {
    if (_weeklyDays.contains(day)) {
      _weeklyDays.remove(day);
    } else {
      _weeklyDays.add(day);
    }
    notifyListeners();
  }

  void updatePresenceCheckPermissions(PresenceCheckPermissions value) {
    _presenceCheckPermissions = value;
    notifyListeners();
  }

  void updateMonthlyDay(String? value) {
    _monthlyDay = value;
    notifyListeners();
  }

  void updateYearlyDay(String? value) {
    _yearlyDay = value;
    notifyListeners();
  }

  void updateYearlyMonth(String? value) {
    _yearlyMonth = value;
    notifyListeners();
  }

  void addShift(EventShift shift) {
    _shifts.add(shift);
    notifyListeners();
  }

  void updateShift(int index, EventShift shift) {
    _shifts[index] = shift;
    notifyListeners();
  }

  void removeShift(int index) {
    _shifts.removeAt(index);
    notifyListeners();
  }

  void reset() {
    _editingEvent = null;
    _name = '';
    _description = '';
    _startDate = '';
    _endDate = '';
    _isRecurring = false;
    _recurrenceType = RecurrenceType.NONE.name;
    _recurrenceEndDate = null;
    _weeklyDays = [];
    _monthlyDay = null;
    _yearlyDay = null;
    _yearlyMonth = null;
    _shifts = [];
    notifyListeners();
  }
}

class ShiftFormProvider with ChangeNotifier {
  EventShift? _editingShift;
  String _startTime = '';
  String _endTime = '';
  String _locationId = '';
  String? _teamId;
  TempTeam? _tempTeam;
  bool _useExistingTeam = true; // true = use teamId, false = use tempTeam
  List<ShiftSubLocation> _subLocations = [];

  EventShift? get editingShift => _editingShift;
  String get startTime => _startTime;
  String get endTime => _endTime;
  String get locationId => _locationId;
  String? get teamId => _teamId;
  TempTeam? get tempTeam => _tempTeam;
  bool get useExistingTeam => _useExistingTeam;
  List<ShiftSubLocation> get subLocations => _subLocations;

  void initializeForm(EventShift? shift) {
    _editingShift = shift;
    _startTime = shift?.startTime ?? '';
    _endTime = shift?.endTime ?? '';
    _locationId = shift?.locationId ?? '';
    _teamId = shift?.teamId;
    _tempTeam = shift?.tempTeam;
    _useExistingTeam = shift?.teamId != null || shift?.tempTeam == null;
    _subLocations = List.from(shift?.subLocations ?? []);
    notifyListeners();
  }

  void updateStartTime(String value) {
    _startTime = value;
    notifyListeners();
  }

  void updateEndTime(String value) {
    _endTime = value;
    notifyListeners();
  }

  void updateLocationId(String value) {
    _locationId = value;
    // Clear sub-locations if location changed
    _subLocations = [];
    notifyListeners();
  }

  void updateTeamId(String? value) {
    _teamId = value;
    notifyListeners();
  }

  void updateUseExistingTeam(bool value) {
    _useExistingTeam = value;
    if (value) {
      _tempTeam = null;
    } else {
      _teamId = null;
    }
    notifyListeners();
  }

  void updateTempTeam(TempTeam? team) {
    _tempTeam = team;
    notifyListeners();
  }

  void addSubLocation(ShiftSubLocation subLocation) {
    _subLocations.add(subLocation);
    notifyListeners();
  }

  void updateSubLocation(int index, ShiftSubLocation subLocation) {
    _subLocations[index] = subLocation;
    notifyListeners();
  }

  void removeSubLocation(int index) {
    _subLocations.removeAt(index);
    notifyListeners();
  }

  EventShift buildShift() {
    return EventShift(
      id: _editingShift?.id ?? const Uuid().v4(),
      startTime: _startTime,
      endTime: _endTime,
      locationId: _locationId,
      teamId: _useExistingTeam ? _teamId : null,
      tempTeam: !_useExistingTeam ? _tempTeam : null,
      subLocations: _subLocations,
    );
  }

  void reset() {
    _editingShift = null;
    _startTime = '';
    _endTime = '';
    _locationId = '';
    _teamId = null;
    _tempTeam = null;
    _useExistingTeam = true;
    _subLocations = [];
    notifyListeners();
  }
}

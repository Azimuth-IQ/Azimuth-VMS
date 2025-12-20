import 'package:firebase_database/firebase_database.dart';

enum RecurrenceType { NONE, DAILY, WEEKLY, MONTHLY, YEARLY }

enum DayOfWeek {
  MONDAY,
  TUESDAY,
  WEDNESDAY,
  THURSDAY,
  FRIDAY,
  SATURDAY,
  SUNDAY,
}

enum Month {
  JANUARY,
  FEBRUARY,
  MARCH,
  APRIL,
  MAY,
  JUNE,
  JULY,
  AUGUST,
  SEPTEMBER,
  OCTOBER,
  NOVEMBER,
  DECEMBER,
}

// Temporary team that exists only within the event (not saved to teams collection)
class TempTeam {
  String id;
  String teamLeaderId;
  List<String> memberIds;

  TempTeam({
    required this.id,
    required this.teamLeaderId,
    required this.memberIds,
  });

  Map<String, dynamic> toJson() {
    return {'id': id, 'teamLeaderId': teamLeaderId, 'memberIds': memberIds};
  }

  factory TempTeam.fromDataSnapshot(DataSnapshot snapshot) {
    List<String> memberIds = [];
    DataSnapshot membersSnapshot = snapshot.child('memberIds');
    if (membersSnapshot.exists) {
      for (DataSnapshot d1 in membersSnapshot.children) {
        String? memberId = d1.value?.toString();
        if (memberId != null) {
          memberIds.add(memberId);
        }
      }
    }

    return TempTeam(
      id: snapshot.child('id').value?.toString() ?? '',
      teamLeaderId: snapshot.child('teamLeaderId').value?.toString() ?? '',
      memberIds: memberIds,
    );
  }
}

class Event {
  String id;
  String name;
  String description;

  // Recurrence
  bool isRecurring;
  String recurrenceType; // "NONE", "DAILY", "WEEKLY", "MONTHLY", "YEARLY"

  // Date range
  String startDate; // "DD-MM-YYYY"
  String endDate; // "DD-MM-YYYY"
  String?
  recurrenceEndDate; // "DD-MM-YYYY" - optional, for when recurring stops

  // Recurrence rules (optional based on type)
  String? weeklyDays; // "MONDAY,WEDNESDAY,FRIDAY" - comma-separated enum names
  String? monthlyDay; // "15" for 15th of each month
  String? yearlyDay; // "25" for 25th day
  String? yearlyMonth; // "DECEMBER" - enum name

  // Shifts
  List<EventShift> shifts;

  Event({
    required this.id,
    required this.name,
    required this.description,
    required this.isRecurring,
    required this.recurrenceType,
    required this.startDate,
    required this.endDate,
    this.recurrenceEndDate,
    this.weeklyDays,
    this.monthlyDay,
    this.yearlyDay,
    this.yearlyMonth,
    required this.shifts,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'isRecurring': isRecurring,
      'recurrenceType': recurrenceType,
      'startDate': startDate,
      'endDate': endDate,
      'recurrenceEndDate': recurrenceEndDate,
      'weeklyDays': weeklyDays,
      'monthlyDay': monthlyDay,
      'yearlyDay': yearlyDay,
      'yearlyMonth': yearlyMonth,
      'shifts': shifts.map((s) => s.toJson()).toList(),
    };
  }

  factory Event.fromDataSnapshot(DataSnapshot snapshot) {
    List<EventShift> shifts = [];
    DataSnapshot shiftsSnapshot = snapshot.child('shifts');
    if (shiftsSnapshot.exists) {
      for (DataSnapshot d1 in shiftsSnapshot.children) {
        shifts.add(EventShift.fromDataSnapshot(d1));
      }
    }

    return Event(
      id: snapshot.child('id').value?.toString() ?? '',
      name: snapshot.child('name').value?.toString() ?? '',
      description: snapshot.child('description').value?.toString() ?? '',
      isRecurring: snapshot.child('isRecurring').value as bool? ?? false,
      recurrenceType:
          snapshot.child('recurrenceType').value?.toString() ?? 'NONE',
      startDate: snapshot.child('startDate').value?.toString() ?? '',
      endDate: snapshot.child('endDate').value?.toString() ?? '',
      recurrenceEndDate: snapshot.child('recurrenceEndDate').value?.toString(),
      weeklyDays: snapshot.child('weeklyDays').value?.toString(),
      monthlyDay: snapshot.child('monthlyDay').value?.toString(),
      yearlyDay: snapshot.child('yearlyDay').value?.toString(),
      yearlyMonth: snapshot.child('yearlyMonth').value?.toString(),
      shifts: shifts,
    );
  }
}

class EventShift {
  String id;
  String startTime; // "HH:mm" e.g., "09:00"
  String endTime; // "HH:mm" e.g., "17:00"

  // Main location
  String locationId;
  String? teamId; // Optional existing team ID
  TempTeam?
  tempTeam; // Optional temporary team (either teamId or tempTeam, not both)

  // Sublocations
  List<ShiftSubLocation> subLocations;

  EventShift({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.locationId,
    this.teamId,
    this.tempTeam,
    required this.subLocations,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startTime': startTime,
      'endTime': endTime,
      'locationId': locationId,
      'teamId': teamId,
      'tempTeam': tempTeam?.toJson(),
      'subLocations': subLocations.map((s) => s.toJson()).toList(),
    };
  }

  factory EventShift.fromDataSnapshot(DataSnapshot snapshot) {
    List<ShiftSubLocation> subLocations = [];
    DataSnapshot subLocsSnapshot = snapshot.child('subLocations');
    if (subLocsSnapshot.exists) {
      for (DataSnapshot d1 in subLocsSnapshot.children) {
        subLocations.add(ShiftSubLocation.fromDataSnapshot(d1));
      }
    }

    TempTeam? tempTeam;
    DataSnapshot tempTeamSnapshot = snapshot.child('tempTeam');
    if (tempTeamSnapshot.exists) {
      tempTeam = TempTeam.fromDataSnapshot(tempTeamSnapshot);
    }

    return EventShift(
      id: snapshot.child('id').value?.toString() ?? '',
      startTime: snapshot.child('startTime').value?.toString() ?? '',
      endTime: snapshot.child('endTime').value?.toString() ?? '',
      locationId: snapshot.child('locationId').value?.toString() ?? '',
      teamId: snapshot.child('teamId').value?.toString(),
      tempTeam: tempTeam,
      subLocations: subLocations,
    );
  }
}

class ShiftSubLocation {
  String id;
  String subLocationId;
  String? teamId; // Optional existing team ID
  TempTeam?
  tempTeam; // Optional temporary team (either teamId or tempTeam, not both)

  ShiftSubLocation({
    required this.id,
    required this.subLocationId,
    this.teamId,
    this.tempTeam,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subLocationId': subLocationId,
      'teamId': teamId,
      'tempTeam': tempTeam?.toJson(),
    };
  }

  factory ShiftSubLocation.fromDataSnapshot(DataSnapshot snapshot) {
    TempTeam? tempTeam;
    DataSnapshot tempTeamSnapshot = snapshot.child('tempTeam');
    if (tempTeamSnapshot.exists) {
      tempTeam = TempTeam.fromDataSnapshot(tempTeamSnapshot);
    }

    return ShiftSubLocation(
      id: snapshot.child('id').value?.toString() ?? '',
      subLocationId: snapshot.child('subLocationId').value?.toString() ?? '',
      teamId: snapshot.child('teamId').value?.toString(),
      tempTeam: tempTeam,
    );
  }
}

// Helper extension methods for easier enum handling
extension DayOfWeekExtension on DayOfWeek {
  String get displayName {
    return toString().split('.').last;
  }

  static DayOfWeek? fromString(String value) {
    try {
      return DayOfWeek.values.firstWhere(
        (e) => e.toString().split('.').last == value,
      );
    } catch (e) {
      return null;
    }
  }
}

extension MonthExtension on Month {
  String get displayName {
    return toString().split('.').last;
  }

  static Month? fromString(String value) {
    try {
      return Month.values.firstWhere(
        (e) => e.toString().split('.').last == value,
      );
    } catch (e) {
      return null;
    }
  }

  int get monthNumber {
    return Month.values.indexOf(this) + 1; // 1-12
  }
}

extension RecurrenceTypeExtension on RecurrenceType {
  String get displayName {
    return toString().split('.').last;
  }

  static RecurrenceType? fromString(String value) {
    try {
      return RecurrenceType.values.firstWhere(
        (e) => e.toString().split('.').last == value,
      );
    } catch (e) {
      return null;
    }
  }
}

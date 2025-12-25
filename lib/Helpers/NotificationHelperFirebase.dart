import 'package:azimuth_vms/Helpers/EventHelperFirebase.dart';
import 'package:azimuth_vms/Helpers/TeamHelperFirebase.dart';
import 'package:azimuth_vms/Models/Event.dart';
import 'package:azimuth_vms/Models/Notification.dart';
import 'package:azimuth_vms/Models/Team.dart';
import 'package:azimuth_vms/Static/FirebaseHelperStatics.dart';
import 'package:firebase_database/firebase_database.dart';

class NotificationHelperFirebase {
  //1- Root Reference
  DatabaseReference rootRef = FirebaseDatabase.instance.ref().child(FirebaseHelperStatics.AppRoot).child("systemusers");

  //2- Basic CRUD operations for Notifications in Firebase Realtime Database
  void createNotification(Notification notification, String userId) async {
    await rootRef.child(userId).child("notifications").child(notification.id).set(notification.toJson());
  }

  Future<List<Notification>> getNotifications(String userId) async {
    DataSnapshot snapshot = await rootRef.child(userId).child("notifications").get();
    List<Notification> notifications = [];
    if (snapshot.exists) {
      for (DataSnapshot d1 in snapshot.children) {
        notifications.add(Notification.fromDataSnapshot(d1));
      }
    }
    return notifications;
  }

  Future<Map<String, List<Notification>>> getNotificationsForUsers(List<String> userIds) async {
    Map<String, List<Notification>> allNotifications = {};
    for (String userId in userIds) {
      getNotifications(userId).then((notifications) {
        allNotifications[userId] = notifications;
      });
    }
    return Future.value(allNotifications);
  }

  Future<List<Notification>> getScopedNotifications(String userId, int numberOfNotification) async {
    DataSnapshot snapshot = await rootRef.child(userId).child("notifications").get();
    List<Notification> notifications = [];
    if (snapshot.exists) {
      for (DataSnapshot d1 in snapshot.children) {
        //return only a scoped number of notifications
        if (notifications.length < numberOfNotification) {
          notifications.add(Notification.fromDataSnapshot(d1));
        } else {
          break;
        }
      }
    }
    return notifications;
  }

  void updateNotification(Notification notification, String userId) async {
    await rootRef.child(userId).child("notifications").child(notification.id).update(notification.toJson());
  }

  void deleteNotification(String notificationId, String userId) async {
    await rootRef.child(userId).child("notifications").child(notificationId).remove();
  }

  void markAsRead(String notificationId, String userId) async {
    await rootRef.child(userId).child("notifications").child(notificationId).update({'isRead': true});
  }

  void markAsUnread(String notificationId, String userId) async {
    await rootRef.child(userId).child("notifications").child(notificationId).update({'isRead': false});
  }

  // Additional helper methods can be added as needed
  //Send Notifications to a Team
  void sendNotificationToTeam(Notification notification, String teamId) async {
    List<String> teamMembersIds = [];
    // get teammembers for this team id
    TeamHelperFirebase teamHelper = TeamHelperFirebase();
    Team? team = await teamHelper.GetTeamById(teamId);
    if (team != null) {
      teamMembersIds.add(team.teamLeaderId);
      teamMembersIds.addAll(team.memberIds);
    }
    for (String memberId in teamMembersIds) {
      createNotification(notification, memberId);
    }
  }

  void sendNotificationToTeamLeaderOnly(Notification notification, String teamId) async {
    // get teammembers for this team id
    TeamHelperFirebase teamHelper = TeamHelperFirebase();
    Team? team = await teamHelper.GetTeamById(teamId);
    if (team != null) {
      String teamLeaderId = team.teamLeaderId;
      createNotification(notification, teamLeaderId);
    }
  }

  void sendNotificationToTeamMembersOnly(Notification notification, String teamId) async {
    List<String> teamMembersIds = [];
    // get teammembers for this team id
    TeamHelperFirebase teamHelper = TeamHelperFirebase();
    Team? team = await teamHelper.GetTeamById(teamId);
    if (team != null) {
      teamMembersIds.addAll(team.memberIds);
    }
    for (String memberId in teamMembersIds) {
      createNotification(notification, memberId);
    }
  }

  //Event Notifications can be added here
  void sendNotificationToAllEvent(Notification notification, String eventId) async {
    //Init Variables
    List<String> userIds = [];
    List<String> teamsIds = [];

    //Lets Get The Event First
    EventHelperFirebase eventHelper = EventHelperFirebase();
    Event? event = await eventHelper.GetEventById(eventId);

    if (event == null) {
      return;
    }

    //Now Lets Get The Shifts for this Event
    List<EventShift> eventShifts = event.shifts;

    if (eventShifts.isEmpty) {
      return;
    }

    for (EventShift shift in eventShifts) {
      //1- Get Team in The whole shift Location
      if (shift.teamId != null) {
        teamsIds.add(shift.teamId!);
      }

      //2- Get Temp Teams for the shift Location
      if (shift.tempTeam != null) {
        userIds.add(shift.tempTeam!.teamLeaderId);
        userIds.addAll(shift.tempTeam!.memberIds);
      }
    }
  }

  // Send notification to team leader when shift is assigned
  void sendShiftAssignmentNotificationToTeamLeader(String teamLeaderId, String eventName, String eventId) async {
    Notification notification = Notification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'New Event Assignment',
      message: 'You have been assigned to manage volunteers for event: $eventName',
      dateTime: DateTime.now(),
      isRead: false,
      type: NotificationType.Alert,
    );
    createNotification(notification, teamLeaderId);
  }

  // Send notification to volunteer when assigned to a shift
  void sendVolunteerAssignmentNotification(String volunteerId, String eventName, String shiftTime) async {
    Notification notification = Notification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Shift Assignment',
      message: 'You have been assigned to $eventName at $shiftTime',
      dateTime: DateTime.now(),
      isRead: false,
      type: NotificationType.Info,
    );
    createNotification(notification, volunteerId);
  }

  // Send notification to team leader when volunteer requests leave
  void sendLeaveRequestNotificationToTeamLeader(String teamLeaderId, String volunteerName, String eventName) async {
    Notification notification = Notification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Leave Request',
      message: '$volunteerName has requested leave from $eventName',
      dateTime: DateTime.now(),
      isRead: false,
      type: NotificationType.Warning,
    );
    createNotification(notification, teamLeaderId);
  }

  // Send notification to volunteer when leave is approved
  void sendLeaveApprovedNotification(String volunteerId, String eventName) async {
    Notification notification = Notification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Leave Request Approved',
      message: 'Your leave request for $eventName has been approved',
      dateTime: DateTime.now(),
      isRead: false,
      type: NotificationType.Info,
    );
    createNotification(notification, volunteerId);
  }

  // Send notification to volunteer when leave is rejected
  void sendLeaveRejectedNotification(String volunteerId, String eventName) async {
    Notification notification = Notification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Leave Request Rejected',
      message: 'Your leave request for $eventName has been rejected',
      dateTime: DateTime.now(),
      isRead: false,
      type: NotificationType.Warning,
    );
    createNotification(notification, volunteerId);
  }

  // Send notification to volunteer when location/sublocation is changed
  void sendLocationReassignmentNotification(String volunteerId, String newLocationName, String eventName) async {
    Notification notification = Notification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Location Change',
      message: 'Your location for $eventName has been changed to $newLocationName',
      dateTime: DateTime.now(),
      isRead: false,
      type: NotificationType.Alert,
    );
    createNotification(notification, volunteerId);
  }

  // Send presence check reminder to all assigned volunteers for an event
  void sendPresenceCheckReminder(List<String> volunteerIds, String eventName, String checkType) async {
    Notification notification = Notification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Presence Check Reminder',
      message: '$checkType presence check is starting for $eventName',
      dateTime: DateTime.now(),
      isRead: false,
      type: NotificationType.Reminder,
    );

    for (String volunteerId in volunteerIds) {
      createNotification(notification, volunteerId);
    }
  }
}

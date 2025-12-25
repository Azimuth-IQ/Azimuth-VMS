import 'package:firebase_database/firebase_database.dart';

enum NotificationType { Info, Warning, Alert, Reminder }

class Notification {
  //1- Variables
  String id;
  String title;
  String message;
  DateTime dateTime;
  bool isRead;
  NotificationType type;

  //2- Constructor
  Notification({required this.id, required this.title, required this.message, required this.dateTime, required this.isRead, required this.type});

  //3- To Json
  Map<String, dynamic> toJson() {
    return {'id': id, 'title': title, 'message': message, 'dateTime': dateTime.toIso8601String(), 'isRead': isRead, 'type': type.toString().split('.').last};
  }

  //4- From DataSnapshot
  factory Notification.fromDataSnapshot(DataSnapshot snapshot) {
    return Notification(
      id: snapshot.child('id').value?.toString() ?? '',
      title: snapshot.child('title').value?.toString() ?? '',
      message: snapshot.child('message').value?.toString() ?? '',
      dateTime: DateTime.parse(snapshot.child('dateTime').value?.toString() ?? DateTime.now().toIso8601String()),
      isRead: snapshot.child('isRead').value as bool? ?? false,
      type: NotificationType.values.firstWhere((e) => e.toString().split('.').last == snapshot.child('type').value?.toString(), orElse: () => NotificationType.Info),
    );
  }
}

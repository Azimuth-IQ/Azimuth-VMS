import 'package:flutter/material.dart' hide Notification;
import 'package:uuid/uuid.dart';
import '../../Helpers/NotificationHelperFirebase.dart';
import '../../Helpers/SystemUserHelperFirebase.dart';
import '../../Helpers/TeamHelperFirebase.dart';
import '../../Helpers/EventHelperFirebase.dart';
import '../../Helpers/ShiftAssignmentHelperFirebase.dart';
import '../../Models/Notification.dart';
import '../../Models/SystemUser.dart';
import '../../Models/Team.dart';
import '../../Models/Event.dart';

class SendNotificationScreen extends StatefulWidget {
  const SendNotificationScreen({super.key});

  @override
  State<SendNotificationScreen> createState() => _SendNotificationScreenState();
}

class _SendNotificationScreenState extends State<SendNotificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();

  final NotificationHelperFirebase _notificationHelper = NotificationHelperFirebase();
  final SystemUserHelperFirebase _userHelper = SystemUserHelperFirebase();
  final TeamHelperFirebase _teamHelper = TeamHelperFirebase();
  final EventHelperFirebase _eventHelper = EventHelperFirebase();
  final ShiftAssignmentHelperFirebase _assignmentHelper = ShiftAssignmentHelperFirebase();

  NotificationType _selectedType = NotificationType.Info;
  String _selectedAudience = 'all_users';
  String? _selectedRole;
  String? _selectedTeamId;
  String? _selectedEventId;

  List<Team> _teams = [];
  List<Event> _events = [];
  bool _isLoading = false;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final teams = await _teamHelper.GetAllTeams();
      final events = await _eventHelper.GetAllEvents();
      setState(() {
        _teams = teams;
        _events = events;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<List<String>> _getTargetUserPhones() async {
    List<String> targetPhones = [];

    switch (_selectedAudience) {
      case 'all_users':
        final users = await _userHelper.GetAllSystemUsers();
        targetPhones = users.map((u) => u.phone).toList();
        break;

      case 'by_role':
        if (_selectedRole != null) {
          final users = await _userHelper.GetAllSystemUsers();
          final roleEnum = SystemUserRole.values.firstWhere((e) => e.toString().split('.').last == _selectedRole);
          targetPhones = users.where((u) => u.role == roleEnum).map((u) => u.phone).toList();
        }
        break;

      case 'by_team':
        if (_selectedTeamId != null) {
          final users = await _userHelper.GetAllSystemUsers();
          targetPhones = users.where((u) => u.teamId == _selectedTeamId).map((u) => u.phone).toList();
        }
        break;

      case 'by_event':
        if (_selectedEventId != null) {
          final assignments = await _assignmentHelper.GetShiftAssignmentsByEvent(_selectedEventId!);
          targetPhones = assignments.map((a) => a.volunteerId).toSet().toList();
        }
        break;
    }

    return targetPhones;
  }

  Future<void> _sendNotifications() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate audience selection
    if (_selectedAudience == 'by_role' && _selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a role')));
      return;
    }
    if (_selectedAudience == 'by_team' && _selectedTeamId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a team')));
      return;
    }
    if (_selectedAudience == 'by_event' && _selectedEventId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select an event')));
      return;
    }

    setState(() => _isSending = true);

    try {
      final targetPhones = await _getTargetUserPhones();

      if (targetPhones.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No users found for selected audience')));
        setState(() => _isSending = false);
        return;
      }

      // Create and send notification to each target user
      for (String phone in targetPhones) {
        final notification = Notification(
          id: const Uuid().v4(),
          title: _titleController.text.trim(),
          message: _messageController.text.trim(),
          dateTime: DateTime.now(),
          isRead: false,
          type: _selectedType,
        );
        _notificationHelper.createNotification(notification, phone);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Notification sent to ${targetPhones.length} user(s)')));
        Navigator.pop(context);
      }
    } catch (e) {
      print('Error sending notifications: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error sending notifications: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Send Notification'), elevation: 0),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Info Card
                    Card(
                      color: Colors.blue.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue.shade700),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text('Send notifications to specific groups of users in the system', style: TextStyle(color: Colors.blue.shade700)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Notification Type
                    const Text('Notification Type', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<NotificationType>(
                      value: _selectedType,
                      decoration: const InputDecoration(border: OutlineInputBorder(), prefixIcon: Icon(Icons.category)),
                      items: NotificationType.values.map((type) {
                        IconData icon;
                        Color color;
                        switch (type) {
                          case NotificationType.Info:
                            icon = Icons.info_outline;
                            color = Colors.blue;
                            break;
                          case NotificationType.Alert:
                            icon = Icons.warning_amber_rounded;
                            color = Colors.orange;
                            break;
                          case NotificationType.Warning:
                            icon = Icons.error_outline;
                            color = Colors.red;
                            break;
                          case NotificationType.Reminder:
                            icon = Icons.alarm;
                            color = Colors.purple;
                            break;
                        }
                        return DropdownMenuItem(
                          value: type,
                          child: Row(
                            children: [
                              Icon(icon, color: color, size: 20),
                              const SizedBox(width: 8),
                              Text(type.toString().split('.').last),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedType = value!);
                      },
                    ),
                    const SizedBox(height: 24),

                    // Title
                    const Text('Title', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Enter notification title', prefixIcon: Icon(Icons.title)),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Title is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Message
                    const Text('Message', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter notification message',
                        prefixIcon: Icon(Icons.message),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 4,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Message is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Audience Selection
                    const Text('Send To', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedAudience,
                      decoration: const InputDecoration(border: OutlineInputBorder(), prefixIcon: Icon(Icons.people)),
                      items: const [
                        DropdownMenuItem(value: 'all_users', child: Text('All Users')),
                        DropdownMenuItem(value: 'by_role', child: Text('By Role')),
                        DropdownMenuItem(value: 'by_team', child: Text('By Team')),
                        DropdownMenuItem(value: 'by_event', child: Text('Event Participants')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedAudience = value!;
                          _selectedRole = null;
                          _selectedTeamId = null;
                          _selectedEventId = null;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Role Selector (shown when by_role is selected)
                    if (_selectedAudience == 'by_role') ...[
                      const Text('Select Role', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedRole,
                        decoration: const InputDecoration(border: OutlineInputBorder(), prefixIcon: Icon(Icons.badge)),
                        hint: const Text('Choose a role'),
                        items: SystemUserRole.values.map((role) {
                          return DropdownMenuItem(value: role.toString().split('.').last, child: Text(role.toString().split('.').last));
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedRole = value);
                        },
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Team Selector (shown when by_team is selected)
                    if (_selectedAudience == 'by_team') ...[
                      const Text('Select Team', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedTeamId,
                        decoration: const InputDecoration(border: OutlineInputBorder(), prefixIcon: Icon(Icons.group)),
                        hint: const Text('Choose a team'),
                        items: _teams.map((team) {
                          return DropdownMenuItem(value: team.id, child: Text(team.name));
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedTeamId = value);
                        },
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Event Selector (shown when by_event is selected)
                    if (_selectedAudience == 'by_event') ...[
                      const Text('Select Event', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedEventId,
                        decoration: const InputDecoration(border: OutlineInputBorder(), prefixIcon: Icon(Icons.event)),
                        hint: const Text('Choose an event'),
                        items: _events.map((event) {
                          return DropdownMenuItem(value: event.id, child: Text(event.name));
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedEventId = value);
                        },
                      ),
                      const SizedBox(height: 16),
                    ],

                    const SizedBox(height: 24),

                    // Send Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _isSending ? null : _sendNotifications,
                        icon: _isSending
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                            : const Icon(Icons.send),
                        label: Text(_isSending ? 'Sending...' : 'Send Notification'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

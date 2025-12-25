import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Helpers/NotificationHelperFirebase.dart';
import '../../Helpers/ShiftAssignmentHelperFirebase.dart';
import '../../Models/Event.dart';
import '../../Models/Location.dart';
import '../../Models/ShiftAssignment.dart';
import '../../Providers/EventsProvider.dart';

class LocationReassignmentDialog extends StatefulWidget {
  final ShiftAssignment assignment;
  final Event event;
  final EventShift shift;

  const LocationReassignmentDialog({super.key, required this.assignment, required this.event, required this.shift});

  @override
  State<LocationReassignmentDialog> createState() => _LocationReassignmentDialogState();
}

class _LocationReassignmentDialogState extends State<LocationReassignmentDialog> {
  String? _selectedSublocationId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedSublocationId = widget.assignment.sublocationId;
  }

  Future<void> _saveReassignment(BuildContext context) async {
    if (_selectedSublocationId == widget.assignment.sublocationId) {
      Navigator.of(context).pop();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final helper = ShiftAssignmentHelperFirebase();
      final notifHelper = NotificationHelperFirebase();
      final eventsProvider = context.read<EventsProvider>();

      // Update assignment
      final updatedAssignment = widget.assignment.copyWith(sublocationId: _selectedSublocationId);
      helper.UpdateShiftAssignment(updatedAssignment);

      // Get new location name for notification
      String newLocationName = 'Main Location';
      if (_selectedSublocationId != null) {
        final mainLocation = eventsProvider.locations.firstWhere((l) => l.id == widget.shift.locationId);
        if (mainLocation.subLocations != null) {
          final subloc = mainLocation.subLocations!.firstWhere(
            (s) => s.id == _selectedSublocationId,
            orElse: () => Location(id: '', name: 'Unknown', description: '', latitude: '', longitude: ''),
          );
          newLocationName = subloc.name;
        }
      }

      // Send notification to volunteer
      notifHelper.sendLocationReassignmentNotification(widget.assignment.volunteerId, newLocationName, widget.event.name);

      if (!context.mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      print('Error reassigning location: $e');
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EventsProvider>(
      builder: (context, provider, child) {
        // Get main location
        final mainLocation = provider.locations.firstWhere(
          (l) => l.id == widget.shift.locationId,
          orElse: () => Location(id: '', name: 'Unknown', description: '', latitude: '', longitude: ''),
        );

        return AlertDialog(
          title: const Text('Reassign Location'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Event: ${widget.event.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Shift: ${widget.shift.startTime} - ${widget.shift.endTime}'),
                const SizedBox(height: 16),
                const Text('Select new location:'),
                const SizedBox(height: 8),
                RadioListTile<String?>(
                  title: Text('Main Location: ${mainLocation.name}'),
                  value: null,
                  groupValue: _selectedSublocationId,
                  onChanged: (value) {
                    setState(() {
                      _selectedSublocationId = value;
                    });
                  },
                ),
                if (mainLocation.subLocations != null && mainLocation.subLocations!.isNotEmpty) ...[
                  const Divider(),
                  const Text('Sublocations:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...mainLocation.subLocations!.map((subloc) {
                    return RadioListTile<String?>(
                      title: Text(subloc.name),
                      subtitle: Text(subloc.description),
                      value: subloc.id,
                      groupValue: _selectedSublocationId,
                      onChanged: (value) {
                        setState(() {
                          _selectedSublocationId = value;
                        });
                      },
                    );
                  }),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: _isLoading ? null : () => Navigator.of(context).pop(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: _isLoading ? null : () => _saveReassignment(context),
              child: _isLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Reassign'),
            ),
          ],
        );
      },
    );
  }
}

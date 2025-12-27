import 'package:azimuth_vms/Models/Event.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventWorkflowScreen extends StatefulWidget {
  final Event event;

  const EventWorkflowScreen({super.key, required this.event});

  @override
  State<EventWorkflowScreen> createState() => _EventWorkflowScreenState();
}

class _EventWorkflowScreenState extends State<EventWorkflowScreen> {
  late Event _event;

  @override
  void initState() {
    super.initState();
    _event = widget.event;
  }

  int _getCurrentStep() {
    if (_event.archived) return 3; // Archived

    final now = DateTime.now();
    final dateFormat = DateFormat('dd-MM-yyyy');

    try {
      final start = dateFormat.parse(_event.startDate);
      final end = dateFormat.parse(_event.endDate);

      // Reset time part for accurate date comparison
      final today = DateTime(now.year, now.month, now.day);

      if (today.isAfter(end)) {
        return 2; // Completed
      } else if (today.isBefore(start)) {
        return 0; // Planning (Before start)
      } else {
        return 1; // Active (During event)
      }
    } catch (e) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Event Workflow'), backgroundColor: Theme.of(context).colorScheme.inversePrimary),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildHeader(), const SizedBox(height: 24), _buildWorkflowStepper()]),
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.purple.shade100,
              child: const Icon(Icons.event, size: 30, color: Colors.purple),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_event.name, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text('${_event.startDate} - ${_event.endDate}', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600])),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _event.archived ? Colors.grey.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: _event.archived ? Colors.grey : Colors.green),
                    ),
                    child: Text(
                      _event.archived ? 'Archived' : 'Active',
                      style: TextStyle(color: _event.archived ? Colors.grey : Colors.green, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkflowStepper() {
    final currentStep = _getCurrentStep();

    return Stepper(
      currentStep: currentStep,
      controlsBuilder: (context, details) => const SizedBox.shrink(),
      steps: [
        Step(
          title: const Text('Planning'),
          subtitle: const Text('Event created and scheduled'),
          content: const Text('Event is in planning phase. You can assign shifts and volunteers.'),
          isActive: currentStep >= 0,
          state: currentStep > 0 ? StepState.complete : StepState.indexed,
        ),
        Step(
          title: const Text('Active'),
          subtitle: const Text('Event is currently running'),
          content: const Text('Event is active. Volunteers can check in/out.'),
          isActive: currentStep >= 1,
          state: currentStep > 1 ? StepState.complete : (currentStep == 1 ? StepState.editing : StepState.indexed),
        ),
        Step(
          title: const Text('Completed'),
          subtitle: const Text('Event date has passed'),
          content: const Text('Event has ended. You can review attendance and feedback.'),
          isActive: currentStep >= 2,
          state: currentStep > 2 ? StepState.complete : (currentStep == 2 ? StepState.editing : StepState.indexed),
        ),
        Step(
          title: const Text('Archived'),
          subtitle: const Text('Event is archived'),
          content: const Text('Event is archived and hidden from main lists.'),
          isActive: currentStep >= 3,
          state: currentStep == 3 ? StepState.complete : StepState.indexed,
        ),
      ],
    );
  }
}

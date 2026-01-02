import 'package:azimuth_vms/Models/Event.dart';
import 'package:azimuth_vms/l10n/app_localizations.dart';
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
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.eventWorkflow)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildHeader(), const SizedBox(height: 24), _buildWorkflowStepper()]),
      ),
    );
  }

  Widget _buildHeader() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: colorScheme.primary.withOpacity(0.1),
              child: Icon(Icons.event, size: 30, color: colorScheme.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_event.name, style: theme.textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text('${_event.startDate} - ${_event.endDate}', style: theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodySmall?.color)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _event.archived ? colorScheme.onSurface.withOpacity(0.1) : colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: _event.archived ? colorScheme.onSurface.withOpacity(0.5) : colorScheme.primary),
                    ),
                    child: Text(
                      _event.archived ? AppLocalizations.of(context)!.archived : AppLocalizations.of(context)!.active,
                      style: TextStyle(color: _event.archived ? colorScheme.onSurface.withOpacity(0.7) : colorScheme.primary, fontSize: 12, fontWeight: FontWeight.bold),
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
    final loc = AppLocalizations.of(context)!;

    return Stepper(
      currentStep: currentStep,
      controlsBuilder: (context, details) => const SizedBox.shrink(),
      steps: [
        Step(
          title: Text(loc.workflowStepPlanning),
          subtitle: Text(loc.workflowStepPlanningSubtitle),
          content: Text(loc.workflowStepPlanningContent),
          isActive: currentStep >= 0,
          state: currentStep > 0 ? StepState.complete : StepState.indexed,
        ),
        Step(
          title: Text(loc.workflowStepActive),
          subtitle: Text(loc.workflowStepActiveSubtitle),
          content: Text(loc.workflowStepActiveContent),
          isActive: currentStep >= 1,
          state: currentStep > 1 ? StepState.complete : (currentStep == 1 ? StepState.editing : StepState.indexed),
        ),
        Step(
          title: Text(loc.workflowStepCompleted),
          subtitle: Text(loc.workflowStepCompletedSubtitle),
          content: Text(loc.workflowStepCompletedContent),
          isActive: currentStep >= 2,
          state: currentStep > 2 ? StepState.complete : (currentStep == 2 ? StepState.editing : StepState.indexed),
        ),
        Step(
          title: Text(loc.workflowStepArchived),
          subtitle: Text(loc.workflowStepArchivedSubtitle),
          content: Text(loc.workflowStepArchivedContent),
          isActive: currentStep >= 3,
          state: currentStep == 3 ? StepState.complete : StepState.indexed,
        ),
      ],
    );
  }
}

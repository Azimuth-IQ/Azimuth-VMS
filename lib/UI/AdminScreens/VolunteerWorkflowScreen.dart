import 'package:azimuth_vms/Helpers/VolunteerFormHelperFirebase.dart';
import 'package:azimuth_vms/Models/VolunteerForm.dart';
import 'package:azimuth_vms/Helpers/PdfGeneratorHelper.dart';
import 'package:azimuth_vms/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class VolunteerWorkflowScreen extends StatefulWidget {
  final VolunteerForm form;

  const VolunteerWorkflowScreen({super.key, required this.form});

  @override
  State<VolunteerWorkflowScreen> createState() => _VolunteerWorkflowScreenState();
}

class _VolunteerWorkflowScreenState extends State<VolunteerWorkflowScreen> {
  late VolunteerForm _form;
  final VolunteerFormHelperFirebase _helper = VolunteerFormHelperFirebase();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _form = widget.form;
  }

  Future<void> _updateStatus(VolunteerFormStatus newStatus) async {
    setState(() => _isLoading = true);
    try {
      _form.status = newStatus;
      await _helper.UpdateForm(_form);
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.statusUpdatedTo(newStatus.name))));
      }
    } catch (e) {
      print('Error updating status: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  int _getCurrentStep() {
    switch (_form.status) {
      case VolunteerFormStatus.Sent:
        return 0;
      case VolunteerFormStatus.Pending:
        return 1;
      case VolunteerFormStatus.Approved1:
      case VolunteerFormStatus.Rejected1:
        return 2;
      case VolunteerFormStatus.Approved2:
      case VolunteerFormStatus.Rejected2:
        return 3;
      case VolunteerFormStatus.Completed:
        return 4;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.volunteerWorkflow)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [_buildHeader(), const SizedBox(height: 24), _buildWorkflowStepper(), const SizedBox(height: 24), _buildActionPanel()],
              ),
            ),
    );
  }

  Widget _buildHeader() {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Text(
                _form.fullName?.substring(0, 1).toUpperCase() ?? '?',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimaryContainer),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_form.fullName ?? l10n.unknownName, style: theme.textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text(_form.mobileNumber ?? l10n.noPhone, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getStatusColor(_form.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: _getStatusColor(_form.status)),
                    ),
                    child: Text(
                      _form.status?.name ?? l10n.unknown,
                      style: TextStyle(color: _getStatusColor(_form.status), fontSize: 12, fontWeight: FontWeight.bold),
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
    final l10n = AppLocalizations.of(context)!;
    return Stepper(
      currentStep: _getCurrentStep(),
      controlsBuilder: (context, details) => const SizedBox.shrink(), // Hide default controls
      steps: [
        Step(
          title: Text(l10n.workflowStepSent),
          subtitle: Text(l10n.workflowStepSentSubtitle),
          content: Text(l10n.workflowStepSentContent),
          isActive: _getCurrentStep() >= 0,
          state: _getCurrentStep() > 0 ? StepState.complete : StepState.indexed,
        ),
        Step(
          title: Text(l10n.workflowStepPendingReview),
          subtitle: Text(l10n.workflowStepPendingSubtitle),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.workflowStepPendingContent),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/admin-form-fill', arguments: _form),
                    icon: const Icon(Icons.visibility),
                    label: Text(l10n.viewForm),
                  ),
                  OutlinedButton.icon(
                    onPressed: () async {
                      try {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.generatingPdf)));
                        await PdfGeneratorHelper.generateAndDownloadPdf(_form);
                        if (mounted) {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          final l10n = AppLocalizations.of(context)!;
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.pdfDownloaded)));
                        }
                      } catch (e) {
                        print('Error generating PDF: $e');
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${AppLocalizations.of(context)!.error}: $e')));
                        }
                      }
                    },
                    icon: const Icon(Icons.print),
                    label: Text(l10n.print),
                  ),
                ],
              ),
            ],
          ),
          isActive: _getCurrentStep() >= 1,
          state: _getCurrentStep() > 1 ? StepState.complete : (_getCurrentStep() == 1 ? StepState.editing : StepState.indexed),
        ),
        Step(
          title: Text(l10n.workflowStepInitialApproval),
          subtitle: Text(l10n.workflowStepInitialApprovalSubtitle),
          content: Text(l10n.workflowStepInitialApprovalContent),
          isActive: _getCurrentStep() >= 2,
          state: _getCurrentStep() > 2
              ? StepState.complete
              : (_form.status == VolunteerFormStatus.Rejected1 ? StepState.error : (_getCurrentStep() == 2 ? StepState.editing : StepState.indexed)),
        ),
        Step(
          title: Text(l10n.workflowStepFinalApproval),
          subtitle: Text(l10n.workflowStepFinalApprovalSubtitle),
          content: Text(l10n.workflowStepFinalApprovalContent),
          isActive: _getCurrentStep() >= 3,
          state: _getCurrentStep() > 3
              ? StepState.complete
              : (_form.status == VolunteerFormStatus.Rejected2 ? StepState.error : (_getCurrentStep() == 3 ? StepState.editing : StepState.indexed)),
        ),
        Step(
          title: Text(l10n.workflowStepCompleted),
          subtitle: Text(l10n.workflowStepCompletedSubtitle),
          content: Text(l10n.workflowStepCompletedContent),
          isActive: _getCurrentStep() >= 4,
          state: _getCurrentStep() == 4 ? StepState.complete : StepState.indexed,
        ),
      ],
    );
  }

  Widget _buildActionPanel() {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    if (_form.status == VolunteerFormStatus.Completed) {
      return Card(
        color: theme.colorScheme.primaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Text(
              l10n.registrationCompleted,
              style: TextStyle(color: theme.colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.actions, style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),
            Row(
              children: [
                if (_form.status == VolunteerFormStatus.Pending) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _updateStatus(VolunteerFormStatus.Approved1),
                      icon: const Icon(Icons.check),
                      label: Text(l10n.approveL1),
                      style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.primary, foregroundColor: theme.colorScheme.onPrimary),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _updateStatus(VolunteerFormStatus.Rejected1),
                      icon: const Icon(Icons.close),
                      label: Text(l10n.reject),
                      style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.error, foregroundColor: theme.colorScheme.onError),
                    ),
                  ),
                ] else if (_form.status == VolunteerFormStatus.Approved1) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _updateStatus(VolunteerFormStatus.Approved2),
                      icon: const Icon(Icons.check_circle),
                      label: Text(l10n.approveL2),
                      style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.primary, foregroundColor: theme.colorScheme.onPrimary),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _updateStatus(VolunteerFormStatus.Rejected2),
                      icon: const Icon(Icons.close),
                      label: Text(l10n.reject),
                      style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.error, foregroundColor: theme.colorScheme.onError),
                    ),
                  ),
                ] else if (_form.status == VolunteerFormStatus.Approved2) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _updateStatus(VolunteerFormStatus.Completed),
                      icon: const Icon(Icons.verified),
                      label: Text(l10n.complete),
                      style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.primary, foregroundColor: theme.colorScheme.onPrimary),
                    ),
                  ),
                ] else if (_form.status == VolunteerFormStatus.Rejected1 || _form.status == VolunteerFormStatus.Rejected2) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _updateStatus(VolunteerFormStatus.Pending),
                      icon: const Icon(Icons.refresh),
                      label: Text(l10n.reEvaluate),
                      style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.tertiary, foregroundColor: theme.colorScheme.onTertiary),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(VolunteerFormStatus? status) {
    switch (status) {
      case VolunteerFormStatus.Sent:
        return Colors.blue;
      case VolunteerFormStatus.Pending:
        return Colors.orange;
      case VolunteerFormStatus.Approved1:
      case VolunteerFormStatus.Approved2:
        return Colors.lightGreen;
      case VolunteerFormStatus.Completed:
        return Colors.green;
      case VolunteerFormStatus.Rejected1:
      case VolunteerFormStatus.Rejected2:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

import 'package:azimuth_vms/Helpers/VolunteerFormHelperFirebase.dart';
import 'package:azimuth_vms/Models/VolunteerForm.dart';
import 'package:azimuth_vms/Helpers/PdfGeneratorHelper.dart';
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Status updated to ${newStatus.name}')));
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
    return Scaffold(
      appBar: AppBar(title: const Text('Volunteer Workflow'), backgroundColor: Theme.of(context).colorScheme.inversePrimary),
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.blue.shade100,
              child: Text(
                _form.fullName?.substring(0, 1).toUpperCase() ?? '?',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue.shade700),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_form.fullName ?? 'Unknown Name', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text(_form.mobileNumber ?? 'No Phone', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600])),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getStatusColor(_form.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: _getStatusColor(_form.status)),
                    ),
                    child: Text(
                      _form.status?.name ?? 'Unknown',
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
    return Stepper(
      currentStep: _getCurrentStep(),
      controlsBuilder: (context, details) => const SizedBox.shrink(), // Hide default controls
      steps: [
        Step(
          title: const Text('Sent'),
          subtitle: const Text('Waiting for volunteer to fill data'),
          content: const Text('Form link has been sent to the volunteer.'),
          isActive: _getCurrentStep() >= 0,
          state: _getCurrentStep() > 0 ? StepState.complete : StepState.indexed,
        ),
        Step(
          title: const Text('Pending Review'),
          subtitle: const Text('Admin checks form and attachments'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Please review the form data and attachments.'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/admin-form-fill', arguments: _form),
                    icon: const Icon(Icons.visibility),
                    label: const Text('View Form'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () async {
                      try {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Generating PDF...')));
                        await PdfGeneratorHelper.generateAndDownloadPdf(_form);
                        if (mounted) {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PDF Downloaded')));
                        }
                      } catch (e) {
                        print('Error generating PDF: $e');
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                        }
                      }
                    },
                    icon: const Icon(Icons.print),
                    label: const Text('Print'),
                  ),
                ],
              ),
            ],
          ),
          isActive: _getCurrentStep() >= 1,
          state: _getCurrentStep() > 1 ? StepState.complete : (_getCurrentStep() == 1 ? StepState.editing : StepState.indexed),
        ),
        Step(
          title: const Text('Initial Approval'),
          subtitle: const Text('First level approval'),
          content: const Text('Form has passed initial review.'),
          isActive: _getCurrentStep() >= 2,
          state: _getCurrentStep() > 2
              ? StepState.complete
              : (_form.status == VolunteerFormStatus.Rejected1 ? StepState.error : (_getCurrentStep() == 2 ? StepState.editing : StepState.indexed)),
        ),
        Step(
          title: const Text('Final Approval'),
          subtitle: const Text('Second level approval'),
          content: const Text('Form has passed final review.'),
          isActive: _getCurrentStep() >= 3,
          state: _getCurrentStep() > 3
              ? StepState.complete
              : (_form.status == VolunteerFormStatus.Rejected2 ? StepState.error : (_getCurrentStep() == 3 ? StepState.editing : StepState.indexed)),
        ),
        Step(
          title: const Text('Completed'),
          subtitle: const Text('Process finished'),
          content: const Text('Volunteer registration is complete.'),
          isActive: _getCurrentStep() >= 4,
          state: _getCurrentStep() == 4 ? StepState.complete : StepState.indexed,
        ),
      ],
    );
  }

  Widget _buildActionPanel() {
    if (_form.status == VolunteerFormStatus.Completed) {
      return const Card(
        color: Colors.green,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Text(
              'Registration Completed',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
            Text('Actions', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            Row(
              children: [
                if (_form.status == VolunteerFormStatus.Pending) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _updateStatus(VolunteerFormStatus.Approved1),
                      icon: const Icon(Icons.check),
                      label: const Text('Approve (L1)'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _updateStatus(VolunteerFormStatus.Rejected1),
                      icon: const Icon(Icons.close),
                      label: const Text('Reject'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                    ),
                  ),
                ] else if (_form.status == VolunteerFormStatus.Approved1) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _updateStatus(VolunteerFormStatus.Approved2),
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Approve (L2)'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _updateStatus(VolunteerFormStatus.Rejected2),
                      icon: const Icon(Icons.close),
                      label: const Text('Reject'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                    ),
                  ),
                ] else if (_form.status == VolunteerFormStatus.Approved2) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _updateStatus(VolunteerFormStatus.Completed),
                      icon: const Icon(Icons.verified),
                      label: const Text('Complete'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                    ),
                  ),
                ] else if (_form.status == VolunteerFormStatus.Rejected1 || _form.status == VolunteerFormStatus.Rejected2) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _updateStatus(VolunteerFormStatus.Pending),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Re-evaluate'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
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

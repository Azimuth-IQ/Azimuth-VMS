import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../../Models/Event.dart';
import '../../Models/LeaveRequest.dart';
import '../../Models/ShiftAssignment.dart';
import '../../Helpers/LeaveRequestHelperFirebase.dart';
import '../../Helpers/NotificationHelperFirebase.dart';
import '../../l10n/app_localizations.dart';

class LeaveRequestScreen extends StatefulWidget {
  final Event event;
  final EventShift shift;
  final ShiftAssignment assignment;

  const LeaveRequestScreen({super.key, required this.event, required this.shift, required this.assignment});

  @override
  State<LeaveRequestScreen> createState() => _LeaveRequestScreenState();
}

class _LeaveRequestScreenState extends State<LeaveRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submitLeaveRequest() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.userNotAuthenticated)));
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final volunteerPhone = user.email!.split('@').first;

      final leaveRequest = LeaveRequest(
        id: const Uuid().v4(),
        volunteerId: volunteerPhone,
        shiftId: widget.shift.id,
        eventId: widget.event.id,
        reason: _reasonController.text.trim(),
        status: LeaveRequestStatus.PENDING,
        requestedAt: DateTime.now().toIso8601String(),
      );

      LeaveRequestHelperFirebase().CreateLeaveRequest(leaveRequest);

      // Send notification to team leader
      String? teamLeaderId;
      if (widget.shift.teamId != null) {
        // Permanent team - team leader is in the Team object
        // This would require loading the team to get the team leader
        // For simplicity, we'll use temp team leader if available
      }
      if (widget.shift.tempTeam != null) {
        teamLeaderId = widget.shift.tempTeam!.teamLeaderId;
      }

      if (teamLeaderId != null) {
        NotificationHelperFirebase().sendLeaveRequestNotificationToTeamLeader(teamLeaderId, volunteerPhone, widget.event.name);
      }

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.leaveRequestSubmittedSuccessfully), backgroundColor: Colors.green));
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      print('Error submitting leave request: $e');
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.errorOccurred(e.toString()))));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.requestLeave)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event info card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.event, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(widget.event.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    _buildInfoRow(l10n.dateLabel, widget.event.startDate),
                    const SizedBox(height: 8),
                    _buildInfoRow(l10n.shiftTimeLabel, '${widget.shift.startTime} - ${widget.shift.endTime}'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Form
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.reasonForLeaveRequest, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(l10n.provideDetailedReasonForLeave, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontSize: 12)),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _reasonController,
                    maxLines: 5,
                    decoration: InputDecoration(hintText: l10n.enterYourReasonHere, border: const OutlineInputBorder(), filled: true),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.pleaseProvideAReason;
                      }
                      if (value.trim().length < 10) {
                        return l10n.pleaseProvideMoreDetailedReason;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Warning notice
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade300),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.orange.shade700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(l10n.teamLeaderWillReviewRequest, style: TextStyle(color: Colors.orange.shade900, fontSize: 12)),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: _isSubmitting ? null : _submitLeaveRequest,
                      icon: _isSubmitting ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.send),
                      label: Text(_isSubmitting ? l10n.submitting : l10n.submitRequest),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
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

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        ),
        Expanded(
          child: Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }
}

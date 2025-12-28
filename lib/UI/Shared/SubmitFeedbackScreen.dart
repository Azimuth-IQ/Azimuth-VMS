import 'package:azimuth_vms/Models/SystemFeedback.dart';
import 'package:azimuth_vms/Providers/SystemFeedbackProvider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';

class SubmitFeedbackScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();

  SubmitFeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = FirebaseAuth.instance.currentUser;
    final userPhone = user?.email?.split('@').first ?? '';
    final feedbackProvider = Provider.of<SystemFeedbackProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(title: Text(l10n.submitFeedback), backgroundColor: Colors.grey[50], elevation: 0, foregroundColor: Colors.black87),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Information Card
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(l10n.shareFeedbackPrompt, style: TextStyle(color: Colors.blue.shade900, fontSize: 14)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Feedback Form
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Message Field
                  TextFormField(
                    controller: _messageController,
                    maxLines: 8,
                    decoration: InputDecoration(labelText: l10n.yourFeedback, hintText: l10n.describeFeedbackDetail, border: const OutlineInputBorder(), alignLabelWithHint: true),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.pleaseEnterFeedback;
                      }
                      if (value.trim().length < 10) {
                        return l10n.provideMoreDetails;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          try {
                            await feedbackProvider.submitFeedback(userId: userPhone, userName: user?.displayName ?? userPhone, message: _messageController.text.trim());

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.feedbackSubmittedSuccessfully), backgroundColor: Colors.green));
                              _messageController.clear();
                            }
                          } catch (e) {
                            print('Error submitting feedback: $e');
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.errorOccurred(e.toString()))));
                            }
                          }
                        }
                      },
                      icon: const Icon(Icons.send),
                      label: Text(l10n.submitFeedback),
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // My Previous Feedback Section
            const Divider(),
            const SizedBox(height: 16),
            Text(l10n.myPreviousFeedback, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),

            // List of user's feedback
            FutureBuilder<List<SystemFeedback>>(
              future: feedbackProvider.getUserFeedback(userPhone),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text(l10n.errorLoadingFeedback(snapshot.error.toString())));
                }

                final myFeedback = snapshot.data ?? [];
                if (myFeedback.isEmpty) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Center(
                        child: Text(l10n.noFeedbackYet, style: const TextStyle(color: Colors.grey)),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: myFeedback.length,
                  itemBuilder: (context, index) {
                    final feedback = myFeedback[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Status Badge and Date
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildStatusBadge(context, feedback.status),
                                Text(_formatDate(feedback.timestamp), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Feedback Message
                            Text(feedback.message, style: const TextStyle(fontSize: 14)),

                            // Resolution Notes (if any)
                            if (feedback.resolutionNotes != null && feedback.resolutionNotes!.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.green.shade200),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.check_circle, color: Colors.green.shade700, size: 16),
                                        const SizedBox(width: 8),
                                        Text(
                                          l10n.adminResponse,
                                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade900, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(feedback.resolutionNotes!, style: TextStyle(color: Colors.green.shade900, fontSize: 13)),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, FeedbackStatus status) {
    final l10n = AppLocalizations.of(context)!;
    Color color;
    IconData icon;
    String label;

    switch (status) {
      case FeedbackStatus.PENDING:
        color = Colors.orange;
        icon = Icons.schedule;
        label = l10n.pending;
        break;
      case FeedbackStatus.IN_PROGRESS:
        color = Colors.blue;
        icon = Icons.hourglass_bottom;
        label = l10n.inProgress;
        break;
      case FeedbackStatus.RESOLVED:
        color = Colors.green;
        icon = Icons.check_circle;
        label = l10n.resolved;
        break;
      case FeedbackStatus.CLOSED:
        color = Colors.grey;
        icon = Icons.close;
        label = l10n.closed;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ],
      ),
    );
  }

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return isoDate;
    }
  }
}

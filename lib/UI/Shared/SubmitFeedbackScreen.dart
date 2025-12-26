import 'package:azimuth_vms/Models/SystemFeedback.dart';
import 'package:azimuth_vms/Providers/SystemFeedbackProvider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SubmitFeedbackScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();

  SubmitFeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userPhone = user?.email?.split('@').first ?? '';
    final feedbackProvider = Provider.of<SystemFeedbackProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Submit Feedback'), backgroundColor: Theme.of(context).colorScheme.inversePrimary),
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
                      child: Text(
                        'Share your feedback, report bugs, or suggest improvements to help us make the system better.',
                        style: TextStyle(color: Colors.blue.shade900, fontSize: 14),
                      ),
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
                    decoration: const InputDecoration(
                      labelText: 'Your Feedback',
                      hintText: 'Describe the issue, bug, or suggestion in detail...',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your feedback';
                      }
                      if (value.trim().length < 10) {
                        return 'Please provide more details (at least 10 characters)';
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
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Feedback submitted successfully!'), backgroundColor: Colors.green));
                              _messageController.clear();
                            }
                          } catch (e) {
                            print('Error submitting feedback: $e');
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                            }
                          }
                        }
                      },
                      icon: const Icon(Icons.send),
                      label: const Text('Submit Feedback'),
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
            Text('My Previous Feedback', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),

            // List of user's feedback
            FutureBuilder<List<SystemFeedback>>(
              future: feedbackProvider.getUserFeedback(userPhone),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error loading feedback: ${snapshot.error}'));
                }

                final myFeedback = snapshot.data ?? [];
                if (myFeedback.isEmpty) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Center(
                        child: Text('You haven\'t submitted any feedback yet', style: TextStyle(color: Colors.grey)),
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
                                _buildStatusBadge(feedback.status),
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
                                          'Admin Response:',
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

  Widget _buildStatusBadge(FeedbackStatus status) {
    Color color;
    IconData icon;
    String label;

    switch (status) {
      case FeedbackStatus.PENDING:
        color = Colors.orange;
        icon = Icons.schedule;
        label = 'Pending';
        break;
      case FeedbackStatus.IN_PROGRESS:
        color = Colors.blue;
        icon = Icons.hourglass_bottom;
        label = 'In Progress';
        break;
      case FeedbackStatus.RESOLVED:
        color = Colors.green;
        icon = Icons.check_circle;
        label = 'Resolved';
        break;
      case FeedbackStatus.CLOSED:
        color = Colors.grey;
        icon = Icons.close;
        label = 'Closed';
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

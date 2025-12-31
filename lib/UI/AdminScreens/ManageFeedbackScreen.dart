import 'package:azimuth_vms/Models/SystemFeedback.dart';
import 'package:azimuth_vms/Providers/SystemFeedbackProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ManageFeedbackScreen extends StatefulWidget {
  const ManageFeedbackScreen({super.key});

  @override
  State<ManageFeedbackScreen> createState() => _ManageFeedbackScreenState();
}

class _ManageFeedbackScreenState extends State<ManageFeedbackScreen> {
  FeedbackStatus? _selectedStatusFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SystemFeedbackProvider>().startListening();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage System Feedback'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // Filter Menu
          PopupMenuButton<FeedbackStatus?>(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter by status',
            onSelected: (status) {
              setState(() {
                _selectedStatusFilter = status;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: null, child: Text('All Feedback')),
              const PopupMenuItem(value: FeedbackStatus.PENDING, child: Text('Pending')),
              const PopupMenuItem(value: FeedbackStatus.IN_PROGRESS, child: Text('In Progress')),
              const PopupMenuItem(value: FeedbackStatus.RESOLVED, child: Text('Resolved')),
              const PopupMenuItem(value: FeedbackStatus.CLOSED, child: Text('Closed')),
            ],
          ),
        ],
      ),
      body: Consumer<SystemFeedbackProvider>(
        builder: (context, provider, child) {
          if (provider.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Apply filter
          List<SystemFeedback> feedbackList;
          if (_selectedStatusFilter == null) {
            feedbackList = provider.allFeedback;
          } else {
            switch (_selectedStatusFilter!) {
              case FeedbackStatus.PENDING:
                feedbackList = provider.pendingFeedback;
                break;
              case FeedbackStatus.IN_PROGRESS:
                feedbackList = provider.inProgressFeedback;
                break;
              case FeedbackStatus.RESOLVED:
                feedbackList = provider.resolvedFeedback;
                break;
              case FeedbackStatus.CLOSED:
                feedbackList = provider.closedFeedback;
                break;
            }
          }

          if (feedbackList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.feedback_outlined, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    _selectedStatusFilter == null ? 'No feedback submitted yet' : 'No ${_selectedStatusFilter!.name.toLowerCase()} feedback',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Summary Cards
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    _buildSummaryCard('Pending', provider.pendingFeedback.length, Colors.orange, Icons.schedule),
                    const SizedBox(width: 12),
                    _buildSummaryCard('In Progress', provider.inProgressFeedback.length, Colors.blue, Icons.hourglass_bottom),
                    const SizedBox(width: 12),
                    _buildSummaryCard('Resolved', provider.resolvedFeedback.length, Colors.green, Icons.check_circle),
                  ],
                ),
              ),

              // Feedback List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: feedbackList.length,
                  itemBuilder: (context, index) {
                    final feedback = feedbackList[index];
                    return _buildFeedbackCard(context, feedback, provider);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(String label, int count, Color color, IconData icon) {
    return Expanded(
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                count.toString(),
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
              ),
              Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeedbackCard(BuildContext context, SystemFeedback feedback, SystemFeedbackProvider provider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(feedback.userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(feedback.userId, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                    ],
                  ),
                ),
                _buildStatusBadge(feedback.status),
              ],
            ),
            const SizedBox(height: 12),

            // Feedback Message
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
              child: Text(feedback.message, style: const TextStyle(fontSize: 14)),
            ),
            const SizedBox(height: 12),

            // Timestamp
            Text('Submitted: ${_formatDate(feedback.timestamp)}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),

            // Resolution Info
            if (feedback.reviewedBy != null) ...[
              const SizedBox(height: 8),
              Text('Reviewed by: ${feedback.reviewedBy}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            ],

            // Resolution Notes
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
                    Text(
                      'Resolution Notes:',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade900, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(feedback.resolutionNotes!, style: TextStyle(color: Colors.green.shade900, fontSize: 13)),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Action Buttons
            Row(
              children: [
                // Change Status Button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showUpdateStatusDialog(context, feedback, provider),
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Update Status'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),

                // Delete Button
                IconButton(
                  onPressed: () => _confirmDelete(context, feedback, provider),
                  icon: const Icon(Icons.delete, color: Colors.red),
                  tooltip: 'Delete feedback',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showUpdateStatusDialog(BuildContext context, SystemFeedback feedback, SystemFeedbackProvider provider) {
    FeedbackStatus selectedStatus = feedback.status;
    final notesController = TextEditingController(text: feedback.resolutionNotes ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Feedback Status'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Status:'),
              const SizedBox(height: 8),
              DropdownButtonFormField<FeedbackStatus>(
                initialValue: selectedStatus,
                decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                items: FeedbackStatus.values.map((status) {
                  return DropdownMenuItem(value: status, child: Text(status.name));
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedStatus = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              const Text('Resolution Notes (optional):'),
              const SizedBox(height: 8),
              TextField(
                controller: notesController,
                maxLines: 4,
                decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Add notes about the resolution...'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              try {
                await provider.updateFeedbackStatus(
                  feedback: feedback,
                  newStatus: selectedStatus,
                  reviewedBy: 'Admin', // You can get actual admin name from FirebaseAuth
                  resolutionNotes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
                );

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Feedback updated successfully'), backgroundColor: Colors.green));
                }
              } catch (e) {
                print('Error updating feedback status: $e');
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, SystemFeedback feedback, SystemFeedbackProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Feedback'),
        content: const Text('Are you sure you want to delete this feedback? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              try {
                await provider.deleteFeedback(feedback.id);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Feedback deleted successfully'), backgroundColor: Colors.green));
                }
              } catch (e) {
                print('Error deleting feedback: $e');
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(FeedbackStatus status) {
    Color color;
    IconData icon;

    switch (status) {
      case FeedbackStatus.PENDING:
        color = Colors.orange;
        icon = Icons.schedule;
        break;
      case FeedbackStatus.IN_PROGRESS:
        color = Colors.blue;
        icon = Icons.hourglass_bottom;
        break;
      case FeedbackStatus.RESOLVED:
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case FeedbackStatus.CLOSED:
        color = Colors.grey;
        icon = Icons.close;
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
            status.name,
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

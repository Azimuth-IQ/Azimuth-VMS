import 'package:azimuth_vms/Models/Event.dart';
import 'package:azimuth_vms/Models/ShiftAssignment.dart';
import 'package:azimuth_vms/Providers/VolunteerEventFeedbackProvider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SubmitEventFeedbackScreen extends StatefulWidget {
  final Event event;
  final ShiftAssignment assignment;

  const SubmitEventFeedbackScreen({
    super.key,
    required this.event,
    required this.assignment,
  });

  @override
  State<SubmitEventFeedbackScreen> createState() => _SubmitEventFeedbackScreenState();
}

class _SubmitEventFeedbackScreenState extends State<SubmitEventFeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();

  int _organizationRating = 3;
  int _logisticsRating = 3;
  int _communicationRating = 3;
  int _managementRating = 3;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  double get _averageRating {
    return (_organizationRating + _logisticsRating + _communicationRating + _managementRating) / 4;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userPhone = user?.email?.split('@').first ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Feedback'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Info Card
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.event, color: Colors.blue.shade700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            widget.event.name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your shift: ${widget.assignment.shiftId}',
                      style: TextStyle(
                        color: Colors.blue.shade800,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Location: ${widget.assignment.sublocationId ?? 'Not assigned'}',
                      style: TextStyle(
                        color: Colors.blue.shade800,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Instructions
            Text(
              'Rate Your Experience',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Please rate the following aspects of the event management (1 = Poor, 5 = Excellent)',
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),

            // Rating Form
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Organization Rating
                  _buildRatingSlider(
                    'Organization & Planning',
                    'How well was the event organized and planned?',
                    _organizationRating,
                    (value) => setState(() => _organizationRating = value),
                    Icons.calendar_today,
                  ),
                  const SizedBox(height: 24),

                  // Logistics Rating
                  _buildRatingSlider(
                    'Logistics & Resources',
                    'Were resources and logistics adequately provided?',
                    _logisticsRating,
                    (value) => setState(() => _logisticsRating = value),
                    Icons.inventory_2,
                  ),
                  const SizedBox(height: 24),

                  // Communication Rating
                  _buildRatingSlider(
                    'Communication',
                    'How effective was the communication before and during the event?',
                    _communicationRating,
                    (value) => setState(() => _communicationRating = value),
                    Icons.chat,
                  ),
                  const SizedBox(height: 24),

                  // Management Rating
                  _buildRatingSlider(
                    'Event Management',
                    'How well was the event managed overall?',
                    _managementRating,
                    (value) => setState(() => _managementRating = value),
                    Icons.manage_accounts,
                  ),
                  const SizedBox(height: 32),

                  // Average Rating Display
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.star, color: Colors.amber.shade700, size: 32),
                        const SizedBox(width: 12),
                        Text(
                          'Average Rating: ${_averageRating.toStringAsFixed(1)} / 5',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Additional Comments
                  const Text(
                    'Additional Comments (Optional)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _messageController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      hintText: 'Share your thoughts, suggestions, or any issues you experienced...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          try {
                            final provider = context.read<VolunteerEventFeedbackProvider>();
                            await provider.submitFeedback(
                              volunteerId: userPhone,
                              volunteerName: user?.displayName ?? userPhone,
                              eventId: widget.event.id,
                              eventName: widget.event.name,
                              shiftId: widget.assignment.id,
                              organizationRating: _organizationRating,
                              logisticsRating: _logisticsRating,
                              communicationRating: _communicationRating,
                              managementRating: _managementRating,
                              message: _messageController.text.trim(),
                            );

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Thank you for your feedback!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              Navigator.pop(context);
                            }
                          } catch (e) {
                            print('Error submitting event feedback: $e');
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e')),
                              );
                            }
                          }
                        }
                      },
                      icon: const Icon(Icons.send),
                      label: const Text('Submit Feedback'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
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

  Widget _buildRatingSlider(
    String title,
    String description,
    int currentValue,
    Function(int) onChanged,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title Row
          Row(
            children: [
              Icon(icon, color: Colors.blue.shade700, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Current Rating Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: _getRatingColor(currentValue),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.star,
                      size: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      currentValue.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Description
          Text(
            description,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          // Rating Slider
          Row(
            children: [
              const Text('1', style: TextStyle(fontWeight: FontWeight.bold)),
              Expanded(
                child: Slider(
                  value: currentValue.toDouble(),
                  min: 1,
                  max: 5,
                  divisions: 4,
                  label: _getRatingLabel(currentValue),
                  onChanged: (value) => onChanged(value.round()),
                ),
              ),
              const Text('5', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          // Rating Labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Poor', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
              Text('Fair', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
              Text('Good', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
              Text('Very Good', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
              Text('Excellent', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
            ],
          ),
        ],
      ),
    );
  }

  Color _getRatingColor(int rating) {
    switch (rating) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.amber;
      case 4:
        return Colors.lightGreen;
      case 5:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getRatingLabel(int rating) {
    switch (rating) {
      case 1:
        return 'Poor';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Very Good';
      case 5:
        return 'Excellent';
      default:
        return '';
    }
  }
}

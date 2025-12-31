import 'package:azimuth_vms/Models/Event.dart';
import 'package:azimuth_vms/Models/VolunteerEventFeedback.dart';
import 'package:azimuth_vms/Providers/EventsProvider.dart';
import 'package:azimuth_vms/Providers/VolunteerEventFeedbackProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EventFeedbackReportScreen extends StatefulWidget {
  const EventFeedbackReportScreen({super.key});

  @override
  State<EventFeedbackReportScreen> createState() => _EventFeedbackReportScreenState();
}

class _EventFeedbackReportScreenState extends State<EventFeedbackReportScreen> {
  Event? _selectedEvent;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VolunteerEventFeedbackProvider>().startListening();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Event Feedback Reports'), backgroundColor: Theme.of(context).colorScheme.inversePrimary),
      body: Column(
        children: [
          // Event Selector
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade100,
            child: Consumer<EventsProvider>(
              builder: (context, eventsProvider, child) {
                if (eventsProvider.events.isEmpty) {
                  return const Center(child: Text('No events available'));
                }

                return DropdownButtonFormField<Event>(
                  initialValue: _selectedEvent,
                  decoration: const InputDecoration(labelText: 'Select Event', border: OutlineInputBorder(), filled: true, fillColor: Colors.white),
                  hint: const Text('Choose an event to view feedback'),
                  items: eventsProvider.events.map((event) {
                    return DropdownMenuItem<Event>(
                      value: event,
                      child: Text(event.name, overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                  onChanged: (event) {
                    setState(() {
                      _selectedEvent = event;
                    });
                    if (event != null) {
                      context.read<VolunteerEventFeedbackProvider>().startListeningToEvent(event.id);
                    }
                  },
                );
              },
            ),
          ),

          // Feedback Report
          Expanded(
            child: _selectedEvent == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.assessment, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text('Select an event to view feedback', style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
                      ],
                    ),
                  )
                : _buildEventFeedbackReport(),
          ),
        ],
      ),
    );
  }

  Widget _buildEventFeedbackReport() {
    return Consumer<VolunteerEventFeedbackProvider>(
      builder: (context, provider, child) {
        if (provider.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        final feedbackList = provider.feedbackByEvent[_selectedEvent!.id] ?? [];

        if (feedbackList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.feedback_outlined, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text('No feedback received for this event yet', style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              // Average Ratings Summary
              FutureBuilder<Map<String, double>>(
                future: provider.getEventAverageRatings(_selectedEvent!.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Padding(padding: const EdgeInsets.all(16.0), child: Text('Error loading averages: ${snapshot.error}'));
                  }

                  final averages = snapshot.data ?? {};
                  return _buildAverageSummary(averages, feedbackList.length);
                },
              ),

              // Individual Feedback List
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(),
                    const SizedBox(height: 16),
                    Text('Individual Feedback (${feedbackList.length})', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: feedbackList.length,
                      itemBuilder: (context, index) {
                        return _buildFeedbackCard(feedbackList[index]);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAverageSummary(Map<String, double> averages, int totalFeedback) {
    final overallAverage = averages['overall'] ?? 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.blue.shade700, Colors.blue.shade500], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.blue.shade200, blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          // Overall Rating
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.star, color: Colors.amber.shade300, size: 48),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Overall Rating', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  Text(
                    '${overallAverage.toStringAsFixed(2)} / 5.00',
                    style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Based on $totalFeedback response${totalFeedback != 1 ? 's' : ''}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 24),

          // Category Ratings
          Row(
            children: [
              Expanded(child: _buildCategoryCard('Organization', averages['organization'] ?? 0.0, Icons.calendar_today)),
              const SizedBox(width: 12),
              Expanded(child: _buildCategoryCard('Logistics', averages['logistics'] ?? 0.0, Icons.inventory_2)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildCategoryCard('Communication', averages['communication'] ?? 0.0, Icons.chat)),
              const SizedBox(width: 12),
              Expanded(child: _buildCategoryCard('Management', averages['management'] ?? 0.0, Icons.manage_accounts)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(String label, double rating, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
          const SizedBox(height: 4),
          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackCard(VolunteerEventFeedback feedback) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(feedback.volunteerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(feedback.shiftId, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                    ],
                  ),
                ),
                // Overall Rating Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: _getRatingColor(feedback.averageRating), borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, size: 16, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        feedback.averageRating.toStringAsFixed(1),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Rating Bars
            _buildRatingBar('Organization', feedback.organizationRating),
            const SizedBox(height: 8),
            _buildRatingBar('Logistics', feedback.logisticsRating),
            const SizedBox(height: 8),
            _buildRatingBar('Communication', feedback.communicationRating),
            const SizedBox(height: 8),
            _buildRatingBar('Management', feedback.managementRating),

            // Message
            if (feedback.message.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Comments:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 4),
                    Text(feedback.message, style: const TextStyle(fontSize: 14)),
                  ],
                ),
              ),
            ],

            // Timestamp
            const SizedBox(height: 12),
            Text('Submitted: ${_formatDate(feedback.timestamp)}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingBar(String label, int rating) {
    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        ),
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(4)),
              ),
              FractionallySizedBox(
                widthFactor: rating / 5,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(color: _getRatingColor(rating.toDouble()), borderRadius: BorderRadius.circular(4)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 30,
          child: Text('$rating/5', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Color _getRatingColor(double rating) {
    if (rating >= 4.5) return Colors.green;
    if (rating >= 3.5) return Colors.lightGreen;
    if (rating >= 2.5) return Colors.amber;
    if (rating >= 1.5) return Colors.orange;
    return Colors.red;
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

import 'package:azimuth_vms/Models/SystemUser.dart';
import 'package:azimuth_vms/Models/VolunteerRating.dart';
import 'package:azimuth_vms/Models/VolunteerRatingCriteria.dart';
import 'package:azimuth_vms/Providers/VolunteerRatingProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VolunteerRatingScreen extends StatelessWidget {
  const VolunteerRatingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rate Volunteers'),
        actions: [IconButton(icon: const Icon(Icons.settings), onPressed: () => Navigator.pushNamed(context, '/rating-criteria-management'), tooltip: 'Manage Criteria')],
      ),
      body: Consumer<VolunteerRatingProvider>(
        builder: (context, provider, child) {
          if (provider.volunteersLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.volunteersWithRatings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text('No volunteers found', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                ],
              ),
            );
          }

          final sortedVolunteers = provider.getVolunteersSortedByRating();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sortedVolunteers.length,
            itemBuilder: (context, index) {
              final entry = sortedVolunteers[index];
              final user = entry.key;
              final rating = entry.value;
              final averageScore = provider.getAverageScore(rating);

              return _buildVolunteerCard(context, user, rating, averageScore);
            },
          );
        },
      ),
    );
  }

  Widget _buildVolunteerCard(BuildContext context, SystemUser user, VolunteerRating? rating, double averageScore) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showRatingDialog(context, user, rating),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 30,
                backgroundColor: averageScore >= 4.0
                    ? Colors.green
                    : averageScore >= 3.0
                    ? Colors.orange
                    : averageScore > 0
                    ? Colors.red
                    : Colors.grey,
                child: Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : 'V',
                  style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 16),

              // User info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(user.phone, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(user.role == SystemUserRole.TEAMLEADER ? Icons.groups : Icons.person, size: 14, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text(user.role == SystemUserRole.TEAMLEADER ? 'Team Leader' : 'Volunteer', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),

              // Rating display
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, color: averageScore > 0 ? Colors.amber : Colors.grey, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        averageScore > 0 ? averageScore.toStringAsFixed(1) : 'N/A',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: averageScore > 0 ? Colors.black87 : Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(rating != null ? 'Last: ${rating.Date}' : 'Not rated', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () => _showRatingDialog(context, user, rating),
                    icon: Icon(rating != null ? Icons.edit : Icons.add, size: 16),
                    label: Text(rating != null ? 'Update' : 'Rate'),
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), textStyle: const TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRatingDialog(BuildContext context, SystemUser user, VolunteerRating? existingRating) {
    final provider = Provider.of<VolunteerRatingProvider>(context, listen: false);

    if (provider.ratingCriteria.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please configure rating criteria first'), backgroundColor: Colors.orange));
      Navigator.pushNamed(context, '/rating-criteria-management');
      return;
    }

    showDialog(
      context: context,
      builder: (context) => _RatingDialog(user: user, existingRating: existingRating, criteria: provider.ratingCriteria),
    );
  }
}

class _RatingDialog extends StatefulWidget {
  final SystemUser user;
  final VolunteerRating? existingRating;
  final List<VolunteerRatingCriteria> criteria;

  const _RatingDialog({required this.user, required this.existingRating, required this.criteria});

  @override
  State<_RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<_RatingDialog> {
  late Map<VolunteerRatingCriteria, int> ratings;
  final List<TextEditingController> noteControllers = [];
  bool saving = false;

  @override
  void initState() {
    super.initState();

    // Initialize ratings
    ratings = {};
    for (var criterion in widget.criteria) {
      // Try to find existing rating for this criterion
      int existingScore = 3; // Default to middle rating

      if (widget.existingRating != null) {
        // Find matching criterion by name
        final existingEntry = widget.existingRating!.ratings.entries.firstWhere((entry) => entry.key.Criteria == criterion.Criteria, orElse: () => MapEntry(criterion, 3));
        existingScore = existingEntry.value;
      }

      ratings[criterion] = existingScore;
    }

    // Initialize notes
    if (widget.existingRating != null && widget.existingRating!.Notes.isNotEmpty) {
      for (var note in widget.existingRating!.Notes) {
        noteControllers.add(TextEditingController(text: note));
      }
    } else {
      noteControllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    for (var controller in noteControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(widget.user.role == SystemUserRole.TEAMLEADER ? Icons.groups : Icons.person, color: Colors.blue),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Rate ${widget.user.name}'),
                Text(
                  widget.user.role == SystemUserRole.TEAMLEADER ? 'Team Leader' : 'Volunteer',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Rating criteria
              Text('Rating Criteria', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              ...widget.criteria.map((criterion) => _buildCriterionRating(criterion)),

              const Divider(height: 32),

              // Notes section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Notes (Optional)', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () {
                      setState(() {
                        noteControllers.add(TextEditingController());
                      });
                    },
                    tooltip: 'Add Note',
                  ),
                ],
              ),
              const SizedBox(height: 8),

              ...List.generate(noteControllers.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: noteControllers[index],
                          decoration: InputDecoration(
                            hintText: 'Add a note...',
                            border: const OutlineInputBorder(),
                            isDense: true,
                            suffixIcon: noteControllers.length > 1
                                ? IconButton(
                                    icon: const Icon(Icons.close, size: 18),
                                    onPressed: () {
                                      setState(() {
                                        noteControllers[index].dispose();
                                        noteControllers.removeAt(index);
                                      });
                                    },
                                  )
                                : null,
                          ),
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: saving ? null : () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: saving ? null : _saveRating,
          child: saving ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Save Rating'),
        ),
      ],
    );
  }

  Widget _buildCriterionRating(VolunteerRatingCriteria criterion) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(criterion.Criteria, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(5, (index) {
              final score = index + 1;
              final isSelected = ratings[criterion] == score;

              return InkWell(
                onTap: () {
                  setState(() {
                    ratings[criterion] = score;
                  });
                },
                child: Column(
                  children: [
                    Icon(isSelected ? Icons.star : Icons.star_border, color: isSelected ? Colors.amber : Colors.grey, size: 32),
                    Text(
                      score.toString(),
                      style: TextStyle(fontSize: 12, color: isSelected ? Colors.amber : Colors.grey, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  void _saveRating() async {
    setState(() {
      saving = true;
    });

    try {
      final provider = Provider.of<VolunteerRatingProvider>(context, listen: false);

      // Collect notes
      final notes = noteControllers.map((c) => c.text.trim()).where((note) => note.isNotEmpty).toList();

      await provider.saveVolunteerRating(widget.user.phone, ratings, notes);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Rating saved for ${widget.user.name}'), backgroundColor: Colors.green));
      }
    } catch (e) {
      print('Error saving rating: $e');
      if (mounted) {
        setState(() {
          saving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving rating: $e'), backgroundColor: Colors.red));
      }
    }
  }
}

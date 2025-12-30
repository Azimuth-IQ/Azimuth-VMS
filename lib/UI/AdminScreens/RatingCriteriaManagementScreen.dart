import 'package:azimuth_vms/Models/VolunteerRatingCriteria.dart';
import 'package:azimuth_vms/Providers/VolunteerRatingProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RatingCriteriaManagementScreen extends StatelessWidget {
  const RatingCriteriaManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Rating Criteria'),
        actions: [IconButton(icon: const Icon(Icons.save), onPressed: () => _saveCriteria(context), tooltip: 'Save Criteria')],
      ),
      body: Consumer<VolunteerRatingProvider>(
        builder: (context, provider, child) {
          if (provider.criteriaLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // Info card
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.blue),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Define the criteria used to rate volunteers. Each criterion will be rated on a scale of 1-5.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Criteria list
              Expanded(
                child: provider.ratingCriteria.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.rule, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text('No criteria defined', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                            const SizedBox(height: 8),
                            Text('Click the + button to add criteria', style: TextStyle(color: Colors.grey[500])),
                          ],
                        ),
                      )
                    : ReorderableListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: provider.ratingCriteria.length,
                        onReorder: (oldIndex, newIndex) {
                          // Handle reordering
                          if (newIndex > oldIndex) {
                            newIndex -= 1;
                          }
                          final item = provider.ratingCriteria.removeAt(oldIndex);
                          provider.ratingCriteria.insert(newIndex, item);
                          provider.saveRatingCriteria(provider.ratingCriteria);
                        },
                        itemBuilder: (context, index) {
                          final criterion = provider.ratingCriteria[index];
                          return _buildCriterionCard(context, provider, criterion, index);
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(onPressed: () => _showAddCriterionDialog(context), child: const Icon(Icons.add), tooltip: 'Add Criterion'),
    );
  }

  Widget _buildCriterionCard(BuildContext context, VolunteerRatingProvider provider, VolunteerRatingCriteria criterion, int index) {
    return Card(
      key: ValueKey(criterion.Criteria),
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: CircleAvatar(child: Text('${index + 1}')),
        title: Text(criterion.Criteria),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _showEditCriterionDialog(context, provider, index, criterion.Criteria),
              tooltip: 'Edit',
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmDelete(context, provider, index, criterion.Criteria),
              tooltip: 'Delete',
            ),
            const Icon(Icons.drag_handle, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _showAddCriterionDialog(BuildContext context) {
    final controller = TextEditingController();
    final provider = Provider.of<VolunteerRatingProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Criterion'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Criterion Name', hintText: 'e.g., Communication Skills', border: OutlineInputBorder()),
          autofocus: true,
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                provider.addCriterion(controller.text.trim());
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Criterion added. Don\'t forget to save!')));
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditCriterionDialog(BuildContext context, VolunteerRatingProvider provider, int index, String currentName) {
    final controller = TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Criterion'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Criterion Name', border: OutlineInputBorder()),
          autofocus: true,
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                provider.updateCriterion(index, controller.text.trim());
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Criterion updated. Don\'t forget to save!')));
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, VolunteerRatingProvider provider, int index, String criterionName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Criterion'),
        content: Text('Are you sure you want to delete "$criterionName"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              provider.removeCriterion(index);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Criterion deleted. Don\'t forget to save!')));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _saveCriteria(BuildContext context) async {
    final provider = Provider.of<VolunteerRatingProvider>(context, listen: false);

    if (provider.ratingCriteria.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cannot save empty criteria list'), backgroundColor: Colors.orange));
      return;
    }

    try {
      await provider.saveRatingCriteria(provider.ratingCriteria);

      // Reload criteria from Firebase to refresh the UI
      await provider.loadRatingCriteria();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Rating criteria saved successfully'), backgroundColor: Colors.green));
      }
    } catch (e) {
      print('Error saving criteria: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving criteria: $e'), backgroundColor: Colors.red));
      }
    }
  }
}

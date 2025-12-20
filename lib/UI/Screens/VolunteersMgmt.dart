import 'package:flutter/material.dart';
import 'package:azimuth_vms/Models/SystemUser.dart';
import 'package:azimuth_vms/Providers/VolunteersProvider.dart';
import 'package:provider/provider.dart';

class VolunteersMgmt extends StatelessWidget {
  const VolunteersMgmt({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(create: (_) => VolunteersProvider()..loadVolunteers(), child: const VolunteersMgmtView());
  }
}

class VolunteersMgmtView extends StatelessWidget {
  const VolunteersMgmtView({super.key});

  void _showVolunteerForm(BuildContext context, {SystemUser? volunteer}) async {
    final result = await showDialog<SystemUser>(
      context: context,
      builder: (context) => ChangeNotifierProvider(
        create: (_) => VolunteerFormProvider()..initializeForm(volunteer),
        child: VolunteerFormDialog(isEdit: volunteer != null),
      ),
    );

    if (result != null) {
      final provider = context.read<VolunteersProvider>();
      if (volunteer == null) {
        provider.createVolunteer(result);
      } else {
        provider.updateVolunteer(result);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VolunteersProvider>(
      builder: (context, provider, child) {
        if (provider.errorMessage != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(provider.errorMessage!)));
          });
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Volunteers Management'),
            actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: () => provider.loadVolunteers())],
          ),
          body: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : provider.volunteers.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.volunteer_activism, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No volunteers found',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      Text('Tap + to add a new volunteer', style: TextStyle(fontSize: 14, color: Colors.grey[500])),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.volunteers.length,
                  itemBuilder: (context, index) {
                    final volunteer = provider.volunteers[index];
                    return VolunteerTile(
                      volunteer: volunteer,
                      onEdit: () => _showVolunteerForm(context, volunteer: volunteer),
                    );
                  },
                ),
          floatingActionButton: FloatingActionButton.extended(onPressed: () => _showVolunteerForm(context), icon: const Icon(Icons.add), label: const Text('Add Volunteer')),
        );
      },
    );
  }
}

class VolunteerTile extends StatelessWidget {
  final SystemUser volunteer;
  final VoidCallback onEdit;

  const VolunteerTile({super.key, required this.volunteer, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.person, color: Colors.blue, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      volunteer.name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1A1F36)),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.phone, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(volunteer.phone, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(icon: const Icon(Icons.edit_outlined), onPressed: onEdit, color: Colors.blue),
            ],
          ),
        ),
      ),
    );
  }
}

class VolunteerFormDialog extends StatelessWidget {
  final bool isEdit;

  const VolunteerFormDialog({super.key, required this.isEdit});

  void _save(BuildContext context, GlobalKey<FormState> formKey) {
    if (formKey.currentState!.validate()) {
      final provider = context.read<VolunteerFormProvider>();

      final volunteer = SystemUser(
        id: provider.phone,
        name: provider.name,
        phone: provider.phone,
        role: SystemUserRole.VOLUNTEER,
        volunteerForm: provider.editingVolunteer?.volunteerForm,
        volunteerRating: provider.editingVolunteer?.volunteerRating,
      );

      Navigator.of(context).pop(volunteer);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();

    return Consumer<VolunteerFormProvider>(
      builder: (context, provider, child) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            constraints: const BoxConstraints(maxWidth: 500),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), shape: BoxShape.circle),
                      child: const Icon(Icons.person_add, color: Colors.blue, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      isEdit ? 'Edit Volunteer' : 'Add New Volunteer',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Color(0xFF1A1F36)),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Form(
                  key: formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        initialValue: provider.name,
                        decoration: const InputDecoration(labelText: 'Full Name *', prefixIcon: Icon(Icons.person)),
                        onChanged: provider.updateName,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter volunteer name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue: provider.phone,
                        decoration: InputDecoration(
                          labelText: 'Phone Number *',
                          prefixIcon: const Icon(Icons.phone),
                          enabled: !isEdit, // Can't change phone when editing
                        ),
                        keyboardType: TextInputType.phone,
                        onChanged: provider.updatePhone,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter phone number';
                          }
                          if (value.length < 10) {
                            return 'Phone number must be at least 10 digits';
                          }
                          return null;
                        },
                      ),
                      if (isEdit)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'Phone number cannot be changed',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600], fontStyle: FontStyle.italic),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
                    const SizedBox(width: 8),
                    ElevatedButton(onPressed: () => _save(context, formKey), child: Text(isEdit ? 'Update' : 'Add')),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

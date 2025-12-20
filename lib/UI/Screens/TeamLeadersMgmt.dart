import 'package:flutter/material.dart';
import 'package:azimuth_vms/Models/SystemUser.dart';
import 'package:azimuth_vms/Providers/TeamLeadersProvider.dart';
import 'package:provider/provider.dart';

class TeamLeadersMgmt extends StatelessWidget {
  const TeamLeadersMgmt({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(create: (_) => TeamLeadersProvider()..loadTeamLeaders(), child: const TeamLeadersMgmtView());
  }
}

class TeamLeadersMgmtView extends StatelessWidget {
  const TeamLeadersMgmtView({super.key});

  void _showTeamLeaderForm(BuildContext context, {SystemUser? teamLeader}) async {
    final result = await showDialog<SystemUser>(
      context: context,
      builder: (context) => ChangeNotifierProvider(
        create: (_) => TeamLeaderFormProvider()..initializeForm(teamLeader),
        child: TeamLeaderFormDialog(isEdit: teamLeader != null),
      ),
    );

    if (result != null) {
      final provider = context.read<TeamLeadersProvider>();
      if (teamLeader == null) {
        provider.createTeamLeader(result);
      } else {
        provider.updateTeamLeader(result);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TeamLeadersProvider>(
      builder: (context, provider, child) {
        if (provider.errorMessage != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(provider.errorMessage!)));
          });
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Team Leaders Management'),
            actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: () => provider.loadTeamLeaders())],
          ),
          body: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : provider.teamLeaders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_pin_circle, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No team leaders found',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      Text('Tap + to add a new team leader', style: TextStyle(fontSize: 14, color: Colors.grey[500])),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.teamLeaders.length,
                  itemBuilder: (context, index) {
                    final teamLeader = provider.teamLeaders[index];
                    return TeamLeaderTile(
                      teamLeader: teamLeader,
                      onEdit: () => _showTeamLeaderForm(context, teamLeader: teamLeader),
                    );
                  },
                ),
          floatingActionButton: FloatingActionButton.extended(onPressed: () => _showTeamLeaderForm(context), icon: const Icon(Icons.add), label: const Text('Add Team Leader')),
        );
      },
    );
  }
}

class TeamLeaderTile extends StatelessWidget {
  final SystemUser teamLeader;
  final VoidCallback onEdit;

  const TeamLeaderTile({super.key, required this.teamLeader, required this.onEdit});

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
                decoration: BoxDecoration(color: Colors.indigo.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.person_pin_circle, color: Colors.indigo, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      teamLeader.name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1A1F36)),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.phone, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(teamLeader.phone, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(icon: const Icon(Icons.edit_outlined), onPressed: onEdit, color: Colors.indigo),
            ],
          ),
        ),
      ),
    );
  }
}

class TeamLeaderFormDialog extends StatelessWidget {
  final bool isEdit;

  const TeamLeaderFormDialog({super.key, required this.isEdit});

  void _save(BuildContext context, GlobalKey<FormState> formKey) {
    if (formKey.currentState!.validate()) {
      final provider = context.read<TeamLeaderFormProvider>();

      final teamLeader = SystemUser(
        id: provider.phone,
        name: provider.name,
        phone: provider.phone,
        role: SystemUserRole.TEAMLEADER,
        volunteerForm: provider.editingTeamLeader?.volunteerForm,
        volunteerRating: provider.editingTeamLeader?.volunteerRating,
      );

      Navigator.of(context).pop(teamLeader);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();

    return Consumer<TeamLeaderFormProvider>(
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
                      decoration: BoxDecoration(color: Colors.indigo.withOpacity(0.1), shape: BoxShape.circle),
                      child: const Icon(Icons.person_add, color: Colors.indigo, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      isEdit ? 'Edit Team Leader' : 'Add New Team Leader',
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
                            return 'Please enter team leader name';
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

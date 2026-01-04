import 'package:flutter/material.dart';
import 'package:azimuth_vms/Models/SystemUser.dart';
import 'package:azimuth_vms/Providers/TeamLeadersProvider.dart';
import 'package:azimuth_vms/UI/Widgets/ArchiveDeleteWidget.dart';
import 'package:azimuth_vms/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class TeamLeadersMgmt extends StatelessWidget {
  const TeamLeadersMgmt({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<TeamLeadersProvider>();
      if (provider.teamLeaders.isEmpty && !provider.isLoading) {
        provider.loadTeamLeaders();
      }
    });
    return const TeamLeadersMgmtView();
  }
}

class TeamLeadersMgmtView extends StatefulWidget {
  const TeamLeadersMgmtView({super.key});

  @override
  State<TeamLeadersMgmtView> createState() => _TeamLeadersMgmtViewState();
}

class _TeamLeadersMgmtViewState extends State<TeamLeadersMgmtView> {
  bool _showArchived = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
        await provider.createTeamLeader(result);
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

        final allTeamLeaders = _showArchived ? provider.archivedTeamLeaders : provider.activeTeamLeaders;

        // Filter team leaders based on search query
        final displayTeamLeaders = _searchQuery.isEmpty
            ? allTeamLeaders
            : allTeamLeaders.where((teamLeader) {
                final query = _searchQuery.toLowerCase();
                return teamLeader.name.toLowerCase().contains(query) || teamLeader.phone.toLowerCase().contains(query);
              }).toList();

        final l10n = AppLocalizations.of(context)!;
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.teamLeadersManagement),
            actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: () => provider.loadTeamLeaders())],
          ),
          body: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    ShowArchivedToggle(
                      showArchived: _showArchived,
                      onChanged: (value) => setState(() => _showArchived = value),
                      archivedCount: provider.archivedTeamLeaders.length,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: l10n.searchTeamLeaders,
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surface,
                        ),
                        onChanged: (value) => setState(() => _searchQuery = value),
                      ),
                    ),
                    Expanded(
                      child: displayTeamLeaders.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.person_pin_circle, size: 64, color: Colors.grey[400]),
                                  const SizedBox(height: 16),
                                  Text(
                                    _showArchived ? 'No archived team leaders' : 'No team leaders found',
                                    style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(AppLocalizations.of(context)!.tapPlusToAddFirstTeamLeader, style: TextStyle(fontSize: 14, color: Colors.grey[500])),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: displayTeamLeaders.length,
                              itemBuilder: (context, index) {
                                final teamLeader = displayTeamLeaders[index];
                                return TeamLeaderTile(
                                  teamLeader: teamLeader,
                                  onEdit: () => _showTeamLeaderForm(context, teamLeader: teamLeader),
                                );
                              },
                            ),
                    ),
                  ],
                ),
          floatingActionButton: FloatingActionButton.extended(
            heroTag: 'team_leaders_mgmt_fab',
            onPressed: () => _showTeamLeaderForm(context),
            icon: const Icon(Icons.add),
            label: Text(AppLocalizations.of(context)!.addTeamLeader),
          ),
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
    final provider = context.read<TeamLeadersProvider>();

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
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(Icons.person_pin_circle, color: Theme.of(context).colorScheme.primary, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(teamLeader.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                        ),
                        if (teamLeader.archived) const SizedBox(width: 8),
                        if (teamLeader.archived) const ArchivedBadge(),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.phone, size: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                        const SizedBox(width: 4),
                        Text(teamLeader.phone, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
                      ],
                    ),
                  ],
                ),
              ),
              ArchiveDeleteMenu(
                isArchived: teamLeader.archived,
                itemType: 'Team Leader',
                itemName: teamLeader.name,
                onArchive: () async {
                  await provider.archiveTeamLeader(teamLeader.phone);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${teamLeader.name} archived')));
                  }
                },
                onUnarchive: () async {
                  await provider.unarchiveTeamLeader(teamLeader.phone);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${teamLeader.name} restored')));
                  }
                },
                onDelete: () async {
                  await provider.deleteTeamLeader(teamLeader.phone);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${teamLeader.name} deleted')));
                  }
                },
              ),
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
                    TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(AppLocalizations.of(context)!.cancel)),
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

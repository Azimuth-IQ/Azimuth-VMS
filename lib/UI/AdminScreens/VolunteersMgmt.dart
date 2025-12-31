import 'package:flutter/material.dart';
import 'package:azimuth_vms/Models/SystemUser.dart';
import 'package:azimuth_vms/Models/Team.dart';
import 'package:azimuth_vms/Providers/VolunteersProvider.dart';
import 'package:azimuth_vms/Providers/TeamsProvider.dart';
import 'package:azimuth_vms/UI/Widgets/ArchiveDeleteWidget.dart';
import 'package:azimuth_vms/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class VolunteersMgmt extends StatelessWidget {
  const VolunteersMgmt({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final volProvider = context.read<VolunteersProvider>();
      if (volProvider.volunteers.isEmpty && !volProvider.isLoading) {
        volProvider.loadVolunteers();
      }
      final teamProvider = context.read<TeamsProvider>();
      if (teamProvider.teams.isEmpty && !teamProvider.isLoading) {
        teamProvider.loadTeams();
      }
    });
    return const VolunteersMgmtView();
  }
}

class VolunteersMgmtView extends StatefulWidget {
  const VolunteersMgmtView({super.key});

  @override
  State<VolunteersMgmtView> createState() => _VolunteersMgmtViewState();
}

class _VolunteersMgmtViewState extends State<VolunteersMgmtView> {
  bool _showArchived = false;

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
        await provider.createVolunteer(result);
      } else {
        provider.updateVolunteer(result);
      }
    }
  }

  void _assignTeam(BuildContext context, SystemUser volunteer, String? teamId) {
    final provider = context.read<VolunteersProvider>();
    final updatedVolunteer = SystemUser(
      id: volunteer.id,
      name: volunteer.name,
      phone: volunteer.phone,
      password: volunteer.password,
      role: volunteer.role,
      teamId: teamId,
      volunteerForm: volunteer.volunteerForm,
      volunteerRating: volunteer.volunteerRating,
      notifications: volunteer.notifications,
      archived: volunteer.archived,
    );
    provider.updateVolunteer(updatedVolunteer);

    final teamName = teamId != null
        ? context
              .read<TeamsProvider>()
              .teams
              .firstWhere(
                (t) => t.id == teamId,
                orElse: () => Team(id: '', name: 'Unknown', teamLeaderId: '', memberIds: [], archived: false),
              )
              .name
        : 'No team';

    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.assignedToTeam(volunteer.name, teamName)), backgroundColor: Colors.green));
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

        final displayVolunteers = _showArchived ? provider.archivedVolunteers : provider.activeVolunteers;

        final l10n = AppLocalizations.of(context)!;
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.volunteersManagement),
            actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: () => provider.loadVolunteers())],
          ),
          body: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    ShowArchivedToggle(showArchived: _showArchived, onChanged: (value) => setState(() => _showArchived = value), archivedCount: provider.archivedVolunteers.length),
                    Expanded(
                      child: displayVolunteers.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.volunteer_activism, size: 64, color: Colors.grey[400]),
                                  const SizedBox(height: 16),
                                  Text(
                                    _showArchived ? l10n.noArchivedEvents : l10n.noVolunteersFound,
                                    style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(l10n.tapPlusToAddVolunteer, style: TextStyle(fontSize: 14, color: Colors.grey[500])),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: displayVolunteers.length,
                              itemBuilder: (context, index) {
                                final volunteer = displayVolunteers[index];
                                return VolunteerTile(
                                  volunteer: volunteer,
                                  onEdit: () => _showVolunteerForm(context, volunteer: volunteer),
                                  onTeamAssign: (teamId) => _assignTeam(context, volunteer, teamId),
                                );
                              },
                            ),
                    ),
                  ],
                ),
          floatingActionButton: FloatingActionButton.extended(
            heroTag: 'volunteers_mgmt_fab',
            onPressed: () => _showVolunteerForm(context),
            icon: const Icon(Icons.add),
            label: Text(l10n.addVolunteer),
          ),
        );
      },
    );
  }
}

class VolunteerTile extends StatelessWidget {
  final SystemUser volunteer;
  final VoidCallback onEdit;
  final Function(String?) onTeamAssign;

  const VolunteerTile({super.key, required this.volunteer, required this.onEdit, required this.onTeamAssign});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<VolunteersProvider>();

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
                child: Icon(Icons.person, color: Theme.of(context).colorScheme.primary, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(volunteer.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                        ),
                        if (volunteer.archived) const SizedBox(width: 8),
                        if (volunteer.archived) const ArchivedBadge(),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.phone, size: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                        const SizedBox(width: 4),
                        Text(volunteer.phone, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Consumer<TeamsProvider>(
                      builder: (context, teamsProvider, child) {
                        final team = volunteer.teamId != null
                            ? teamsProvider.teams.firstWhere(
                                (t) => t.id == volunteer.teamId,
                                orElse: () => Team(id: '', name: 'Unknown', teamLeaderId: '', memberIds: [], archived: false),
                              )
                            : null;
                        return Row(
                          children: [
                            Icon(Icons.groups, size: 14, color: team != null ? Colors.green : Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              team != null ? team.name : 'No team assigned',
                              style: TextStyle(fontSize: 14, color: team != null ? Colors.green : Colors.grey[600], fontStyle: team == null ? FontStyle.italic : null),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) {
                  if (value == 'edit') {
                    onEdit();
                  } else if (value == 'assign') {
                    _showTeamAssignDialog(context);
                  } else if (value == 'archive') {
                    _showArchiveDialog(context, provider);
                  } else if (value == 'unarchive') {
                    _showUnarchiveDialog(context, provider);
                  } else if (value == 'delete') {
                    _showDeleteDialog(context, provider);
                  }
                },
                itemBuilder: (context) {
                  final l10n = AppLocalizations.of(context)!;
                  return [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(children: [const Icon(Icons.edit, size: 20), const SizedBox(width: 8), Text(l10n.edit)]),
                    ),
                    PopupMenuItem(
                      value: 'assign',
                      child: Row(children: [const Icon(Icons.group_add, size: 20), const SizedBox(width: 8), Text(l10n.assignTeam)]),
                    ),
                    if (!volunteer.archived) ...[
                      const PopupMenuDivider(),
                      PopupMenuItem(
                        value: 'archive',
                        child: Row(
                          children: [
                            const Icon(Icons.archive, size: 20, color: Colors.orange),
                            const SizedBox(width: 8),
                            Text(l10n.archive, style: const TextStyle(color: Colors.orange)),
                          ],
                        ),
                      ),
                    ],
                    if (volunteer.archived)
                      PopupMenuItem(
                        value: 'unarchive',
                        child: Row(
                          children: [
                            const Icon(Icons.unarchive, size: 20, color: Colors.green),
                            const SizedBox(width: 8),
                            Text(l10n.restore, style: const TextStyle(color: Colors.green)),
                          ],
                        ),
                      ),
                    const PopupMenuDivider(),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          const Icon(Icons.delete, size: 20, color: Colors.red),
                          const SizedBox(width: 8),
                          Text(l10n.delete, style: const TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ];
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showArchiveDialog(BuildContext context, VolunteersProvider provider) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.archive, color: Colors.orange),
            const SizedBox(width: 8),
            Text(l10n.archiveVolunteer),
          ],
        ),
        content: Text(l10n.archiveVolunteerConfirm(volunteer.name)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(l10n.cancel)),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () async {
              Navigator.pop(dialogContext);
              await provider.archiveVolunteer(volunteer.phone);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${volunteer.name} ${l10n.archived}')));
              }
            },
            child: Text(l10n.archive),
          ),
        ],
      ),
    );
  }

  void _showUnarchiveDialog(BuildContext context, VolunteersProvider provider) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.unarchive, color: Colors.green),
            const SizedBox(width: 8),
            Text(l10n.restoreVolunteer),
          ],
        ),
        content: Text(l10n.restoreVolunteerConfirm(volunteer.name)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(l10n.cancel)),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () async {
              Navigator.pop(dialogContext);
              await provider.unarchiveVolunteer(volunteer.phone);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${volunteer.name} ${l10n.restored}')));
              }
            },
            child: Text(l10n.restore),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, VolunteersProvider provider) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.delete, color: Colors.red),
            const SizedBox(width: 8),
            Text(l10n.deleteVolunteer),
          ],
        ),
        content: Text(l10n.deleteVolunteerConfirm(volunteer.name)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(l10n.cancel)),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(dialogContext);
              await provider.deleteVolunteer(volunteer.phone);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${volunteer.name} ${l10n.deleted}')));
              }
            },
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  void _showTeamAssignDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final teamsProvider = context.read<TeamsProvider>();
    String? selectedTeamId = volunteer.teamId;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(l10n.assignTeam),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.selectTeamFor(volunteer.name)),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: selectedTeamId,
                decoration: InputDecoration(labelText: l10n.team, border: const OutlineInputBorder()),
                items: [
                  DropdownMenuItem(value: null, child: Text(l10n.noTeam)),
                  ...teamsProvider.teams.map((team) => DropdownMenuItem(value: team.id, child: Text(team.name))),
                ],
                onChanged: (value) {
                  setState(() => selectedTeamId = value);
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
            ElevatedButton(
              onPressed: () {
                onTeamAssign(selectedTeamId);
                Navigator.pop(context);
              },
              child: Text(l10n.assign),
            ),
          ],
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
    final l10n = AppLocalizations.of(context)!;
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
                      isEdit ? l10n.editVolunteer : l10n.addVolunteer,
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
                        decoration: InputDecoration(labelText: '${l10n.name} *', prefixIcon: const Icon(Icons.person)),
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
                          labelText: '${l10n.phoneNumber} *',
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
                    TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.cancel)),
                    const SizedBox(width: 8),
                    ElevatedButton(onPressed: () => _save(context, formKey), child: Text(isEdit ? l10n.update : l10n.add)),
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

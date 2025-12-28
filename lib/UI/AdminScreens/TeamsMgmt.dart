import 'package:flutter/material.dart';
import 'package:azimuth_vms/Models/Team.dart';
import 'package:azimuth_vms/Providers/TeamsProvider.dart';
import 'package:azimuth_vms/UI/Widgets/ArchiveDeleteWidget.dart';
import 'package:azimuth_vms/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class TeamsMgmt extends StatelessWidget {
  const TeamsMgmt({super.key});

  @override
  Widget build(BuildContext context) {
    // Use the global TeamsProvider instead of creating a new one
    // Trigger load if empty
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<TeamsProvider>();
      if (provider.teams.isEmpty && !provider.isLoading) {
        provider.loadTeams();
      }
    });

    return const TeamsMgmtView();
  }
}

class TeamsMgmtView extends StatefulWidget {
  const TeamsMgmtView({super.key});

  @override
  State<TeamsMgmtView> createState() => _TeamsMgmtViewState();
}

class _TeamsMgmtViewState extends State<TeamsMgmtView> {
  bool _showArchived = false;

  void _showTeamForm(BuildContext context, {Team? team}) async {
    final result = await showDialog<Team>(
      context: context,
      builder: (context) => ChangeNotifierProvider(
        create: (_) => TeamFormProvider()..initializeForm(team),
        child: TeamFormDialog(isEdit: team != null),
      ),
    );

    if (result != null) {
      final provider = context.read<TeamsProvider>();
      if (team == null) {
        provider.createTeam(result);
      } else {
        provider.updateTeam(result);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TeamsProvider>(
      builder: (context, provider, child) {
        if (provider.errorMessage != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(provider.errorMessage!)));
          });
        }

        final displayTeams = _showArchived ? provider.archivedTeams : provider.activeTeams;

        return Scaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.teamsManagement),
            actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: () => provider.loadTeams())],
          ),
          body: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    ShowArchivedToggle(showArchived: _showArchived, onChanged: (value) => setState(() => _showArchived = value), archivedCount: provider.archivedTeams.length),
                    Expanded(
                      child: displayTeams.isEmpty
                          ? Center(child: Text(_showArchived ? 'No archived teams' : 'No active teams found.\nTap + to add a new team.', textAlign: TextAlign.center))
                          : ListView.builder(
                              itemCount: displayTeams.length,
                              itemBuilder: (context, index) {
                                final team = displayTeams[index];
                                return TeamTile(
                                  team: team,
                                  onEdit: () => _showTeamForm(context, team: team),
                                );
                              },
                            ),
                    ),
                  ],
                ),
          floatingActionButton: FloatingActionButton(heroTag: 'teams_mgmt_fab', onPressed: () => _showTeamForm(context), child: const Icon(Icons.add)),
        );
      },
    );
  }
}

class TeamTile extends StatelessWidget {
  final Team team;
  final VoidCallback onEdit;

  const TeamTile({super.key, required this.team, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<TeamsProvider>();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ExpansionTile(
        leading: const Icon(Icons.groups),
        title: Text(team.name),
        subtitle: Row(
          children: [
            Expanded(child: Text(AppLocalizations.of(context)!.teamLeaderIDColon(team.teamLeaderId))),
            if (team.archived) const SizedBox(width: 8),
            if (team.archived) const ArchivedBadge(),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.edit), onPressed: onEdit),
            ArchiveDeleteMenu(
              isArchived: team.archived,
              itemType: 'Team',
              itemName: team.name,
              onArchive: () async {
                await provider.archiveTeam(team.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${team.name} archived')));
                }
              },
              onUnarchive: () async {
                await provider.unarchiveTeam(team.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${team.name} restored')));
                }
              },
              onDelete: () async {
                await provider.deleteTeam(team.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${team.name} deleted')));
                }
              },
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [const Icon(Icons.person, size: 16), const SizedBox(width: 8), Text(AppLocalizations.of(context)!.leaderColonWithId(team.teamLeaderId))]),
                if (team.memberIds.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(AppLocalizations.of(context)!.teamMembersColon, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...team.memberIds.map(
                    (memberId) => Padding(
                      padding: const EdgeInsets.only(left: 16, top: 4),
                      child: Row(children: [const Icon(Icons.person_outline, size: 16), const SizedBox(width: 8), Text(memberId)]),
                    ),
                  ),
                ] else
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      'No team members added',
                      style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TeamFormDialog extends StatelessWidget {
  final bool isEdit;

  const TeamFormDialog({super.key, required this.isEdit});

  void _addMember(BuildContext context) async {
    final provider = context.read<TeamFormProvider>();

    if (provider.volunteers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.noVolunteersAvailable)));
      return;
    }

    final memberId = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.addTeamMember),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: provider.volunteers.length,
            itemBuilder: (context, index) {
              final volunteer = provider.volunteers[index];
              final isAlreadyAdded = provider.memberIds.contains(volunteer.phone);

              return ListTile(
                enabled: !isAlreadyAdded,
                leading: Icon(Icons.person_outline, color: isAlreadyAdded ? Colors.grey : null),
                title: Text(volunteer.name, style: TextStyle(color: isAlreadyAdded ? Colors.grey : null)),
                subtitle: Text(volunteer.phone, style: TextStyle(color: isAlreadyAdded ? Colors.grey : null)),
                trailing: isAlreadyAdded
                    ? Chip(
                        label: Text(AppLocalizations.of(context)!.added, style: TextStyle(fontSize: 10)),
                        padding: EdgeInsets.symmetric(horizontal: 4),
                      )
                    : null,
                onTap: isAlreadyAdded ? null : () => Navigator.of(context).pop(volunteer.phone),
              );
            },
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(AppLocalizations.of(context)!.cancel))],
      ),
    );

    if (memberId != null) {
      context.read<TeamFormProvider>().addMemberId(memberId);
    }
  }

  void _save(BuildContext context, GlobalKey<FormState> formKey) {
    if (formKey.currentState!.validate()) {
      final provider = context.read<TeamFormProvider>();
      final team = Team(
        id: isEdit ? provider.editingTeam?.id ?? const Uuid().v4() : const Uuid().v4(),
        name: provider.name,
        teamLeaderId: provider.teamLeaderId,
        memberIds: provider.memberIds,
      );

      Navigator.of(context).pop(team);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();

    return Consumer<TeamFormProvider>(
      builder: (context, provider, child) {
        return Dialog(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(isEdit ? 'Edit Team' : 'Add New Team', style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue: provider.name,
                        decoration: const InputDecoration(labelText: 'Team Name *', border: OutlineInputBorder(), prefixIcon: Icon(Icons.groups)),
                        onChanged: provider.updateName,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a team name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      provider.loadingUsers
                          ? const Center(child: CircularProgressIndicator())
                          : DropdownButtonFormField<String>(
                              initialValue: provider.teamLeaderId.isEmpty ? null : provider.teamLeaderId,
                              decoration: const InputDecoration(
                                labelText: 'Team Leader *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.person),
                                hintText: 'Select team leader',
                              ),
                              items: provider.teamLeaders.map((leader) {
                                return DropdownMenuItem<String>(value: leader.phone, child: Text('${leader.name} (${leader.phone})'));
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  provider.updateTeamLeaderId(value);
                                }
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select a team leader';
                                }
                                return null;
                              },
                            ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(AppLocalizations.of(context)!.teamMembers, style: Theme.of(context).textTheme.titleMedium),
                          IconButton(icon: const Icon(Icons.add_circle), onPressed: () => _addMember(context), tooltip: 'Add Member'),
                        ],
                      ),
                      if (provider.memberIds.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(AppLocalizations.of(context)!.noMembersAdded, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
                        )
                      else
                        ...provider.memberIds.asMap().entries.map((entry) {
                          final index = entry.key;
                          final memberId = entry.value;
                          final volunteer = provider.volunteers.firstWhere((v) => v.phone == memberId, orElse: () => null as dynamic);
                          final displayName = '${volunteer.name} (${volunteer.phone})';

                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: const Icon(Icons.person_outline),
                              title: Text(displayName),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => provider.removeMemberId(index),
                                tooltip: 'Remove',
                              ),
                            ),
                          );
                        }),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(AppLocalizations.of(context)!.cancel)),
                          const SizedBox(width: 8),
                          ElevatedButton(onPressed: () => _save(context, formKey), child: Text(isEdit ? 'Update' : 'Create')),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

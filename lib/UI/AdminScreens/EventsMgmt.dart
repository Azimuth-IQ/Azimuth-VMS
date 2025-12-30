import 'package:flutter/material.dart';
import 'package:azimuth_vms/Models/Event.dart';
import 'package:azimuth_vms/Models/Location.dart';
import 'package:azimuth_vms/Providers/EventsProvider.dart';
import 'package:azimuth_vms/UI/AdminScreens/EventWorkflowScreen.dart';
import 'package:azimuth_vms/UI/Widgets/ArchiveDeleteWidget.dart';
import 'package:azimuth_vms/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class EventsMgmt extends StatelessWidget {
  const EventsMgmt({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      EventsProvider provider = context.read<EventsProvider>();
      if (!provider.isLoading) {
        if (provider.events.isEmpty) {
          provider.loadEvents();
        }
        if (provider.locations.isEmpty) {
          provider.loadLocations();
        }
        if (provider.teams.isEmpty) {
          provider.loadTeams();
        }
        if (provider.systemUsers.isEmpty) {
          provider.loadSystemUsers();
        }
      }
    });
    return const EventsMgmtView();
  }
}

class EventsMgmtView extends StatefulWidget {
  const EventsMgmtView({super.key});

  @override
  State<EventsMgmtView> createState() => _EventsMgmtViewState();
}

class _EventsMgmtViewState extends State<EventsMgmtView> {
  bool _showArchived = false;

  void _showEventForm(BuildContext context, {Event? event}) async {
    EventsProvider eventsProvider = context.read<EventsProvider>();

    Event? result = await showDialog<Event>(
      context: context,
      builder: (context) => MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: eventsProvider),
          ChangeNotifierProvider(create: (_) => EventFormProvider()..initializeForm(event)),
        ],
        child: EventFormDialog(isEdit: event != null),
      ),
    );

    if (result != null) {
      if (event == null) {
        eventsProvider.createEvent(result);
      } else {
        eventsProvider.updateEvent(result);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EventsProvider>(
      builder: (context, provider, child) {
        if (provider.errorMessage != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(provider.errorMessage!)));
          });
        }

        List<Event> displayEvents = _showArchived ? provider.archivedEvents : provider.activeEvents;

        return Scaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.eventsManagement),
            actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: () => provider.loadEvents())],
          ),
          body: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    ShowArchivedToggle(showArchived: _showArchived, onChanged: (value) => setState(() => _showArchived = value), archivedCount: provider.archivedEvents.length),
                    Expanded(
                      child: displayEvents.isEmpty
                          ? Center(
                              child: Text(
                                _showArchived ? AppLocalizations.of(context)!.noArchivedEvents : AppLocalizations.of(context)!.noActiveEventsFound,
                                textAlign: TextAlign.center,
                              ),
                            )
                          : ListView.builder(
                              itemCount: displayEvents.length,
                              itemBuilder: (context, index) {
                                Event event = displayEvents[index];
                                return EventTile(
                                  event: event,
                                  onEdit: () => _showEventForm(context, event: event),
                                );
                              },
                            ),
                    ),
                  ],
                ),
          floatingActionButton: FloatingActionButton(heroTag: 'events_mgmt_fab', onPressed: () => _showEventForm(context), child: const Icon(Icons.add)),
        );
      },
    );
  }
}

class EventTile extends StatelessWidget {
  final Event event;
  final VoidCallback onEdit;

  const EventTile({super.key, required this.event, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    EventsProvider provider = context.read<EventsProvider>();
    final l10n = AppLocalizations.of(context)!;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ExpansionTile(
        leading: const Icon(Icons.event),
        title: Text(event.name),
        subtitle: Row(
          children: [
            Expanded(child: Text('${event.startDate} - ${event.endDate}')),
            if (event.archived) const SizedBox(width: 8),
            if (event.archived) const ArchivedBadge(),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.timeline),
              tooltip: l10n.viewWorkflow,
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => EventWorkflowScreen(event: event)));
              },
            ),
            IconButton(icon: const Icon(Icons.edit), onPressed: onEdit),
            ArchiveDeleteMenu(
              isArchived: event.archived,
              itemType: 'Event',
              itemName: event.name,
              onArchive: () async {
                await provider.archiveEvent(event.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${event.name} ${l10n.archived}')));
                }
              },
              onUnarchive: () async {
                await provider.unarchiveEvent(event.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${event.name} ${l10n.restored}')));
                }
              },
              onDelete: () async {
                await provider.deleteEvent(event.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${event.name} ${l10n.deleted}')));
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
                Row(
                  children: [
                    const Icon(Icons.description, size: 16),
                    const SizedBox(width: 8),
                    Expanded(child: Text(event.description)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(children: [const Icon(Icons.calendar_today, size: 16), const SizedBox(width: 8), Text('${event.startDate} ${l10n.to} ${event.endDate}')]),
                if (event.isRecurring) ...[
                  const SizedBox(height: 8),
                  Row(children: [const Icon(Icons.repeat, size: 16), const SizedBox(width: 8), Text('${l10n.recurrence}: ${event.recurrenceType}')]),
                ],
                if (event.shifts.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text('${l10n.shifts}:', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...event.shifts.map((shift) {
                    // Get location name instead of ID
                    final location = provider.locations.firstWhere(
                      (l) => l.id == shift.locationId,
                      orElse: () => Location(id: '', name: shift.locationId, description: '', latitude: '', longitude: ''),
                    );
                    final locationName = location.id.isNotEmpty ? location.name : shift.locationId;
                    return Padding(padding: const EdgeInsets.only(left: 16, top: 4), child: Text('${shift.startTime} - ${shift.endTime} (${l10n.location}: $locationName)'));
                  }),
                ] else
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      l10n.noShiftsAdded,
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

class EventFormDialog extends StatelessWidget {
  final bool isEdit;

  const EventFormDialog({super.key, required this.isEdit});

  Future<void> _pickDate(BuildContext context, String title, Function(String) onDateSelected) async {
    final DateTime? picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2030));

    if (picked != null) {
      String formattedDate = DateFormat('dd-MM-yyyy').format(picked);
      onDateSelected(formattedDate);
    }
  }

  void _showShiftForm(BuildContext context, {EventShift? shift, int? index}) async {
    EventsProvider eventsProvider = context.read<EventsProvider>();

    // Ensure data is loaded before showing dialog
    if (eventsProvider.locations.isEmpty || eventsProvider.teams.isEmpty) {
      print('📦 Loading required data for shift form...');
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      await Future.wait([
        if (eventsProvider.locations.isEmpty) eventsProvider.loadLocations(),
        if (eventsProvider.teams.isEmpty) eventsProvider.loadTeams(),
        if (eventsProvider.systemUsers.isEmpty) eventsProvider.loadSystemUsers(),
      ]);

      if (context.mounted) Navigator.pop(context); // Close loading dialog
    }

    EventShift? result = await showDialog<EventShift>(
      context: context,
      builder: (context) => MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: eventsProvider),
          ChangeNotifierProvider(create: (_) => ShiftFormProvider()..initializeForm(shift)),
        ],
        child: ShiftFormDialog(isEdit: shift != null),
      ),
    );

    if (result != null) {
      EventFormProvider eventFormProvider = context.read<EventFormProvider>();
      if (shift == null) {
        eventFormProvider.addShift(result);
      } else {
        eventFormProvider.updateShift(index!, result);
      }
    }
  }

  void _save(BuildContext context, GlobalKey<FormState> formKey) {
    if (formKey.currentState!.validate()) {
      EventFormProvider provider = context.read<EventFormProvider>();

      Event event = Event(
        id: isEdit ? provider.editingEvent?.id ?? const Uuid().v4() : const Uuid().v4(),
        name: provider.name,
        description: provider.description,
        startDate: provider.startDate,
        endDate: provider.endDate,
        isRecurring: provider.isRecurring,
        recurrenceType: provider.recurrenceType,
        recurrenceEndDate: provider.recurrenceEndDate,
        weeklyDays: provider.weeklyDays.isNotEmpty ? provider.weeklyDays.join(',') : null,
        monthlyDay: provider.monthlyDay,
        yearlyDay: provider.yearlyDay,
        yearlyMonth: provider.yearlyMonth,
        presenceCheckPermissions: provider.presenceCheckPermissions,
        shifts: provider.shifts,
      );

      Navigator.of(context).pop(event);
    }
  }

  @override
  Widget build(BuildContext context) {
    GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final l10n = AppLocalizations.of(context)!;

    return Consumer<EventFormProvider>(
      builder: (context, provider, child) {
        return Dialog(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.95,
            constraints: const BoxConstraints(maxWidth: 700, maxHeight: 700),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(isEdit ? l10n.editEvent : l10n.addNewEvent, style: Theme.of(context).textTheme.headlineSmall),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFormField(
                              initialValue: provider.name,
                              decoration: InputDecoration(labelText: l10n.eventNameRequired, border: const OutlineInputBorder(), prefixIcon: const Icon(Icons.event)),
                              onChanged: provider.updateName,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return l10n.pleaseEnterEventName;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              initialValue: provider.description,
                              decoration: InputDecoration(labelText: l10n.description, border: const OutlineInputBorder(), prefixIcon: const Icon(Icons.description)),
                              maxLines: 3,
                              onChanged: provider.updateDescription,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: TextEditingController(text: provider.startDate),
                                    decoration: InputDecoration(
                                      labelText: l10n.startDateRequired,
                                      border: const OutlineInputBorder(),
                                      prefixIcon: const Icon(Icons.calendar_today),
                                      hintText: l10n.dateFormatHint,
                                    ),
                                    readOnly: true,
                                    onTap: () => _pickDate(context, 'Start Date', provider.updateStartDate),
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return l10n.required;
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextFormField(
                                    controller: TextEditingController(text: provider.endDate),
                                    decoration: InputDecoration(
                                      labelText: l10n.endDateRequired,
                                      border: const OutlineInputBorder(),
                                      prefixIcon: const Icon(Icons.calendar_today),
                                      hintText: l10n.dateFormatHint,
                                    ),
                                    readOnly: true,
                                    onTap: () => _pickDate(context, 'End Date', provider.updateEndDate),
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return l10n.required;
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<PresenceCheckPermissions>(
                              value: provider.presenceCheckPermissions,
                              decoration: InputDecoration(
                                labelText: l10n.presenceCheckPermissionsRequired,
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.admin_panel_settings),
                              ),
                              items: PresenceCheckPermissions.values.map((perm) {
                                return DropdownMenuItem<PresenceCheckPermissions>(value: perm, child: Text(perm.name.replaceAll('_', ' ')));
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  provider.updatePresenceCheckPermissions(value);
                                }
                              },
                            ),
                            const SizedBox(height: 16),
                            SwitchListTile(title: Text(l10n.recurringEvent), value: provider.isRecurring, onChanged: provider.updateIsRecurring),
                            if (provider.isRecurring) ...[
                              const SizedBox(height: 16),
                              DropdownButtonFormField<String>(
                                initialValue: provider.recurrenceType,
                                decoration: InputDecoration(labelText: l10n.recurrenceTypeRequired, border: const OutlineInputBorder(), prefixIcon: const Icon(Icons.repeat)),
                                items: RecurrenceType.values.where((type) => type != RecurrenceType.NONE).map((type) {
                                  return DropdownMenuItem<String>(value: type.name, child: Text(type.displayName));
                                }).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    provider.updateRecurrenceType(value);
                                  }
                                },
                              ),
                              const SizedBox(height: 16),
                              if (provider.recurrenceType == RecurrenceType.WEEKLY.name) _buildWeeklyDaysSelector(context, provider),
                              if (provider.recurrenceType == RecurrenceType.MONTHLY.name) _buildMonthlyDaySelector(context, provider),
                              if (provider.recurrenceType == RecurrenceType.YEARLY.name) _buildYearlySelector(context, provider),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: TextEditingController(text: provider.recurrenceEndDate ?? ''),
                                decoration: InputDecoration(
                                  labelText: l10n.recurrenceEndDate,
                                  border: const OutlineInputBorder(),
                                  prefixIcon: const Icon(Icons.event_busy),
                                  hintText: l10n.dateFormatHint,
                                ),
                                readOnly: true,
                                onTap: () => _pickDate(context, 'Recurrence End Date', provider.updateRecurrenceEndDate),
                              ),
                            ],
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(l10n.shifts, style: Theme.of(context).textTheme.titleMedium),
                                TextButton.icon(onPressed: () => _showShiftForm(context), icon: const Icon(Icons.add), label: Text(l10n.addShift)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            if (provider.shifts.isEmpty)
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text(
                                    l10n.noShiftsAdded,
                                    style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                                  ),
                                ),
                              )
                            else
                              ...provider.shifts.asMap().entries.map((entry) {
                                int index = entry.key;
                                EventShift shift = entry.value;
                                // Get location name from EventsProvider instead of ID
                                final eventsProvider = context.read<EventsProvider>();
                                final location = eventsProvider.locations.firstWhere(
                                  (l) => l.id == shift.locationId,
                                  orElse: () => Location(id: '', name: shift.locationId, description: '', latitude: '', longitude: ''),
                                );
                                final locationName = location.id.isNotEmpty ? location.name : shift.locationId;
                                return Card(
                                  child: ListTile(
                                    leading: const Icon(Icons.schedule),
                                    title: Text('${shift.startTime} - ${shift.endTime}'),
                                    subtitle: Text('${l10n.locationColon} $locationName'),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit),
                                          onPressed: () => _showShiftForm(context, shift: shift, index: index),
                                        ),
                                        IconButton(icon: const Icon(Icons.delete), onPressed: () => provider.removeShift(index)),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.cancel)),
                      const SizedBox(width: 8),
                      ElevatedButton(onPressed: () => _save(context, formKey), child: Text(l10n.save)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWeeklyDaysSelector(BuildContext context, EventFormProvider provider) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.selectDays, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: DayOfWeek.values.map((day) {
            final isSelected = provider.weeklyDays.contains(day.name);
            return FilterChip(label: Text(day.displayName), selected: isSelected, onSelected: (selected) => provider.toggleWeeklyDay(day.name));
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMonthlyDaySelector(BuildContext context, EventFormProvider provider) {
    final l10n = AppLocalizations.of(context)!;
    return DropdownButtonFormField<String>(
      initialValue: provider.monthlyDay,
      decoration: InputDecoration(labelText: l10n.dayOfMonthRequired, border: const OutlineInputBorder(), hintText: l10n.selectDayHint),
      items: List.generate(31, (index) => index + 1).map((day) {
        return DropdownMenuItem<String>(value: day.toString(), child: Text(l10n.dayNumber(day)));
      }).toList(),
      onChanged: provider.updateMonthlyDay,
      validator: (value) {
        if (provider.recurrenceType == RecurrenceType.MONTHLY.name && (value == null || value.isEmpty)) {
          return l10n.pleaseSelectDay;
        }
        return null;
      },
    );
  }

  Widget _buildYearlySelector(BuildContext context, EventFormProvider provider) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        DropdownButtonFormField<String>(
          initialValue: provider.yearlyMonth,
          decoration: InputDecoration(labelText: l10n.monthRequired, border: const OutlineInputBorder()),
          items: Month.values.map((month) {
            return DropdownMenuItem<String>(value: month.name, child: Text(month.displayName));
          }).toList(),
          onChanged: provider.updateYearlyMonth,
          validator: (value) {
            if (provider.recurrenceType == RecurrenceType.YEARLY.name && (value == null || value.isEmpty)) {
              return l10n.pleaseSelectMonth;
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: provider.yearlyDay,
          decoration: InputDecoration(labelText: l10n.dayRequired, border: const OutlineInputBorder()),
          items: List.generate(31, (index) => index + 1).map((day) {
            return DropdownMenuItem<String>(value: day.toString(), child: Text(l10n.dayNumber(day)));
          }).toList(),
          onChanged: provider.updateYearlyDay,
          validator: (value) {
            if (provider.recurrenceType == RecurrenceType.YEARLY.name && (value == null || value.isEmpty)) {
              return l10n.pleaseSelectDay;
            }
            return null;
          },
        ),
      ],
    );
  }
}

class ShiftFormDialog extends StatelessWidget {
  final bool isEdit;

  const ShiftFormDialog({super.key, required this.isEdit});

  Future<void> _pickTime(BuildContext context, String title, Function(String) onTimeSelected) async {
    final TimeOfDay? picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());

    if (picked != null) {
      String formattedTime = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      onTimeSelected(formattedTime);
    }
  }

  void _showSubLocationForm(BuildContext context, Location selectedLocation, {ShiftSubLocation? subLocation, int? index}) async {
    if (selectedLocation.subLocations == null || selectedLocation.subLocations!.isEmpty) {
      print('Error showing sublocation form: No sublocations available');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.thisLocationHasNoSublocations)));
      return;
    }

    EventsProvider eventsProvider = context.read<EventsProvider>();
    String? selectedSubLocationId = subLocation?.subLocationId;
    String? selectedTeamId = subLocation?.teamId;
    TempTeam? selectedTempTeam = subLocation?.tempTeam;
    bool useExistingTeam = subLocation?.teamId != null || (subLocation?.tempTeam == null && subLocation?.teamId == null);

    ShiftSubLocation? result = await showDialog<ShiftSubLocation>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final l10n = AppLocalizations.of(context)!;
          return AlertDialog(
            title: Text(subLocation == null ? l10n.addSubLocation : l10n.editSubLocation),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: selectedSubLocationId,
                      decoration: InputDecoration(labelText: l10n.subLocationRequired, border: const OutlineInputBorder()),
                      items: selectedLocation.subLocations!.map((subLoc) {
                        return DropdownMenuItem<String>(value: subLoc.id, child: Text(subLoc.name));
                      }).toList(),
                      onChanged: (value) => setState(() => selectedSubLocationId = value),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(l10n.teamAssignment, style: const TextStyle(fontWeight: FontWeight.bold)),
                        SegmentedButton<bool>(
                          segments: [
                            ButtonSegment<bool>(value: true, label: Text(l10n.existing), icon: const Icon(Icons.groups, size: 16)),
                            ButtonSegment<bool>(value: false, label: Text(l10n.temporary), icon: const Icon(Icons.person_add, size: 16)),
                          ],
                          selected: {useExistingTeam},
                          onSelectionChanged: (Set<bool> selection) {
                            setState(() {
                              useExistingTeam = selection.first;
                              if (useExistingTeam) {
                                selectedTempTeam = null;
                              } else {
                                selectedTeamId = null;
                              }
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (useExistingTeam)
                      DropdownButtonFormField<String>(
                        initialValue: selectedTeamId,
                        decoration: InputDecoration(labelText: l10n.teamOptional, border: const OutlineInputBorder(), hintText: l10n.selectTeam),
                        items: [
                          DropdownMenuItem<String>(value: null, child: Text(l10n.none)),
                          ...eventsProvider.teams.map((team) {
                            return DropdownMenuItem<String>(value: team.id, child: Text(team.name));
                          }),
                        ],
                        onChanged: (value) => setState(() => selectedTeamId = value),
                      )
                    else
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(l10n.temporaryTeam, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  if (selectedTempTeam == null)
                                    ElevatedButton.icon(
                                      onPressed: () async {
                                        final tempTeam = await _showTempTeamForm(context, eventsProvider);
                                        if (tempTeam != null) {
                                          setState(() => selectedTempTeam = tempTeam);
                                        }
                                      },
                                      icon: const Icon(Icons.add, size: 16),
                                      label: Text(l10n.create, style: const TextStyle(fontSize: 12)),
                                    )
                                  else
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit, size: 18),
                                          onPressed: () async {
                                            final tempTeam = await _showTempTeamForm(context, eventsProvider, existingTempTeam: selectedTempTeam);
                                            if (tempTeam != null) {
                                              setState(() => selectedTempTeam = tempTeam);
                                            }
                                          },
                                        ),
                                        IconButton(icon: const Icon(Icons.delete, size: 18), onPressed: () => setState(() => selectedTempTeam = null)),
                                      ],
                                    ),
                                ],
                              ),
                              if (selectedTempTeam != null) ...[
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.person, size: 14),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Leader: ${eventsProvider.teamLeaders.where((u) => u.phone == selectedTempTeam!.teamLeaderId).firstOrNull?.name ?? selectedTempTeam!.teamLeaderId}',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                                if (selectedTempTeam!.memberIds.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(AppLocalizations.of(context)!.membersColonBold, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                                  ...selectedTempTeam!.memberIds.map((memberId) {
                                    final memberName = eventsProvider.volunteers.where((u) => u.phone == memberId).firstOrNull?.name ?? memberId;
                                    return Padding(
                                      padding: const EdgeInsets.only(left: 12, top: 4),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.person_outline, size: 12),
                                          const SizedBox(width: 6),
                                          Expanded(child: Text(memberName, style: const TextStyle(fontSize: 11))),
                                        ],
                                      ),
                                    );
                                  }),
                                ] else
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      l10n.noMembers,
                                      style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.grey),
                                    ),
                                  ),
                              ] else
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    l10n.noTemporaryTeamCreated,
                                    style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.grey),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.cancel)),
              ElevatedButton(
                onPressed: () {
                  if (selectedSubLocationId == null || selectedSubLocationId!.isEmpty) {
                    print('Error saving sublocation: No sublocation selected');
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.pleaseSelectSublocation)));
                    return;
                  }

                  ShiftSubLocation newSubLocation = ShiftSubLocation(
                    id: subLocation?.id ?? const Uuid().v4(),
                    subLocationId: selectedSubLocationId!,
                    teamId: useExistingTeam ? selectedTeamId : null,
                    tempTeam: useExistingTeam ? null : selectedTempTeam,
                  );

                  Navigator.of(context).pop(newSubLocation);
                },
                child: Text(l10n.save),
              ),
            ],
          );
        },
      ),
    );

    if (result != null) {
      ShiftFormProvider shiftFormProvider = context.read<ShiftFormProvider>();
      if (subLocation == null) {
        shiftFormProvider.addSubLocation(result);
      } else {
        shiftFormProvider.updateSubLocation(index!, result);
      }
    }
  }

  void _save(BuildContext context, GlobalKey<FormState> formKey) {
    if (formKey.currentState!.validate()) {
      ShiftFormProvider provider = context.read<ShiftFormProvider>();
      EventShift shift = provider.buildShift();
      Navigator.of(context).pop(shift);
    }
  }

  Widget _buildTempTeamSection(BuildContext context, ShiftFormProvider provider, EventsProvider eventsProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(AppLocalizations.of(context)!.temporaryTeam, style: const TextStyle(fontWeight: FontWeight.bold)),
                if (provider.tempTeam == null)
                  ElevatedButton.icon(
                    onPressed: () async {
                      TempTeam? result = await _showTempTeamForm(context, eventsProvider);
                      if (result != null) provider.updateTempTeam(result);
                    },
                    icon: const Icon(Icons.add),
                    label: Text(AppLocalizations.of(context)!.createTeam),
                  )
                else
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () async {
                          TempTeam? result = await _showTempTeamForm(context, eventsProvider, existingTempTeam: provider.tempTeam);
                          if (result != null) provider.updateTempTeam(result);
                        },
                      ),
                      IconButton(icon: const Icon(Icons.delete), onPressed: () => provider.updateTempTeam(null)),
                    ],
                  ),
              ],
            ),
            if (provider.tempTeam != null) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.person, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    '${AppLocalizations.of(context)!.leaderColon2} ${eventsProvider.teamLeaders.where((u) => u.phone == provider.tempTeam!.teamLeaderId).firstOrNull?.name ?? provider.tempTeam!.teamLeaderId}',
                  ),
                ],
              ),
              if (provider.tempTeam!.memberIds.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(AppLocalizations.of(context)!.membersColonBold, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ...provider.tempTeam!.memberIds.map((memberId) {
                  String memberName = eventsProvider.volunteers.where((u) => u.phone == memberId).firstOrNull?.name ?? memberId;
                  return Padding(
                    padding: const EdgeInsets.only(left: 16, top: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.person_outline, size: 14),
                        const SizedBox(width: 8),
                        Text(memberName, style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  );
                }),
              ] else
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    'No members',
                    style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey),
                  ),
                ),
            ] else
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'No temporary team created',
                  style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<TempTeam?> _showTempTeamForm(BuildContext context, EventsProvider eventsProvider, {TempTeam? existingTempTeam}) async {
    String selectedLeaderId = existingTempTeam?.teamLeaderId ?? '';
    List<String> selectedMemberIds = List.from(existingTempTeam?.memberIds ?? []);

    TempTeam? result = await showDialog<TempTeam>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(AppLocalizations.of(context)!.createTeam),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: selectedLeaderId.isEmpty ? null : selectedLeaderId,
                      decoration: const InputDecoration(labelText: 'Team Leader *', border: OutlineInputBorder(), prefixIcon: Icon(Icons.person)),
                      items: eventsProvider.teamLeaders.map((leader) {
                        return DropdownMenuItem<String>(value: leader.phone, child: Text('${leader.name} (${leader.phone})'));
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => selectedLeaderId = value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(AppLocalizations.of(context)!.teamMembers, style: const TextStyle(fontWeight: FontWeight.bold)),
                        TextButton.icon(
                          onPressed: () async {
                            final memberId = await _selectMember(context, eventsProvider, selectedMemberIds);
                            if (memberId != null) {
                              setState(() => selectedMemberIds.add(memberId));
                            }
                          },
                          icon: const Icon(Icons.add),
                          label: Text(AppLocalizations.of(context)!.add),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (selectedMemberIds.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'No members added',
                          style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                        ),
                      )
                    else
                      ...selectedMemberIds.asMap().entries.map((entry) {
                        int index = entry.key;
                        String memberId = entry.value;
                        String memberName = eventsProvider.volunteers.where((u) => u.phone == memberId).firstOrNull?.name ?? memberId;
                        return ListTile(
                          dense: true,
                          leading: const Icon(Icons.person_outline, size: 16),
                          title: Text(memberName),
                          trailing: IconButton(icon: const Icon(Icons.delete, size: 18), onPressed: () => setState(() => selectedMemberIds.removeAt(index))),
                        );
                      }),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(AppLocalizations.of(context)!.cancel)),
              ElevatedButton(
                onPressed: () {
                  if (selectedLeaderId.isEmpty) {
                    print('Error creating temp team: No leader selected');
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.pleaseSelectTeamLeader)));
                    return;
                  }

                  TempTeam tempTeam = TempTeam(id: existingTempTeam?.id ?? const Uuid().v4(), teamLeaderId: selectedLeaderId, memberIds: selectedMemberIds);

                  Navigator.of(context).pop(tempTeam);
                },
                child: Text(AppLocalizations.of(context)!.save),
              ),
            ],
          );
        },
      ),
    );

    return result;
  }

  Future<String?> _selectMember(BuildContext context, EventsProvider eventsProvider, List<String> alreadySelected) async {
    return await showDialog<String>(
      context: context,
      builder: (context) => _MemberSelectionDialog(volunteers: eventsProvider.volunteers, alreadySelected: alreadySelected),
    );
  }

  @override
  Widget build(BuildContext context) {
    GlobalKey<FormState> formKey = GlobalKey<FormState>();
    EventsProvider eventsProvider = context.read<EventsProvider>();

    return Consumer<ShiftFormProvider>(
      builder: (context, provider, child) {
        Location? selectedLocation = eventsProvider.locations.where((loc) => loc.id == provider.locationId).firstOrNull;

        return Dialog(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(isEdit ? 'Edit Shift' : 'Add New Shift', style: Theme.of(context).textTheme.headlineSmall),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: TextEditingController(text: provider.startTime),
                                    decoration: const InputDecoration(
                                      labelText: 'Start Time *',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.access_time),
                                      hintText: 'HH:mm',
                                    ),
                                    readOnly: true,
                                    onTap: () => _pickTime(context, 'Start Time', provider.updateStartTime),
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return 'Required';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextFormField(
                                    controller: TextEditingController(text: provider.endTime),
                                    decoration: const InputDecoration(
                                      labelText: 'End Time *',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.access_time),
                                      hintText: 'HH:mm',
                                    ),
                                    readOnly: true,
                                    onTap: () => _pickTime(context, 'End Time', provider.updateEndTime),
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return 'Required';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Builder(
                              builder: (context) {
                                if (eventsProvider.locations.isEmpty) {
                                  print('⚠️ No locations available in EventsProvider');
                                  return TextFormField(
                                    enabled: false,
                                    decoration: InputDecoration(
                                      labelText: 'Location *',
                                      border: const OutlineInputBorder(),
                                      prefixIcon: const Icon(Icons.location_on),
                                      hintText: 'Loading locations...',
                                      helperText: 'No locations loaded. Please wait or refresh.',
                                    ),
                                  );
                                }
                                print('✓ ${eventsProvider.locations.length} locations available');
                                List<DropdownMenuItem<String>> locationItems = eventsProvider.locations.map((location) {
                                  return DropdownMenuItem<String>(value: location.id, child: Text(location.name));
                                }).toList();

                                String? validLocationId = locationItems.any((item) => item.value == provider.locationId) ? provider.locationId : null;

                                return DropdownButtonFormField<String>(
                                  value: validLocationId,
                                  decoration: const InputDecoration(
                                    labelText: 'Location *',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.location_on),
                                    hintText: 'Select location',
                                  ),
                                  items: locationItems,
                                  onChanged: (value) {
                                    if (value != null) {
                                      provider.updateLocationId(value);
                                    }
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please select a location';
                                    }
                                    return null;
                                  },
                                );
                              },
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(child: Text(AppLocalizations.of(context)!.teamAssignment, style: Theme.of(context).textTheme.titleMedium)),
                                SegmentedButton<bool>(
                                  segments: [
                                    ButtonSegment<bool>(value: true, label: Text(AppLocalizations.of(context)!.existing), icon: const Icon(Icons.groups, size: 16)),
                                    ButtonSegment<bool>(value: false, label: Text(AppLocalizations.of(context)!.temporary), icon: const Icon(Icons.person_add, size: 16)),
                                  ],
                                  selected: {provider.useExistingTeam},
                                  onSelectionChanged: (Set<bool> selection) {
                                    provider.updateUseExistingTeam(selection.first);
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (provider.useExistingTeam)
                              Builder(
                                builder: (context) {
                                  if (eventsProvider.teams.isEmpty) {
                                    print('⚠️ No teams available in EventsProvider');
                                    return TextFormField(
                                      enabled: false,
                                      decoration: InputDecoration(
                                        labelText: 'Team (Optional)',
                                        border: const OutlineInputBorder(),
                                        prefixIcon: const Icon(Icons.groups),
                                        hintText: 'Loading teams...',
                                        helperText: 'No teams loaded. Please wait or refresh.',
                                      ),
                                    );
                                  }
                                  print('✓ ${eventsProvider.teams.length} teams available');
                                  List<DropdownMenuItem<String>> teamItems = [
                                    DropdownMenuItem<String>(value: null, child: Text(AppLocalizations.of(context)!.none)),
                                    ...eventsProvider.teams.map((team) {
                                      return DropdownMenuItem<String>(value: team.id, child: Text(team.name));
                                    }),
                                  ];

                                  String? validTeamId = teamItems.any((item) => item.value == provider.teamId) ? provider.teamId : null;

                                  return DropdownButtonFormField<String>(
                                    value: validTeamId,
                                    decoration: const InputDecoration(
                                      labelText: 'Team (Optional)',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.groups),
                                      hintText: 'Select team',
                                    ),
                                    items: teamItems,
                                    onChanged: provider.updateTeamId,
                                  );
                                },
                              )
                            else
                              _buildTempTeamSection(context, provider, eventsProvider),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(AppLocalizations.of(context)!.subLocations, style: Theme.of(context).textTheme.titleMedium),
                                TextButton.icon(
                                  onPressed: selectedLocation != null && selectedLocation.subLocations != null && selectedLocation.subLocations!.isNotEmpty
                                      ? () => _showSubLocationForm(context, selectedLocation)
                                      : null,
                                  icon: const Icon(Icons.add),
                                  label: Text(AppLocalizations.of(context)!.addSubLocation),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            if (provider.subLocations.isEmpty)
                              const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Text(
                                    'No sublocations added',
                                    style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                                  ),
                                ),
                              )
                            else
                              ...provider.subLocations.asMap().entries.map((entry) {
                                int index = entry.key;
                                ShiftSubLocation subLoc = entry.value;
                                String subLocationName = selectedLocation?.subLocations?.where((s) => s.id == subLoc.subLocationId).firstOrNull?.name ?? 'Unknown';
                                String? teamName = eventsProvider.teams.where((t) => t.id == subLoc.teamId).firstOrNull?.name;

                                return Card(
                                  child: ListTile(
                                    leading: const Icon(Icons.place),
                                    title: Text(subLocationName),
                                    subtitle: teamName != null ? Text(AppLocalizations.of(context)!.teamColon(teamName)) : null,
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit),
                                          onPressed: selectedLocation != null ? () => _showSubLocationForm(context, selectedLocation, subLocation: subLoc, index: index) : null,
                                        ),
                                        IconButton(icon: const Icon(Icons.delete), onPressed: () => provider.removeSubLocation(index)),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(AppLocalizations.of(context)!.cancel)),
                      const SizedBox(width: 8),
                      ElevatedButton(onPressed: () => _save(context, formKey), child: Text(AppLocalizations.of(context)!.save)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Member Selection Dialog with Search
class _MemberSelectionDialog extends StatefulWidget {
  final List<SystemUser> volunteers;
  final List<String> alreadySelected;

  const _MemberSelectionDialog({required this.volunteers, required this.alreadySelected});

  @override
  State<_MemberSelectionDialog> createState() => __MemberSelectionDialogState();
}

class __MemberSelectionDialogState extends State<_MemberSelectionDialog> {
  String _searchQuery = '';

  List<SystemUser> get _filteredVolunteers {
    if (_searchQuery.isEmpty) {
      return widget.volunteers;
    }
    final query = _searchQuery.toLowerCase();
    return widget.volunteers.where((v) => v.name.toLowerCase().contains(query) || v.phone.contains(query)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredVolunteers = _filteredVolunteers;

    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.selectTeamMember),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.searchByNameOrPhone,
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
            const SizedBox(height: 12),
            Expanded(
              child: filteredVolunteers.isEmpty
                  ? Center(child: Text(AppLocalizations.of(context)!.noResultsFound))
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: filteredVolunteers.length,
                      itemBuilder: (context, index) {
                        final volunteer = filteredVolunteers[index];
                        final isAlreadyAdded = widget.alreadySelected.contains(volunteer.phone);

                        return ListTile(
                          enabled: !isAlreadyAdded,
                          leading: Icon(Icons.person_outline, color: isAlreadyAdded ? Colors.grey : null),
                          title: Text(volunteer.name, style: TextStyle(color: isAlreadyAdded ? Colors.grey : null)),
                          subtitle: Text(volunteer.phone, style: TextStyle(color: isAlreadyAdded ? Colors.grey : null)),
                          trailing: isAlreadyAdded
                              ? Chip(
                                  label: Text(AppLocalizations.of(context)!.added, style: const TextStyle(fontSize: 10)),
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                )
                              : null,
                          onTap: isAlreadyAdded ? null : () => Navigator.of(context).pop(volunteer.phone),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(AppLocalizations.of(context)!.cancel))],
    );
  }
}

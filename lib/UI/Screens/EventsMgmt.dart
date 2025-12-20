import 'package:flutter/material.dart';
import 'package:azimuth_vms/Models/Event.dart';
import 'package:azimuth_vms/Models/Location.dart';
import 'package:azimuth_vms/Providers/EventsProvider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class EventsMgmt extends StatelessWidget {
  const EventsMgmt({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EventsProvider()
        ..loadEvents()
        ..loadLocations()
        ..loadTeams()
        ..loadSystemUsers(),
      child: const EventsMgmtView(),
    );
  }
}

class EventsMgmtView extends StatelessWidget {
  const EventsMgmtView({super.key});

  void _showEventForm(BuildContext context, {Event? event}) async {
    final eventsProvider = context.read<EventsProvider>();

    final result = await showDialog<Event>(
      context: context,
      builder: (context) => MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: eventsProvider),
          ChangeNotifierProvider(
            create: (_) => EventFormProvider()..initializeForm(event),
          ),
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
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(provider.errorMessage!)));
          });
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Events Management'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => provider.loadEvents(),
              ),
            ],
          ),
          body: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : provider.events.isEmpty
              ? const Center(
                  child: Text(
                    'No events found.\nTap + to add a new event.',
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.builder(
                  itemCount: provider.events.length,
                  itemBuilder: (context, index) {
                    final event = provider.events[index];
                    return EventTile(
                      event: event,
                      onEdit: () => _showEventForm(context, event: event),
                    );
                  },
                ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showEventForm(context),
            child: const Icon(Icons.add),
          ),
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
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ExpansionTile(
        leading: const Icon(Icons.event),
        title: Text(event.name),
        subtitle: Text('${event.startDate} - ${event.endDate}'),
        trailing: IconButton(icon: const Icon(Icons.edit), onPressed: onEdit),
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
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16),
                    const SizedBox(width: 8),
                    Text('${event.startDate} to ${event.endDate}'),
                  ],
                ),
                if (event.isRecurring) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.repeat, size: 16),
                      const SizedBox(width: 8),
                      Text('Recurrence: ${event.recurrenceType}'),
                    ],
                  ),
                ],
                if (event.shifts.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Shifts:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...event.shifts.map(
                    (shift) => Padding(
                      padding: const EdgeInsets.only(left: 16, top: 4),
                      child: Text(
                        '${shift.startTime} - ${shift.endTime} (Location: ${shift.locationId})',
                      ),
                    ),
                  ),
                ] else
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      'No shifts added',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
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

  Future<void> _pickDate(
    BuildContext context,
    String title,
    Function(String) onDateSelected,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      final formattedDate = DateFormat('dd-MM-yyyy').format(picked);
      onDateSelected(formattedDate);
    }
  }

  void _showShiftForm(
    BuildContext context, {
    EventShift? shift,
    int? index,
  }) async {
    final eventsProvider = context.read<EventsProvider>();

    final result = await showDialog<EventShift>(
      context: context,
      builder: (context) => MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: eventsProvider),
          ChangeNotifierProvider(
            create: (_) => ShiftFormProvider()..initializeForm(shift),
          ),
        ],
        child: ShiftFormDialog(isEdit: shift != null),
      ),
    );

    if (result != null) {
      final eventFormProvider = context.read<EventFormProvider>();
      if (shift == null) {
        eventFormProvider.addShift(result);
      } else {
        eventFormProvider.updateShift(index!, result);
      }
    }
  }

  void _save(BuildContext context, GlobalKey<FormState> formKey) {
    if (formKey.currentState!.validate()) {
      final provider = context.read<EventFormProvider>();

      final event = Event(
        id: isEdit
            ? provider.editingEvent?.id ?? const Uuid().v4()
            : const Uuid().v4(),
        name: provider.name,
        description: provider.description,
        startDate: provider.startDate,
        endDate: provider.endDate,
        isRecurring: provider.isRecurring,
        recurrenceType: provider.recurrenceType,
        recurrenceEndDate: provider.recurrenceEndDate,
        weeklyDays: provider.weeklyDays.isNotEmpty
            ? provider.weeklyDays.join(',')
            : null,
        monthlyDay: provider.monthlyDay,
        yearlyDay: provider.yearlyDay,
        yearlyMonth: provider.yearlyMonth,
        shifts: provider.shifts,
      );

      Navigator.of(context).pop(event);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();

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
                  child: Text(
                    isEdit ? 'Edit Event' : 'Add New Event',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
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
                              decoration: const InputDecoration(
                                labelText: 'Event Name *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.event),
                              ),
                              onChanged: provider.updateName,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter event name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              initialValue: provider.description,
                              decoration: const InputDecoration(
                                labelText: 'Description',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.description),
                              ),
                              maxLines: 3,
                              onChanged: provider.updateDescription,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: TextEditingController(
                                      text: provider.startDate,
                                    ),
                                    decoration: const InputDecoration(
                                      labelText: 'Start Date *',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.calendar_today),
                                      hintText: 'DD-MM-YYYY',
                                    ),
                                    readOnly: true,
                                    onTap: () => _pickDate(
                                      context,
                                      'Start Date',
                                      provider.updateStartDate,
                                    ),
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Required';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextFormField(
                                    controller: TextEditingController(
                                      text: provider.endDate,
                                    ),
                                    decoration: const InputDecoration(
                                      labelText: 'End Date *',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.calendar_today),
                                      hintText: 'DD-MM-YYYY',
                                    ),
                                    readOnly: true,
                                    onTap: () => _pickDate(
                                      context,
                                      'End Date',
                                      provider.updateEndDate,
                                    ),
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Required';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SwitchListTile(
                              title: const Text('Recurring Event'),
                              value: provider.isRecurring,
                              onChanged: provider.updateIsRecurring,
                            ),
                            if (provider.isRecurring) ...[
                              const SizedBox(height: 16),
                              DropdownButtonFormField<String>(
                                value: provider.recurrenceType,
                                decoration: const InputDecoration(
                                  labelText: 'Recurrence Type *',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.repeat),
                                ),
                                items: RecurrenceType.values
                                    .where(
                                      (type) => type != RecurrenceType.NONE,
                                    )
                                    .map((type) {
                                      return DropdownMenuItem<String>(
                                        value: type.name,
                                        child: Text(type.displayName),
                                      );
                                    })
                                    .toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    provider.updateRecurrenceType(value);
                                  }
                                },
                              ),
                              const SizedBox(height: 16),
                              if (provider.recurrenceType ==
                                  RecurrenceType.WEEKLY.name)
                                _buildWeeklyDaysSelector(provider),
                              if (provider.recurrenceType ==
                                  RecurrenceType.MONTHLY.name)
                                _buildMonthlyDaySelector(provider),
                              if (provider.recurrenceType ==
                                  RecurrenceType.YEARLY.name)
                                _buildYearlySelector(provider),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: TextEditingController(
                                  text: provider.recurrenceEndDate ?? '',
                                ),
                                decoration: const InputDecoration(
                                  labelText: 'Recurrence End Date (Optional)',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.event_busy),
                                  hintText: 'DD-MM-YYYY',
                                ),
                                readOnly: true,
                                onTap: () => _pickDate(
                                  context,
                                  'Recurrence End Date',
                                  provider.updateRecurrenceEndDate,
                                ),
                              ),
                            ],
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Shifts',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                                TextButton.icon(
                                  onPressed: () => _showShiftForm(context),
                                  icon: const Icon(Icons.add),
                                  label: const Text('Add Shift'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            if (provider.shifts.isEmpty)
                              const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Text(
                                    'No shifts added',
                                    style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              )
                            else
                              ...provider.shifts.asMap().entries.map((entry) {
                                final index = entry.key;
                                final shift = entry.value;
                                return Card(
                                  child: ListTile(
                                    leading: const Icon(Icons.schedule),
                                    title: Text(
                                      '${shift.startTime} - ${shift.endTime}',
                                    ),
                                    subtitle: Text(
                                      'Location: ${shift.locationId}',
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit),
                                          onPressed: () => _showShiftForm(
                                            context,
                                            shift: shift,
                                            index: index,
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete),
                                          onPressed: () =>
                                              provider.removeShift(index),
                                        ),
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
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _save(context, formKey),
                        child: const Text('Save'),
                      ),
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

  Widget _buildWeeklyDaysSelector(EventFormProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Days:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: DayOfWeek.values.map((day) {
            final isSelected = provider.weeklyDays.contains(day.name);
            return FilterChip(
              label: Text(day.displayName),
              selected: isSelected,
              onSelected: (selected) => provider.toggleWeeklyDay(day.name),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMonthlyDaySelector(EventFormProvider provider) {
    return DropdownButtonFormField<String>(
      value: provider.monthlyDay,
      decoration: const InputDecoration(
        labelText: 'Day of Month *',
        border: OutlineInputBorder(),
        hintText: 'Select day (1-31)',
      ),
      items: List.generate(31, (index) => index + 1).map((day) {
        return DropdownMenuItem<String>(
          value: day.toString(),
          child: Text('Day $day'),
        );
      }).toList(),
      onChanged: provider.updateMonthlyDay,
      validator: (value) {
        if (provider.recurrenceType == RecurrenceType.MONTHLY.name &&
            (value == null || value.isEmpty)) {
          return 'Please select a day';
        }
        return null;
      },
    );
  }

  Widget _buildYearlySelector(EventFormProvider provider) {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          value: provider.yearlyMonth,
          decoration: const InputDecoration(
            labelText: 'Month *',
            border: OutlineInputBorder(),
          ),
          items: Month.values.map((month) {
            return DropdownMenuItem<String>(
              value: month.name,
              child: Text(month.displayName),
            );
          }).toList(),
          onChanged: provider.updateYearlyMonth,
          validator: (value) {
            if (provider.recurrenceType == RecurrenceType.YEARLY.name &&
                (value == null || value.isEmpty)) {
              return 'Please select a month';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: provider.yearlyDay,
          decoration: const InputDecoration(
            labelText: 'Day *',
            border: OutlineInputBorder(),
          ),
          items: List.generate(31, (index) => index + 1).map((day) {
            return DropdownMenuItem<String>(
              value: day.toString(),
              child: Text('Day $day'),
            );
          }).toList(),
          onChanged: provider.updateYearlyDay,
          validator: (value) {
            if (provider.recurrenceType == RecurrenceType.YEARLY.name &&
                (value == null || value.isEmpty)) {
              return 'Please select a day';
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

  Future<void> _pickTime(
    BuildContext context,
    String title,
    Function(String) onTimeSelected,
  ) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      final formattedTime =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      onTimeSelected(formattedTime);
    }
  }

  void _showSubLocationForm(
    BuildContext context,
    Location selectedLocation, {
    ShiftSubLocation? subLocation,
    int? index,
  }) async {
    if (selectedLocation.subLocations == null ||
        selectedLocation.subLocations!.isEmpty) {
      print('Error showing sublocation form: No sublocations available');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This location has no sublocations')),
      );
      return;
    }

    final eventsProvider = context.read<EventsProvider>();
    String? selectedSubLocationId = subLocation?.subLocationId;
    String? selectedTeamId = subLocation?.teamId;

    final result = await showDialog<ShiftSubLocation>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          subLocation == null ? 'Add SubLocation' : 'Edit SubLocation',
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: selectedSubLocationId,
              decoration: const InputDecoration(
                labelText: 'SubLocation *',
                border: OutlineInputBorder(),
              ),
              items: selectedLocation.subLocations!.map((subLoc) {
                return DropdownMenuItem<String>(
                  value: subLoc.id,
                  child: Text(subLoc.name),
                );
              }).toList(),
              onChanged: (value) => selectedSubLocationId = value,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedTeamId,
              decoration: const InputDecoration(
                labelText: 'Team (Optional)',
                border: OutlineInputBorder(),
                hintText: 'Select team',
              ),
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('None'),
                ),
                ...eventsProvider.teams.map((team) {
                  return DropdownMenuItem<String>(
                    value: team.id,
                    child: Text(team.name),
                  );
                }),
              ],
              onChanged: (value) => selectedTeamId = value,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (selectedSubLocationId == null ||
                  selectedSubLocationId!.isEmpty) {
                print('Error saving sublocation: No sublocation selected');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please select a sublocation')),
                );
                return;
              }

              final newSubLocation = ShiftSubLocation(
                id: subLocation?.id ?? const Uuid().v4(),
                subLocationId: selectedSubLocationId!,
                teamId: selectedTeamId,
              );

              Navigator.of(context).pop(newSubLocation);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != null) {
      final shiftFormProvider = context.read<ShiftFormProvider>();
      if (subLocation == null) {
        shiftFormProvider.addSubLocation(result);
      } else {
        shiftFormProvider.updateSubLocation(index!, result);
      }
    }
  }

  void _save(BuildContext context, GlobalKey<FormState> formKey) {
    if (formKey.currentState!.validate()) {
      final provider = context.read<ShiftFormProvider>();
      final shift = provider.buildShift();
      Navigator.of(context).pop(shift);
    }
  }

  Widget _buildTempTeamSection(
    BuildContext context,
    ShiftFormProvider provider,
    EventsProvider eventsProvider,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Temporary Team',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                if (provider.tempTeam == null)
                  ElevatedButton.icon(
                    onPressed: () =>
                        _showTempTeamForm(context, provider, eventsProvider),
                    icon: const Icon(Icons.add),
                    label: const Text('Create Team'),
                  )
                else
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showTempTeamForm(
                          context,
                          provider,
                          eventsProvider,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => provider.updateTempTeam(null),
                      ),
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
                    'Leader: ${eventsProvider.teamLeaders.where((u) => u.phone == provider.tempTeam!.teamLeaderId).firstOrNull?.name ?? provider.tempTeam!.teamLeaderId}',
                  ),
                ],
              ),
              if (provider.tempTeam!.memberIds.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Text(
                  'Members:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                ...provider.tempTeam!.memberIds.map((memberId) {
                  final memberName =
                      eventsProvider.volunteers
                          .where((u) => u.phone == memberId)
                          .firstOrNull
                          ?.name ??
                      memberId;
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
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                  ),
                ),
            ] else
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'No temporary team created',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showTempTeamForm(
    BuildContext context,
    ShiftFormProvider provider,
    EventsProvider eventsProvider,
  ) async {
    String selectedLeaderId = provider.tempTeam?.teamLeaderId ?? '';
    List<String> selectedMemberIds = List.from(
      provider.tempTeam?.memberIds ?? [],
    );

    final result = await showDialog<TempTeam>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Create Temporary Team'),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedLeaderId.isEmpty ? null : selectedLeaderId,
                      decoration: const InputDecoration(
                        labelText: 'Team Leader *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      items: eventsProvider.teamLeaders.map((leader) {
                        return DropdownMenuItem<String>(
                          value: leader.phone,
                          child: Text('${leader.name} (${leader.phone})'),
                        );
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
                        const Text(
                          'Team Members',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextButton.icon(
                          onPressed: () async {
                            final memberId = await _selectMember(
                              context,
                              eventsProvider,
                              selectedMemberIds,
                            );
                            if (memberId != null) {
                              setState(() => selectedMemberIds.add(memberId));
                            }
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Add'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (selectedMemberIds.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'No members added',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    else
                      ...selectedMemberIds.asMap().entries.map((entry) {
                        final index = entry.key;
                        final memberId = entry.value;
                        final memberName =
                            eventsProvider.volunteers
                                .where((u) => u.phone == memberId)
                                .firstOrNull
                                ?.name ??
                            memberId;
                        return ListTile(
                          dense: true,
                          leading: const Icon(Icons.person_outline, size: 16),
                          title: Text(memberName),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, size: 18),
                            onPressed: () => setState(
                              () => selectedMemberIds.removeAt(index),
                            ),
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (selectedLeaderId.isEmpty) {
                    print('Error creating temp team: No leader selected');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please select a team leader'),
                      ),
                    );
                    return;
                  }

                  final tempTeam = TempTeam(
                    id: provider.tempTeam?.id ?? const Uuid().v4(),
                    teamLeaderId: selectedLeaderId,
                    memberIds: selectedMemberIds,
                  );

                  Navigator.of(context).pop(tempTeam);
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );

    if (result != null) {
      provider.updateTempTeam(result);
    }
  }

  Future<String?> _selectMember(
    BuildContext context,
    EventsProvider eventsProvider,
    List<String> alreadySelected,
  ) async {
    return await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Team Member'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: eventsProvider.volunteers.length,
            itemBuilder: (context, index) {
              final volunteer = eventsProvider.volunteers[index];
              final isAlreadyAdded = alreadySelected.contains(volunteer.phone);

              return ListTile(
                enabled: !isAlreadyAdded,
                leading: Icon(
                  Icons.person_outline,
                  color: isAlreadyAdded ? Colors.grey : null,
                ),
                title: Text(
                  volunteer.name,
                  style: TextStyle(color: isAlreadyAdded ? Colors.grey : null),
                ),
                subtitle: Text(
                  volunteer.phone,
                  style: TextStyle(color: isAlreadyAdded ? Colors.grey : null),
                ),
                trailing: isAlreadyAdded
                    ? const Chip(
                        label: Text('Added', style: TextStyle(fontSize: 10)),
                        padding: EdgeInsets.symmetric(horizontal: 4),
                      )
                    : null,
                onTap: isAlreadyAdded
                    ? null
                    : () => Navigator.of(context).pop(volunteer.phone),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final eventsProvider = context.read<EventsProvider>();

    return Consumer<ShiftFormProvider>(
      builder: (context, provider, child) {
        final selectedLocation = eventsProvider.locations
            .where((loc) => loc.id == provider.locationId)
            .firstOrNull;

        return Dialog(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    isEdit ? 'Edit Shift' : 'Add New Shift',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
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
                                    controller: TextEditingController(
                                      text: provider.startTime,
                                    ),
                                    decoration: const InputDecoration(
                                      labelText: 'Start Time *',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.access_time),
                                      hintText: 'HH:mm',
                                    ),
                                    readOnly: true,
                                    onTap: () => _pickTime(
                                      context,
                                      'Start Time',
                                      provider.updateStartTime,
                                    ),
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Required';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextFormField(
                                    controller: TextEditingController(
                                      text: provider.endTime,
                                    ),
                                    decoration: const InputDecoration(
                                      labelText: 'End Time *',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.access_time),
                                      hintText: 'HH:mm',
                                    ),
                                    readOnly: true,
                                    onTap: () => _pickTime(
                                      context,
                                      'End Time',
                                      provider.updateEndTime,
                                    ),
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Required';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              value: provider.locationId.isEmpty
                                  ? null
                                  : provider.locationId,
                              decoration: const InputDecoration(
                                labelText: 'Location *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.location_on),
                                hintText: 'Select location',
                              ),
                              items: eventsProvider.locations.map((location) {
                                return DropdownMenuItem<String>(
                                  value: location.id,
                                  child: Text(location.name),
                                );
                              }).toList(),
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
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Team Assignment',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium,
                                  ),
                                ),
                                SegmentedButton<bool>(
                                  segments: const [
                                    ButtonSegment<bool>(
                                      value: true,
                                      label: Text('Existing'),
                                      icon: Icon(Icons.groups, size: 16),
                                    ),
                                    ButtonSegment<bool>(
                                      value: false,
                                      label: Text('Temporary'),
                                      icon: Icon(Icons.person_add, size: 16),
                                    ),
                                  ],
                                  selected: {provider.useExistingTeam},
                                  onSelectionChanged: (Set<bool> selection) {
                                    provider.updateUseExistingTeam(
                                      selection.first,
                                    );
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (provider.useExistingTeam)
                              DropdownButtonFormField<String>(
                                value: provider.teamId,
                                decoration: const InputDecoration(
                                  labelText: 'Team (Optional)',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.groups),
                                  hintText: 'Select team',
                                ),
                                items: [
                                  const DropdownMenuItem<String>(
                                    value: null,
                                    child: Text('None'),
                                  ),
                                  ...eventsProvider.teams.map((team) {
                                    return DropdownMenuItem<String>(
                                      value: team.id,
                                      child: Text(team.name),
                                    );
                                  }),
                                ],
                                onChanged: provider.updateTeamId,
                              )
                            else
                              _buildTempTeamSection(
                                context,
                                provider,
                                eventsProvider,
                              ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'SubLocations',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                                TextButton.icon(
                                  onPressed:
                                      selectedLocation != null &&
                                          selectedLocation.subLocations !=
                                              null &&
                                          selectedLocation
                                              .subLocations!
                                              .isNotEmpty
                                      ? () => _showSubLocationForm(
                                          context,
                                          selectedLocation,
                                        )
                                      : null,
                                  icon: const Icon(Icons.add),
                                  label: const Text('Add SubLocation'),
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
                                    style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              )
                            else
                              ...provider.subLocations.asMap().entries.map((
                                entry,
                              ) {
                                final index = entry.key;
                                final subLoc = entry.value;
                                final subLocationName =
                                    selectedLocation?.subLocations
                                        ?.where(
                                          (s) => s.id == subLoc.subLocationId,
                                        )
                                        .firstOrNull
                                        ?.name ??
                                    'Unknown';
                                final teamName = eventsProvider.teams
                                    .where((t) => t.id == subLoc.teamId)
                                    .firstOrNull
                                    ?.name;

                                return Card(
                                  child: ListTile(
                                    leading: const Icon(Icons.place),
                                    title: Text(subLocationName),
                                    subtitle: teamName != null
                                        ? Text('Team: $teamName')
                                        : null,
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit),
                                          onPressed: selectedLocation != null
                                              ? () => _showSubLocationForm(
                                                  context,
                                                  selectedLocation,
                                                  subLocation: subLoc,
                                                  index: index,
                                                )
                                              : null,
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete),
                                          onPressed: () =>
                                              provider.removeSubLocation(index),
                                        ),
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
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _save(context, formKey),
                        child: const Text('Save'),
                      ),
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

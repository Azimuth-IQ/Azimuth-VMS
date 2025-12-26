import 'package:flutter/material.dart';
import 'package:azimuth_vms/Models/Location.dart';
import 'package:azimuth_vms/Providers/LocationsProvider.dart';
import 'package:azimuth_vms/UI/Widgets/ArchiveDeleteWidget.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class LocationsMgmt extends StatelessWidget {
  const LocationsMgmt({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(create: (_) => LocationsProvider()..loadLocations(), child: const LocationsMgmtView());
  }
}

class LocationsMgmtView extends StatefulWidget {
  const LocationsMgmtView({super.key});

  @override
  State<LocationsMgmtView> createState() => _LocationsMgmtViewState();
}

class _LocationsMgmtViewState extends State<LocationsMgmtView> {
  bool _showArchived = false;

  void _showLocationForm(BuildContext context, {Location? location}) async {
    final result = await showDialog<Location>(
      context: context,
      builder: (context) => ChangeNotifierProvider(
        create: (_) => LocationFormProvider()..initializeForm(location),
        child: LocationFormDialog(isEdit: location != null),
      ),
    );

    if (result != null) {
      final provider = context.read<LocationsProvider>();
      if (location == null) {
        provider.createLocation(result);
      } else {
        provider.updateLocation(result);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocationsProvider>(
      builder: (context, provider, child) {
        if (provider.errorMessage != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(provider.errorMessage!)));
          });
        }

        final displayLocations = _showArchived ? provider.archivedLocations : provider.activeLocations;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Locations Management'),
            actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: () => provider.loadLocations())],
          ),
          body: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    ShowArchivedToggle(showArchived: _showArchived, onChanged: (value) => setState(() => _showArchived = value), archivedCount: provider.archivedLocations.length),
                    Expanded(
                      child: displayLocations.isEmpty
                          ? Center(child: Text(_showArchived ? 'No archived locations' : 'No active locations found.\nTap + to add a new location.', textAlign: TextAlign.center))
                          : ListView.builder(
                              itemCount: displayLocations.length,
                              itemBuilder: (context, index) {
                                final location = displayLocations[index];
                                return LocationTile(
                                  location: location,
                                  onEdit: () => _showLocationForm(context, location: location),
                                );
                              },
                            ),
                    ),
                  ],
                ),
          floatingActionButton: FloatingActionButton(onPressed: () => _showLocationForm(context), child: const Icon(Icons.add)),
        );
      },
    );
  }
}

class LocationTile extends StatelessWidget {
  final Location location;
  final VoidCallback onEdit;

  const LocationTile({super.key, required this.location, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<LocationsProvider>();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ExpansionTile(
        leading: const Icon(Icons.location_on),
        title: Text(location.name),
        subtitle: Row(
          children: [
            Expanded(child: Text(location.description)),
            if (location.archived) const SizedBox(width: 8),
            if (location.archived) const ArchivedBadge(),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.edit), onPressed: onEdit),
            ArchiveDeleteMenu(
              isArchived: location.archived,
              itemType: 'Location',
              itemName: location.name,
              onArchive: () async {
                await provider.archiveLocation(location.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${location.name} archived')));
                }
              },
              onUnarchive: () async {
                await provider.unarchiveLocation(location.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${location.name} restored')));
                }
              },
              onDelete: () async {
                await provider.deleteLocation(location.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${location.name} deleted')));
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
                Row(children: [const Icon(Icons.gps_fixed, size: 16), const SizedBox(width: 8), Text('Lat: ${location.latitude}, Lon: ${location.longitude}')]),
                if (location.imageUrl != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.image, size: 16),
                      const SizedBox(width: 8),
                      Expanded(child: Text(location.imageUrl!, maxLines: 1, overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                ],
                if (location.subLocations != null && location.subLocations!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text('Sub-locations:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...location.subLocations!.map(
                    (subLoc) => Padding(
                      padding: const EdgeInsets.only(left: 16, top: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.subdirectory_arrow_right, size: 16),
                          const SizedBox(width: 8),
                          Expanded(child: Text('${subLoc.name} - ${subLoc.description}')),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LocationFormDialog extends StatelessWidget {
  final bool isEdit;

  const LocationFormDialog({super.key, required this.isEdit});

  void _pickLocationOnMap(BuildContext context) async {
    final provider = context.read<LocationFormProvider>();
    final LatLng? pickedLocation = await showDialog<LatLng>(
      context: context,
      builder: (context) => MapPickerDialog(initialLocation: LatLng(provider.latitude, provider.longitude)),
    );

    if (pickedLocation != null) {
      provider.updateCoordinates(pickedLocation.latitude, pickedLocation.longitude);
    }
  }

  void _addSubLocation(BuildContext context) async {
    final result = await showDialog<Location>(
      context: context,
      builder: (context) => ChangeNotifierProvider(create: (_) => SubLocationFormProvider(), child: const SubLocationFormDialog(isEdit: false)),
    );

    if (result != null) {
      context.read<LocationFormProvider>().addSubLocation(result);
    }
  }

  void _editSubLocation(BuildContext context, int index, Location subLocation) async {
    final result = await showDialog<Location>(
      context: context,
      builder: (context) => ChangeNotifierProvider(create: (_) => SubLocationFormProvider()..initializeForm(subLocation), child: const SubLocationFormDialog(isEdit: true)),
    );

    if (result != null) {
      context.read<LocationFormProvider>().updateSubLocation(index, result);
    }
  }

  void _save(BuildContext context, GlobalKey<FormState> formKey) {
    if (formKey.currentState!.validate()) {
      final provider = context.read<LocationFormProvider>();
      final location = Location(
        id: isEdit ? provider.editingLocation?.id ?? const Uuid().v4() : const Uuid().v4(),
        name: provider.name,
        description: provider.description,
        imageUrl: provider.imageUrl.isEmpty ? null : provider.imageUrl,
        latitude: provider.latitude.toString(),
        longitude: provider.longitude.toString(),
        subLocations: provider.subLocations.isEmpty ? null : provider.subLocations,
      );

      Navigator.of(context).pop(location);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();

    return Consumer<LocationFormProvider>(
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
                      Text(isEdit ? 'Edit Location' : 'Add New Location', style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue: provider.name,
                        decoration: const InputDecoration(labelText: 'Name *', border: OutlineInputBorder(), prefixIcon: Icon(Icons.label)),
                        onChanged: provider.updateName,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue: provider.description,
                        decoration: const InputDecoration(labelText: 'Description *', border: OutlineInputBorder(), prefixIcon: Icon(Icons.description)),
                        maxLines: 3,
                        onChanged: provider.updateDescription,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a description';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue: provider.imageUrl,
                        decoration: const InputDecoration(labelText: 'Image URL (optional)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.image)),
                        onChanged: provider.updateImageUrl,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              key: ValueKey(provider.latitude),
                              initialValue: provider.latitude.toString(),
                              decoration: const InputDecoration(labelText: 'Latitude *', border: OutlineInputBorder(), prefixIcon: Icon(Icons.gps_fixed)),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                              onChanged: (value) {
                                final lat = double.tryParse(value);
                                if (lat != null) provider.updateLatitude(lat);
                              },
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Required';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Invalid number';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              key: ValueKey(provider.longitude),
                              initialValue: provider.longitude.toString(),
                              decoration: const InputDecoration(labelText: 'Longitude *', border: OutlineInputBorder(), prefixIcon: Icon(Icons.gps_fixed)),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                              onChanged: (value) {
                                final lon = double.tryParse(value);
                                if (lon != null) provider.updateLongitude(lon);
                              },
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Required';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Invalid number';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _pickLocationOnMap(context),
                          icon: const Icon(Icons.map),
                          label: const Text('Pick Location on Map'),
                          style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(16)),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Sub-locations', style: Theme.of(context).textTheme.titleMedium),
                          IconButton(icon: const Icon(Icons.add_circle), onPressed: () => _addSubLocation(context), tooltip: 'Add Sub-location'),
                        ],
                      ),
                      if (provider.subLocations.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('No sub-locations added', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
                        )
                      else
                        ...provider.subLocations.asMap().entries.map((entry) {
                          final index = entry.key;
                          final subLoc = entry.value;
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: const Icon(Icons.subdirectory_arrow_right),
                              title: Text(subLoc.name),
                              subtitle: Text(subLoc.description),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () => _editSubLocation(context, index, subLoc),
                                    tooltip: 'Edit',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => provider.removeSubLocation(index),
                                    tooltip: 'Delete',
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
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

class MapPickerDialog extends StatefulWidget {
  final LatLng initialLocation;

  const MapPickerDialog({super.key, required this.initialLocation});

  @override
  State<MapPickerDialog> createState() => _MapPickerDialogState();
}

class _MapPickerDialogState extends State<MapPickerDialog> {
  late LatLng _selectedLocation;

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          children: [
            AppBar(
              title: const Text('Pick Location'),
              leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
            ),
            Expanded(
              child: GoogleMap(
                initialCameraPosition: CameraPosition(target: _selectedLocation, zoom: 14),
                onMapCreated: (controller) {},
                onTap: (latLng) {
                  setState(() {
                    _selectedLocation = latLng;
                  });
                },
                markers: {
                  Marker(
                    markerId: const MarkerId('selected'),
                    position: _selectedLocation,
                    draggable: true,
                    onDragEnd: (latLng) {
                      setState(() {
                        _selectedLocation = latLng;
                      });
                    },
                  ),
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey[200],
              child: Column(
                children: [
                  Text('Tap on map or drag marker to select location', style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 8),
                  Text(
                    'Lat: ${_selectedLocation.latitude.toStringAsFixed(6)}, '
                    'Lon: ${_selectedLocation.longitude.toStringAsFixed(6)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(onPressed: () => Navigator.of(context).pop(_selectedLocation), child: const Text('Confirm Location')),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SubLocationFormDialog extends StatelessWidget {
  final bool isEdit;

  const SubLocationFormDialog({super.key, required this.isEdit});

  void _pickLocationOnMap(BuildContext context) async {
    final provider = context.read<SubLocationFormProvider>();
    final LatLng? pickedLocation = await showDialog<LatLng>(
      context: context,
      builder: (context) => MapPickerDialog(initialLocation: LatLng(provider.latitude, provider.longitude)),
    );

    if (pickedLocation != null) {
      provider.updateCoordinates(pickedLocation.latitude, pickedLocation.longitude);
    }
  }

  void _save(BuildContext context, GlobalKey<FormState> formKey) {
    if (formKey.currentState!.validate()) {
      final provider = context.read<SubLocationFormProvider>();
      final subLocation = Location(
        id: isEdit ? provider.editingSubLocation?.id ?? const Uuid().v4() : const Uuid().v4(),
        name: provider.name,
        description: provider.description,
        imageUrl: null,
        latitude: provider.latitude.toString(),
        longitude: provider.longitude.toString(),
        subLocations: null,
      );

      Navigator.of(context).pop(subLocation);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();

    return Consumer<SubLocationFormProvider>(
      builder: (context, provider, child) {
        return Dialog(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            constraints: const BoxConstraints(maxWidth: 500),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(isEdit ? 'Edit Sub-location' : 'Add Sub-location', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue: provider.name,
                        decoration: const InputDecoration(labelText: 'Name *', border: OutlineInputBorder(), prefixIcon: Icon(Icons.label)),
                        onChanged: provider.updateName,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue: provider.description,
                        decoration: const InputDecoration(labelText: 'Description *', border: OutlineInputBorder(), prefixIcon: Icon(Icons.description)),
                        maxLines: 2,
                        onChanged: provider.updateDescription,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a description';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              key: ValueKey(provider.latitude),
                              initialValue: provider.latitude.toString(),
                              decoration: const InputDecoration(labelText: 'Latitude *', border: OutlineInputBorder()),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                              onChanged: (value) {
                                final lat = double.tryParse(value);
                                if (lat != null) {
                                  provider.updateCoordinates(lat, provider.longitude);
                                }
                              },
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Required';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Invalid';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              key: ValueKey(provider.longitude),
                              initialValue: provider.longitude.toString(),
                              decoration: const InputDecoration(labelText: 'Longitude *', border: OutlineInputBorder()),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                              onChanged: (value) {
                                final lon = double.tryParse(value);
                                if (lon != null) {
                                  provider.updateCoordinates(provider.latitude, lon);
                                }
                              },
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Required';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Invalid';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(onPressed: () => _pickLocationOnMap(context), icon: const Icon(Icons.map), label: const Text('Pick on Map')),
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
              ),
            ),
          ),
        );
      },
    );
  }
}

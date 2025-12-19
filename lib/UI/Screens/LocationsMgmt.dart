import 'package:flutter/material.dart';
import 'package:azimuth_vms/Models/Location.dart';
import 'package:azimuth_vms/Helpers/LocationHelperFirebase.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';

class LocationsMgmt extends StatefulWidget {
  const LocationsMgmt({super.key});

  @override
  State<LocationsMgmt> createState() => _LocationsMgmtState();
}

class _LocationsMgmtState extends State<LocationsMgmt> {
  final LocationHelperFirebase _locationHelper = LocationHelperFirebase();
  List<Location> _locations = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  Future<void> _loadLocations() async {
    setState(() => _isLoading = true);
    try {
      final locations = await _locationHelper.GetAllLocations();
      setState(() {
        _locations = locations;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading locations: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading locations: $e')));
      }
    }
  }

  void _showLocationForm({Location? location}) async {
    final result = await showDialog<Location>(
      context: context,
      builder: (context) => LocationFormDialog(location: location),
    );

    if (result != null) {
      if (location == null) {
        _locationHelper.CreateLocation(result);
      } else {
        _locationHelper.UpdateLocation(result);
      }
      _loadLocations();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Locations Management'),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _loadLocations)],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _locations.isEmpty
          ? const Center(child: Text('No locations found.\nTap + to add a new location.', textAlign: TextAlign.center))
          : ListView.builder(
              itemCount: _locations.length,
              itemBuilder: (context, index) {
                final location = _locations[index];
                return LocationTile(
                  location: location,
                  onEdit: () => _showLocationForm(location: location),
                  onRefresh: _loadLocations,
                );
              },
            ),
      floatingActionButton: FloatingActionButton(onPressed: () => _showLocationForm(), child: const Icon(Icons.add)),
    );
  }
}

class LocationTile extends StatelessWidget {
  final Location location;
  final VoidCallback onEdit;
  final VoidCallback onRefresh;

  const LocationTile({super.key, required this.location, required this.onEdit, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ExpansionTile(
        leading: const Icon(Icons.location_on),
        title: Text(location.name),
        subtitle: Text(location.description),
        trailing: IconButton(icon: const Icon(Icons.edit), onPressed: onEdit),
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

class LocationFormDialog extends StatefulWidget {
  final Location? location;

  const LocationFormDialog({super.key, this.location});

  @override
  State<LocationFormDialog> createState() => _LocationFormDialogState();
}

class _LocationFormDialogState extends State<LocationFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _imageUrlController;
  late TextEditingController _latitudeController;
  late TextEditingController _longitudeController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.location?.name ?? '');
    _descriptionController = TextEditingController(text: widget.location?.description ?? '');
    _imageUrlController = TextEditingController(text: widget.location?.imageUrl ?? '');
    _latitudeController = TextEditingController(text: widget.location?.latitude ?? '0.0');
    _longitudeController = TextEditingController(text: widget.location?.longitude ?? '0.0');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  Future<void> _pickLocationOnMap() async {
    final LatLng? pickedLocation = await showDialog<LatLng>(
      context: context,
      builder: (context) => MapPickerDialog(initialLocation: LatLng(double.tryParse(_latitudeController.text) ?? 0.0, double.tryParse(_longitudeController.text) ?? 0.0)),
    );

    if (pickedLocation != null) {
      setState(() {
        _latitudeController.text = pickedLocation.latitude.toString();
        _longitudeController.text = pickedLocation.longitude.toString();
      });
    }
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final location = Location(
        id: widget.location?.id ?? const Uuid().v4(),
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        imageUrl: _imageUrlController.text.trim().isEmpty ? null : _imageUrlController.text.trim(),
        latitude: _latitudeController.text.trim(),
        longitude: _longitudeController.text.trim(),
        subLocations: widget.location?.subLocations,
      );

      Navigator.of(context).pop(location);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 600),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.location == null ? 'Add New Location' : 'Edit Location', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Name *', border: OutlineInputBorder(), prefixIcon: Icon(Icons.label)),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Description *', border: OutlineInputBorder(), prefixIcon: Icon(Icons.description)),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _imageUrlController,
                    decoration: const InputDecoration(labelText: 'Image URL (optional)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.image)),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _latitudeController,
                          decoration: const InputDecoration(labelText: 'Latitude *', border: OutlineInputBorder(), prefixIcon: Icon(Icons.gps_fixed)),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
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
                          controller: _longitudeController,
                          decoration: const InputDecoration(labelText: 'Longitude *', border: OutlineInputBorder(), prefixIcon: Icon(Icons.gps_fixed)),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
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
                      onPressed: _pickLocationOnMap,
                      icon: const Icon(Icons.map),
                      label: const Text('Pick Location on Map'),
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(16)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
                      const SizedBox(width: 8),
                      ElevatedButton(onPressed: _save, child: Text(widget.location == null ? 'Create' : 'Update')),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
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
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          children: [
            AppBar(
              title: const Text('Pick Location'),
              leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(_selectedLocation),
                  child: const Text('CONFIRM', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
            Expanded(
              child: GoogleMap(
                initialCameraPosition: CameraPosition(target: _selectedLocation, zoom: 14),
                onMapCreated: (controller) => _mapController = controller,
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

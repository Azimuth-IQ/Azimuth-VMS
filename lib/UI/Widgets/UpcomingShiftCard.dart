import 'package:azimuth_vms/Helpers/EventHelperFirebase.dart';
import 'package:azimuth_vms/Helpers/LocationHelperFirebase.dart';
import 'package:azimuth_vms/Models/Event.dart';
import 'package:azimuth_vms/Models/Location.dart';
import 'package:azimuth_vms/Models/ShiftAssignment.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class UpcomingShiftCard extends StatefulWidget {
  final ShiftAssignment? assignment;
  final Event? event;
  final EventShift? shift;
  final Location? location;

  const UpcomingShiftCard({super.key, this.assignment, this.event, this.shift, this.location});

  @override
  State<UpcomingShiftCard> createState() => _UpcomingShiftCardState();
}

class _UpcomingShiftCardState extends State<UpcomingShiftCard> {
  final EventHelperFirebase _eventHelper = EventHelperFirebase();
  final LocationHelperFirebase _locationHelper = LocationHelperFirebase();

  Event? _event;
  EventShift? _shift;
  Location? _location;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.event != null && widget.shift != null) {
      _event = widget.event;
      _shift = widget.shift;
      _location = widget.location;
      _isLoading = false;
    } else if (widget.assignment != null) {
      _loadDetails();
    } else {
      _isLoading = false;
    }
  }

  Future<void> _loadDetails() async {
    try {
      final event = await _eventHelper.GetEventById(widget.assignment!.eventId);
      if (event != null) {
        final shift = event.shifts.firstWhere(
          (s) => s.id == widget.assignment!.shiftId,
          orElse: () => event.shifts.first, // Fallback
        );

        Location? location;
        if (shift.locationId.isNotEmpty) {
          location = await _locationHelper.GetLocationById(shift.locationId);
        }

        if (mounted) {
          setState(() {
            _event = event;
            _shift = shift;
            _location = location;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error loading shift details: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Card(
        child: SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
      );
    }

    if (_event == null || _shift == null) {
      return const SizedBox.shrink();
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Map Header
          SizedBox(
            height: 150,
            child: _location != null
                ? GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(double.tryParse(_location!.latitude) ?? 33.3152, double.tryParse(_location!.longitude) ?? 44.3661),
                      zoom: 15,
                    ),
                    zoomControlsEnabled: false,
                    scrollGesturesEnabled: false,
                    zoomGesturesEnabled: false,
                    rotateGesturesEnabled: false,
                    tiltGesturesEnabled: false,
                    markers: {
                      Marker(
                        markerId: MarkerId(_location!.id),
                        position: LatLng(double.tryParse(_location!.latitude) ?? 33.3152, double.tryParse(_location!.longitude) ?? 44.3661),
                      ),
                    },
                  )
                : Container(
                    color: Colors.grey.shade200,
                    child: const Center(child: Icon(Icons.map_outlined, size: 48, color: Colors.grey)),
                  ),
          ),

          // Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: const Text(
                        'NEXT SHIFT',
                        style: TextStyle(color: Colors.blue, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _event!.startDate,
                      style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(_event!.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.access_time_rounded, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text('${_shift!.startTime} - ${_shift!.endTime}', style: TextStyle(color: Colors.grey.shade600)),
                    const SizedBox(width: 16),
                    Icon(Icons.location_on_rounded, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        _location?.name ?? 'Unknown Location',
                        style: TextStyle(color: Colors.grey.shade600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

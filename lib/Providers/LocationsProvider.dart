import 'package:flutter/material.dart';
import 'package:azimuth_vms/Models/Location.dart';
import 'package:azimuth_vms/Helpers/LocationHelperFirebase.dart';

class LocationsProvider with ChangeNotifier {
  final LocationHelperFirebase _locationHelper = LocationHelperFirebase();

  List<Location> _locations = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Location> get locations => _locations;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadLocations() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _locations = await _locationHelper.GetAllLocations();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error loading locations: $e');
      _errorMessage = 'Error loading locations: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  void createLocation(Location location) {
    _locationHelper.CreateLocation(location);
    loadLocations();
  }

  void updateLocation(Location location) {
    _locationHelper.UpdateLocation(location);
    loadLocations();
  }
}

class LocationFormProvider with ChangeNotifier {
  Location? _editingLocation;
  List<Location> _subLocations = [];

  String _name = '';
  String _description = '';
  String _imageUrl = '';
  double _latitude = 33.3152;
  double _longitude = 44.3661;

  Location? get editingLocation => _editingLocation;
  List<Location> get subLocations => _subLocations;
  String get name => _name;
  String get description => _description;
  String get imageUrl => _imageUrl;
  double get latitude => _latitude;
  double get longitude => _longitude;

  void initializeForm(Location? location) {
    _editingLocation = location;
    _name = location?.name ?? '';
    _description = location?.description ?? '';
    _imageUrl = location?.imageUrl ?? '';
    _latitude = double.tryParse(location?.latitude ?? '33.3152') ?? 33.3152;
    _longitude = double.tryParse(location?.longitude ?? '44.3661') ?? 44.3661;
    _subLocations = List.from(location?.subLocations ?? []);
    notifyListeners();
  }

  void updateName(String value) {
    _name = value;
    notifyListeners();
  }

  void updateDescription(String value) {
    _description = value;
    notifyListeners();
  }

  void updateImageUrl(String value) {
    _imageUrl = value;
    notifyListeners();
  }

  void updateLatitude(double value) {
    _latitude = value;
    notifyListeners();
  }

  void updateLongitude(double value) {
    _longitude = value;
    notifyListeners();
  }

  void updateCoordinates(double lat, double lon) {
    _latitude = lat;
    _longitude = lon;
    notifyListeners();
  }

  void addSubLocation(Location subLocation) {
    _subLocations.add(subLocation);
    notifyListeners();
  }

  void updateSubLocation(int index, Location subLocation) {
    _subLocations[index] = subLocation;
    notifyListeners();
  }

  void removeSubLocation(int index) {
    _subLocations.removeAt(index);
    notifyListeners();
  }

  void reset() {
    _editingLocation = null;
    _subLocations = [];
    _name = '';
    _description = '';
    _imageUrl = '';
    _latitude = 33.3152;
    _longitude = 44.3661;
    notifyListeners();
  }
}

class SubLocationFormProvider with ChangeNotifier {
  Location? _editingSubLocation;

  String _name = '';
  String _description = '';
  double _latitude = 33.3152;
  double _longitude = 44.3661;

  Location? get editingSubLocation => _editingSubLocation;
  String get name => _name;
  String get description => _description;
  double get latitude => _latitude;
  double get longitude => _longitude;

  void initializeForm(Location? location) {
    _editingSubLocation = location;
    _name = location?.name ?? '';
    _description = location?.description ?? '';
    _latitude = double.tryParse(location?.latitude ?? '33.3152') ?? 33.3152;
    _longitude = double.tryParse(location?.longitude ?? '44.3661') ?? 44.3661;
    notifyListeners();
  }

  void updateName(String value) {
    _name = value;
    notifyListeners();
  }

  void updateDescription(String value) {
    _description = value;
    notifyListeners();
  }

  void updateCoordinates(double lat, double lon) {
    _latitude = lat;
    _longitude = lon;
    notifyListeners();
  }

  void reset() {
    _editingSubLocation = null;
    _name = '';
    _description = '';
    _latitude = 33.3152;
    _longitude = 44.3661;
    notifyListeners();
  }
}

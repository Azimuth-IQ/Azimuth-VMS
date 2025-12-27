import 'dart:async';
import 'package:flutter/material.dart';
import 'package:azimuth_vms/Models/CarouselImage.dart';
import 'package:azimuth_vms/Helpers/CarouselImageHelperFirebase.dart';

class CarouselProvider with ChangeNotifier {
  final CarouselImageHelperFirebase _helper = CarouselImageHelperFirebase();

  List<CarouselImage> _images = [];
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<List<CarouselImage>>? _subscription;

  List<CarouselImage> get images => _images;
  List<CarouselImage> get visibleImages => _images.where((img) => img.isVisible).toList();
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void startListening() {
    _subscription = _helper.StreamCarouselImages().listen(
      (images) {
        _images = images;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        print('Error streaming carousel images: $error');
        _errorMessage = 'Error loading carousel images: $error';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
  }

  Future<void> loadImages() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _images = await _helper.GetAllCarouselImages();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error loading carousel images: $e');
      _errorMessage = 'Error loading carousel images: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createImage(CarouselImage image) async {
    try {
      await _helper.CreateCarouselImage(image);
      await loadImages();
    } catch (e) {
      print('Error creating carousel image: $e');
      _errorMessage = 'Error creating image: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateImage(CarouselImage image) async {
    try {
      await _helper.UpdateCarouselImage(image);
      await loadImages();
    } catch (e) {
      print('Error updating carousel image: $e');
      _errorMessage = 'Error updating image: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteImage(String id) async {
    try {
      await _helper.DeleteCarouselImage(id);
      await loadImages();
    } catch (e) {
      print('Error deleting carousel image: $e');
      _errorMessage = 'Error deleting image: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> toggleVisibility(String id, bool isVisible) async {
    try {
      await _helper.ToggleVisibility(id, isVisible);
      await loadImages();
    } catch (e) {
      print('Error toggling visibility: $e');
      _errorMessage = 'Error updating visibility: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> reorderImages(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    List<CarouselImage> reorderedImages = List.from(_images);
    CarouselImage image = reorderedImages.removeAt(oldIndex);
    reorderedImages.insert(newIndex, image);

    // Update order for all images
    for (int i = 0; i < reorderedImages.length; i++) {
      reorderedImages[i].order = i;
      await _helper.UpdateOrder(reorderedImages[i].id, i);
    }

    await loadImages();
  }

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }
}

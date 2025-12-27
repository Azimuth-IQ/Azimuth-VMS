import 'package:azimuth_vms/Models/CarouselImage.dart';
import 'package:azimuth_vms/Static/FirebaseHelperStatics.dart';
import 'package:firebase_database/firebase_database.dart';

class CarouselImageHelperFirebase {
  DatabaseReference rootRef = FirebaseDatabase.instance.ref().child(FirebaseHelperStatics.AppRoot).child("carouselImages");

  // Create
  Future<void> CreateCarouselImage(CarouselImage image) async {
    await rootRef.child(image.id).set(image.toJson());
  }

  // Read By ID
  Future<CarouselImage?> GetCarouselImageById(String id) async {
    DataSnapshot snapshot = await rootRef.child(id).get();
    if (snapshot.exists) {
      return CarouselImage.fromDataSnapshot(snapshot);
    }
    return null;
  }

  // Read All
  Future<List<CarouselImage>> GetAllCarouselImages() async {
    DataSnapshot snapshot = await rootRef.get();
    List<CarouselImage> images = [];
    if (snapshot.exists) {
      for (DataSnapshot d1 in snapshot.children) {
        try {
          CarouselImage image = CarouselImage.fromDataSnapshot(d1);
          images.add(image);
        } catch (e) {
          print('Error parsing carousel image ${d1.key}: $e');
        }
      }
    }
    // Sort by order
    images.sort((a, b) => a.order.compareTo(b.order));
    return images;
  }

  // Read Visible Only
  Future<List<CarouselImage>> GetVisibleCarouselImages() async {
    List<CarouselImage> allImages = await GetAllCarouselImages();
    return allImages.where((img) => img.isVisible).toList();
  }

  // Update
  Future<void> UpdateCarouselImage(CarouselImage image) async {
    await rootRef.child(image.id).update(image.toJson());
  }

  // Delete
  Future<void> DeleteCarouselImage(String id) async {
    await rootRef.child(id).remove();
  }

  // Toggle Visibility
  Future<void> ToggleVisibility(String id, bool isVisible) async {
    await rootRef.child(id).update({'isVisible': isVisible});
  }

  // Update Order
  Future<void> UpdateOrder(String id, int order) async {
    await rootRef.child(id).update({'order': order});
  }

  // Stream All Images
  Stream<List<CarouselImage>> StreamCarouselImages() {
    return rootRef.onValue.map((event) {
      List<CarouselImage> images = [];
      if (event.snapshot.exists) {
        for (DataSnapshot d1 in event.snapshot.children) {
          try {
            images.add(CarouselImage.fromDataSnapshot(d1));
          } catch (e) {
            print('Error parsing carousel image: $e');
          }
        }
      }
      images.sort((a, b) => a.order.compareTo(b.order));
      return images;
    });
  }
}

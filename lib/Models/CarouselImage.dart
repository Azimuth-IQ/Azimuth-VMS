import 'package:firebase_database/firebase_database.dart';

class CarouselImage {
  String id;
  String imageUrl;
  String title;
  String description;
  bool isVisible;
  int order;
  String uploadedBy;
  String uploadedAt;

  CarouselImage({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.isVisible,
    required this.order,
    required this.uploadedBy,
    required this.uploadedAt,
  });

  Map<String, dynamic> toJson() {
    return {'id': id, 'imageUrl': imageUrl, 'title': title, 'description': description, 'isVisible': isVisible, 'order': order, 'uploadedBy': uploadedBy, 'uploadedAt': uploadedAt};
  }

  factory CarouselImage.fromDataSnapshot(DataSnapshot snapshot) {
    return CarouselImage(
      id: snapshot.child('id').value?.toString() ?? '',
      imageUrl: snapshot.child('imageUrl').value?.toString() ?? '',
      title: snapshot.child('title').value?.toString() ?? '',
      description: snapshot.child('description').value?.toString() ?? '',
      isVisible: snapshot.child('isVisible').value as bool? ?? true,
      order: int.tryParse(snapshot.child('order').value?.toString() ?? '0') ?? 0,
      uploadedBy: snapshot.child('uploadedBy').value?.toString() ?? '',
      uploadedAt: snapshot.child('uploadedAt').value?.toString() ?? '',
    );
  }
}

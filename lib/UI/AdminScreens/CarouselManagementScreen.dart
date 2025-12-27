import 'package:flutter/material.dart';
import 'package:azimuth_vms/Models/CarouselImage.dart';
import 'package:azimuth_vms/Providers/CarouselProvider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class CarouselManagementScreen extends StatelessWidget {
  const CarouselManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      CarouselProvider provider = context.read<CarouselProvider>();
      if (!provider.isLoading && provider.images.isEmpty) {
        provider.loadImages();
      }
    });

    return const CarouselManagementView();
  }
}

class CarouselManagementView extends StatefulWidget {
  const CarouselManagementView({super.key});

  @override
  State<CarouselManagementView> createState() => _CarouselManagementViewState();
}

class _CarouselManagementViewState extends State<CarouselManagementView> {
  void _showImageForm(BuildContext context, {CarouselImage? image}) async {
    CarouselProvider provider = context.read<CarouselProvider>();

    CarouselImage? result = await showDialog<CarouselImage>(
      context: context,
      builder: (context) => ImageFormDialog(image: image),
    );

    if (result != null) {
      try {
        if (image == null) {
          await provider.createImage(result);
        } else {
          await provider.updateImage(result);
        }
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(image == null ? 'Image added successfully' : 'Image updated successfully')));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CarouselProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Carousel Management'),
            actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: () => provider.loadImages())],
          ),
          body: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : provider.images.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text('No carousel images yet', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                      const SizedBox(height: 8),
                      Text('Tap + to add your first image', style: TextStyle(fontSize: 14, color: Colors.grey[500])),
                    ],
                  ),
                )
              : ReorderableListView.builder(
                  itemCount: provider.images.length,
                  onReorder: (oldIndex, newIndex) {
                    provider.reorderImages(oldIndex, newIndex);
                  },
                  itemBuilder: (context, index) {
                    CarouselImage image = provider.images[index];
                    return Card(
                      key: ValueKey(image.id),
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: ListTile(
                        leading: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.drag_handle, color: Colors.grey[600]),
                            const SizedBox(width: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.network(
                                image.imageUrl,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(width: 60, height: 60, color: Colors.grey[300], child: const Icon(Icons.broken_image)),
                              ),
                            ),
                          ],
                        ),
                        title: Text(image.title),
                        subtitle: Text(image.description.isEmpty ? 'No description' : image.description, maxLines: 1, overflow: TextOverflow.ellipsis),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Switch(
                              value: image.isVisible,
                              onChanged: (value) {
                                provider.toggleVisibility(image.id, value);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _showImageForm(context, image: image),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                bool? confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Delete Image'),
                                    content: Text('Are you sure you want to delete "${image.title}"?'),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                      ElevatedButton(
                                        onPressed: () => Navigator.pop(context, true),
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true && context.mounted) {
                                  try {
                                    await provider.deleteImage(image.id);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Image deleted successfully')));
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
                                    }
                                  }
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
          floatingActionButton: FloatingActionButton(heroTag: 'carousel_fab', onPressed: () => _showImageForm(context), child: const Icon(Icons.add)),
        );
      },
    );
  }
}

class ImageFormDialog extends StatefulWidget {
  final CarouselImage? image;

  const ImageFormDialog({super.key, this.image});

  @override
  State<ImageFormDialog> createState() => _ImageFormDialogState();
}

class _ImageFormDialogState extends State<ImageFormDialog> {
  late TextEditingController _imageUrlController;
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late bool _isVisible;
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _imageUrlController = TextEditingController(text: widget.image?.imageUrl ?? '');
    _titleController = TextEditingController(text: widget.image?.title ?? '');
    _descriptionController = TextEditingController(text: widget.image?.description ?? '');
    _isVisible = widget.image?.isVisible ?? true;
  }

  @override
  void dispose() {
    _imageUrlController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _uploadImage() async {
    try {
      // Pick image file
      FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image, allowMultiple: false);

      if (result == null) return;

      PlatformFile file = result.files.first;

      if (file.bytes == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error: Could not read file'), backgroundColor: Colors.red));
        }
        return;
      }

      setState(() {
        _isUploading = true;
        _uploadProgress = 0.0;
      });

      // Create a unique filename
      String fileName = 'carousel_${const Uuid().v4()}.${file.extension}';

      // Upload to Firebase Storage
      Reference storageRef = FirebaseStorage.instance.ref().child('carousel_images/$fileName');
      UploadTask uploadTask = storageRef.putData(file.bytes!);

      // Listen to upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        setState(() {
          _uploadProgress = snapshot.bytesTransferred / snapshot.totalBytes;
        });
      });

      // Wait for upload to complete
      TaskSnapshot snapshot = await uploadTask;

      // Get download URL
      String downloadUrl = await snapshot.ref.getDownloadURL();

      setState(() {
        _imageUrlController.text = downloadUrl;
        _isUploading = false;
        _uploadProgress = 0.0;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Image uploaded successfully!'), backgroundColor: Colors.green));
      }
    } catch (e) {
      print('Error uploading image: $e');
      setState(() {
        _isUploading = false;
        _uploadProgress = 0.0;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e'), backgroundColor: Colors.red));
      }
    }
  }

  void _save() async {
    if (_titleController.text.trim().isEmpty || _imageUrlController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Title and Image URL are required'), backgroundColor: Colors.red));
      return;
    }

    User? user = FirebaseAuth.instance.currentUser;
    String currentUserPhone = user?.email?.split('@').first ?? 'unknown';
    String timestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    CarouselImage image = CarouselImage(
      id: widget.image?.id ?? const Uuid().v4(),
      imageUrl: _imageUrlController.text.trim(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      isVisible: _isVisible,
      order: widget.image?.order ?? 0,
      uploadedBy: widget.image?.uploadedBy ?? currentUserPhone,
      uploadedAt: widget.image?.uploadedAt ?? timestamp,
    );

    Navigator.of(context).pop(image);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(widget.image == null ? 'Add Carousel Image' : 'Edit Carousel Image', style: Theme.of(context).textTheme.headlineSmall),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Upload Image Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isUploading ? null : _uploadImage,
                        icon: _isUploading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.cloud_upload),
                        label: Text(_isUploading ? 'Uploading... ${(_uploadProgress * 100).toStringAsFixed(0)}%' : 'Upload Image from PC'),
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12), backgroundColor: Colors.blue, foregroundColor: Colors.white),
                      ),
                    ),
                    if (_isUploading) ...[const SizedBox(height: 8), LinearProgressIndicator(value: _uploadProgress)],
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),
                    const Center(
                      child: Text(
                        'OR',
                        style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Divider(),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _imageUrlController,
                      decoration: const InputDecoration(
                        labelText: 'Image URL *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.link),
                        hintText: 'https://example.com/image.jpg',
                      ),
                      enabled: !_isUploading,
                    ),
                    const SizedBox(height: 16),
                    if (_imageUrlController.text.isNotEmpty)
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            _imageUrlController.text,
                            height: 150,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              height: 150,
                              color: Colors.grey[300],
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [Icon(Icons.broken_image, size: 48), SizedBox(height: 8), Text('Invalid Image URL')],
                              ),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(labelText: 'Title *', border: OutlineInputBorder(), prefixIcon: Icon(Icons.title)),
                      enabled: !_isUploading,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder(), prefixIcon: Icon(Icons.description)),
                      maxLines: 3,
                      enabled: !_isUploading,
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Visible to Users'),
                      subtitle: Text(_isVisible ? 'This image will be shown in the carousel' : 'This image is hidden'),
                      value: _isVisible,
                      onChanged: (value) {
                        setState(() {
                          _isVisible = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
                  const SizedBox(width: 8),
                  ElevatedButton(onPressed: _save, child: const Text('Save')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

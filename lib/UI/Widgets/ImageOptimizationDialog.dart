import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

class ImageOptimizationDialog extends StatefulWidget {
  final Uint8List originalImageData;
  final String imageName;

  const ImageOptimizationDialog({super.key, required this.originalImageData, required this.imageName});

  @override
  State<ImageOptimizationDialog> createState() => _ImageOptimizationDialogState();
}

class _ImageOptimizationDialogState extends State<ImageOptimizationDialog> {
  late img.Image _originalImage;
  late img.Image _processedImage;
  late Uint8List _processedImageData;

  double _quality = 85;
  double _scale = 1.0;
  int _originalSize = 0;
  int _processedSize = 0;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _originalSize = widget.originalImageData.lengthInBytes;
    _initializeImage();
  }

  void _initializeImage() {
    setState(() => _isProcessing = true);

    try {
      _originalImage = img.decodeImage(widget.originalImageData)!;
      _processedImage = _originalImage.clone();
      _processImage();
    } catch (e) {
      print('Error initializing image: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _processImage() {
    setState(() => _isProcessing = true);

    try {
      // Apply scaling
      final scaledWidth = (_originalImage.width * _scale).round();
      final scaledHeight = (_originalImage.height * _scale).round();

      _processedImage = img.copyResize(_originalImage, width: scaledWidth, height: scaledHeight, interpolation: img.Interpolation.cubic);

      // Encode with quality setting
      _processedImageData = Uint8List.fromList(img.encodeJpg(_processedImage, quality: _quality.round()));

      _processedSize = _processedImageData.lengthInBytes;
    } catch (e) {
      print('Error processing image: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUnder500KB = _processedSize <= 500 * 1024;

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
              child: Row(
                children: [
                  Icon(Icons.image_outlined, color: theme.colorScheme.onPrimary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Optimize Image',
                      style: TextStyle(color: theme.colorScheme.onPrimary, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: theme.colorScheme.onPrimary),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image Preview
                    Center(
                      child: Container(
                        constraints: const BoxConstraints(maxHeight: 250),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: _isProcessing
                              ? const Center(
                                  child: Padding(padding: EdgeInsets.all(50), child: CircularProgressIndicator()),
                                )
                              : Image.memory(_processedImageData, fit: BoxFit.contain),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Size Info
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isUnder500KB ? Colors.green.shade50 : Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: isUnder500KB ? Colors.green : Colors.orange, width: 2),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  Text('Original', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                  const SizedBox(height: 4),
                                  Text(_formatSize(_originalSize), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const Icon(Icons.arrow_forward, size: 20),
                              Column(
                                children: [
                                  Text('Optimized', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatSize(_processedSize),
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isUnder500KB ? Colors.green : Colors.orange),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            isUnder500KB ? '✓ Image is within 500KB limit' : '⚠ Image exceeds 500KB - adjust settings',
                            style: TextStyle(fontSize: 12, color: isUnder500KB ? Colors.green.shade700 : Colors.orange.shade700, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Quality Slider
                    Text('Image Quality', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Slider(
                            value: _quality,
                            min: 10,
                            max: 100,
                            divisions: 90,
                            label: '${_quality.round()}%',
                            onChanged: (value) {
                              setState(() => _quality = value);
                              _processImage();
                            },
                          ),
                        ),
                        SizedBox(width: 50, child: Text('${_quality.round()}%', textAlign: TextAlign.right)),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Scale Slider
                    Text('Image Size', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Slider(
                            value: _scale,
                            min: 0.2,
                            max: 1.0,
                            divisions: 80,
                            label: '${(_scale * 100).round()}%',
                            onChanged: (value) {
                              setState(() => _scale = value);
                              _processImage();
                            },
                          ),
                        ),
                        SizedBox(width: 50, child: Text('${(_scale * 100).round()}%', textAlign: TextAlign.right)),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Dimensions Info
                    Text(
                      '${(_originalImage.width * _scale).round()} × ${(_originalImage.height * _scale).round()} px',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border(top: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
                  const SizedBox(width: 12),
                  ElevatedButton(onPressed: isUnder500KB ? () => Navigator.of(context).pop(_processedImageData) : null, child: const Text('Use Optimized Image')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

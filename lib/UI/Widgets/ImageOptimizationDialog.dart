import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import '../../l10n/app_localizations.dart';

class ImageOptimizationDialog extends StatefulWidget {
  final Uint8List originalImageData;
  final String imageName;

  const ImageOptimizationDialog({super.key, required this.originalImageData, required this.imageName});

  @override
  State<ImageOptimizationDialog> createState() => _ImageOptimizationDialogState();
}

class _ImageOptimizationDialogState extends State<ImageOptimizationDialog> {
  late img.Image _originalImage;
  img.Image? _processedImage;
  Uint8List? _processedImageData;

  double _quality = 85;
  double _scale = 1.0;
  int _originalSize = 0;
  int _estimatedSize = 0;
  bool _isInitializing = false;
  bool _isOptimizing = false;
  String? _errorMessage;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _originalSize = widget.originalImageData.lengthInBytes;
    _initializeImage();
  }

  Future<void> _initializeImage() async {
    setState(() => _isInitializing = true);

    try {
      // Decode image asynchronously to prevent UI blocking
      final decodedImage = await _decodeImageAsync(widget.originalImageData);
      if (decodedImage == null) {
        setState(() {
          _errorMessage = 'Failed to decode image';
          _isInitializing = false;
        });
        return;
      }

      _originalImage = decodedImage;

      // For very large images (>2MB), start with reduced scale
      if (_originalSize > 2 * 1024 * 1024) {
        _scale = 0.5;
      }

      // Calculate estimated size instead of processing
      _calculateEstimatedSize();

      setState(() => _isInitializing = false);
    } catch (e) {
      print('Error initializing image: $e');
      setState(() {
        _errorMessage = 'Error: $e';
        _isInitializing = false;
      });
    }
  }

  Future<img.Image?> _decodeImageAsync(Uint8List data) async {
    try {
      return await Future.microtask(() => img.decodeImage(data));
    } catch (e) {
      print('Error decoding image: $e');
      return null;
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSliderChanged() {
    // Cancel any existing timer
    _debounceTimer?.cancel();

    // Recalculate estimated size after a short delay (100ms for smooth UI)
    _debounceTimer = Timer(const Duration(milliseconds: 100), () {
      _calculateEstimatedSize();
    });
  }

  void _calculateEstimatedSize() {
    setState(() {
      // Estimate based on scale and quality
      // This is an approximation: scaled pixels * quality factor * bytes per pixel
      final scaledPixels = (_originalImage.width * _scale) * (_originalImage.height * _scale);
      final qualityFactor = _quality / 100;

      // JPEG compression: roughly 0.5-3 bytes per pixel depending on quality
      // Higher quality = more bytes per pixel
      final bytesPerPixel = 0.5 + (qualityFactor * 2.5);

      _estimatedSize = (scaledPixels * bytesPerPixel).round();
    });
  }

  Future<void> _optimizeImage() async {
    setState(() => _isOptimizing = true);

    try {
      // Process in microtask to prevent blocking UI
      await Future.microtask(() {
        // Apply scaling
        final scaledWidth = (_originalImage.width * _scale).round();
        final scaledHeight = (_originalImage.height * _scale).round();

        // Use faster interpolation for large images
        final interpolation = (_originalSize > 2 * 1024 * 1024) ? img.Interpolation.linear : img.Interpolation.cubic;

        _processedImage = img.copyResize(_originalImage, width: scaledWidth, height: scaledHeight, interpolation: interpolation);

        // Encode with quality setting
        _processedImageData = Uint8List.fromList(img.encodeJpg(_processedImage!, quality: _quality.round()));
      });

      // Image optimized successfully, close dialog and return data
      if (mounted && _processedImageData != null) {
        Navigator.of(context).pop(_processedImageData);
      }
    } catch (e) {
      print('Error optimizing image: $e');
      setState(() {
        _errorMessage = 'Optimization error: $e';
        _isOptimizing = false;
      });
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
    final l10n = AppLocalizations.of(context)!;
    final isUnder500KB = _estimatedSize <= 500 * 1024;

    // Show optimizing overlay
    if (_isOptimizing) {
      return Dialog(
        backgroundColor: theme.dialogBackgroundColor,
        child: Container(
          padding: const EdgeInsets.all(48),
          constraints: const BoxConstraints(maxWidth: 300),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: theme.colorScheme.primary),
              const SizedBox(height: 24),
              Text(
                l10n.optimizeImage,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.processing,
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7)),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Show error if image failed to process
    if (_errorMessage != null) {
      return Dialog(
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
              const SizedBox(height: 16),
              Text(l10n.error, style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.error)),
              const SizedBox(height: 8),
              Text(_errorMessage!, textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 24),
              FilledButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.close)),
            ],
          ),
        ),
      );
    }

    return Dialog(
      backgroundColor: theme.dialogBackgroundColor,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [theme.colorScheme.primary, theme.colorScheme.primary.withOpacity(0.8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
              child: Row(
                children: [
                  Icon(Icons.image_outlined, color: theme.colorScheme.onPrimary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.optimizeImage,
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
                          border: Border.all(color: theme.dividerColor, width: 2),
                          borderRadius: BorderRadius.circular(12),
                          color: theme.cardColor,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: _isInitializing
                              ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(50),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        CircularProgressIndicator(color: theme.colorScheme.primary),
                                        const SizedBox(height: 16),
                                        Text(l10n.loading, style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
                                      ],
                                    ),
                                  ),
                                )
                              : Stack(
                                  children: [
                                    Image.memory(widget.originalImageData, fit: BoxFit.contain),
                                    Positioned(
                                      bottom: 0,
                                      left: 0,
                                      right: 0,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.bottomCenter,
                                            end: Alignment.topCenter,
                                            colors: [
                                              Colors.black.withOpacity(0.8),
                                              Colors.black.withOpacity(0.0),
                                            ],
                                          ),
                                        ),
                                        child: Text(
                                          'Preview: ${(_originalImage.width * _scale).round()} × ${(_originalImage.height * _scale).round()} px',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Size Info
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isUnder500KB
                              ? [Colors.green.withOpacity(0.1), Colors.green.withOpacity(0.05)]
                              : [Colors.orange.withOpacity(0.1), Colors.orange.withOpacity(0.05)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isUnder500KB ? Colors.green : Colors.orange, width: 2),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    l10n.original,
                                    style: TextStyle(fontSize: 13, color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7), fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _formatSize(_originalSize),
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color),
                                  ),
                                ],
                              ),
                              Icon(Icons.arrow_forward_rounded, size: 24, color: theme.iconTheme.color),
                              Column(
                                children: [
                                  Text(
                                    l10n.optimized,
                                    style: TextStyle(fontSize: 13, color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7), fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _formatSize(_estimatedSize),
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isUnder500KB ? Colors.green.shade700 : Colors.orange.shade700),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(color: (isUnder500KB ? Colors.green : Colors.orange).withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isUnder500KB ? Icons.check_circle_rounded : Icons.warning_rounded,
                                  size: 18,
                                  color: isUnder500KB ? Colors.green.shade700 : Colors.orange.shade700,
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    isUnder500KB ? l10n.imageWithinLimit : l10n.imageExceedsLimit,
                                    style: TextStyle(fontSize: 13, color: isUnder500KB ? Colors.green.shade700 : Colors.orange.shade700, fontWeight: FontWeight.w600),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Quality Slider
                    Text(
                      l10n.imageQuality,
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: theme.textTheme.titleMedium?.color),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: theme.dividerColor),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Slider(
                              value: _quality,
                              min: 10,
                              max: 100,
                              divisions: 90,
                              label: '${_quality.round()}%',
                              activeColor: theme.colorScheme.primary,
                              onChanged: _isInitializing
                                  ? null
                                  : (value) {
                                      setState(() => _quality = value);
                                      _onSliderChanged();
                                    },
                            ),
                          ),
                          SizedBox(
                            width: 50,
                            child: Text(
                              '${_quality.round()}%',
                              textAlign: TextAlign.right,
                              style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Scale Slider
                    Text(
                      l10n.imageSize,
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: theme.textTheme.titleMedium?.color),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: theme.dividerColor),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Slider(
                              value: _scale,
                              min: 0.2,
                              max: 1.0,
                              divisions: 80,
                              label: '${(_scale * 100).round()}%',
                              activeColor: theme.colorScheme.primary,
                              onChanged: _isInitializing
                                  ? null
                                  : (value) {
                                      setState(() => _scale = value);
                                      _onSliderChanged();
                                    },
                            ),
                          ),
                          SizedBox(
                            width: 50,
                            child: Text(
                              '${(_scale * 100).round()}%',
                              textAlign: TextAlign.right,
                              style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Dimensions Info
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(color: theme.colorScheme.primaryContainer.withOpacity(0.3), borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.photo_size_select_large_rounded, size: 16, color: theme.colorScheme.primary),
                          const SizedBox(width: 8),
                          Text(
                            '${(_originalImage.width * _scale).round()} × ${(_originalImage.height * _scale).round()} px',
                            style: TextStyle(fontSize: 13, color: theme.textTheme.bodyMedium?.color, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border(top: BorderSide(color: theme.dividerColor, width: 1.5)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
                    child: Text(l10n.cancel),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: isUnder500KB ? () => _optimizeImage() : null,
                    icon: const Icon(Icons.check_circle_rounded, size: 20),
                    label: Text(l10n.useOptimizedImage),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                    ),
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

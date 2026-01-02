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
  img.Image? _originalImage;
  Uint8List? _currentImageData;
  Uint8List? _optimizedImageData;

  int _originalSize = 0;
  int _currentSize = 0;
  bool _isInitializing = true;
  bool _isProcessing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _originalSize = widget.originalImageData.lengthInBytes;
    _currentImageData = widget.originalImageData;
    _currentSize = _originalSize;
    _initializeAndOptimize();
  }

  Future<void> _initializeAndOptimize() async {
    setState(() {
      _isInitializing = true;
      _errorMessage = null;
    });

    try {
      // Decode image
      final decodedImage = await _decodeImageAsync(widget.originalImageData);
      if (decodedImage == null) {
        setState(() {
          _errorMessage = 'Failed to decode image';
          _isInitializing = false;
        });
        return;
      }

      _originalImage = decodedImage;

      // Auto-optimize to under 500KB
      await _autoOptimize();

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

  Future<void> _autoOptimize() async {
    if (_originalImage == null) return;

    const int targetSize = 500 * 1024; // 500KB
    if (_originalSize <= targetSize) {
      _optimizedImageData = widget.originalImageData;
      _currentImageData = widget.originalImageData;
      _currentSize = _originalSize;
      return;
    }

    int quality = 85;
    double scale = 1.0;
    Uint8List? bestResult;
    int bestSize = _originalSize;

    // Reduce scale if needed
    while (bestSize > targetSize && scale > 0.3) {
      final scaledWidth = (_originalImage!.width * scale).round();
      final scaledHeight = (_originalImage!.height * scale).round();
      final resized = img.copyResize(_originalImage!, width: scaledWidth, height: scaledHeight, interpolation: img.Interpolation.linear);
      final encoded = Uint8List.fromList(img.encodeJpg(resized, quality: quality));

      if (encoded.lengthInBytes <= targetSize) {
        bestResult = encoded;
        bestSize = encoded.lengthInBytes;
        break;
      }
      scale -= 0.1;
    }

    // Reduce quality if needed
    if (bestSize > targetSize) {
      quality = 75;
      while (quality >= 40 && bestSize > targetSize) {
        final scaledWidth = (_originalImage!.width * scale).round();
        final scaledHeight = (_originalImage!.height * scale).round();
        final resized = img.copyResize(_originalImage!, width: scaledWidth, height: scaledHeight, interpolation: img.Interpolation.linear);
        final encoded = Uint8List.fromList(img.encodeJpg(resized, quality: quality));

        if (encoded.lengthInBytes <= targetSize) {
          bestResult = encoded;
          bestSize = encoded.lengthInBytes;
          break;
        }
        quality -= 5;
      }
    }

    if (bestResult != null) {
      _optimizedImageData = bestResult;
      _currentImageData = bestResult;
      _currentSize = bestSize;
    } else {
      _optimizedImageData = widget.originalImageData;
      _currentImageData = widget.originalImageData;
      _currentSize = _originalSize;
    }
  }

  void _rotateLeft() async {
    if (_isProcessing || _currentImageData == null) return;
    setState(() => _isProcessing = true);

    try {
      final decoded = await _decodeImageAsync(_currentImageData!);
      if (decoded == null) return;

      final rotated = img.copyRotate(decoded, angle: -90);
      final encoded = Uint8List.fromList(img.encodeJpg(rotated, quality: 85));

      if (encoded.lengthInBytes > 500 * 1024) {
        _originalImage = rotated;
        await _autoOptimize();
      } else {
        setState(() {
          _currentImageData = encoded;
          _currentSize = encoded.lengthInBytes;
        });
      }
    } catch (e) {
      print('Error rotating image: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _rotateRight() async {
    if (_isProcessing || _currentImageData == null) return;
    setState(() => _isProcessing = true);

    try {
      final decoded = await _decodeImageAsync(_currentImageData!);
      if (decoded == null) return;

      final rotated = img.copyRotate(decoded, angle: 90);
      final encoded = Uint8List.fromList(img.encodeJpg(rotated, quality: 85));

      if (encoded.lengthInBytes > 500 * 1024) {
        _originalImage = rotated;
        await _autoOptimize();
      } else {
        setState(() {
          _currentImageData = encoded;
          _currentSize = encoded.lengthInBytes;
        });
      }
    } catch (e) {
      print('Error rotating image: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _reset() {
    setState(() {
      _currentImageData = _optimizedImageData;
      _currentSize = _optimizedImageData?.lengthInBytes ?? _originalSize;
    });
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
    final isUnder500KB = _currentSize <= 500 * 1024;

    // Show loading screen
    if (_isInitializing) {
      return Dialog(
        backgroundColor: theme.dialogBackgroundColor,
        child: Container(
          padding: const EdgeInsets.all(48),
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: theme.colorScheme.primary),
              const SizedBox(height: 24),
              Text(
                l10n.autoOptimizing,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
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
        backgroundColor: theme.dialogBackgroundColor,
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
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                style: FilledButton.styleFrom(backgroundColor: theme.colorScheme.primary, foregroundColor: theme.colorScheme.onPrimary),
                child: Text(l10n.close),
              ),
            ],
          ),
        ),
      );
    }

    return Dialog(
      backgroundColor: theme.dialogBackgroundColor,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 750),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
              child: Row(
                children: [
                  Icon(Icons.image_outlined, color: theme.colorScheme.onPrimaryContainer),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.optimizeImage,
                      style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: theme.colorScheme.onPrimaryContainer),
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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Image Preview
                    Container(
                      height: 350,
                      decoration: BoxDecoration(
                        border: Border.all(color: theme.dividerColor, width: 2),
                        borderRadius: BorderRadius.circular(12),
                        color: theme.cardColor,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: _isProcessing
                            ? Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircularProgressIndicator(color: theme.colorScheme.primary),
                                    const SizedBox(height: 16),
                                    Text(l10n.optimizingImage, style: theme.textTheme.bodyMedium),
                                  ],
                                ),
                              )
                            : _currentImageData != null
                            ? Image.memory(_currentImageData!, fit: BoxFit.contain)
                            : const SizedBox(),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Size Info
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: (isUnder500KB ? Colors.green : Colors.orange).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isUnder500KB ? Colors.green : Colors.orange, width: 2),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Text(l10n.currentSize, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              Text(
                                _formatSize(_currentSize),
                                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: isUnder500KB ? Colors.green.shade700 : Colors.orange.shade700),
                              ),
                            ],
                          ),
                          Icon(isUnder500KB ? Icons.check_circle : Icons.warning, color: isUnder500KB ? Colors.green : Colors.orange, size: 32),
                          Column(
                            children: [
                              Text(l10n.targetSize, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              Text(
                                '< 500 KB',
                                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: isUnder500KB ? Colors.green.shade700 : Colors.orange.shade700),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Controls
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _isProcessing ? null : _rotateLeft,
                                icon: const Icon(Icons.rotate_left),
                                label: Text(l10n.rotateLeft),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  side: BorderSide(color: theme.colorScheme.primary),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _isProcessing ? null : _rotateRight,
                                icon: const Icon(Icons.rotate_right),
                                label: Text(l10n.rotateRight),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  side: BorderSide(color: theme.colorScheme.primary),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: _isProcessing ? null : _reset,
                          icon: const Icon(Icons.refresh),
                          label: Text(l10n.resetImage),
                          style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                        ),
                      ],
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
                border: Border(top: BorderSide(color: theme.dividerColor)),
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
                    onPressed: (isUnder500KB && !_isProcessing && _currentImageData != null) ? () => Navigator.of(context).pop(_currentImageData) : null,
                    icon: const Icon(Icons.check_circle, size: 20),
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

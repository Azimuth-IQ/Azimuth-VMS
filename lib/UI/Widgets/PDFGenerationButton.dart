import 'package:flutter/material.dart';
import 'package:azimuth_vms/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:azimuth_vms/Helpers/PDFServiceAPIHelper.dart';
import 'package:azimuth_vms/Helpers/VolunteerFormHelperFirebase.dart';
import 'package:azimuth_vms/Models/VolunteerForm.dart';

/// PDF Generation Button Widget
/// Shows different states: Generate, Regenerate, View, Download
class PDFGenerationButton extends StatefulWidget {
  final VolunteerForm form;
  final VoidCallback? onPDFGenerated;

  const PDFGenerationButton({Key? key, required this.form, this.onPDFGenerated}) : super(key: key);

  @override
  State<PDFGenerationButton> createState() => _PDFGenerationButtonState();
}

class _PDFGenerationButtonState extends State<PDFGenerationButton> {
  bool _isGenerating = false;
  String? _errorMessage;

  Future<void> _generatePDF({bool regenerate = false}) async {
    setState(() {
      _isGenerating = true;
      _errorMessage = null;
    });

    try {
      final l10n = AppLocalizations.of(context)!;

      // Generate PDF and get Firebase Storage URL
      final pdfUrl = await PDFServiceAPIHelper.generateAndSavePDF(widget.form, regenerate: regenerate);

      if (pdfUrl == null) {
        setState(() {
          _errorMessage = l10n.errorGeneratingPDF;
          _isGenerating = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.errorGeneratingPDF), backgroundColor: Colors.red));
        }
        return;
      }

      // Update form with PDF URL
      widget.form.generatedPdfUrl = pdfUrl;

      // Save to Firebase
      if (widget.form.mobileNumber != null) {
        await VolunteerFormHelperFirebase().UpdateForm(widget.form);
      }

      setState(() {
        _isGenerating = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.pdfGeneratedSuccessfully),
            backgroundColor: Colors.green,
            action: SnackBarAction(label: l10n.viewPDF, textColor: Colors.white, onPressed: () => _openPDF(pdfUrl)),
          ),
        );
      }

      widget.onPDFGenerated?.call();
    } catch (e) {
      print('Error in _generatePDF: $e');
      setState(() {
        _errorMessage = e.toString();
        _isGenerating = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${AppLocalizations.of(context)!.errorGeneratingPDF}: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _openPDF(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      print('Error opening PDF: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error opening PDF: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final hasPDF = widget.form.generatedPdfUrl != null && widget.form.generatedPdfUrl!.isNotEmpty;

    if (_isGenerating) {
      return Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary))),
              const SizedBox(width: 12),
              Expanded(
                child: Text(l10n.generatingPDF, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.picture_as_pdf, color: hasPDF ? Colors.green : theme.colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(hasPDF ? l10n.downloadPDF : l10n.pdfNotGenerated, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(_errorMessage!, style: TextStyle(color: Colors.red, fontSize: 12)),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                if (hasPDF) ...[
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _openPDF(widget.form.generatedPdfUrl!),
                      icon: const Icon(Icons.visibility, size: 18),
                      label: Text(l10n.viewPDF),
                      style: FilledButton.styleFrom(backgroundColor: theme.colorScheme.primary),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(onPressed: () => _generatePDF(regenerate: true), icon: const Icon(Icons.refresh, size: 18), label: Text(l10n.regeneratePDF)),
                  ),
                ] else
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _generatePDF(regenerate: false),
                      icon: const Icon(Icons.add, size: 18),
                      label: Text(l10n.generatePDF),
                      style: FilledButton.styleFrom(backgroundColor: theme.colorScheme.primary),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

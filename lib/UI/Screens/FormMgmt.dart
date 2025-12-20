import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'dart:html' as html;
import 'dart:ui' as ui;
// ignore: avoid_web_libraries_in_flutter
import 'dart:ui_web' as ui_web;

class FormMgmt extends StatefulWidget {
  const FormMgmt({super.key});

  @override
  State<FormMgmt> createState() => _FormMgmtState();
}

class _FormMgmtState extends State<FormMgmt> {
  PdfDocument? _document;
  Uint8List? _pdfBytes;
  bool _isLoading = false;
  String? _errorMessage;

  // Form field controllers
  final Map<String, TextEditingController> _fieldControllers = {};
  final Map<String, bool> _checkboxValues = {};
  final Map<String, String> _radioButtonValues = {};

  @override
  void initState() {
    super.initState();
    _loadPdfForm();
  }

  @override
  void dispose() {
    // Dispose all controllers
    for (var controller in _fieldControllers.values) {
      controller.dispose();
    }
    _document?.dispose();
    super.dispose();
  }

  Future<void> _loadPdfForm() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Load the PDF from assets
      final ByteData data = await rootBundle.load('assets/pdfs/form1.pdf');
      final Uint8List bytes = data.buffer.asUint8List();

      // Load the PDF document
      _document = PdfDocument(inputBytes: bytes);

      // Extract form fields and initialize controllers
      _extractFormFields();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading PDF form: $e');
      setState(() {
        _errorMessage = 'Error loading PDF form: $e';
        _isLoading = false;
      });
    }
  }

  void _extractFormFields() {
    if (_document == null) return;

    final PdfForm form = _document!.form;

    for (int i = 0; i < form.fields.count; i++) {
      final PdfField field = form.fields[i];

      if (field is PdfTextBoxField) {
        _fieldControllers[field.name ?? 'field_$i'] = TextEditingController(text: field.text ?? '');
      } else if (field is PdfCheckBoxField) {
        _checkboxValues[field.name ?? 'checkbox_$i'] = field.isChecked ?? false;
      } else if (field is PdfRadioButtonListField) {
        _radioButtonValues[field.name ?? 'radio_$i'] = field.selectedIndex.toString();
      }
    }
  }

  Future<void> _fillAndFlattenForm() async {
    if (_document == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final PdfForm form = _document!.form;

      // Fill text fields
      for (int i = 0; i < form.fields.count; i++) {
        final PdfField field = form.fields[i];

        if (field is PdfTextBoxField) {
          final controller = _fieldControllers[field.name];
          if (controller != null) {
            field.text = controller.text;
          }
        } else if (field is PdfCheckBoxField) {
          final value = _checkboxValues[field.name];
          if (value != null) {
            field.isChecked = value;
          }
        } else if (field is PdfRadioButtonListField) {
          final value = _radioButtonValues[field.name];
          if (value != null) {
            field.selectedIndex = int.tryParse(value) ?? 0;
          }
        }
      }

      // Flatten the form
      form.flattenAllFields();

      // Save the document
      final List<int> bytes = await _document!.save();
      _pdfBytes = Uint8List.fromList(bytes);

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Form filled and flattened successfully!')));
      }
    } catch (e) {
      print('Error filling and flattening form: $e');
      setState(() {
        _errorMessage = 'Error processing form: $e';
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _downloadPdf() {
    if (_pdfBytes == null) return;

    try {
      final blob = html.Blob([_pdfBytes!], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', 'filled_form_${DateTime.now().millisecondsSinceEpoch}.pdf')
        ..click();
      html.Url.revokeObjectUrl(url);

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PDF downloaded successfully!')));
    } catch (e) {
      print('Error downloading PDF: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error downloading: $e')));
    }
  }

  void _printPdf() {
    if (_pdfBytes == null) return;

    try {
      final blob = html.Blob([_pdfBytes!], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.window.open(url, '_blank');
      html.Url.revokeObjectUrl(url);
    } catch (e) {
      print('Error printing PDF: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error printing: $e')));
    }
  }

  void _previewPdf() {
    if (_pdfBytes == null) return;

    final String viewId = 'pdf-preview-${DateTime.now().millisecondsSinceEpoch}';
    final iframe = html.IFrameElement()
      ..src = html.Url.createObjectUrlFromBlob(html.Blob([_pdfBytes!], 'application/pdf'))
      ..style.border = 'none'
      ..style.width = '100%'
      ..style.height = '100%';

    // Register the view factory
    // ignore: undefined_prefixed_name
    ui_web.platformViewRegistry.registerViewFactory(viewId, (int viewId) => iframe);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('PDF Preview', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const Divider(),
              Expanded(child: HtmlElementView(viewType: viewId)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Management'),
        actions: [
          if (_pdfBytes != null) ...[
            IconButton(icon: const Icon(Icons.visibility), tooltip: 'Preview PDF', onPressed: _previewPdf),
            IconButton(icon: const Icon(Icons.download), tooltip: 'Download PDF', onPressed: _downloadPdf),
            IconButton(icon: const Icon(Icons.print), tooltip: 'Print PDF', onPressed: _printPdf),
          ],
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: _loadPdfForm, child: const Text('Retry')),
                ],
              ),
            )
          : _buildFormFields(),
      floatingActionButton: _document != null
          ? FloatingActionButton.extended(onPressed: _fillAndFlattenForm, icon: const Icon(Icons.check), label: const Text('Fill & Flatten'))
          : null,
    );
  }

  Widget _buildFormFields() {
    if (_document == null) return const SizedBox.shrink();

    final form = _document!.form;

    if (form.fields.count == 0) {
      return const Center(child: Text('No form fields found in the PDF'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Fill Form Fields', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Found ${form.fields.count} form fields', style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(form.fields.count, (index) {
            final field = form.fields[index];
            return _buildFieldWidget(field, index);
          }),
          const SizedBox(height: 80), // Space for FAB
        ],
      ),
    );
  }

  Widget _buildFieldWidget(PdfField field, int index) {
    if (field is PdfTextBoxField) {
      return Card(
        margin: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.text_fields, size: 20),
                  const SizedBox(width: 8),
                  Text(field.name ?? 'Text Field $index', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _fieldControllers[field.name ?? 'field_$index'],
                decoration: InputDecoration(hintText: 'Enter ${field.name ?? 'value'}', border: const OutlineInputBorder()),
                maxLines: field.multiline ? 3 : 1,
              ),
            ],
          ),
        ),
      );
    } else if (field is PdfCheckBoxField) {
      return Card(
        margin: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: CheckboxListTile(
            title: Row(
              children: [
                const Icon(Icons.check_box_outlined, size: 20),
                const SizedBox(width: 8),
                Text(field.name ?? 'Checkbox $index', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            value: _checkboxValues[field.name ?? 'checkbox_$index'] ?? false,
            onChanged: (value) {
              setState(() {
                _checkboxValues[field.name ?? 'checkbox_$index'] = value ?? false;
              });
            },
          ),
        ),
      );
    } else if (field is PdfRadioButtonListField) {
      return Card(
        margin: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.radio_button_checked, size: 20),
                  const SizedBox(width: 8),
                  Text(field.name ?? 'Radio Button $index', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 12),
              ...List.generate(field.items.count, (itemIndex) {
                return RadioListTile<String>(
                  title: Text('Option ${itemIndex + 1}'),
                  value: itemIndex.toString(),
                  groupValue: _radioButtonValues[field.name ?? 'radio_$index'],
                  onChanged: (value) {
                    setState(() {
                      _radioButtonValues[field.name ?? 'radio_$index'] = value ?? '0';
                    });
                  },
                );
              }),
            ],
          ),
        ),
      );
    } else if (field is PdfComboBoxField) {
      return Card(
        margin: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.arrow_drop_down_circle, size: 20),
                  const SizedBox(width: 8),
                  Text(field.name ?? 'Combo Box $index', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: List.generate(field.items.count, (itemIndex) => DropdownMenuItem(value: itemIndex.toString(), child: Text(field.items[itemIndex].text))),
                onChanged: (value) {
                  if (value != null) {
                    field.selectedIndex = int.parse(value);
                  }
                },
              ),
            ],
          ),
        ),
      );
    } else {
      return Card(
        margin: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('${field.name ?? 'Field $index'} (${field.runtimeType})', style: const TextStyle(fontStyle: FontStyle.italic)),
        ),
      );
    }
  }
}

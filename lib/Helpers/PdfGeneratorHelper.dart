import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:azimuth_vms/Models/VolunteerForm.dart';
import 'dart:html' as html;

class PdfGeneratorHelper {
  static Future<void> generateAndDownloadPdf(VolunteerForm form) async {
    try {
      // Load the PDF template
      final ByteData data = await rootBundle.load('assets/pdfs/form1.pdf');
      final Uint8List bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      final PdfDocument document = PdfDocument(inputBytes: bytes);

      // Get form
      final PdfForm pdfForm = document.form;

      // Fill form fields
      _setFieldValue(pdfForm, 'Text23', form.formNumber);
      _setFieldValue(pdfForm, 'Text24', form.groupNameAndCode);
      _setFieldValue(pdfForm, 'Text1', form.fullName);
      _setFieldValue(pdfForm, 'Text2', form.education);
      _setFieldValue(pdfForm, 'Text3', form.birthDate);
      _setFieldValue(pdfForm, 'Text4', form.maritalStatus);
      _setFieldValue(pdfForm, 'Text5', form.numberOfChildren);
      _setFieldValue(pdfForm, 'Text6', form.motherName);
      _setFieldValue(pdfForm, 'Text7', form.mobileNumber);
      _setFieldValue(pdfForm, 'Text8', form.currentAddress);
      _setFieldValue(pdfForm, 'Text9', form.nearestLandmark);
      _setFieldValue(pdfForm, 'Text10', form.mukhtarName);
      _setFieldValue(pdfForm, 'Text11', form.civilStatusDirectorate);
      _setFieldValue(pdfForm, 'Text12', form.previousAddress);
      _setFieldValue(pdfForm, 'Text13', form.volunteerParticipationCount);
      _setFieldValue(pdfForm, 'Text14', form.profession);
      _setFieldValue(pdfForm, 'Text15', form.jobTitle);
      _setFieldValue(pdfForm, 'Text16', form.departmentName);
      _setFieldValue(pdfForm, 'Text17', form.politicalAffiliation);
      _setFieldValue(pdfForm, 'Text18', form.talentAndExperience);
      _setFieldValue(pdfForm, 'Text19', form.languages);
      _setFieldValue(pdfForm, 'Text20', form.idCardNumber);
      _setFieldValue(pdfForm, 'Text21', form.recordNumber);
      _setFieldValue(pdfForm, 'Text22', form.pageNumber);
      _setFieldValue(pdfForm, 'Text25', form.rationCardNumber);
      _setFieldValue(pdfForm, 'Text26', form.agentName);
      _setFieldValue(pdfForm, 'Text27', form.supplyCenterNumber);
      _setFieldValue(pdfForm, 'Text28', form.residenceCardNumber);
      _setFieldValue(pdfForm, 'Text29', form.issuer);
      _setFieldValue(pdfForm, 'Text30', form.no);

      // Flatten fields
      pdfForm.flattenAllFields();

      // Save the document
      final List<int> savedBytes = await document.save();
      document.dispose();

      // Download the file
      final blob = html.Blob([Uint8List.fromList(savedBytes)], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final filename = '${form.fullName ?? "volunteer"}_${form.mobileNumber ?? "no_phone"}.pdf';
      final anchor = html.AnchorElement()
        ..href = url
        ..style.display = 'none'
        ..download = filename;
      html.document.body?.children.add(anchor);
      anchor.click();
      html.document.body?.children.remove(anchor);
      html.Url.revokeObjectUrl(url);

      print('PDF generated successfully');
    } catch (e) {
      print('Error generating PDF: $e');
      rethrow;
    }
  }

  static void _setFieldValue(PdfForm pdfForm, String fieldName, String? value) {
    if (value != null && value.isNotEmpty) {
      for (int i = 0; i < pdfForm.fields.count; i++) {
        if (pdfForm.fields[i].name == fieldName) {
          final field = pdfForm.fields[i];
          if (field is PdfTextBoxField) {
            field.text = value;
          }
          break;
        }
      }
    }
  }
}

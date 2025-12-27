import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:azimuth_vms/Models/VolunteerForm.dart';
import 'dart:html' as html; // For web download

class PdfGeneratorHelper {
  static Future<void> generateAndDownloadPdf(VolunteerForm form) async {
    // Load the PDF template
    final ByteData data = await rootBundle.load('assets/pdfs/form1.pdf');
    final Uint8List bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    final PdfDocument document = PdfDocument(inputBytes: bytes);

    // Fill the form
    final PdfForm pdfForm = document.form;

    void setFieldValue(String fieldName, String? value) {
      if (value != null && value.isNotEmpty) {
        try {
          PdfField? field;
          for (int i = 0; i < pdfForm.fields.count; i++) {
            if (pdfForm.fields[i].name == fieldName) {
              field = pdfForm.fields[i];
              break;
            }
          }
          if (field != null && field is PdfTextBoxField) {
            field.text = value;
          }
        } catch (e) {
          print('Error setting field $fieldName: $e');
        }
      }
    }

    // Map fields (same mapping as FormFillPage)
    setFieldValue('Text1', form.formNumber);
    setFieldValue('Text2', form.groupNameAndCode);
    setFieldValue('Text3', form.fullName);
    setFieldValue('Text4', form.education);
    setFieldValue('Text5', form.birthDate);
    setFieldValue('Text6', form.maritalStatus);
    setFieldValue('Text7', form.numberOfChildren);
    setFieldValue('Text8', form.motherName);
    setFieldValue('Text9', form.mobileNumber);
    setFieldValue('Text10', form.currentAddress);
    setFieldValue('Text11', form.nearestLandmark);
    setFieldValue('Text12', form.mukhtarName);
    setFieldValue('Text13', form.civilStatusDirectorate);
    setFieldValue('Text14', form.previousAddress);
    setFieldValue('Text15', form.volunteerParticipationCount);
    setFieldValue('Text16', form.profession);
    setFieldValue('Text17', form.jobTitle);
    setFieldValue('Text18', form.departmentName);
    setFieldValue('Text19', form.politicalAffiliation);
    setFieldValue('Text20', form.talentAndExperience);
    setFieldValue('Text21', form.languages);
    setFieldValue('Text22', form.idCardNumber);
    setFieldValue('Text23', form.recordNumber);
    setFieldValue('Text24', form.pageNumber);
    setFieldValue('Text25', form.rationCardNumber);
    setFieldValue('Text26', form.agentName);
    setFieldValue('Text27', form.supplyCenterNumber);
    setFieldValue('Text28', form.residenceCardNumber);
    setFieldValue('Text29', form.issuer);
    setFieldValue('Text30', form.no);

    // Flatten fields to make them read-only
    pdfForm.flattenAllFields();

    // Save the document
    final List<int> savedBytes = await document.save();
    document.dispose();

    // Download the file (Web specific)
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
  }
}

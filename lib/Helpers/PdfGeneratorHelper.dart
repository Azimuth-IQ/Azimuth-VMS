import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/services.dart' show rootBundle;
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:azimuth_vms/Models/VolunteerForm.dart';
import 'dart:html' as html; // For web download

class PdfGeneratorHelper {
  static Future<void> generateAndDownloadPdf(VolunteerForm form) async {
    try {
      // Load the PDF template
      final ByteData data = await rootBundle.load('assets/pdfs/form1.pdf');
      final Uint8List bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      final PdfDocument document = PdfDocument(inputBytes: bytes);

      // Load Cairo font for Arabic text - this is the correct way per Syncfusion docs
      final ByteData fontData = await rootBundle.load('assets/fonts/Cairo-VariableFont_slnt,wght.ttf');
      final Uint8List fontBytes = fontData.buffer.asUint8List();
      final PdfTrueTypeFont arabicFont = PdfTrueTypeFont(fontBytes, 10);

      // Get the first page to draw text on
      final PdfPage page = document.pages[0];

      // Draw Arabic text using TrueType font (proper way for Arabic per docs)
      _drawTextOnTemplate(page, form, arabicFont);

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

      print('PDF generated successfully with Arabic text support');
    } catch (e) {
      print('Error generating PDF: $e');
      rethrow;
    }
  }

  static void _drawTextOnTemplate(PdfPage page, VolunteerForm form, PdfTrueTypeFont font) {
    // Define text format for Arabic (Right-to-Left) - per Syncfusion documentation
    final PdfStringFormat rtlFormat = PdfStringFormat(textDirection: PdfTextDirection.rightToLeft, alignment: PdfTextAlignment.right);

    final PdfStringFormat ltrFormat = PdfStringFormat(textDirection: PdfTextDirection.leftToRight, alignment: PdfTextAlignment.left);

    // Field positions - adjust these based on your template layout
    // Format: 'fieldName': ui.Rect.fromLTWH(x, y, width, height)
    final Map<String, ui.Rect> fieldBounds = {
      'Text1': ui.Rect.fromLTWH(120, 90, 400, 15), // Form Number
      'Text2': ui.Rect.fromLTWH(120, 110, 400, 15), // Group Name & Code
      'Text3': ui.Rect.fromLTWH(120, 130, 400, 15), // Full Name
      'Text4': ui.Rect.fromLTWH(120, 150, 400, 15), // Education
      'Text5': ui.Rect.fromLTWH(120, 170, 200, 15), // Birth Date
      'Text6': ui.Rect.fromLTWH(120, 190, 200, 15), // Marital Status
      'Text7': ui.Rect.fromLTWH(120, 210, 100, 15), // Number of Children
      'Text8': ui.Rect.fromLTWH(120, 230, 400, 15), // Mother Name
      'Text9': ui.Rect.fromLTWH(120, 250, 200, 15), // Mobile Number
      'Text10': ui.Rect.fromLTWH(120, 270, 400, 15), // Current Address
      'Text11': ui.Rect.fromLTWH(120, 290, 400, 15), // Nearest Landmark
      'Text12': ui.Rect.fromLTWH(120, 310, 300, 15), // Mukhtar Name
      'Text13': ui.Rect.fromLTWH(120, 330, 300, 15), // Civil Status Directorate
      'Text14': ui.Rect.fromLTWH(120, 350, 400, 15), // Previous Address
      'Text15': ui.Rect.fromLTWH(120, 370, 100, 15), // Volunteer Participation Count
      'Text16': ui.Rect.fromLTWH(120, 390, 300, 15), // Profession
      'Text17': ui.Rect.fromLTWH(120, 410, 300, 15), // Job Title
      'Text18': ui.Rect.fromLTWH(120, 430, 300, 15), // Department Name
      'Text19': ui.Rect.fromLTWH(120, 450, 300, 15), // Political Affiliation
      'Text20': ui.Rect.fromLTWH(120, 470, 400, 30), // Talent & Experience
      'Text21': ui.Rect.fromLTWH(120, 505, 300, 15), // Languages
      'Text22': ui.Rect.fromLTWH(120, 525, 200, 15), // ID Card Number
      'Text23': ui.Rect.fromLTWH(120, 545, 200, 15), // Record Number
      'Text24': ui.Rect.fromLTWH(120, 565, 100, 15), // Page Number
      'Text25': ui.Rect.fromLTWH(120, 585, 200, 15), // Ration Card Number
      'Text26': ui.Rect.fromLTWH(120, 605, 300, 15), // Agent Name
      'Text27': ui.Rect.fromLTWH(120, 625, 200, 15), // Supply Center Number
      'Text28': ui.Rect.fromLTWH(120, 645, 200, 15), // Residence Card Number
      'Text29': ui.Rect.fromLTWH(120, 665, 300, 15), // Issuer
      'Text30': ui.Rect.fromLTWH(120, 685, 100, 15), // No
    };

    // Helper function to check if text contains Arabic characters
    bool containsArabic(String? text) {
      if (text == null || text.isEmpty) return false;
      return text.runes.any((rune) => rune >= 0x0600 && rune <= 0x06FF);
    }

    // Helper function to draw text with proper formatting
    void drawText(String key, String? value) {
      if (value != null && value.isNotEmpty && fieldBounds.containsKey(key)) {
        final isArabic = containsArabic(value);
        page.graphics.drawString(value, font, brush: PdfBrushes.black, bounds: fieldBounds[key]!, format: isArabic ? rtlFormat : ltrFormat);
      }
    }

    // Draw all form fields
    drawText('Text1', form.formNumber);
    drawText('Text2', form.groupNameAndCode);
    drawText('Text3', form.fullName);
    drawText('Text4', form.education);
    drawText('Text5', form.birthDate);
    drawText('Text6', form.maritalStatus);
    drawText('Text7', form.numberOfChildren);
    drawText('Text8', form.motherName);
    drawText('Text9', form.mobileNumber);
    drawText('Text10', form.currentAddress);
    drawText('Text11', form.nearestLandmark);
    drawText('Text12', form.mukhtarName);
    drawText('Text13', form.civilStatusDirectorate);
    drawText('Text14', form.previousAddress);
    drawText('Text15', form.volunteerParticipationCount);
    drawText('Text16', form.profession);
    drawText('Text17', form.jobTitle);
    drawText('Text18', form.departmentName);
    drawText('Text19', form.politicalAffiliation);
    drawText('Text20', form.talentAndExperience);
    drawText('Text21', form.languages);
    drawText('Text22', form.idCardNumber);
    drawText('Text23', form.recordNumber);
    drawText('Text24', form.pageNumber);
    drawText('Text25', form.rationCardNumber);
    drawText('Text26', form.agentName);
    drawText('Text27', form.supplyCenterNumber);
    drawText('Text28', form.residenceCardNumber);
    drawText('Text29', form.issuer);
    drawText('Text30', form.no);
  }
}

import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:azimuth_vms/Models/VolunteerForm.dart';

class PDFServiceAPIHelper {
  static const String _baseUrl = 'https://volunteer-register-393889560496.europe-west1.run.app';
  static const String _loginPhone = '07705371953';
  static const String _loginPassword = 'root';

  // Session cookie storage
  static String? _sessionCookie;

  /// Authenticate with the PDF generation service
  static Future<bool> _authenticate() async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'phone': _loginPhone, 'password': _loginPassword},
      );

      if (response.statusCode == 200 || response.statusCode == 303) {
        // Extract session cookie
        final setCookie = response.headers['set-cookie'];
        if (setCookie != null) {
          _sessionCookie = setCookie.split(';')[0]; // Get only the session cookie
          print('PDF Service authenticated successfully');
          return true;
        }
      }

      print('PDF Service authentication failed: ${response.statusCode}');
      return false;
    } catch (e) {
      print('Error authenticating with PDF service: $e');
      return false;
    }
  }

  /// Map VolunteerForm to API format (Text1-Text30)
  static Map<String, String> _mapFormToAPIFormat(VolunteerForm form) {
    return {
      'text1': form.formNumber ?? '',
      'text2': form.groupNameAndCode ?? '',
      'text3': form.fullName ?? '',
      'text4': form.education ?? '',
      'text5': form.birthDate ?? '',
      'text6': form.maritalStatus ?? '',
      'text7': form.numberOfChildren ?? '',
      'text8': form.motherName ?? '',
      'text9': form.mobileNumber ?? '',
      'text10': form.currentAddress ?? '',
      'text11': form.nearestLandmark ?? '',
      'text12': form.mukhtarName ?? '',
      'text13': form.civilStatusDirectorate ?? '',
      'text14': form.previousAddress ?? '',
      'text15': form.volunteerParticipationCount ?? '',
      'text16': form.profession ?? '',
      'text17': form.jobTitle ?? '',
      'text18': form.departmentName ?? '',
      'text19': form.politicalAffiliation ?? '',
      'text20': form.talentAndExperience ?? '',
      'text21': form.languages ?? '',
      'text22': form.idCardNumber ?? '',
      'text23': form.recordNumber ?? '',
      'text24': form.pageNumber ?? '',
      'text25': form.rationCardNumber ?? '',
      'text26': form.agentName ?? '',
      'text27': form.supplyCenterNumber ?? '',
      'text28': form.residenceCardNumber ?? '',
      'text29': form.issuer ?? '',
      'text30': form.no ?? '',
    };
  }

  /// Create a new volunteer in the PDF service and get the ID
  static Future<int?> _createVolunteerInAPI(VolunteerForm form) async {
    try {
      // Ensure authenticated
      if (_sessionCookie == null) {
        final authenticated = await _authenticate();
        if (!authenticated) return null;
      }

      final formData = _mapFormToAPIFormat(form);

      // Create multipart request
      var request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/new'));
      request.headers['Cookie'] = _sessionCookie!;

      // Add all form fields
      formData.forEach((key, value) {
        request.fields[key] = value;
      });

      // TODO: Add photo if available from Firebase Storage
      // Download photo from Firebase Storage and attach it

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 303 || response.statusCode == 200) {
        // Extract volunteer ID from redirect location
        final location = response.headers['location'];
        if (location != null && location.contains('/edit/')) {
          final idStr = location.split('/edit/').last;
          return int.tryParse(idStr);
        }
      }

      print('Failed to create volunteer in API: ${response.statusCode}');
      return null;
    } catch (e) {
      print('Error creating volunteer in API: $e');
      return null;
    }
  }

  /// Generate PDF from the API service
  static Future<Uint8List?> _downloadPDFFromAPI(int volunteerId) async {
    try {
      // Ensure authenticated
      if (_sessionCookie == null) {
        final authenticated = await _authenticate();
        if (!authenticated) return null;
      }

      final response = await http.get(Uri.parse('$_baseUrl/pdf/$volunteerId'), headers: {'Cookie': _sessionCookie!});

      if (response.statusCode == 200) {
        print('PDF downloaded successfully from API');
        return response.bodyBytes;
      }

      print('Failed to download PDF from API: ${response.statusCode}');
      return null;
    } catch (e) {
      print('Error downloading PDF from API: $e');
      return null;
    }
  }

  /// Upload PDF to Firebase Storage
  static Future<String?> _uploadPDFToStorage(Uint8List pdfBytes, String fileName) async {
    try {
      final storageRef = FirebaseStorage.instance.ref();
      final pdfRef = storageRef.child('pdfs/$fileName');

      // Upload with metadata
      final metadata = SettableMetadata(contentType: 'application/pdf', customMetadata: {'generatedAt': DateTime.now().toIso8601String()});

      await pdfRef.putData(pdfBytes, metadata);

      // Get download URL
      final downloadUrl = await pdfRef.getDownloadURL();
      print('PDF uploaded to Firebase Storage: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('Error uploading PDF to Firebase Storage: $e');
      return null;
    }
  }

  /// Generate PDF for a volunteer form and save to Firebase Storage
  /// Returns the Firebase Storage download URL
  static Future<String?> generateAndSavePDF(VolunteerForm form, {bool regenerate = false}) async {
    try {
      print('Starting PDF generation for mobile: ${form.mobileNumber}');

      // Create volunteer in the PDF service
      final volunteerId = await _createVolunteerInAPI(form);
      if (volunteerId == null) {
        print('Failed to create volunteer in PDF service');
        return null;
      }

      print('Volunteer created in PDF service with ID: $volunteerId');

      // Generate PDF from the API
      final pdfBytes = await _downloadPDFFromAPI(volunteerId);
      if (pdfBytes == null) {
        print('Failed to download PDF from API');
        return null;
      }

      // Create filename based on form data
      final sanitizedName = (form.fullName ?? form.mobileNumber ?? 'volunteer').replaceAll(' ', '_').replaceAll('/', '_').replaceAll('\\', '_').replaceAll(':', '_');

      final timestamp = regenerate ? '_${DateTime.now().millisecondsSinceEpoch}' : '';
      final fileName = '${sanitizedName}$timestamp.pdf';

      // Upload to Firebase Storage
      final downloadUrl = await _uploadPDFToStorage(pdfBytes, fileName);

      if (downloadUrl != null) {
        print('PDF generation complete. URL: $downloadUrl');
      }

      return downloadUrl;
    } catch (e) {
      print('Error in generateAndSavePDF: $e');
      return null;
    }
  }

  /// Generate QR code for a volunteer (for future use)
  static Future<Uint8List?> generateQRCode(int volunteerId) async {
    try {
      // Ensure authenticated
      if (_sessionCookie == null) {
        final authenticated = await _authenticate();
        if (!authenticated) return null;
      }

      final response = await http.get(Uri.parse('$_baseUrl/qr/$volunteerId'), headers: {'Cookie': _sessionCookie!});

      if (response.statusCode == 200) {
        return response.bodyBytes;
      }

      return null;
    } catch (e) {
      print('Error generating QR code: $e');
      return null;
    }
  }

  /// Clear session (logout)
  static void clearSession() {
    _sessionCookie = null;
  }
}

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
      print('🔐 [PDF AUTH] Starting authentication...');
      print('🔐 [PDF AUTH] URL: $_baseUrl/login');
      print('🔐 [PDF AUTH] Phone: $_loginPhone');

      // Properly encode form data
      final formData = 'phone=${Uri.encodeComponent(_loginPhone)}&password=${Uri.encodeComponent(_loginPassword)}';
      print('🔐 [PDF AUTH] Form data: $formData');

      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': '*/*',
        },
        body: formData,
      );

      print('🔐 [PDF AUTH] Response Status: ${response.statusCode}');
      print('🔐 [PDF AUTH] Response Headers: ${response.headers}');
      print('🔐 [PDF AUTH] Response Body: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}...');

      if (response.statusCode == 200 || response.statusCode == 303) {
        // Extract session cookie
        final setCookie = response.headers['set-cookie'];
        if (setCookie != null) {
          _sessionCookie = setCookie.split(';')[0]; // Get only the session cookie
          print('✅ [PDF AUTH] Authentication successful! Cookie: ${_sessionCookie?.substring(0, 30)}...');
          return true;
        } else {
          print('❌ [PDF AUTH] No set-cookie header in response');
        }
      }

      print('❌ [PDF AUTH] Authentication failed: ${response.statusCode}');
      return false;
    } catch (e, stackTrace) {
      print('❌ [PDF AUTH] Error authenticating: $e');
      print('❌ [PDF AUTH] Stack trace: $stackTrace');
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
      print('👤 [CREATE VOLUNTEER] Starting volunteer creation...');
      print('👤 [CREATE VOLUNTEER] Name: ${form.fullName}, Mobile: ${form.mobileNumber}');

      // Ensure authenticated
      if (_sessionCookie == null) {
        print('👤 [CREATE VOLUNTEER] No session cookie, authenticating...');
        final authenticated = await _authenticate();
        if (!authenticated) {
          print('❌ [CREATE VOLUNTEER] Authentication failed');
          return null;
        }
      }

      final formData = _mapFormToAPIFormat(form);
      print('👤 [CREATE VOLUNTEER] Form data fields: ${formData.keys.length}');

      // Create multipart request
      var request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/new'));
      request.headers['Cookie'] = _sessionCookie!;

      // Add all form fields
      formData.forEach((key, value) {
        request.fields[key] = value;
      });

      print('👤 [CREATE VOLUNTEER] Sending POST request to $_baseUrl/new');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('👤 [CREATE VOLUNTEER] Response Status: ${response.statusCode}');
      print('👤 [CREATE VOLUNTEER] Response Headers: ${response.headers}');

      if (response.statusCode == 303 || response.statusCode == 200) {
        // Extract volunteer ID from redirect location
        final location = response.headers['location'];
        print('👤 [CREATE VOLUNTEER] Redirect location: $location');

        if (location != null && location.contains('/edit/')) {
          final idStr = location.split('/edit/').last;
          final id = int.tryParse(idStr);
          print('✅ [CREATE VOLUNTEER] Created successfully with ID: $id');
          return id;
        }
      }

      print('❌ [CREATE VOLUNTEER] Failed: ${response.statusCode}');
      print('❌ [CREATE VOLUNTEER] Response body: ${response.body}');
      return null;
    } catch (e, stackTrace) {
      print('❌ [CREATE VOLUNTEER] Error: $e');
      print('❌ [CREATE VOLUNTEER] Stack trace: $stackTrace');
      return null;
    }
  }

  /// Generate PDF from the API service
  static Future<Uint8List?> _downloadPDFFromAPI(int volunteerId) async {
    try {
      print('📄 [DOWNLOAD PDF] Starting PDF download for volunteer ID: $volunteerId');

      // Ensure authenticated
      if (_sessionCookie == null) {
        print('📄 [DOWNLOAD PDF] No session cookie, authenticating...');
        final authenticated = await _authenticate();
        if (!authenticated) {
          print('❌ [DOWNLOAD PDF] Authentication failed');
          return null;
        }
      }

      print('📄 [DOWNLOAD PDF] Requesting: $_baseUrl/pdf/$volunteerId');
      final response = await http.get(Uri.parse('$_baseUrl/pdf/$volunteerId'), headers: {'Cookie': _sessionCookie!});

      print('📄 [DOWNLOAD PDF] Response Status: ${response.statusCode}');
      print('📄 [DOWNLOAD PDF] Response Size: ${response.bodyBytes.length} bytes');

      if (response.statusCode == 200) {
        print('✅ [DOWNLOAD PDF] PDF downloaded successfully (${(response.bodyBytes.length / 1024).toStringAsFixed(2)} KB)');
        return response.bodyBytes;
      }

      print('❌ [DOWNLOAD PDF] Failed: ${response.statusCode}');
      return null;
    } catch (e, stackTrace) {
      print('❌ [DOWNLOAD PDF] Error: $e');
      print('❌ [DOWNLOAD PDF] Stack trace: $stackTrace');
      return null;
    }
  }

  /// Upload PDF to Firebase Storage
  static Future<String?> _uploadPDFToStorage(Uint8List pdfBytes, String fileName) async {
    try {
      print('☁️ [FIREBASE UPLOAD] Starting upload to Firebase Storage');
      print('☁️ [FIREBASE UPLOAD] File name: $fileName');
      print('☁️ [FIREBASE UPLOAD] File size: ${(pdfBytes.length / 1024).toStringAsFixed(2)} KB');

      final storageRef = FirebaseStorage.instance.ref();
      final pdfRef = storageRef.child('pdfs/$fileName');

      // Upload with metadata
      final metadata = SettableMetadata(contentType: 'application/pdf', customMetadata: {'generatedAt': DateTime.now().toIso8601String()});

      print('☁️ [FIREBASE UPLOAD] Uploading to path: pdfs/$fileName');
      await pdfRef.putData(pdfBytes, metadata);

      // Get download URL
      final downloadUrl = await pdfRef.getDownloadURL();
      print('✅ [FIREBASE UPLOAD] Upload successful!');
      print('✅ [FIREBASE UPLOAD] Download URL: $downloadUrl');
      return downloadUrl;
    } catch (e, stackTrace) {
      print('❌ [FIREBASE UPLOAD] Error: $e');
      print('❌ [FIREBASE UPLOAD] Stack trace: $stackTrace');
      return null;
    }
  }

  /// Generate PDF for a volunteer form and save to Firebase Storage
  /// Returns the Firebase Storage download URL
  static Future<String?> generateAndSavePDF(VolunteerForm form, {bool regenerate = false}) async {
    try {
      print('═══════════════════════════════════════');
      print('🚀 [PDF GENERATION] Starting PDF generation process');
      print('🚀 [PDF GENERATION] Mobile: ${form.mobileNumber}');
      print('🚀 [PDF GENERATION] Name: ${form.fullName}');
      print('🚀 [PDF GENERATION] Regenerate: $regenerate');
      print('═══════════════════════════════════════');

      // Create volunteer in the PDF service
      final volunteerId = await _createVolunteerInAPI(form);
      if (volunteerId == null) {
        print('❌ [PDF GENERATION] Failed to create volunteer in PDF service');
        return null;
      }

      print('✅ [PDF GENERATION] Volunteer created with ID: $volunteerId');

      // Generate PDF from the API
      final pdfBytes = await _downloadPDFFromAPI(volunteerId);
      if (pdfBytes == null) {
        print('❌ [PDF GENERATION] Failed to download PDF from API');
        return null;
      }

      // Create filename based on form data
      final sanitizedName = (form.fullName ?? form.mobileNumber ?? 'volunteer').replaceAll(' ', '_').replaceAll('/', '_').replaceAll('\\', '_').replaceAll(':', '_');

      final timestamp = regenerate ? '_${DateTime.now().millisecondsSinceEpoch}' : '';
      final fileName = '${sanitizedName}$timestamp.pdf';

      // Upload to Firebase Storage
      final downloadUrl = await _uploadPDFToStorage(pdfBytes, fileName);

      if (downloadUrl != null) {
        print('═══════════════════════════════════════');
        print('✅ [PDF GENERATION] COMPLETE!');
        print('✅ [PDF GENERATION] URL: $downloadUrl');
        print('═══════════════════════════════════════');
      } else {
        print('❌ [PDF GENERATION] Failed to upload to Firebase Storage');
      }

      return downloadUrl;
    } catch (e, stackTrace) {
      print('═══════════════════════════════════════');
      print('❌ [PDF GENERATION] FATAL ERROR');
      print('❌ [PDF GENERATION] Error: $e');
      print('❌ [PDF GENERATION] Stack trace: $stackTrace');
      print('═══════════════════════════════════════');
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

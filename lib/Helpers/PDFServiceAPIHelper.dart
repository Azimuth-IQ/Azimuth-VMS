import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:azimuth_vms/Models/VolunteerForm.dart';

class PDFServiceAPIHelper {
  static const String _baseUrl = 'https://volunteer-register-393889560496.europe-west1.run.app';

  /// Check if API is healthy
  static Future<bool> checkHealth() async {
    try {
      print('🏥 [HEALTH CHECK] Checking API health...');
      final response = await http.get(Uri.parse('$_baseUrl/health'));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final isHealthy = data['status'] == 'healthy' && data['template_available'] == true;
        print(isHealthy 
          ? '✅ [HEALTH CHECK] API is healthy!' 
          : '⚠️ [HEALTH CHECK] API responded but not healthy');
        return isHealthy;
      }
      
      print('❌ [HEALTH CHECK] API returned ${response.statusCode}');
      return false;
    } catch (e) {
      print('❌ [HEALTH CHECK] Error: $e');
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
      print('☁️ [FIREBASE] Starting upload to Firebase Storage');
      print('☁️ [FIREBASE] File name: $fileName');
      print('☁️ [FIREBASE] File size: ${(pdfBytes.length / 1024).toStringAsFixed(2)} KB');

      final storageRef = FirebaseStorage.instance.ref();
      final pdfRef = storageRef.child('pdfs/$fileName');

      // Upload with metadata
      final metadata = SettableMetadata(
        contentType: 'application/pdf',
        customMetadata: {
          'generatedAt': DateTime.now().toIso8601String(),
        },
      );

      print('☁️ [FIREBASE] Uploading to path: pdfs/$fileName');
      await pdfRef.putData(pdfBytes, metadata);

      // Get download URL
      final downloadUrl = await pdfRef.getDownloadURL();
      print('✅ [FIREBASE] Upload successful!');
      print('✅ [FIREBASE] Download URL: ${downloadUrl.substring(0, 100)}...');
      return downloadUrl;
    } catch (e, stackTrace) {
      print('❌ [FIREBASE] Error: $e');
      print('❌ [FIREBASE] Stack trace: $stackTrace');
      return null;
    }
  }

  /// Generate PDF for a volunteer form and save to Firebase Storage
  /// Returns the Firebase Storage download URL
  static Future<String?> generateAndSavePDF(VolunteerForm form, {bool regenerate = false}) async {
    try {
      print('═══════════════════════════════════════');
      print('🚀 [PDF GENERATION] Starting PDF generation');
      print('🚀 [PDF GENERATION] Mobile: ${form.mobileNumber}');
      print('🚀 [PDF GENERATION] Name: ${form.fullName}');
      print('🚀 [PDF GENERATION] Regenerate: $regenerate');
      print('═══════════════════════════════════════');

      // Generate PDF from new API
      final result = await _generatePDFFromAPI(form);
      if (result == null || result['success'] != true) {
        final errorMsg = result?['error'] ?? 'Unknown error';
        final errorCode = result?['errorCode'] ?? 'UNKNOWN';
        print('❌ [PDF GENERATION] Failed: $errorMsg (Code: $errorCode)');
        return null;
      }

      final pdfBytes = result['pdfBytes'] as Uint8List;
      final apiFilename = result['filename'] as String;

      // Create filename for Firebase Storage
      final timestamp = regenerate ? '_${DateTime.now().millisecondsSinceEpoch}' : '';
      final fileName = apiFilename.replaceAll('.pdf', '$timestamp.pdf');

      print('✅ [PDF GENERATION] PDF generated from API');
      print('✅ [PDF GENERATION] Size: ${(pdfBytes.length / 1024).toStringAsFixed(2)} KB');

      // Upload to Firebase Storage
      final downloadUrl = await _uploadPDFToStorage(pdfBytes, fileName);

      if (downloadUrl != null) {
        print('═══════════════════════════════════════');
        print('✅ [PDF GENERATION] COMPLETE!');
        print('✅ [PDF GENERATION] URL: ${downloadUrl.substring(0, 100)}...');
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
}

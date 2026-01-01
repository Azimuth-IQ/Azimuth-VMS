import 'dart:convert';
import 'dart:typed_data';
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
        print(isHealthy ? '✅ [HEALTH CHECK] API is healthy!' : '⚠️ [HEALTH CHECK] API responded but not healthy');
        return isHealthy;
      }

      print('❌ [HEALTH CHECK] API returned ${response.statusCode}');
      return false;
    } catch (e) {
      print('❌ [HEALTH CHECK] Error: $e');
      return false;
    }
  }

  /// Map VolunteerForm to JSON for new API
  static Map<String, dynamic> _mapFormToJSON(VolunteerForm form) {
    return {
      'fullName': form.fullName ?? '',
      'formNumber': form.formNumber ?? '',
      'groupNameAndCode': form.groupNameAndCode ?? '',
      'education': form.education ?? '',
      'birthDate': form.birthDate ?? '',
      'maritalStatus': form.maritalStatus ?? '',
      'numberOfChildren': form.numberOfChildren ?? '',
      'motherName': form.motherName ?? '',
      'phoneNumber': form.mobileNumber ?? '',
      'currentAddress': form.currentAddress ?? '',
      'nearestLandmark': form.nearestLandmark ?? '',
      'mukhtarName': form.mukhtarName ?? '',
      'civilStatusDirectorate': form.civilStatusDirectorate ?? '',
      'previousAddress': form.previousAddress ?? '',
      'volunteerParticipationCount': form.volunteerParticipationCount ?? '',
      'profession': form.profession ?? '',
      'jobTitle': form.jobTitle ?? '',
      'departmentName': form.departmentName ?? '',
      'politicalAffiliation': form.politicalAffiliation ?? '',
      'talentAndExperience': form.talentAndExperience ?? '',
      'languages': form.languages ?? '',
      'idCardNumber': form.idCardNumber ?? '',
      'recordNumber': form.recordNumber ?? '',
      'pageNumber': form.pageNumber ?? '',
      'rationCardNumber': form.rationCardNumber ?? '',
      'agentName': form.agentName ?? '',
      'supplyCenterNumber': form.supplyCenterNumber ?? '',
      'residenceCardNumber': form.residenceCardNumber ?? '',
      'issuer': form.issuer ?? '',
      'no': form.no ?? '',
    };
  }

  /// Generate PDF using new simplified API
  static Future<Map<String, dynamic>?> _generatePDFFromAPI(VolunteerForm form) async {
    try {
      print('📄 [PDF API] Starting PDF generation...');
      print('📄 [PDF API] Name: ${form.fullName}, Mobile: ${form.mobileNumber}');

      // Create multipart request
      var request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/generate-pdf'));

      // Add volunteer data as JSON string
      final volunteerData = _mapFormToJSON(form);
      request.fields['volunteer_data'] = jsonEncode(volunteerData);
      
      print('📄 [PDF API] Volunteer data: ${jsonEncode(volunteerData).substring(0, 200)}...');

      // TODO: Add photo if available in VolunteerForm
      // if (form.photoPath != null && form.photoPath!.isNotEmpty) {
      //   final photoFile = File(form.photoPath!);
      //   if (await photoFile.exists()) {
      //     request.files.add(await http.MultipartFile.fromPath('photo', form.photoPath!));
      //     print('📄 [PDF API] Added photo: ${form.photoPath}');
      //   }
      // }

      print('📄 [PDF API] Sending POST request to $_baseUrl/generate-pdf');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('📄 [PDF API] Response Status: ${response.statusCode}');
      print('📄 [PDF API] Response Size: ${response.body.length} bytes');

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        
        if (result['success'] == true && result['pdf_base64'] != null) {
          print('✅ [PDF API] PDF generated successfully!');
          print('✅ [PDF API] Filename: ${result['filename']}');
          print('✅ [PDF API] Size: ${(result['file_size_bytes'] / 1024).toStringAsFixed(2)} KB');
          
          return {
            'success': true,
            'pdfBytes': base64Decode(result['pdf_base64']),
            'filename': result['filename'],
            'fileSize': result['file_size_bytes'],
            'generatedAt': result['generated_at'],
          };
        }
      }

      // Handle error response
      try {
        final error = jsonDecode(response.body);
        print('❌ [PDF API] Error: ${error['error']}');
        print('❌ [PDF API] Error Code: ${error['error_code']}');
        return {
          'success': false,
          'error': error['error'] ?? 'Unknown error',
          'errorCode': error['error_code'] ?? 'UNKNOWN',
        };
      } catch (_) {
        print('❌ [PDF API] Failed: ${response.statusCode}');
        print('❌ [PDF API] Body: ${response.body}');
        return {
          'success': false,
          'error': 'HTTP ${response.statusCode}',
          'errorCode': 'HTTP_ERROR',
        };
      }
    } catch (e, stackTrace) {
      print('❌ [PDF API] Error: $e');
      print('❌ [PDF API] Stack trace: $stackTrace');
      return {
        'success': false,
        'error': e.toString(),
        'errorCode': 'NETWORK_ERROR',
      };
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
      final metadata = SettableMetadata(contentType: 'application/pdf', customMetadata: {'generatedAt': DateTime.now().toIso8601String()});

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

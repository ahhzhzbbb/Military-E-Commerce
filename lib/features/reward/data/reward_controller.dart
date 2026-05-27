import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:military_e_commerce/core/api/api_client.dart';
import 'package:military_e_commerce/core/constants/api_constants.dart';

class RewardController {
  // This class can be used to manage the state and logic related to rewards.
  // For example, you can add methods to fetch rewards from an API, calculate points, etc.

  // Example method to fetch rewards (this is just a placeholder)
  final ApiClient apiClient = ApiClient();

  bool isLoading = true;
  String? error;

  Future<void> uploadFile(PlatformFile file) async {
    isLoading = true;
    error = null;

    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.uploadFile}');
      var request = http.MultipartRequest('POST', uri);
      
      // Add file to the request
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path!,
          filename: file.name,
        ),
      );
      
      // Add authorization header if token exists
      if (apiClient.isLoggedIn) {
        final token = await apiClient.getAccessToken();
        if (token != null) {
          request.headers['Authorization'] = 'Bearer $token';
        }
      }

      final response = await request.send();
      
      if (response.statusCode != 200 && response.statusCode != 201) {
        error = 'Upload failed with status code: ${response.statusCode}';
      }
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
    }
  }
}
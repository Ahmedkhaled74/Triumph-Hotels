import 'package:triumph_hotels/models/user_model.dart';
import 'package:triumph_hotels/services/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();
  final String _tokenKey = 'auth_token';

  // 1.1 Register
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    final response = await _apiClient.post(
      '/auth/register/',
      body: {
        'email': email,
        'password': password,
        'first_name': firstName,
        'last_name': lastName,
      },
    );
    
    if (response != null && response['token'] != null) {
      await _saveToken(response['token']);
    }
    return response;
  }

  // 1.2 Login
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      '/auth/login/',
      body: {
        'email': email,
        'password': password,
      },
    );

    if (response != null && response['token'] != null) {
      await _saveToken(response['token']);
    }
    return response;
  }

  // 1.3 Logout
  Future<void> logout() async {
    try {
      await _apiClient.post('/auth/logout/');
    } finally {
      // Always remove token locally even if API fails
      await _removeToken();
    }
  }

  // 1.4 Get Profile
  Future<UserModel> getProfile() async {
    final response = await _apiClient.get('/auth/profile/');
    return UserModel.fromJson(response);
  }

  Future<UserModel> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? nationality,
    String? avatarPath,
  }) async {
    if (avatarPath != null && avatarPath.isNotEmpty) {
      final Map<String, String> fields = {};
      if (firstName != null) fields['first_name'] = firstName;
      if (lastName != null) fields['last_name'] = lastName;
      if (phone != null) fields['phone'] = phone;
      if (nationality != null) fields['nationality'] = nationality;

      final response = await _apiClient.patchMultipart(
        '/auth/profile/',
        fields: fields,
        fileField: 'avatar',
        filePath: avatarPath,
      );
      return UserModel.fromJson(response);
    } else {
      final Map<String, dynamic> body = {};
      if (firstName != null) body['first_name'] = firstName;
      if (lastName != null) body['last_name'] = lastName;
      if (phone != null) body['phone'] = phone;
      if (nationality != null) body['nationality'] = nationality;

      final response = await _apiClient.patch(
        '/auth/profile/',
        body: body,
      );
      return UserModel.fromJson(response);
    }
  }

  // Token Management Helpers
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<void> _removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }
}

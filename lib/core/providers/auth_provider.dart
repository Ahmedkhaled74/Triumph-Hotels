import 'package:flutter/material.dart';
import 'package:triumph_hotels/models/user_model.dart';
import 'package:triumph_hotels/services/auth_service.dart';
import 'package:triumph_hotels/services/api_client.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider() {
    _loadUser();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  Future<void> _loadUser() async {
    final token = await _authService.getToken();
    if (token != null && token.isNotEmpty) {
      await fetchProfile();
    }
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _setError(null);
    try {
      await _authService.login(email: email, password: password);
      await fetchProfile();
      return true;
    } on ApiException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('An unexpected error occurred.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      await _authService.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      );
      await fetchProfile();
      return true;
    } on ApiException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('An unexpected error occurred.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchProfile() async {
    _setLoading(true);
    _setError(null);
    try {
      _currentUser = await _authService.getProfile();
    } catch (e) {
      _currentUser = null;
      await _authService.logout(); // Clear invalid token
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      await _authService.logout();
    } catch (e) {
      // Ignore error on logout
    } finally {
      _currentUser = null;
      _setLoading(false);
    }
  }

  Future<bool> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? nationality,
    String? avatarPath,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      _currentUser = await _authService.updateProfile(
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        nationality: nationality,
        avatarPath: avatarPath,
      );
      return true;
    } on ApiException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('An unexpected error occurred.');
      return false;
    } finally {
      _setLoading(false);
    }
  }
}

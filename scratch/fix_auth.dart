import 'dart:io';

void main() {
  final file = File(r'd:\mytest_app\Mobile App\lib\core\providers\guest_portal_provider.dart');
  var content = file.readAsStringSync();

  if (!content.contains('void logout(')) {
    final logoutMethod = '''
  // ─── Logout ────────────────────────────────────────────────────────────────
  
  Future<void> logout() async {
    await _service.clearSession();
    _sessionId = null;
    _guestInfo = null;
    _requests = [];
    _foodOrders = [];
    _laundryOrders = [];
    _notificationsList = [];
    _unreadNotificationsCount = 0;
    _chatMessages = [];
    _unreadChatCount = 0;
    _stopListeningToEvents();
    notifyListeners();
  }

  void _checkAuthError(dynamic e) {
    if (e is ApiException && (e.statusCode == 401 || e.statusCode == 403)) {
      logout();
    }
  }
''';
    final lastBraceIdx = content.lastIndexOf('}');
    content = content.substring(0, lastBraceIdx) + logoutMethod + content.substring(lastBraceIdx);
  }

  content = content.replaceAllMapped(RegExp(r'(catch\s*\(\s*([a-zA-Z0-9_]+)\s*\)\s*\{)'), (match) {
    if (match.group(2) == '_') return match.group(0)!; // ignore catch (_)
    return '${match.group(0)}\n      _checkAuthError(${match.group(2)});';
  });

  file.writeAsStringSync(content);
  print('Updated guest_portal_provider.dart successfully');
}

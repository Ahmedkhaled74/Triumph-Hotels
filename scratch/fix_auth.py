import re

path = r"d:\mytest_app\Mobile App\lib\core\providers\guest_portal_provider.dart"

with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

# Add logout method if it doesn't exist
if 'void logout(' not in content:
    logout_method = """
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
"""
    # Insert before last closing brace
    last_brace_idx = content.rfind('}')
    content = content[:last_brace_idx] + logout_method + content[last_brace_idx:]

# Regex to find catch blocks
# We want to insert `_checkAuthError(e);` at the beginning of catch blocks
# e.g., catch (e) {
# e.g., on ApiException catch (e) {

def replacer(match):
    prefix = match.group(1) # e.g., `catch (e) {` or `on ApiException catch (e) {`
    return prefix + "\n      _checkAuthError(e);"

content = re.sub(r'(catch\s*\(\s*([a-zA-Z0-9_]+)\s*\)\s*\{)', replacer, content)

with open(path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Updated guest_portal_provider.dart")

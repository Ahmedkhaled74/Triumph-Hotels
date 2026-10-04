import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:triumph_hotels/services/guest_portal_service.dart';
import 'package:triumph_hotels/core/providers/guest_portal_provider.dart';

void main() {
  test('Test requests and transport', () async {
    SharedPreferences.setMockInitialValues({'guest_session_id': 'test_session'}); // We might need a real session ID?
    // Let's just create a new GuestPortalService and login to get a real session.
    final service = GuestPortalService();
    try {
      final session = await service.loginGuest(
        hotelId: '2', // Example hotel ID
        roomNumber: '101',
        lastName: 'Test',
      );
      print('Session created: ${session['sessionId']}');
      
      final requests = await service.fetchRequests();
      print('Total requests: ${requests.length}');
      
      if (requests.isNotEmpty) {
        print('Recent request: ${requests.first}');
      }
      
      // Now let's try creating a transport request
      print('Creating transport request...');
      try {
        await service.requestTransportation(
          vehicleId: '1',
          destination: 'Airport',
          pickupTime: DateTime.now().toIso8601String(),
          passengers: 2,
        );
        print('Transport request succeeded!');
      } catch (e) {
        print('Transport request failed: $e');
      }
      
      final updatedRequests = await service.fetchRequests();
      print('Total requests after: ${updatedRequests.length}');
      if (updatedRequests.length > requests.length) {
         print('New request added: ${updatedRequests.first}');
      } else {
         print('No new request was added to the history.');
      }
      
    } catch (e) {
      print('Test failed: $e');
    }
  });
}

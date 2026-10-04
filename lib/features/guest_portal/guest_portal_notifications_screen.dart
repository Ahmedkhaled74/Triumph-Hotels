import 'package:flutter/material.dart';
import 'package:triumph_hotels/core/utils/app_translations.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:triumph_hotels/core/providers/guest_portal_provider.dart';
import 'package:triumph_hotels/core/constants/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:triumph_hotels/features/guest_portal/guest_portal_requests_screen.dart';

class GuestPortalNotificationsScreen extends StatefulWidget {
  const GuestPortalNotificationsScreen({super.key});

  @override
  State<GuestPortalNotificationsScreen> createState() => _GuestPortalNotificationsScreenState();
}

class _GuestPortalNotificationsScreenState extends State<GuestPortalNotificationsScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch latest notifications on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GuestPortalProvider>().fetchNotifications();
    });
  }

  String _formatTime(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    final date = DateTime.tryParse(dateStr);
    if (date == null) return '';
    // E.g., '12:15 PM, Jul 25'
    return DateFormat('h:mm a, MMM d').format(date.toLocal());
  }

  IconData _getIconForType(String? type) {
    switch (type) {
      case 'ticket_status':
        return Icons.build_circle_rounded;
      case 'order_status':
        return Icons.restaurant_menu_rounded;
      case 'laundry_status':
        return Icons.local_laundry_service_rounded;
      case 'chat_message':
        return Icons.chat_bubble_rounded;
      default:
        return Icons.notifications_active_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<GuestPortalProvider>();
    final notifications = provider.notificationsList;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notifications'.tr(context),
          style: GoogleFonts.playfairDisplay(
            color: AppColors.primary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (notifications.isNotEmpty && provider.unreadNotificationsCount > 0)
            TextButton(
              onPressed: () {
                provider.markAllNotificationsAsRead();
              },
              child: Text(
                'Mark all read'.tr(context),
                style: GoogleFonts.roboto(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: theme.dividerColor,
            height: 1.0,
          ),
        ),
      ),
      body: notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_rounded,
                    size: 80,
                    color: theme.dividerColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No notifications yet'.tr(context),
                    style: GoogleFonts.playfairDisplay(
                      color: theme.textTheme.bodyLarge?.color,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'We will let you know when there are updates.'.tr(context),
                    style: GoogleFonts.roboto(
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          : ListView.separated(
              itemCount: notifications.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final notif = notifications[index];
                final isRead = notif['read'] == true || 
                               notif['read'] == 'true' || 
                               notif['is_read'] == true || 
                               notif['is_read'] == 'true';
                final id = notif['id']?.toString() ?? '';

                return InkWell(
                  onTap: () {
                    if (!isRead) {
                      provider.markNotificationAsRead(id);
                    }
                    
                    // Handle Navigation
                    final type = notif['type']?.toString() ?? '';
                    final refId = notif['reference_id']?.toString() ?? 
                                  notif['ticket_id']?.toString() ?? 
                                  notif['data']?['request_id']?.toString() ??
                                  notif['data']?['ticket_id']?.toString();
                    
                    if (refId != null && refId.isNotEmpty) {
                      if (type == 'ticket_status' || type == 'chat_message') {
                        final request = provider.requests.cast<Map<String, dynamic>>().firstWhere(
                          (r) => r['id'] == refId || r['ticket_id'] == refId || r['ticketNumber'] == refId,
                          orElse: () => <String, dynamic>{},
                        );
                        if (request.isNotEmpty) {
                          GuestPortalRequestsScreen.showRequestDetails(context, request);
                        }
                      }
                    }
                  },
                  child: Container(
                    color: isRead ? Colors.transparent : AppColors.primary.withOpacity(0.05),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon Column
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isRead ? theme.cardColor : AppColors.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isRead ? theme.dividerColor : AppColors.primary.withOpacity(0.3),
                            ),
                          ),
                          child: Icon(
                            _getIconForType(notif['type']?.toString()),
                            color: isRead ? theme.unselectedWidgetColor : AppColors.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        
                        // Text Column
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      notif['title']?.toString() ?? 'Notification',
                                      style: GoogleFonts.roboto(
                                        color: isRead 
                                            ? theme.textTheme.bodyLarge?.color?.withOpacity(0.7) 
                                            : theme.textTheme.bodyLarge?.color,
                                        fontSize: 16,
                                        fontWeight: isRead ? FontWeight.w500 : FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  if (!isRead)
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                notif['message']?.toString() ?? '',
                                style: GoogleFonts.roboto(
                                  color: theme.textTheme.bodyMedium?.color?.withOpacity(isRead ? 0.6 : 0.9),
                                  fontSize: 14,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _formatTime(notif['createdAt']?.toString()),
                                style: GoogleFonts.roboto(
                                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

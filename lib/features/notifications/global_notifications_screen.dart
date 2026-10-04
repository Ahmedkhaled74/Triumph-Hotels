import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:triumph_hotels/core/constants/app_colors.dart';
import 'package:triumph_hotels/core/providers/global_notification_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

class GlobalNotificationsScreen extends StatefulWidget {
  const GlobalNotificationsScreen({super.key});

  @override
  State<GlobalNotificationsScreen> createState() => _GlobalNotificationsScreenState();
}

class _GlobalNotificationsScreenState extends State<GlobalNotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = Provider.of<GlobalNotificationProvider>(context, listen: false);
      await provider.fetchNotifications();
      provider.markAllAsRead();
    });
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open link')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Notifications', 
          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      body: Consumer<GlobalNotificationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.notifications.isEmpty) {
            return Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (provider.errorMessage != null && provider.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Failed to load notifications', style: TextStyle(color: Colors.red)),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.fetchNotifications(),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                    child: Text('Retry', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
          }

          if (provider.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No new offers or updates yet.', style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchNotifications(),
            color: AppColors.primary,
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: provider.notifications.length,
              itemBuilder: (context, index) {
                final notification = provider.notifications[index];
                return Card(
                  margin: EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: notification.url != null && notification.url!.isNotEmpty 
                        ? () => _launchUrl(notification.url!) 
                        : null,
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.local_offer_outlined, color: AppColors.primary, size: 20),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  notification.title,
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                              ),
                              Text(
                                DateFormat('MMM d, h:mm a').format(notification.createdAt),
                                style: TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            notification.message,
                            style: TextStyle(
                              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8) ?? Colors.black87, 
                              fontSize: 14,
                            ),
                          ),
                          if (notification.url != null && notification.url!.isNotEmpty) ...[
                            SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  'View Details',
                                  style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                                ),
                                Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.primary),
                              ],
                            ),
                          ]
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

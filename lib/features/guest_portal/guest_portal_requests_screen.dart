import 'dart:async';
import 'package:flutter/material.dart';
import 'package:triumph_hotels/core/utils/app_translations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:triumph_hotels/core/constants/app_colors.dart';
import 'package:triumph_hotels/core/utils/responsive_utils.dart';
import 'package:triumph_hotels/features/guest_portal/widgets/create_request_bottom_sheet.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:triumph_hotels/core/providers/guest_portal_provider.dart';

class GuestPortalRequestsScreen extends StatefulWidget {
  const GuestPortalRequestsScreen({super.key});

  static void showRequestDetails(BuildContext context, Map<String, dynamic> request) {
    final theme = Theme.of(context);
    final status = (request['status'] ?? request['Status'] ?? 'pending').toString().toLowerCase();
    String statusStr = 'Pending';
    Color statusColor = Colors.orange;
    if (status == 'resolved' || status == 'completed' || status == 'closed') {
      statusStr = 'Resolved';
      statusColor = Colors.green;
    } else if (status == 'in_progress' || status == 'open') {
      statusStr = 'In Progress';
      statusColor = Colors.blue;
    }

    String displayTime = '';
    final createdAt = request['created_at'] ?? request['createdAt'];
    if (createdAt != null && createdAt.toString().isNotEmpty) {
      try {
        final dt = DateTime.parse(createdAt.toString()).toLocal();
        displayTime = '${dt.hour}:${dt.minute.toString().padLeft(2, '0')}, ${dt.day}/${dt.month}/${dt.year}';
      } catch (_) {}
    }

    final ticketId = (request['ticket_id'] ?? request['id'] ?? '').toString();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _RequestDetailSheet(
        request: request,
        theme: theme,
        ticketId: ticketId,
        statusStr: statusStr,
        statusColor: statusColor,
        displayTime: displayTime,
      ),
    );
  }

  @override
  State<GuestPortalRequestsScreen> createState() => _GuestPortalRequestsScreenState();
}

class _GuestPortalRequestsScreenState extends State<GuestPortalRequestsScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch live requests from TicketX API when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GuestPortalProvider>().fetchRequests();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSmallScreen = ResponsiveUtils.isSmallScreen(context);
    final isTablet = ResponsiveUtils.isTablet(context);
    
    final provider = context.watch<GuestPortalProvider>();
    // Show all requests sorted by newest first
    final activeRequests = List<dynamic>.from(provider.requests)
      ..sort((a, b) {
        final aTime = a['created_at'] ?? a['createdAt'] ?? '';
        final bTime = b['created_at'] ?? b['createdAt'] ?? '';
        // If aTime is empty, treat it as very new (put it first)
        if (aTime.isEmpty && bTime.isNotEmpty) return -1;
        if (bTime.isEmpty && aTime.isNotEmpty) return 1;
        return bTime.compareTo(aTime); // Newest first
      });

    // Only show top 5 recent requests
    final displayRequests = activeRequests.take(5).toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 20.0 : ResponsiveUtils.getScreenWidth(context) * 0.1,
          vertical: isSmallScreen ? 20.0 : 32.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Your Requests'.tr(context),
              style: GoogleFonts.roboto(
                color: AppColors.primary,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ).animate().fade().slideY(begin: 0.2),
            
            const SizedBox(height: 8),
            
            Text(
              'Track your active requests or create a new one.'.tr(context),
              style: GoogleFonts.roboto(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                fontSize: 16,
              ),
            ).animate().fade(delay: 100.ms).slideY(begin: 0.2),
            
            const SizedBox(height: 32),
            
            // Create New Request Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  CreateRequestBottomSheet.show(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 5,
                  shadowColor: AppColors.primary.withOpacity(0.4),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_circle_outline, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'CREATE NEW REQUEST'.tr(context),
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().fade(delay: 200.ms).slideY(begin: 0.2),
            
            const SizedBox(height: 40),
            
            Text(
              'Recent History'.tr(context),
              style: GoogleFonts.roboto(
                color: AppColors.primary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ).animate().fade(delay: 300.ms).slideY(begin: 0.2),
            
            const SizedBox(height: 16),
            
            // Grid for tablet/desktop, List for mobile
            if (provider.isLoading && displayRequests.isEmpty)
              const Center(child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(),
              ))
            else if (displayRequests.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text(
                    'No pending requests. All caught up! 🎉'.tr(context),
                    style: GoogleFonts.roboto(
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else if (isSmallScreen)
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: displayRequests.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return _buildRequestCard(context, theme, displayRequests[index]).animate().fade(delay: Duration(milliseconds: 400 + (index * 100))).slideY(begin: 0.2);
                },
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isTablet ? 2 : 3,
                  childAspectRatio: 2.5,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: displayRequests.length,
                itemBuilder: (context, index) {
                  return _buildRequestCard(context, theme, displayRequests[index]).animate().fade(delay: Duration(milliseconds: 400 + (index * 100))).slideY(begin: 0.2);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestCard(BuildContext context, ThemeData theme, Map<String, dynamic> request) {
    // Use ticket_status (actual API field) with fallback to status
    final rawStatus = (request['ticket_status'] ?? request['status'] ?? 'pending').toString().toLowerCase();

    Color statusColor;
    String statusStr;
    if (rawStatus.contains('pending') || rawStatus.contains('in_progress') || rawStatus.contains('open')) {
      statusColor = Colors.orange;
      statusStr = 'In Progress'.tr(context);
    } else if (rawStatus.contains('approved')) {
      statusColor = Colors.blue;
      statusStr = 'Approved'.tr(context);
    } else if (rawStatus.contains('completed') || rawStatus.contains('resolved')) {
      statusColor = Colors.green;
      statusStr = 'Resolved'.tr(context);
    } else {
      statusColor = Colors.grey;
      statusStr = rawStatus.toUpperCase();
    }

    // Use created_at (actual API field name)
    String displayTime = request['created_at'] ?? request['createdAt'] ?? '';
    try {
      if (displayTime.isNotEmpty) {
        final dt = DateTime.parse(displayTime).toLocal();
        displayTime = '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
      }
    } catch (_) {}

    final category  = request['category'] ?? '';
    final staffName = request['assigned_staff_name'] ?? '';

    return InkWell(
      onTap: () => _showRequestDetails(context, theme, request, statusStr, statusColor, displayTime),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  request['title'] ?? 'Request'.tr(context),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.roboto(
                    color: theme.textTheme.bodyLarge?.color,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                if (category.isNotEmpty)
                  Text(
                    category,
                    style: GoogleFonts.roboto(
                      color: AppColors.primary.withOpacity(0.8),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                if (staffName.isNotEmpty) ...
                  [
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.person_outline, size: 13, color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5)),
                        const SizedBox(width: 4),
                        Text(
                          staffName,
                          style: GoogleFonts.roboto(
                            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        displayTime,
                        style: GoogleFonts.roboto(
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: statusColor.withOpacity(0.3)),
                      ),
                      child: Text(
                        statusStr,
                        style: GoogleFonts.roboto(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ));
  }

  void _showRequestDetails(
    BuildContext context, 
    ThemeData theme, 
    Map<String, dynamic> request, 
    String statusStr, 
    Color statusColor,
    String displayTime,
  ) {
    final ticketId = (request['ticket_id'] ?? request['id'] ?? '').toString();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _RequestDetailSheet(
          theme: theme,
          request: request,
          statusStr: statusStr,
          statusColor: statusColor,
          displayTime: displayTime,
          ticketId: ticketId,
        );
      },
    );
  }
}

// ─── Request Detail Sheet with Chat ─────────────────────────────────────────

class _RequestDetailSheet extends StatefulWidget {
  final ThemeData theme;
  final Map<String, dynamic> request;
  final String statusStr;
  final Color statusColor;
  final String displayTime;
  final String ticketId;

  const _RequestDetailSheet({
    required this.theme,
    required this.request,
    required this.statusStr,
    required this.statusColor,
    required this.displayTime,
    required this.ticketId,
  });

  @override
  State<_RequestDetailSheet> createState() => _RequestDetailSheetState();
}

class _RequestDetailSheetState extends State<_RequestDetailSheet> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> _messages = [];
  bool _isLoadingMessages = false;
  bool _isSending = false;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    if (widget.ticketId.isNotEmpty) {
      _fetchMessages();
    }
    // Listen to tab changes to start/stop polling
    _tabController.addListener(() {
      if (_tabController.index == 1) {
        _startPolling();
      } else {
        _stopPolling();
      }
    });
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    // Poll every 5 seconds when chat tab is open
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _fetchMessages(silent: true);
    });
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  @override
  void dispose() {
    _stopPolling();
    _tabController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchMessages({bool silent = false}) async {
    if (!silent) setState(() => _isLoadingMessages = true);
    try {
      final provider = context.read<GuestPortalProvider>();
      final messages = await provider.fetchRequestMessages(widget.request['id']?.toString() ?? '');
      if (mounted) {
        // Sort by created_at ascending so oldest messages appear at top
        final sorted = messages
            .map((m) => Map<String, dynamic>.from(m as Map))
            .toList()
          ..sort((a, b) {
            final rawA = a['created_at'] ?? a['createdAt'] ?? '';
            final rawB = b['created_at'] ?? b['createdAt'] ?? '';
            // Since dates are ISO-like (e.g. 2026-08-04 21:04:04...), simple string comparison works perfectly
            return rawA.toString().compareTo(rawB.toString());
          });
        final wasAtBottom = !_scrollController.hasClients ||
            _scrollController.position.pixels >=
                _scrollController.position.maxScrollExtent - 80;
        setState(() => _messages = sorted);
        // Only auto-scroll if the user was already near the bottom
        if (wasAtBottom) _scrollToBottom();
      }
    } catch (e) {
      debugPrint('Error fetching messages: $e');
    } finally {
      if (mounted && !silent) setState(() => _isLoadingMessages = false);
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSending = true);
    _messageController.clear();

    // Optimistically add the message
    final optimisticMsg = {
      'message': text,
      'is_guest': true,
      'created_at': DateTime.now().toIso8601String(),
      'sender': 'You',
    };
    setState(() => _messages.add(optimisticMsg));
    _scrollToBottom();

    try {
      final provider = context.read<GuestPortalProvider>();
      await provider.sendRequestMessage(widget.request['id']?.toString() ?? '', text);
      await _fetchMessages(silent: true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: theme.dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.request['title'] ?? 'Request',
                            style: GoogleFonts.roboto(
                              color: AppColors.primary,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.displayTime,
                            style: GoogleFonts.roboto(
                              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: widget.statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: widget.statusColor.withOpacity(0.3)),
                      ),
                      child: Text(
                        widget.statusStr,
                        style: GoogleFonts.roboto(
                          color: widget.statusColor,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Tabs
              TabBar(
                controller: _tabController,
                indicatorColor: AppColors.primary,
                labelColor: AppColors.primary,
                unselectedLabelColor: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
                labelStyle: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 14),
                tabs: const [
                  Tab(text: 'Details'),
                  Tab(text: 'Chat with Staff'),
                ],
              ),
              const Divider(height: 1),
              // Tab views
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // ── DETAILS TAB ──
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _detailRow(theme, Icons.title, 'Title', widget.request['title'] ?? 'N/A'),
                          const SizedBox(height: 16),
                          _detailRow(theme, Icons.category, 'Category', widget.request['category'] ?? 'N/A'),
                          const SizedBox(height: 16),
                          _detailRow(theme, Icons.access_time, 'Date', widget.displayTime),
                          const SizedBox(height: 16),
                          if ((widget.request['assigned_staff_name'] ?? '').isNotEmpty) ...[
                            _detailRow(theme, Icons.person, 'Assigned To', widget.request['assigned_staff_name']),
                            const SizedBox(height: 16),
                          ],
                          _detailRow(theme, Icons.priority_high, 'Priority', (widget.request['priority'] ?? 'Normal').toString().toUpperCase()),
                          const SizedBox(height: 32),
                          if ((widget.request['description'] ?? widget.request['text'] ?? '').isNotEmpty) ...[
                            _detailRow(theme, Icons.description_outlined, 'Description', widget.request['description'] ?? widget.request['text']),
                            const SizedBox(height: 16),
                          ],
                          // Chat CTA
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.chat_bubble_outline, color: AppColors.primary),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Have a question about this request? Chat directly with our staff.',
                                    style: GoogleFonts.roboto(
                                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () => _tabController.animateTo(1),
                                  child: Text(
                                    'Open Chat',
                                    style: GoogleFonts.roboto(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // ── CHAT TAB ──
                    Column(
                      children: [
                        Expanded(
                          child: _isLoadingMessages
                              ? const Center(child: CircularProgressIndicator())
                              : _messages.isEmpty
                                  ? Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.chat_bubble_outline,
                                              size: 48, color: theme.textTheme.bodyMedium?.color?.withOpacity(0.3)),
                                          const SizedBox(height: 12),
                                          Text(
                                            'No messages yet.\nSend a message to our staff!',
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.roboto(
                                              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : ListView.builder(
                                      controller: _scrollController,
                                      padding: const EdgeInsets.all(16),
                                      itemCount: _messages.length,
                                      itemBuilder: (context, index) {
                                        final msg = _messages[index];
                                        final isGuest = msg['is_guest'] == true || msg['sender_type'] == 'guest';
                                        return _buildMessageBubble(theme, msg, isGuest);
                                      },
                                    ),
                        ),
                        // Message input
                        Container(
                          padding: EdgeInsets.only(
                            left: 16,
                            right: 16,
                            top: 12,
                            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                          ),
                          decoration: BoxDecoration(
                            color: theme.scaffoldBackgroundColor,
                            border: Border(top: BorderSide(color: theme.dividerColor)),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _messageController,
                                  minLines: 1,
                                  maxLines: 4,
                                  decoration: InputDecoration(
                                    hintText: 'Write a message to staff...'.tr(context),
                                    hintStyle: GoogleFonts.roboto(
                                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.4),
                                      fontSize: 14,
                                    ),
                                    filled: true,
                                    fillColor: theme.cardColor,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(24),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  ),
                                  style: GoogleFonts.roboto(fontSize: 14),
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: _isSending ? null : _sendMessage,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: _isSending ? AppColors.primary.withOpacity(0.5) : AppColors.primary,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary.withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: _isSending
                                      ? const Padding(
                                          padding: EdgeInsets.all(12),
                                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                        )
                                      : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessageBubble(ThemeData theme, Map<String, dynamic> msg, bool isGuest) {
    final text = msg['message'] ?? msg['text'] ?? '';
    final sender = isGuest ? 'You'.tr(context) : (msg['sender'] ?? msg['sender_name'] ?? 'Staff'.tr(context));
    String time = '';
    try {
      final raw = msg['created_at'] ?? msg['createdAt'] ?? '';
      if (raw.isNotEmpty) {
        // API returns "YYYY-MM-DD HH:MM:SS.mmm+03", fix for DateTime.parse
        final cleanRaw = raw.toString()
            .replaceAll(' ', 'T')
            .replaceAllMapped(RegExp(r'\+\d{2}$'), (m) => '${m.group(0)}:00');
        final dt = DateTime.parse(cleanRaw).toLocal();
        time = '${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
      }
    } catch (_) {}

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Align(
        alignment: isGuest ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: isGuest ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              sender,
              style: GoogleFonts.roboto(
                fontSize: 11,
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isGuest ? AppColors.primary : theme.cardColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isGuest ? 18 : 4),
                  bottomRight: Radius.circular(isGuest ? 4 : 18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    text.toString(),
                    style: GoogleFonts.roboto(
                      color: isGuest ? Colors.white : theme.textTheme.bodyLarge?.color,
                      fontSize: 14,
                    ),
                  ),
                  if (time.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      time,
                      style: GoogleFonts.roboto(
                        fontSize: 10,
                        color: isGuest ? Colors.white.withOpacity(0.6) : theme.textTheme.bodyMedium?.color?.withOpacity(0.4),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(ThemeData theme, IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.primary.withOpacity(0.7)),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.roboto(
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.roboto(
                  color: theme.textTheme.bodyLarge?.color,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

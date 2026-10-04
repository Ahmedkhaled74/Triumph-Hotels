import 'dart:async';
import 'package:flutter/material.dart';
import 'package:triumph_hotels/core/utils/app_translations.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:triumph_hotels/core/providers/guest_portal_provider.dart';
import 'package:triumph_hotels/core/constants/app_colors.dart';

class GuestPortalChatScreen extends StatefulWidget {
  const GuestPortalChatScreen({super.key});

  @override
  State<GuestPortalChatScreen> createState() => _GuestPortalChatScreenState();
}

class _GuestPortalChatScreenState extends State<GuestPortalChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isInitializing = true;
  Timer? _pollingTimer; // Just in case SSE fails or as a fallback

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initChat();
      }
    });
  }

  Future<void> _initChat() async {
    final provider = context.read<GuestPortalProvider>();
    await provider.startChat();
    setState(() {
      _isInitializing = false;
    });
    _scrollToBottom();
    
    // We will poll every 10 seconds as a fallback in case SSE isn't working properly
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (mounted) {
        context.read<GuestPortalProvider>().refreshChatMessages(silent: true).then((_) {
          if (!mounted) return;
          context.read<GuestPortalProvider>().markChatAsRead();
          _scrollToBottom();
        });
      }
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      // Delay slightly to let ListView render new items
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted && _scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();
    context.read<GuestPortalProvider>().sendChatMessage(text).then((_) {
      _scrollToBottom();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<GuestPortalProvider>();
    final messages = provider.chatMessages;

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
        title: Column(
          children: [
            Text(
              'Guest Services'.tr(context),
              style: GoogleFonts.playfairDisplay(
                color: AppColors.primary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Online 24/7'.tr(context),
              style: GoogleFonts.roboto(
                color: Colors.green,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: theme.dividerColor,
            height: 1.0,
          ),
        ),
      ),
      body: _isInitializing && messages.isEmpty
          ? Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      Center(
                        child: Icon(
                          Icons.support_agent_rounded,
                          size: 150,
                          color: AppColors.primary.withOpacity(0.05),
                        ),
                      ),
                      ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final msg = messages[index];
                          final isGuest = msg['sender_type'] == 'guest';
                          final senderName = msg['sender_name']?.toString() ?? 'Hotel Staff'.tr(context);
                          final isAi = msg['is_ai_response'] == true;

                          return _buildMessageBubble(
                            text: msg['message']?.toString() ?? '',
                            isGuest: isGuest,
                            senderName: senderName,
                            isAi: isAi,
                            theme: theme,
                          );
                        },
                      ),
                    ],
                  ),
                ),
                _buildMessageInput(theme),
              ],
            ),
    );
  }

  Widget _buildMessageBubble({
    required String text,
    required bool isGuest,
    required String senderName,
    required bool isAi,
    required ThemeData theme,
  }) {
    final bgColor = isGuest ? AppColors.primary : theme.cardColor;
    final textColor = isGuest ? theme.scaffoldBackgroundColor : theme.textTheme.bodyLarge?.color ?? Colors.white;
    final borderRadius = BorderRadius.only(
      topLeft: const Radius.circular(16),
      topRight: const Radius.circular(16),
      bottomLeft: isGuest ? const Radius.circular(16) : const Radius.circular(4),
      bottomRight: isGuest ? const Radius.circular(4) : const Radius.circular(16),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: isGuest ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isGuest)
            Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isAi) Icon(Icons.auto_awesome, size: 12, color: AppColors.primary),
                  if (isAi) const SizedBox(width: 4),
                  Text(
                    senderName,
                    style: GoogleFonts.roboto(
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: borderRadius,
              border: isGuest ? null : Border.all(color: theme.dividerColor),
            ),
            child: Text(
              text,
              style: GoogleFonts.roboto(
                color: textColor,
                fontSize: 15,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24), // Extra bottom padding for SafeArea
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(color: theme.dividerColor),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: theme.dividerColor),
              ),
              child: TextField(
                controller: _messageController,
                style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                decoration: InputDecoration(
                  hintText: 'Type your message...'.tr(context),
                  hintStyle: TextStyle(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.send_rounded,
                  color: theme.scaffoldBackgroundColor,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

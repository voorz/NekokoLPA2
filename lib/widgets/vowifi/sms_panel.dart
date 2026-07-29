import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// 板块3: 短信管理
///
/// 一个迷你 SMS 对话界面，包含消息列表和底部输入栏。
/// 所有数据通过 [SmsConversation] 传入，发送回调 [onSend] 留空待接入。
class VoWiFiSmsPanel extends StatefulWidget {
  final SmsConversation? conversation;
  final ValueChanged<String>? onSend;

  const VoWiFiSmsPanel({
    super.key,
    this.conversation,
    this.onSend,
  });

  @override
  State<VoWiFiSmsPanel> createState() => _VoWiFiSmsPanelState();
}

class _VoWiFiSmsPanelState extends State<VoWiFiSmsPanel> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<SmsMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    if (widget.conversation != null) {
      _messages.addAll(widget.conversation!.messages);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(SmsMessage(
        body: text,
        isSent: true,
        timestamp: DateTime.now(),
      ));
      _controller.clear();
    });

    widget.onSend?.call(text);

    // Auto-scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final contact = widget.conversation?.contact ?? '--';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: theme.brightness == Brightness.dark ? 0.2 : 0.03,
            ),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              children: [
                Icon(
                  Icons.sms_outlined,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '短信管理',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                Text(
                  contact,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.onSurfaceSubtle(context),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Message list
          SizedBox(
            height: 280,
            child: _messages.isEmpty
                ? Center(
                    child: Text(
                      '暂无短信',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.onSurfaceVerySubtle(context),
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) =>
                        _MessageBubble(message: _messages[index]),
                  ),
          ),
          const Divider(height: 1),
          // Input bar
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      hintText: '输入短信内容…',
                      hintStyle: TextStyle(
                        fontSize: 13,
                        color: AppTheme.onSurfaceVerySubtle(context),
                      ),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.4),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(
                          color: theme.colorScheme.primary.withValues(alpha: 0.4),
                          width: 1.5,
                        ),
                      ),
                    ),
                    onSubmitted: (_) => _handleSend(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _handleSend,
                  icon: const Icon(Icons.send_rounded, size: 18),
                  style: IconButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final SmsMessage message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSent = message.isSent;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment:
            isSent ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isSent) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              child: Icon(
                Icons.person,
                size: 16,
                color: AppTheme.onSurfaceSubtle(context),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.6,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: isSent
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: isSent
                      ? const Radius.circular(16)
                      : const Radius.circular(4),
                  bottomRight: isSent
                      ? const Radius.circular(4)
                      : const Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.body,
                    style: TextStyle(
                      fontSize: 13,
                      color: isSent
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      fontSize: 10,
                      color: isSent
                          ? theme.colorScheme.onPrimary.withValues(alpha: 0.6)
                          : AppTheme.onSurfaceVerySubtle(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isSent) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 14,
              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.15),
              child: Icon(
                Icons.person,
                size: 16,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }
}

// ---------------------------------------------------------------------------
// Data models
// --------------------------------------------------------------------------

class SmsMessage {
  final String body;
  final bool isSent;
  final DateTime timestamp;

  SmsMessage({
    required this.body,
    required this.isSent,
    required this.timestamp,
  });
}

class SmsConversation {
  final String contact;
  final List<SmsMessage> messages;

  const SmsConversation({
    required this.contact,
    this.messages = const [],
  });
}

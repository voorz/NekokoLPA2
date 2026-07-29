import 'package:flutter/material.dart';

import '../widgets/vowifi/sim_info_panel.dart';
import '../widgets/vowifi/status_panel.dart';
import '../widgets/vowifi/sms_panel.dart';
import '../widgets/vowifi/dialer_panel.dart';

// Re-export data models so callers only need to import this one file.
export '../widgets/vowifi/sim_info_panel.dart' show SimDeviceInfo;
export '../widgets/vowifi/status_panel.dart' show VoWiFiStatus, VoWiFiOverallState, VoWiFiSubSystemState;
export '../widgets/vowifi/sms_panel.dart' show SmsConversation, SmsMessage;

/// VoWiFi 管理页面
///
/// 当用户在 AppBar 胶囊 Tab 中选择 "VoWiFi" 时显示此页面。
/// 包含 4 个板块：SIM/设备信息、运行状态、短信管理、拨号盘。
///
/// 当前使用占位数据，后续接入真实逻辑时替换 [simInfo] / [status] /
/// [conversation] / [onCall] 即可。
class VoWiFiManagementPage extends StatelessWidget {
  /// 当前选中号码（用于顶部标题展示）
  final String? activeNumber;

  /// SIM / 设备信息，null 时显示空占位
  final SimDeviceInfo? simInfo;

  /// VoWiFi 运行状态，null 时显示 idle 占位
  final VoWiFiStatus? status;

  /// 短信会话数据
  final SmsConversation? conversation;

  /// 拨号回调
  final ValueChanged<String>? onCall;

  /// 发送短信回调
  final ValueChanged<String>? onSmsSend;

  const VoWiFiManagementPage({
    super.key,
    this.activeNumber,
    this.simInfo,
    this.status,
    this.conversation,
    this.onCall,
    this.onSmsSend,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 800;
        final padding = isWide ? 24.0 : 16.0;

        // On wide screens, lay out sections in a 2-column grid
        if (isWide) {
          return SingleChildScrollView(
            padding: EdgeInsets.only(
              left: padding,
              right: padding,
              top: 8,
              bottom: 80,
            ),
            child: Column(
              children: [
                // Top: SIM info + Status side by side (equal height)
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: SimInfoPanel(info: simInfo)),
                      const SizedBox(width: 16),
                      Expanded(child: VoWiFiStatusPanel(status: status)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Bottom: SMS + Dialer side by side (equal height)
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 2,
                        child: VoWiFiSmsPanel(
                          conversation: conversation,
                          onSend: onSmsSend,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 1,
                        child: VoWiFiDialerPanel(onCall: onCall),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        // Narrow: single column scroll
        return SingleChildScrollView(
          padding: EdgeInsets.only(
            left: padding,
            right: padding,
            top: 8,
            bottom: 80,
          ),
          child: Column(
            children: [
              SimInfoPanel(info: simInfo),
              VoWiFiStatusPanel(status: status),
              VoWiFiSmsPanel(
                conversation: conversation,
                onSend: onSmsSend,
              ),
              VoWiFiDialerPanel(onCall: onCall),
            ],
          ),
        );
      },
    );
  }
}

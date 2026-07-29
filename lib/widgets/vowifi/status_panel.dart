import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// 板块2: 运行状态
///
/// 顶部一条 WiFi-Calling 总览横幅，下方 5 个子系统状态柱
/// (SIM / Access / Tunnel / IMS / SMS)，再下方为数据平面和最后原因。
class VoWiFiStatusPanel extends StatelessWidget {
  final VoWiFiStatus? status;

  const VoWiFiStatusPanel({super.key, this.status});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = status ?? VoWiFiStatus.empty();

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
                  Icons.insights_outlined,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '运行状态',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status banner
                _StatusBanner(status: s),
                const SizedBox(height: 16),
                // Sub-system status bars
                Row(
                  children: [
                    Expanded(
                      child: _SubSystemBar(
                        label: 'SIM',
                        state: s.simState,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _SubSystemBar(
                        label: 'Access',
                        state: s.accessState,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _SubSystemBar(
                        label: 'Tunnel',
                        state: s.tunnelState,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _SubSystemBar(
                        label: 'IMS',
                        state: s.imsState,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _SubSystemBar(
                        label: 'SMS',
                        state: s.smsState,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Detail rows
                _DetailRow(label: '数据平面', value: s.dataPlane),
                _DetailRow(label: '最后原因', value: s.lastReason),
                _DetailRow(label: '最后原因', value: s.lastReason2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// --------------------------------------------------------------------------

class _StatusBanner extends StatelessWidget {
  final VoWiFiStatus status;

  const _StatusBanner({required this.status});

  @override
  Widget build(BuildContext context) {
    final overall = status.overall;
    final color = overall.color;
    final bgColor = color.withValues(alpha: 0.1);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(Icons.wifi_calling, size: 20, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'WiFi-Calling',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                Text(
                  overall.label,
                  style: TextStyle(
                    fontSize: 12,
                    color: color.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          // Pulsing dot
          if (overall == VoWiFiOverallState.ready)
            _PulsingDot(color: color)
          else
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
              ),
            ),
        ],
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  final Color color;

  const _PulsingDot({required this.color});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final scale = 1.0 + _controller.value * 0.4;
        final opacity = 1.0 - _controller.value * 0.5;
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 10 * scale,
              height: 10 * scale,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color.withValues(alpha: opacity * 0.3),
              ),
            ),
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SubSystemBar extends StatelessWidget {
  final String label;
  final VoWiFiSubSystemState state;

  const _SubSystemBar({required this.label, required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = state.color;

    return Column(
      children: [
        // Bar
        Container(
          height: 4,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: state == VoWiFiSubSystemState.inactive
                ? AppTheme.onSurfaceVerySubtle(context)
                : theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String? value;

  const _DetailRow({required this.label, this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.onSurfaceSubtle(context),
            ),
          ),
          Text(
            value ?? '--',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Data models
// --------------------------------------------------------------------------

enum VoWiFiOverallState {
  ready('全部就绪', Color(0xFF43A047)),
  connecting('连接中…', Color(0xFFFFA726)),
  error('异常', Color(0xFFEF5350)),
  idle('未激活', Color(0xFF9E9E9E));

  final String label;
  final Color color;
  const VoWiFiOverallState(this.label, this.color);
}

enum VoWiFiSubSystemState {
  active(Color(0xFF43A047)),
  inactive(Color(0xFFBDBDBD)),
  error(Color(0xFFEF5350));

  final Color color;
  const VoWiFiSubSystemState(this.color);
}

class VoWiFiStatus {
  final VoWiFiOverallState overall;
  final VoWiFiSubSystemState simState;
  final VoWiFiSubSystemState accessState;
  final VoWiFiSubSystemState tunnelState;
  final VoWiFiSubSystemState imsState;
  final VoWiFiSubSystemState smsState;
  final String? dataPlane;
  final String? lastReason;
  final String? lastReason2;

  const VoWiFiStatus({
    this.overall = VoWiFiOverallState.idle,
    this.simState = VoWiFiSubSystemState.inactive,
    this.accessState = VoWiFiSubSystemState.inactive,
    this.tunnelState = VoWiFiSubSystemState.inactive,
    this.imsState = VoWiFiSubSystemState.inactive,
    this.smsState = VoWiFiSubSystemState.inactive,
    this.dataPlane,
    this.lastReason,
    this.lastReason2,
  });

  factory VoWiFiStatus.empty() => const VoWiFiStatus();

  /// A sample "all-ready" status for UI prototyping.
  factory VoWiFiStatus.ready() => const VoWiFiStatus(
        overall: VoWiFiOverallState.ready,
        simState: VoWiFiSubSystemState.active,
        accessState: VoWiFiSubSystemState.active,
        tunnelState: VoWiFiSubSystemState.active,
        imsState: VoWiFiSubSystemState.active,
        smsState: VoWiFiSubSystemState.active,
        dataPlane: 'userspace',
        lastReason: 'sms_ready',
        lastReason2: '--',
      );
}

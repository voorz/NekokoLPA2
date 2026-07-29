import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// 板块1: SIM / 设备信息
///
/// 展示当前 eUICC + 读卡器硬件的识别参数。
/// 所有字段通过 [SimDeviceInfo] 传入，UI 层不做数据获取。
class SimInfoPanel extends StatelessWidget {
  final SimDeviceInfo? info;

  const SimInfoPanel({super.key, this.info});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final data = info ?? SimDeviceInfo.empty();

    return _PanelCard(
      title: 'SIM / 设备',
      icon: Icons.sim_card_outlined,
      child: Column(
        children: [
          _InfoRow(label: 'IMEI', value: data.imei),
          _InfoRow(label: 'ICCID', value: data.iccid, mono: true),
          _InfoRow(label: 'IMSI', value: data.imsi, mono: true),
          _InfoRow(label: '本机号码', value: data.phoneNumber),
          _InfoRow(
            label: '原运营商',
            child: Row(
              children: [
                if (data.operatorFlagUrl != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: Image.network(
                        data.operatorFlagUrl!,
                        width: 18,
                        height: 12,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const SizedBox(width: 18, height: 12),
                      ),
                    ),
                  ),
                Flexible(
                  child: Text(
                    data.operatorName ?? '--',
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          _InfoRow(label: '固件版本', value: data.firmwareVersion),
          _InfoRow(
            label: '飞行模式',
            child: _StatusChip(
              active: data.airplaneMode,
              activeText: '是',
              inactiveText: '否',
            ),
          ),
          _InfoRow(
            label: '运行模式',
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                data.runningMode ?? '--',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
// Internal helpers
// --------------------------------------------------------------------------

class _PanelCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _PanelCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              children: [
                Icon(icon, size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String? value;
  final bool mono;
  final Widget? child;

  const _InfoRow({
    required this.label,
    this.value,
    this.mono = false,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.onSurfaceSubtle(context),
              ),
            ),
          ),
          Expanded(
            child: child ??
                Text(
                  value ?? '--',
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.colorScheme.onSurface,
                    fontFamily: mono ? 'monospace' : null,
                    fontWeight: mono ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final bool active;
  final String activeText;
  final String inactiveText;

  const _StatusChip({
    required this.active,
    required this.activeText,
    required this.inactiveText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = active ? const Color(0xFF43A047) : theme.colorScheme.outline;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        active ? activeText : inactiveText,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

/// Data model for [SimInfoPanel].
class SimDeviceInfo {
  final String? imei;
  final String? iccid;
  final String? imsi;
  final String? phoneNumber;
  final String? operatorName;
  final String? operatorFlagUrl;
  final String? firmwareVersion;
  final bool airplaneMode;
  final String? runningMode;

  const SimDeviceInfo({
    this.imei,
    this.iccid,
    this.imsi,
    this.phoneNumber,
    this.operatorName,
    this.operatorFlagUrl,
    this.firmwareVersion,
    this.airplaneMode = false,
    this.runningMode,
  });

  factory SimDeviceInfo.empty() => const SimDeviceInfo();
}

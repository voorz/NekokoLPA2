import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';

/// 板块4: 电话拨号盘
///
/// 一个标准 DTMF 拨号盘，顶部显示输入的号码，下方 3×4 数字键盘。
/// [onCall] 回调留空待接入。
class VoWiFiDialerPanel extends StatefulWidget {
  final ValueChanged<String>? onCall;

  const VoWiFiDialerPanel({super.key, this.onCall});

  @override
  State<VoWiFiDialerPanel> createState() => _VoWiFiDialerPanelState();
}

class _VoWiFiDialerPanelState extends State<VoWiFiDialerPanel> {
  final TextEditingController _numberController = TextEditingController();

  @override
  void dispose() {
    _numberController.dispose();
    super.dispose();
  }

  void _appendDigit(String digit) {
    HapticFeedback.lightImpact();
    setState(() {
      _numberController.text += digit;
      _numberController.selection = TextSelection.fromPosition(
        TextPosition(offset: _numberController.text.length),
      );
    });
  }

  void _backspace() {
    HapticFeedback.lightImpact();
    final text = _numberController.text;
    if (text.isNotEmpty) {
      setState(() {
        _numberController.text =
            text.substring(0, text.length - 1);
        _numberController.selection = TextSelection.fromPosition(
          TextPosition(offset: _numberController.text.length),
        );
      });
    }
  }

  void _call() {
    HapticFeedback.mediumImpact();
    final number = _numberController.text.trim();
    if (number.isNotEmpty) {
      widget.onCall?.call(number);
    }
  }

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
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              children: [
                Icon(
                  Icons.dialpad_rounded,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '拨号盘',
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
              children: [
                // Number display
                SizedBox(
                  height: 52,
                  child: Center(
                    child: TextField(
                      controller: _numberController,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 1.5,
                        color: theme.colorScheme.onSurface,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        hintText: '',
                        contentPadding: EdgeInsets.zero,
                      ),
                      keyboardType: TextInputType.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Keypad grid
                ..._buildKeypadRows(theme),
                const SizedBox(height: 12),
                // Call / backspace row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const SizedBox(width: 56),
                    _CallButton(onTap: _call),
                    _DialKey(
                      display: '',
                      subLabel: '',
                      onTap: _backspace,
                      child: Icon(
                        Icons.backspace_outlined,
                        size: 22,
                        color: AppTheme.onSurfaceSubtle(context),
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
  }

  List<Widget> _buildKeypadRows(ThemeData theme) {
    const keys = <_DialKeyData>[
      _DialKeyData('1', ''),
      _DialKeyData('2', 'ABC'),
      _DialKeyData('3', 'DEF'),
      _DialKeyData('4', 'GHI'),
      _DialKeyData('5', 'JKL'),
      _DialKeyData('6', 'MNO'),
      _DialKeyData('7', 'PQRS'),
      _DialKeyData('8', 'TUV'),
      _DialKeyData('9', 'WXYZ'),
      _DialKeyData('*', ''),
      _DialKeyData('0', '+'),
      _DialKeyData('#', ''),
    ];

    final rows = <Widget>[];
    for (var i = 0; i < keys.length; i += 3) {
      final rowKeys = keys.sublist(i, i + 3);
      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: rowKeys
                .map((k) => _DialKey(
                      display: k.display,
                      subLabel: k.subLabel,
                      onTap: () => _appendDigit(k.display),
                    ))
                .toList(),
          ),
        ),
      );
    }
    return rows;
  }
}

class _DialKeyData {
  final String display;
  final String subLabel;
  const _DialKeyData(this.display, this.subLabel);
}

class _DialKey extends StatelessWidget {
  final String display;
  final String subLabel;
  final VoidCallback onTap;
  final Widget? child;

  const _DialKey({
    required this.display,
    required this.subLabel,
    required this.onTap,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        ),
        child: child ??
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    display,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w400,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  if (subLabel.isNotEmpty)
                    Text(
                      subLabel,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                        color: AppTheme.onSurfaceVerySubtle(context),
                      ),
                    ),
                ],
              ),
            ),
      ),
    );
  }
}

class _CallButton extends StatelessWidget {
  final VoidCallback onTap;

  const _CallButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF43A047),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF43A047).withValues(alpha: 0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.phone,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }
}

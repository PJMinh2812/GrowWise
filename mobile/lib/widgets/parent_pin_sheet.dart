import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';

/// Hiển thị hộp thoại PIN phụ huynh. Trả về true nếu xác thực/đặt PIN thành công.
/// Tự quyết định chế độ tạo mới hay nhập tuỳ theo đã có PIN chưa.
Future<bool> showParentPinDialog(BuildContext context) async {
  final hasPin = await SupabaseService.hasParentPin();
  if (!context.mounted) return false;
  final ok = await showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (_) => _ParentPinDialog(createMode: !hasPin),
  );
  return ok ?? false;
}

class _ParentPinDialog extends StatefulWidget {
  final bool createMode;
  const _ParentPinDialog({required this.createMode});

  @override
  State<_ParentPinDialog> createState() => _ParentPinDialogState();
}

class _ParentPinDialogState extends State<_ParentPinDialog> {
  String _pin = '';
  String _firstPin = ''; // create mode: nhập lần 1
  bool _confirmStage = false;
  String _error = '';
  bool _busy = false;
  int _attemptsLeft = 3;

  String get _title {
    if (widget.createMode) {
      return _confirmStage ? 'Xác nhận mã PIN' : 'Tạo mã PIN 4 số';
    }
    return 'Nhập mã PIN phụ huynh';
  }

  String get _subtitle =>
      widget.createMode ? 'Đặt mã để bảo vệ chế độ Cha mẹ' : 'Để con không tự ý vào';

  Future<void> _press(String d) async {
    if (_busy || _pin.length >= 4) return;
    setState(() {
      _error = '';
      _pin += d;
    });
    if (_pin.length == 4) await _complete();
  }

  void _backspace() {
    if (_pin.isEmpty) return;
    setState(() {
      _error = '';
      _pin = _pin.substring(0, _pin.length - 1);
    });
  }

  Future<void> _complete() async {
    if (widget.createMode) {
      if (!_confirmStage) {
        setState(() {
          _firstPin = _pin;
          _pin = '';
          _confirmStage = true;
        });
        return;
      }
      if (_pin != _firstPin) {
        setState(() {
          _error = 'PIN xác nhận không khớp. Thử lại.';
          _pin = '';
          _firstPin = '';
          _confirmStage = false;
        });
        return;
      }
      setState(() => _busy = true);
      await SupabaseService.setParentPin(_pin);
      if (mounted) Navigator.pop(context, true);
      return;
    }

    // verify
    setState(() => _busy = true);
    final ok = await SupabaseService.verifyParentPin(_pin);
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context, true);
    } else {
      final left = _attemptsLeft - 1;
      setState(() {
        _attemptsLeft = left;
        _pin = '';
        _busy = false;
        _error = left <= 0 ? 'Sai PIN nhiều lần.' : 'Sai PIN, còn $left lần thử.';
      });
      if (left <= 0 && mounted) Navigator.pop(context, false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🦉', style: TextStyle(fontSize: 36)),
            const SizedBox(height: 8),
            Text(
              _title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppTheme.indigo,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _subtitle,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 20),

            // dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (i) {
                final filled = i < _pin.length;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: filled ? AppTheme.indigo : AppTheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: filled ? AppTheme.indigo : AppTheme.border,
                      width: 2,
                    ),
                  ),
                  child: filled
                      ? const Center(
                          child: Icon(Icons.circle, size: 10, color: Colors.white))
                      : null,
                );
              }),
            ),
            const SizedBox(height: 12),
            if (_error.isNotEmpty)
              Text(
                _error,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: AppTheme.coral,
                ),
              ),
            const SizedBox(height: 12),

            // keypad
            ...['123', '456', '789'].map((row) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: row.split('').map(_key).toList(),
                  ),
                )),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 72),
                _key('0'),
                _keyWidget(
                  onTap: _backspace,
                  child: const Icon(Icons.backspace_outlined,
                      color: AppTheme.textSecondary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _key(String d) => _keyWidget(
        onTap: () => _press(d),
        child: Text(
          d,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
      );

  Widget _keyWidget({required VoidCallback onTap, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Material(
        color: AppTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: _busy ? null : onTap,
          child: SizedBox(width: 60, height: 56, child: Center(child: child)),
        ),
      ),
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  final List<_Msg> _msgs = [];
  bool _typing = false;

  static const _replies = {
    'nhiệm vụ': 'Con có 2 nhiệm vụ cần làm hôm nay: "Đọc sách 30 phút" và "Tưới cây ban công". Hãy cố lên, con sẽ kiếm được 40 xu nếu hoàn thành cả hai! 💪',
    'xu': 'Con hiện có 850 xu trong hũ tiền. Con đang tiết kiệm rất tốt! Hũ Tiết kiệm của con đã có 255 xu rồi đó 🎉',
    'ước mơ': 'Con đang tiết kiệm để mua Lego Technic! Con đã có 850/1000 xu rồi, chỉ cần thêm 150 xu nữa thôi. Cố lên nào! 🧱',
    'level': 'Con đang ở Level 5 Explorer và có 78/100 XP. Chỉ cần hoàn thành thêm 1-2 nhiệm vụ nữa là lên Level 6 rồi! ⭐',
    'huy hiệu': 'Con đã có 6 huy hiệu: 🏅 Khởi đầu, 🔥 3 ngày liên tiếp, 🌟 Level 5!, 📚 Mọt sách, 🏆 Hoàn thành 20 việc, 💪 Sức khỏe tốt. Bộ sưu tập đẹp đấy!',
    'chào': 'Xin chào ${""} ! Mình là trợ lý AI của GrowWise. Mình có thể giúp con theo dõi nhiệm vụ, xem số xu, và nhiều thứ thú vị khác! 🌱',
    'giỏi': 'Con đang làm rất tốt! Tuần này con đã hoàn thành 5 nhiệm vụ và kiếm được 110 xu. Bố/Mẹ rất tự hào về con! 💛',
    'mệt': 'Nghỉ ngơi một chút là ổn thôi con ơi! Nhưng đừng quên còn 2 nhiệm vụ chờ con nhé. Sau khi nghỉ ngơi xong, con sẽ làm được thôi! 😊',
    'buồn': 'Con buồn à? Mình ở đây để lắng nghe con nè. Nhớ rằng bố/mẹ luôn yêu con và tự hào về con dù kết quả thế nào! ❤️',
    'tiết kiệm': 'Tiết kiệm là thói quen rất tốt! Hũ Tiết kiệm của con đang có 255 xu (30% tổng xu). Con đang tiết kiệm để mua Lego Technic. Mục tiêu gần rồi! 🏦',
    'bố': 'Bố có nhắn tin cho con là: "Minh ơi, hôm nay con làm rất tốt! Bố rất tự hào về con 💛"',
    'mẹ': 'Mẹ muốn nhắn với con: Con hãy cố gắng hoàn thành bài tập hôm nay nhé, mẹ tin con làm được! 🌸',
  };

  static const _defaults = [
    'Hôm nay con có 2 nhiệm vụ cần hoàn thành. Con có muốn xem chi tiết không? 📋',
    'Con đang tiết kiệm rất tốt! Chỉ còn 150 xu nữa là mua được Lego Technic rồi! 🧱',
    'Bố/Mẹ vừa giao thêm nhiệm vụ mới cho con. Vào tab Nhiệm vụ để xem nhé! 🎯',
    'Con đã kiếm được 850 xu tổng cộng. Thật tuyệt vời! Tiếp tục phát huy nhé! 💪',
  ];

  int _defaultIdx = 0;

  @override
  void initState() {
    super.initState();
    final app = context.read<AppState>();
    final s = app.strings;
    final name = app.childName.isNotEmpty ? app.childName : 'bạn nhỏ';
    _msgs.add(_Msg(
      text: s.aiGreeting(name),
      isAi: true,
    ));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _send() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _msgs.add(_Msg(text: text, isAi: false));
      _typing = true;
    });
    _ctrl.clear();
    _scrollDown();

    final lower = text.toLowerCase();
    String? reply;
    for (final entry in _replies.entries) {
      if (lower.contains(entry.key)) {
        reply = entry.value;
        break;
      }
    }
    reply ??= _defaults[_defaultIdx % _defaults.length];
    _defaultIdx++;

    Timer(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      setState(() {
        _typing = false;
        _msgs.add(_Msg(text: reply!, isAi: true));
      });
      _scrollDown();
    });
  }

  void _sendQuick(String text) {
    _ctrl.text = text;
    _send();
  }

  void _scrollDown() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>().strings;
    return Scaffold(
      backgroundColor: AppTheme.surfaceBright,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceContainerLowest,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.primaryFixed,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.primaryFixedDim, width: 2),
              ),
              child: const Center(child: Text('🤖', style: TextStyle(fontSize: 20))),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'GrowWise AI',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppTheme.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      s.aiOnline,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: AppTheme.textHint,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: AppTheme.surfaceContainerHigh),
        ),
      ),
      body: Column(
        children: [
          // Quick actions
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            color: AppTheme.surfaceContainerLowest,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _QuickChip(s.aiQuickTasks, () => _sendQuick('Nhiệm vụ hôm nay của con là gì?')),
                  _QuickChip(s.aiQuickCoins, () => _sendQuick('Con có bao nhiêu xu?')),
                  _QuickChip(s.aiQuickDreams, () => _sendQuick('Con đang tiết kiệm ước mơ gì?')),
                  _QuickChip(s.aiQuickMessage, () => _sendQuick('Bố có nhắn gì cho con không?')),
                ],
              ),
            ),
          ),

          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              itemCount: _msgs.length + (_typing ? 1 : 0),
              itemBuilder: (ctx, i) {
                if (i == _msgs.length) return const _TypingBubble();
                final msg = _msgs[i];
                return _ChatBubble(msg: msg)
                    .animate()
                    .fadeIn(duration: 300.ms)
                    .slideY(begin: 0.1, end: 0);
              },
            ),
          ),

          // Input
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLowest,
              border: Border(top: BorderSide(color: AppTheme.surfaceContainerHigh)),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceBright,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppTheme.surfaceContainerHigh, width: 2),
                      ),
                      child: TextField(
                        controller: _ctrl,
                        onSubmitted: (_) => _send(),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: AppTheme.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: s.aiInputHint,
                          hintStyle: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            color: AppTheme.textHint,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _send,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppTheme.vibrantPrimary,
                        shape: BoxShape.circle,
                        boxShadow: const [
                          BoxShadow(color: AppTheme.onPrimaryFixedVariant, offset: Offset(0, 3)),
                        ],
                      ),
                      child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Msg {
  final String text;
  final bool isAi;
  _Msg({required this.text, required this.isAi});
}

class _ChatBubble extends StatelessWidget {
  final _Msg msg;
  const _ChatBubble({required this.msg});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: msg.isAi ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (msg.isAi) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppTheme.primaryFixed,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primaryFixedDim),
              ),
              child: const Center(child: Text('🤖', style: TextStyle(fontSize: 16))),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: msg.isAi ? AppTheme.surfaceContainerLowest : AppTheme.vibrantPrimary,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: msg.isAi ? const Radius.circular(4) : const Radius.circular(20),
                  bottomRight: msg.isAi ? const Radius.circular(20) : const Radius.circular(4),
                ),
                border: msg.isAi ? Border.all(color: AppTheme.surfaceContainerHigh, width: 2) : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                msg.text,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  height: 1.5,
                  color: msg.isAi ? AppTheme.textPrimary : Colors.white,
                ),
              ),
            ),
          ),
          if (!msg.isAi) const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _TypingBubble extends StatefulWidget {
  const _TypingBubble();

  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppTheme.primaryFixed,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.primaryFixedDim),
            ),
            child: const Center(child: Text('🤖', style: TextStyle(fontSize: 16))),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLowest,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(20),
              ),
              border: Border.all(color: AppTheme.surfaceContainerHigh, width: 2),
            ),
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (ctx, _) => Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (i) {
                  final delay = i / 3;
                  final t = (_ctrl.value - delay).clamp(0.0, 1.0);
                  final bounce = t < 0.5 ? 2 * t : 2 * (1 - t);
                  return Transform.translate(
                    offset: Offset(0, -4 * bounce),
                    child: Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.vibrantPrimary.withValues(alpha: 0.5 + bounce * 0.5),
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _QuickChip(this.label, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.primaryFixed,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.primaryFixedDim, width: 2),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppTheme.vibrantPrimary,
          ),
        ),
      ),
    );
  }
}

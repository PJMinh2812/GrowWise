import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/video_lesson_model.dart';
import '../../providers/app_state.dart';

const _kPrimary = Color(0xFF630ED4);
const _kPrimaryFixed = Color(0xFFEADDFF);
const _kSecondaryContainer = Color(0xFFFEA619);
const _kSurface = Color(0xFFFDF9EE);
const _kOnSurface = Color(0xFF1C1C15);
const _kOnSurfaceVariant = Color(0xFF4A4455);
const _kGreen = Color(0xFF22C55E);
const _kGreenDark = Color(0xFF005321);
const _kSurfaceContainerHigh = Color(0xFFECE8DD);
const _kTertiaryFixed = Color(0xFF6BFF8F);
const _kOnTertiaryFixed = Color(0xFF002109);

class StoryReaderScreen extends StatefulWidget {
  final VideoLesson lesson;
  const StoryReaderScreen({super.key, required this.lesson});

  @override
  State<StoryReaderScreen> createState() => _StoryReaderScreenState();
}

class _StoryReaderScreenState extends State<StoryReaderScreen> {
  final PageController _pageCtrl = PageController();
  final FlutterTts _tts = FlutterTts();
  int _currentPage = 0;
  bool _ttsReady = false;
  bool _isSpeaking = false;

  // Quiz state (shown after last page)
  bool _showQuiz = false;
  int? _selectedOption;
  bool _answered = false;

  List<StoryPage> get _pages => widget.lesson.storyPages;
  VideoQuiz? get _quiz => widget.lesson.quizzes.isNotEmpty ? widget.lesson.quizzes.first : null;
  bool get _onLastPage => _currentPage == _pages.length - 1;
  bool get _hasPages => _pages.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    final langs = await _tts.getLanguages as List?;
    if (langs != null) {
      final hasVi = langs.contains('vi-VN') || langs.contains('vi');
      if (hasVi) {
        await _tts.setLanguage(langs.contains('vi-VN') ? 'vi-VN' : 'vi');
        _ttsReady = true;
      }
    } else {
      await _tts.setLanguage('vi-VN');
      _ttsReady = true;
    }
    await _tts.setSpeechRate(0.45);
    await _tts.setPitch(1.05);
    await _tts.setVolume(1.0);
    _tts.setCompletionHandler(() {
      if (mounted) setState(() => _isSpeaking = false);
    });
    if (mounted) setState(() {});
  }

  Future<void> _speak(String text) async {
    if (_isSpeaking) {
      await _tts.stop();
      setState(() => _isSpeaking = false);
      return;
    }
    setState(() => _isSpeaking = true);
    await _tts.speak(text);
  }

  void _goNext() {
    if (_onLastPage) {
      if (_quiz != null) {
        setState(() => _showQuiz = true);
      } else {
        _complete();
      }
    } else {
      _tts.stop();
      setState(() => _isSpeaking = false);
      _pageCtrl.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _goPrev() {
    if (_currentPage > 0) {
      _tts.stop();
      setState(() => _isSpeaking = false);
      _pageCtrl.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _selectOption(int i) {
    if (_answered) return;
    setState(() {
      _selectedOption = i;
      _answered = true;
    });
  }

  void _complete() {
    final app = context.read<AppState>();
    if (!app.isLessonCompleted(widget.lesson.id)) {
      app.markLessonCompleted(widget.lesson.id);
    }
    _showCompletionDialog();
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (ctx) => _CompletionDialog(
        title: widget.lesson.title,
        onDone: () {
          Navigator.pop(ctx);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  void dispose() {
    _tts.stop();
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final safeTop = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: _kSurface,
      body: Column(
        children: [
          // Top bar
          Container(
            padding: EdgeInsets.fromLTRB(16, safeTop + 8, 16, 12),
            decoration: const BoxDecoration(
              color: _kSurface,
              border: Border(bottom: BorderSide(color: _kSurfaceContainerHigh, width: 1)),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: _kSurfaceContainerHigh,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.arrow_back_rounded, color: _kOnSurface, size: 20),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.lesson.title,
                    style: GoogleFonts.nunitoSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: _kOnSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (!_showQuiz)
                  Text(
                    '${_currentPage + 1}/${_pages.length}',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _kOnSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),

          // Progress bar
          if (!_showQuiz && _hasPages)
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: (_currentPage + 1) / _pages.length),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              builder: (context2, v, child) => LinearProgressIndicator(
                value: v,
                minHeight: 6,
                backgroundColor: _kSurfaceContainerHigh,
                valueColor: const AlwaysStoppedAnimation<Color>(_kPrimary),
              ),
            ),

          // Main content
          Expanded(
            child: _showQuiz
                ? _buildQuiz()
                : !_hasPages
                    ? _buildEmptyState()
                    : _buildReader(),
          ),
        ],
      ),
    );
  }

  Widget _buildReader() {
    return Column(
      children: [
        // Page image
        Expanded(
          child: PageView.builder(
            controller: _pageCtrl,
            itemCount: _pages.length,
            onPageChanged: (i) {
              _tts.stop();
              setState(() {
                _currentPage = i;
                _isSpeaking = false;
              });
            },
            itemBuilder: (_, i) {
              final page = _pages[i];
              return Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  children: [
                    // Image
                    Expanded(
                      flex: 3,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: page.imageUrl.isNotEmpty
                            ? Image.network(
                                page.imageUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder: (ctx, err, stack) => _PlaceholderImage(emoji: widget.lesson.thumbnailEmoji),
                              )
                            : _PlaceholderImage(emoji: widget.lesson.thumbnailEmoji),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Caption
                    Expanded(
                      flex: 1,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _kPrimaryFixed,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: SingleChildScrollView(
                          child: Text(
                            page.caption,
                            style: GoogleFonts.nunitoSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: _kOnSurface,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        // Bottom navigation
        Container(
          padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).padding.bottom + 16),
          child: Row(
            children: [
              // Prev button
              _NavButton(
                icon: Icons.arrow_back_rounded,
                onTap: _currentPage > 0 ? _goPrev : null,
              ),
              const SizedBox(width: 12),
              // TTS button
              if (_ttsReady)
                _TtsButton(
                  isSpeaking: _isSpeaking,
                  onTap: () {
                    final caption = _pages[_currentPage].caption;
                    if (caption.isNotEmpty) _speak(caption);
                  },
                ),
              const Spacer(),
              // Next / Finish button
              _NavButton(
                icon: _onLastPage ? Icons.check_rounded : Icons.arrow_forward_rounded,
                filled: true,
                onTap: _goNext,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuiz() {
    final quiz = _quiz!;
    final options = quiz.options.toList();
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '❓ Câu hỏi!',
            style: GoogleFonts.nunitoSans(fontSize: 13, fontWeight: FontWeight.w700, color: _kPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            quiz.question,
            style: GoogleFonts.nunitoSans(fontSize: 18, fontWeight: FontWeight.w800, color: _kOnSurface, height: 1.3),
          ),
          const SizedBox(height: 20),
          ...options.asMap().entries.map((entry) {
            final i = entry.key;
            final opt = entry.value;
            final isPicked = _selectedOption == i;
            final isCorrect = i == quiz.correctIndex;
            Color borderColor;
            Color bgColor;
            if (!_answered) {
              borderColor = _kSurfaceContainerHigh;
              bgColor = Colors.white;
            } else if (isCorrect) {
              borderColor = _kGreen;
              bgColor = const Color(0xFFE8FFF0);
            } else if (isPicked) {
              borderColor = Colors.red;
              bgColor = const Color(0xFFFFF0F0);
            } else {
              borderColor = _kSurfaceContainerHigh;
              bgColor = Colors.white;
            }
            return GestureDetector(
              onTap: () => _selectOption(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor, width: 2),
                ),
                child: Row(
                  children: [
                    Text(opt.emoji, style: const TextStyle(fontSize: 22)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        opt.text,
                        style: GoogleFonts.nunitoSans(fontSize: 15, fontWeight: FontWeight.w700, color: _kOnSurface),
                      ),
                    ),
                    if (_answered && isCorrect)
                      const Icon(Icons.check_circle_rounded, color: _kGreen, size: 20),
                    if (_answered && isPicked && !isCorrect)
                      const Icon(Icons.cancel_rounded, color: Colors.red, size: 20),
                  ],
                ),
              ),
            );
          }),
          if (_answered) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _selectedOption == quiz.correctIndex ? const Color(0xFFE8FFF0) : const Color(0xFFFFF0F0),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                (_selectedOption == quiz.correctIndex ? 'Chính xác! ' : 'Chưa đúng. ') + quiz.explanation,
                style: GoogleFonts.nunitoSans(
                  fontSize: 14,
                  color: _selectedOption == quiz.correctIndex ? _kGreenDark : Colors.red.shade800,
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: FilledButton(
                onPressed: _complete,
                style: FilledButton.styleFrom(
                  backgroundColor: _kPrimary,
                  shape: const StadiumBorder(),
                ),
                child: Text(
                  'Hoàn thành bài học 🎉',
                  style: GoogleFonts.nunitoSans(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('📖', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              widget.lesson.title,
              textAlign: TextAlign.center,
              style: GoogleFonts.nunitoSans(fontSize: 20, fontWeight: FontWeight.w800, color: _kOnSurface),
            ),
            const SizedBox(height: 8),
            Text(
              widget.lesson.description,
              textAlign: TextAlign.center,
              style: GoogleFonts.nunitoSans(fontSize: 14, color: _kOnSurfaceVariant, height: 1.5),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(
                onPressed: _complete,
                style: FilledButton.styleFrom(backgroundColor: _kPrimary, shape: const StadiumBorder()),
                child: Text('Đánh dấu hoàn thành', style: GoogleFonts.nunitoSans(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sub-widgets ────────────────────────────────────────────────────────────────

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool filled;
  const _NavButton({required this.icon, this.onTap, this.filled = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.35 : 1.0,
        child: Container(
          width: 52, height: 52,
          decoration: BoxDecoration(
            color: filled ? _kPrimary : _kSurfaceContainerHigh,
            borderRadius: BorderRadius.circular(16),
            boxShadow: filled
                ? [BoxShadow(color: _kPrimary.withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 3))]
                : null,
          ),
          child: Icon(icon, color: filled ? Colors.white : _kOnSurface, size: 24),
        ),
      ),
    );
  }
}

class _TtsButton extends StatelessWidget {
  final bool isSpeaking;
  final VoidCallback onTap;
  const _TtsButton({required this.isSpeaking, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 52, height: 52,
        decoration: BoxDecoration(
          color: isSpeaking ? _kSecondaryContainer : _kSurfaceContainerHigh,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          isSpeaking ? Icons.volume_up_rounded : Icons.volume_off_rounded,
          color: isSpeaking ? Colors.white : _kOnSurfaceVariant,
          size: 24,
        ),
      ),
    );
  }
}

class _PlaceholderImage extends StatelessWidget {
  final String emoji;
  const _PlaceholderImage({required this.emoji});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _kPrimaryFixed,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Center(child: Text(emoji, style: const TextStyle(fontSize: 80))),
    );
  }
}

class _CompletionDialog extends StatelessWidget {
  final String title;
  final VoidCallback onDone;
  const _CompletionDialog({required this.title, required this.onDone});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      backgroundColor: _kSurface,
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 12),
            Text(
              'Xuất sắc!',
              style: GoogleFonts.nunitoSans(fontSize: 24, fontWeight: FontWeight.w900, color: _kOnSurface),
            ),
            const SizedBox(height: 8),
            Text(
              'Bạn đã đọc xong "$title"',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunitoSans(fontSize: 14, color: _kOnSurfaceVariant, height: 1.5),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _kTertiaryFixed,
                borderRadius: BorderRadius.circular(99),
                boxShadow: const [BoxShadow(color: Color(0xFF005C26), offset: Offset(0, 2))],
              ),
              child: Text(
                '+10 XP',
                style: GoogleFonts.nunitoSans(fontSize: 16, fontWeight: FontWeight.w800, color: _kOnTertiaryFixed),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: onDone,
                style: FilledButton.styleFrom(backgroundColor: _kPrimary, shape: const StadiumBorder()),
                child: Text(
                  'Tiếp tục',
                  style: GoogleFonts.nunitoSans(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

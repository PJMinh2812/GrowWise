import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../models/video_lesson_model.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';
import '../../utils/age_group.dart';

class VideoLessonScreen extends StatefulWidget {
  final VideoLesson lesson;
  const VideoLessonScreen({super.key, required this.lesson});

  @override
  State<VideoLessonScreen> createState() => _VideoLessonScreenState();
}

class _VideoLessonScreenState extends State<VideoLessonScreen> {
  late YoutubePlayerController _vc;
  final FlutterTts _tts = FlutterTts();
  late StreamSubscription<Object> _positionSub;
  bool _ttsAvailable = true;
  final Set<int> _shownQuizIndexes = {};
  VideoQuiz? _activeQuiz;
  bool _answered = false;
  int? _selectedOption;

  @override
  void initState() {
    super.initState();
    _vc = YoutubePlayerController.fromVideoId(
      videoId: widget.lesson.youtubeId,
      autoPlay: false,
      params: const YoutubePlayerParams(showControls: true, showFullscreenButton: true),
    );
    _positionSub = _vc.videoStateStream.listen((state) {
      _onPosition(state.position);
      if (state.position >= Duration(seconds: widget.lesson.durationSeconds - 2) &&
          state.position > Duration.zero) {
        _onVideoEnd();
      }
    });
    _initTts();
  }

  Future<void> _initTts() async {
    // Check available languages and pick best Vietnamese option
    final langs = await _tts.getLanguages as List?;
    String lang = 'vi-VN';
    if (langs != null) {
      if (langs.contains('vi-VN')) {
        lang = 'vi-VN';
      } else if (langs.contains('vi')) {
        lang = 'vi';
      }
      // If neither found, TTS will use device default — show warning below
      _ttsAvailable = langs.contains('vi-VN') || langs.contains('vi');
    }
    await _tts.setLanguage(lang);
    await _tts.setSpeechRate(0.75); // slower = clearer for kids
    await _tts.setPitch(1.1);       // slightly higher = friendlier tone
    await _tts.setVolume(1.0);
    if (mounted) setState(() {});
  }

  void _onPosition(Duration position) {
    if (_activeQuiz != null) return;
    final secs = position.inSeconds;
    for (int i = 0; i < widget.lesson.quizzes.length; i++) {
      final quiz = widget.lesson.quizzes[i];
      if (!_shownQuizIndexes.contains(i) && secs >= quiz.triggerAt) {
        _shownQuizIndexes.add(i);
        _vc.pauseVideo();
        setState(() {
          _activeQuiz = quiz;
          _answered = false;
          _selectedOption = null;
        });
        final isYoung = context.read<AppState>().childAge.ageGroup == AgeGroup.young;
        if (isYoung || widget.lesson.audience == 'child') {
          _tts.speak(quiz.question);
        }
        break;
      }
    }
  }

  void _selectOption(int index) {
    if (_answered) return;
    setState(() {
      _selectedOption = index;
      _answered = true;
    });
  }

  void _resumeVideo() {
    setState(() => _activeQuiz = null);
    _vc.playVideo();
  }

  void _onVideoEnd() {
    final app = context.read<AppState>();
    if (!app.isLessonCompleted(widget.lesson.id)) {
      app.markLessonCompleted(widget.lesson.id);
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎓', style: TextStyle(fontSize: 64))
                .animate()
                .scale(begin: const Offset(0.2, 0.2), duration: 600.ms, curve: Curves.elasticOut),
            const SizedBox(height: 12),
            Text(
              'Hoàn thành bài học!',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.textPrimary,
              ),
            ).animate(delay: 200.ms).fadeIn(),
            const SizedBox(height: 8),
            Text(
              '+10 XP đã được cộng vào tài khoản!',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13, color: AppTheme.textSecondary,
              ),
            ).animate(delay: 300.ms).fadeIn(),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.vibrantPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(
                'Tuyệt vời! 🎉',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showTtsHintDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Cài giọng Tiếng Việt',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
        content: Text(
          'Android:\nSettings → General management → Language & Input → Text-to-speech → Google TTS → Install Vietnamese\n\n'
          'iOS:\nSettings → Accessibility → Spoken Content → Voices → Vietnamese\n\n'
          'Giả lập Android:\nSettings → General management → Text-to-speech → Google TTS → Settings → Install voice data → Vietnamese',
          style: GoogleFonts.plusJakartaSans(fontSize: 13, height: 1.5),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.vibrantPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Đã hiểu',
                style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _positionSub.cancel();
    _vc.close();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerControllerProvider(
      controller: _vc,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(
            widget.lesson.title,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15,
            ),
          ),
        ),
        body: Column(
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: YoutubePlayer(controller: _vc),
            ),
            if (_activeQuiz != null)
              Expanded(
                child: _QuizOverlay(
                  quiz: _activeQuiz!,
                  answered: _answered,
                  selectedOption: _selectedOption,
                  onSelect: _selectOption,
                  onResume: _resumeVideo,
                  ttsAvailable: _ttsAvailable,
                  onSpeakQuestion: () => _tts.speak(_activeQuiz!.question),
                  onSpeakOption: (text) => _tts.speak(text),
                  onShowTtsHint: () => _showTtsHintDialog(context),
                ),
              )
            else
              Expanded(
                child: _LessonInfo(lesson: widget.lesson),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Quiz Overlay ──────────────────────────────────────────────────────────────

class _QuizOverlay extends StatelessWidget {
  final VideoQuiz quiz;
  final bool answered;
  final int? selectedOption;
  final void Function(int) onSelect;
  final VoidCallback onResume;
  final bool ttsAvailable;
  final VoidCallback onSpeakQuestion;
  final void Function(String) onSpeakOption;
  final VoidCallback onShowTtsHint;

  const _QuizOverlay({
    required this.quiz,
    required this.answered,
    required this.selectedOption,
    required this.onSelect,
    required this.onResume,
    required this.ttsAvailable,
    required this.onSpeakQuestion,
    required this.onSpeakOption,
    required this.onShowTtsHint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.surfaceBright,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Text('🤔', style: TextStyle(fontSize: 22)),
                const SizedBox(width: 8),
                Text(
                  'Câu hỏi!',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textPrimary,
                  ),
                ),
                const Spacer(),
                if (ttsAvailable)
                  IconButton(
                    icon: const Icon(Icons.volume_up_rounded, color: AppTheme.vibrantPrimary),
                    onPressed: onSpeakQuestion,
                    tooltip: 'Đọc câu hỏi',
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.volume_off_rounded, color: AppTheme.outline),
                    onPressed: () => onShowTtsHint(),
                    tooltip: 'Chưa có giọng Tiếng Việt',
                  ),
              ],
            ).animate().slideY(begin: 0.2).fadeIn(),
            // TTS unavailable banner
            if (!ttsAvailable) ...[
              const SizedBox(height: 6),
              GestureDetector(
                onTap: onShowTtsHint,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFED7AA)),
                  ),
                  child: Row(
                    children: [
                      const Text('🔔', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Chưa có giọng Tiếng Việt — nhấn để xem cách cài',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11, color: const Color(0xFF92400E),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate(delay: 200.ms).fadeIn(),
            ],
            const SizedBox(height: 8),
            Text(
              quiz.question,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 17, fontWeight: FontWeight.w700, color: AppTheme.textPrimary, height: 1.4,
              ),
            ).animate(delay: 100.ms).fadeIn(),
            const SizedBox(height: 16),
            // Options
            ...quiz.options.asMap().entries.map((entry) {
              final i = entry.key;
              final opt = entry.value;
              final isCorrect = i == quiz.correctIndex;
              final isSelected = selectedOption == i;

              Color borderColor = AppTheme.outlineVariant;
              Color bgColor = AppTheme.surfaceContainerLowest;
              if (answered && isCorrect) {
                borderColor = const Color(0xFF22C55E);
                bgColor = const Color(0xFFF0FDF4);
              } else if (answered && isSelected && !isCorrect) {
                borderColor = const Color(0xFFEF4444);
                bgColor = const Color(0xFFFFF1F2);
              }

              return GestureDetector(
                onTap: () {
                  if (!answered) onSelect(i);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor, width: 2),
                  ),
                  child: Row(
                    children: [
                      Text(opt.emoji, style: const TextStyle(fontSize: 28)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          opt.text,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14, fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      if (answered && isCorrect)
                        const Icon(Icons.check_circle, color: Color(0xFF22C55E)),
                      if (answered && isSelected && !isCorrect)
                        const Icon(Icons.cancel, color: Color(0xFFEF4444)),
                      IconButton(
                        icon: const Icon(Icons.volume_up_rounded, size: 18, color: AppTheme.outline),
                        onPressed: () => onSpeakOption(opt.text),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
              ).animate(delay: Duration(milliseconds: 150 + i * 80)).slideX(begin: 0.15).fadeIn();
            }),
            if (answered) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.primaryFixed,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  '💡 ${quiz.explanation}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13, color: AppTheme.textPrimary, height: 1.4,
                  ),
                ),
              ).animate().fadeIn().slideY(begin: 0.1),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: onResume,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.vibrantPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    'Tiếp tục xem ▶',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ),
              ).animate().fadeIn(),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Lesson Info ───────────────────────────────────────────────────────────────

class _LessonInfo extends StatelessWidget {
  final VideoLesson lesson;
  const _LessonInfo({required this.lesson});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final completed = app.isLessonCompleted(lesson.id);

    return Container(
      color: AppTheme.surfaceBright,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(lesson.thumbnailEmoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  lesson.title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textPrimary,
                  ),
                ),
              ),
              if (completed)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('✅ Hoàn thành',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF16A34A),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            lesson.description,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14, color: AppTheme.textSecondary, height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _InfoChip('🎯', lesson.category),
              const SizedBox(width: 8),
              _InfoChip('⏱', '${lesson.durationSeconds ~/ 60} phút'),
              const SizedBox(width: 8),
              _InfoChip('❓', '${lesson.quizzes.length} câu hỏi'),
            ],
          ),
          if (!completed) ...[
            const SizedBox(height: 12),
            Text(
              '💡 Hoàn thành bài học để nhận +10 XP!',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12, color: AppTheme.vibrantPrimary, fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String emoji;
  final String label;
  const _InfoChip(this.emoji, this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$emoji $label',
        style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.textSecondary),
      ),
    );
  }
}

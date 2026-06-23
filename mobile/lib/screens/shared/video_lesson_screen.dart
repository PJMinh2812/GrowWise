import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../models/video_lesson_model.dart';
import '../../providers/app_state.dart';
import '../../utils/age_group.dart';

// Stitch "Storybook Finance" palette
const _kPrimary = Color(0xFF630ED4);
const _kPrimaryFixed = Color(0xFFEADDFF);
const _kPrimaryFixedDim = Color(0xFFD2BBFF);
const _kPrimaryContainer = Color(0xFF7C3AED);
const _kOnPrimaryFixedVariant = Color(0xFF5A00C6);
const _kSecondaryContainer = Color(0xFFFEA619);
const _kOnSecondaryContainer = Color(0xFF684000);
const _kTertiaryFixed = Color(0xFF6BFF8F);
const _kOnTertiaryFixed = Color(0xFF002109);
const _kSurface = Color(0xFFFDF9EE);
const _kSurfaceContainerLowest = Color(0xFFFFFFFF);
const _kSurfaceContainerHigh = Color(0xFFECE8DD);
const _kSurfaceVariant = Color(0xFFE6E2D8);
const _kOnSurface = Color(0xFF1C1C15);
const _kOnSurfaceVariant = Color(0xFF4A4455);
const _kOutline = Color(0xFF7B7487);
const _kGreen = Color(0xFF22C55E);
const _kGreenBg = Color(0xFFF0FDF4);
const _kGreenDark = Color(0xFF005321);
const _kRed = Color(0xFFEF4444);
const _kRedBg = Color(0xFFFFF1F2);

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
  late StreamSubscription<YoutubePlayerValue> _playerStateSub;
  bool _ttsAvailable = true;
  bool _videoStarted = false;
  int _maxReachedSeconds = 0;
  int _lastPositionSeconds = 0;
  final Set<int> _shownQuizIndexes = {};
  VideoQuiz? _activeQuiz;
  bool _answered = false;
  int? _selectedOption;

  @override
  void initState() {
    super.initState();
    _vc = YoutubePlayerController.fromVideoId(
      videoId: widget.lesson.youtubeId ?? '',
      autoPlay: false,
      params: const YoutubePlayerParams(
        showControls: false,
        showFullscreenButton: false,
      ),
    );
    final threshold85 = (widget.lesson.durationSeconds * 0.85).floor();
    _positionSub = _vc.videoStateStream.listen((state) {
      // Always keep paused during quiz
      if (_activeQuiz != null) {
        if (_vc.value.playerState == PlayerState.playing) _vc.pauseVideo();
        return;
      }

      final positionSec = state.position.inSeconds;

      // Prevent forward seeking: detect jump > 8s ahead of last known position
      // AND ahead of furthest point already watched
      if (mounted) {
        final isCompleted = context.read<AppState>().isLessonCompleted(
          widget.lesson.id,
        );
        if (!isCompleted) {
          final jumpedAhead = positionSec - _lastPositionSeconds;
          if (jumpedAhead > 300 && positionSec > _maxReachedSeconds + 300) {
            _vc.seekTo(seconds: _maxReachedSeconds.toDouble());
            return;
          }
        }
      }

      if (positionSec > _maxReachedSeconds) _maxReachedSeconds = positionSec;
      _lastPositionSeconds = positionSec;

      _onPosition(state.position);
      if (state.position >= Duration(seconds: threshold85) &&
          state.position > Duration.zero) {
        _onVideoEnd();
      }
    });
    _playerStateSub = _vc.stream.listen((value) {
      if (value.playerState == PlayerState.ended) _onVideoEnd();
    });
    _initTts();
  }

  Future<void> _initTts() async {
    final langs = await _tts.getLanguages as List?;
    String lang = 'vi-VN';
    if (langs != null) {
      if (langs.contains('vi-VN')) {
        lang = 'vi-VN';
      } else if (langs.contains('vi')) {
        lang = 'vi';
      }
      _ttsAvailable = langs.contains('vi-VN') || langs.contains('vi');
    }
    await _tts.setLanguage(lang);
    await _tts.setSpeechRate(0.4);
    await _tts.setPitch(1.0);
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
        final isYoung =
            context.read<AppState>().childAge.ageGroup == AgeGroup.young;
        if (isYoung || widget.lesson.audience == 'child')
          _tts.speak(quiz.question);
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
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (ctx) => _CompletionDialog(
        onDone: () {
          Navigator.pop(ctx);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showTtsHintDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Cài giọng Tiếng Việt',
          style: GoogleFonts.nunitoSans(
            fontWeight: FontWeight.w800,
            color: _kOnSurface,
          ),
        ),
        content: Text(
          'Android:\nSettings → General management → Language & Input → Text-to-speech → Google TTS → Install Vietnamese\n\n'
          'iOS:\nSettings → Accessibility → Spoken Content → Voices → Vietnamese\n\n'
          'Giả lập Android:\nSettings → General management → Text-to-speech → Google TTS → Settings → Install voice data → Vietnamese',
          style: GoogleFonts.nunitoSans(
            fontSize: 13,
            height: 1.5,
            color: _kOnSurfaceVariant,
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            style: FilledButton.styleFrom(
              backgroundColor: _kPrimary,
              shape: const StadiumBorder(),
            ),
            child: Text(
              'Đã hiểu',
              style: GoogleFonts.nunitoSans(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _positionSub.cancel();
    _playerStateSub.cancel();
    _vc.close();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final completed = context.watch<AppState>().isLessonCompleted(
      widget.lesson.id,
    );
    return YoutubePlayerControllerProvider(
      controller: _vc,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          children: [
            // ── Video Zone ─────────────────────────────────────────────
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: YoutubePlayer(controller: _vc),
                ),
                // Emoji thumbnail overlay — hides iframe before user starts
                if (!_videoStarted)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black,
                      child: Center(
                        child: Text(
                          widget.lesson.thumbnailEmoji,
                          style: const TextStyle(fontSize: 80),
                        ),
                      ),
                    ),
                  ),

                // Quiz active: fully opaque cover so video is completely hidden
                if (_activeQuiz != null)
                  Positioned.fill(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {},
                      onPanDown: (_) {},
                      child: Container(
                        color: Colors.black,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('🤔', style: TextStyle(fontSize: 40)),
                              const SizedBox(height: 8),
                              Text(
                                'Trả lời câu hỏi để tiếp tục',
                                style: GoogleFonts.nunitoSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                // Gradient + title overlay (normal state)
                if (_activeQuiz == null)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.8),
                            ],
                            stops: const [0.45, 1.0],
                          ),
                        ),
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _kSecondaryContainer,
                                borderRadius: BorderRadius.circular(99),
                                boxShadow: [
                                  BoxShadow(
                                    color: _kOnSecondaryContainer.withValues(
                                      alpha: 0.4,
                                    ),
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                '+10 XP',
                                style: GoogleFonts.nunitoSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: _kOnSecondaryContainer,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.lesson.title,
                              style: GoogleFonts.nunitoSans(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                // Back button
                Positioned(
                  top: MediaQuery.of(context).padding.top + 8,
                  left: 16,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // ── Bottom Content Panel ───────────────────────────────────
            if (_activeQuiz != null)
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: _kSurfaceContainerLowest,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                  ),
                  child: _QuizPanel(
                    quiz: _activeQuiz!,
                    answered: _answered,
                    selectedOption: _selectedOption,
                    onSelect: _selectOption,
                    onResume: _resumeVideo,
                    ttsAvailable: _ttsAvailable,
                    onSpeakQuestion: () => _tts.speak(_activeQuiz!.question),
                    onSpeakOption: (t) => _tts.speak(t),
                    onShowTtsHint: () => _showTtsHintDialog(context),
                  ),
                ),
              )
            else if (!_videoStarted)
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: _kSurfaceContainerLowest,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                  ),
                  child: _LessonInfoPanel(
                    lesson: widget.lesson,
                    completed: completed,
                    started: false,
                    onStart: () {
                      setState(() => _videoStarted = true);
                      _vc.playVideo();
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Lesson Info Panel ─────────────────────────────────────────────────────────

class _LessonInfoPanel extends StatelessWidget {
  final VideoLesson lesson;
  final bool completed;
  final bool started;
  final VoidCallback onStart;

  const _LessonInfoPanel({
    required this.lesson,
    required this.completed,
    required this.started,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 12),
        Container(
          width: 48,
          height: 5,
          decoration: BoxDecoration(
            color: _kSurfaceVariant,
            borderRadius: BorderRadius.circular(99),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _kPrimaryFixed,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: const [
                          BoxShadow(
                            color: _kPrimaryFixedDim,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          lesson.thumbnailEmoji,
                          style: const TextStyle(fontSize: 26),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        lesson.title,
                        style: GoogleFonts.nunitoSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: _kOnSurface,
                          height: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (completed)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _kTertiaryFixed,
                          borderRadius: BorderRadius.circular(99),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0xFF005C26),
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.check_circle_rounded,
                              size: 14,
                              color: _kOnTertiaryFixed,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Hoàn thành',
                              style: GoogleFonts.nunitoSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: _kOnTertiaryFixed,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  lesson.description,
                  style: GoogleFonts.nunitoSans(
                    fontSize: 15,
                    color: _kOnSurfaceVariant,
                    height: 1.6,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _InfoChip(
                      emoji: '🎯',
                      label: lesson.category,
                      bgColor: const Color(0xFFDBEAFE),
                      textColor: const Color(0xFF1E40AF),
                      borderColor: const Color(0xFFBFDBFE),
                    ),
                    _InfoChip(
                      emoji: '⏱',
                      label: '${lesson.durationSeconds ~/ 60} phút',
                      bgColor: const Color(0xFFEDE9FE),
                      textColor: const Color(0xFF5B21B6),
                      borderColor: const Color(0xFFDDD6FE),
                    ),
                    _InfoChip(
                      emoji: '❓',
                      label: '${lesson.quizzes.length} câu hỏi',
                      bgColor: const Color(0xFFFFF7ED),
                      textColor: const Color(0xFF92400E),
                      borderColor: const Color(0xFFFED7AA),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        // Bottom actions
        Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            8,
            20,
            MediaQuery.of(context).padding.bottom + 20,
          ),
          child: Column(
            children: [
              if (!completed) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: _kPrimaryContainer,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _kPrimaryFixed, width: 2),
                    boxShadow: const [
                      BoxShadow(
                        color: _kOnPrimaryFixedVariant,
                        offset: Offset(0, 4),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text('💡', style: TextStyle(fontSize: 18)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Hoàn thành để nhận +10 XP!',
                        style: GoogleFonts.nunitoSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 12),
              ],
              // Ẩn nút khi đang học (chưa hoàn thành) — chỉ giữ nút "Xem lại" khi đã xong
              if (!started || completed)
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: FilledButton(
                    onPressed: onStart,
                    style: FilledButton.styleFrom(
                      backgroundColor: _kPrimary,
                      shape: const StadiumBorder(),
                    ),
                    child: Text(
                      completed ? 'Xem lại bài học' : 'Bắt đầu bài học',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Quiz Panel ────────────────────────────────────────────────────────────────

class _QuizPanel extends StatelessWidget {
  final VideoQuiz quiz;
  final bool answered;
  final int? selectedOption;
  final void Function(int) onSelect;
  final VoidCallback onResume;
  final bool ttsAvailable;
  final VoidCallback onSpeakQuestion;
  final void Function(String) onSpeakOption;
  final VoidCallback onShowTtsHint;

  const _QuizPanel({
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
    return Column(
      children: [
        const SizedBox(height: 12),
        Container(
          width: 48,
          height: 5,
          decoration: BoxDecoration(
            color: _kSurfaceVariant,
            borderRadius: BorderRadius.circular(99),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Text(
                      '🤔 Câu hỏi!',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: _kOnSurface,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: ttsAvailable ? onSpeakQuestion : onShowTtsHint,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: ttsAvailable
                              ? _kPrimaryFixed
                              : _kSurfaceContainerHigh,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: ttsAvailable
                                ? _kPrimary.withValues(alpha: 0.2)
                                : Colors.transparent,
                          ),
                        ),
                        child: Icon(
                          ttsAvailable
                              ? Icons.volume_up_rounded
                              : Icons.volume_off_rounded,
                          color: ttsAvailable ? _kPrimary : _kOutline,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn().slideY(begin: 0.1),
                if (!ttsAvailable) ...[
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: onShowTtsHint,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
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
                              style: GoogleFonts.nunitoSans(
                                fontSize: 11,
                                color: const Color(0xFF92400E),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate(delay: 200.ms).fadeIn(),
                ],
                const SizedBox(height: 16),
                Text(
                  quiz.question,
                  style: GoogleFonts.nunitoSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: _kOnSurfaceVariant,
                    height: 1.4,
                  ),
                ).animate(delay: 100.ms).fadeIn(),
                const SizedBox(height: 20),
                // Options
                ...quiz.options.asMap().entries.map((entry) {
                  final i = entry.key;
                  final opt = entry.value;
                  final isCorrect = i == quiz.correctIndex;
                  final isSelected = selectedOption == i;

                  Color borderColor = _kSurfaceVariant;
                  Color bgColor = _kSurfaceContainerLowest;
                  Color textColor = _kOnSurface;
                  Widget? trailingIcon;

                  if (answered && isCorrect) {
                    borderColor = _kGreen;
                    bgColor = _kGreenBg;
                    textColor = _kGreenDark;
                    trailingIcon = const Icon(
                      Icons.check_circle_rounded,
                      color: _kGreen,
                    );
                  } else if (answered && isSelected && !isCorrect) {
                    borderColor = _kRed;
                    bgColor = _kRedBg;
                    trailingIcon = const Icon(
                      Icons.cancel_rounded,
                      color: _kRed,
                    );
                  }

                  return GestureDetector(
                        onTap: answered ? null : () => onSelect(i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: borderColor, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Text(
                                opt.emoji,
                                style: const TextStyle(fontSize: 26),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  opt.text,
                                  style: GoogleFonts.nunitoSans(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: textColor,
                                  ),
                                ),
                              ),
                              if (trailingIcon != null)
                                trailingIcon
                              else
                                GestureDetector(
                                  onTap: () => onSpeakOption(opt.text),
                                  child: const Icon(
                                    Icons.volume_up_rounded,
                                    size: 18,
                                    color: _kOutline,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      )
                      .animate(delay: Duration(milliseconds: 80 * i))
                      .slideX(begin: 0.1)
                      .fadeIn();
                }),
                // Explanation
                if (answered) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _kPrimaryFixed,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _kPrimary.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('💡', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Giỏi lắm!',
                                style: GoogleFonts.nunitoSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: _kOnSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                quiz.explanation,
                                style: GoogleFonts.nunitoSans(
                                  fontSize: 13,
                                  color: _kOnSurfaceVariant,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn().slideY(begin: 0.1),
                ],
              ],
            ),
          ),
        ),
        if (answered)
          Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              0,
              20,
              MediaQuery.of(context).padding.bottom + 20,
            ),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: FilledButton.icon(
                onPressed: onResume,
                style: FilledButton.styleFrom(
                  backgroundColor: _kPrimary,
                  shape: const StadiumBorder(),
                ),
                icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
                label: Text(
                  'Tiếp tục xem',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ).animate().fadeIn().slideY(begin: 0.1),
          ),
      ],
    );
  }
}

// ── Info Chip ─────────────────────────────────────────────────────────────────

class _InfoChip extends StatelessWidget {
  final String emoji;
  final String label;
  final Color bgColor;
  final Color textColor;
  final Color borderColor;

  const _InfoChip({
    required this.emoji,
    required this.label,
    required this.bgColor,
    required this.textColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.nunitoSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Completion Dialog ─────────────────────────────────────────────────────────

class _CompletionDialog extends StatelessWidget {
  final VoidCallback onDone;
  const _CompletionDialog({required this.onDone});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: _kSurfaceContainerLowest,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Hero icon
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: _kSurface,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Text('🎓', style: TextStyle(fontSize: 52)),
              ),
            ).animate().scale(
              begin: const Offset(0.3, 0.3),
              duration: 600.ms,
              curve: Curves.elasticOut,
            ),
            const SizedBox(height: 20),
            Text(
              'Hoàn thành bài học!',
              style: GoogleFonts.nunitoSans(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: _kOnSurface,
              ),
            ).animate(delay: 150.ms).fadeIn(),
            const SizedBox(height: 6),
            Text(
              '+10 XP đã được cộng vào tài khoản!',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunitoSans(
                fontSize: 15,
                color: _kOnSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ).animate(delay: 200.ms).fadeIn(),
            const SizedBox(height: 20),
            // XP reward card
            Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _kPrimaryFixedDim.withValues(alpha: 0.4),
                        _kSecondaryContainer.withValues(alpha: 0.3),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _kOutline.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('⭐', style: TextStyle(fontSize: 26)),
                      const SizedBox(width: 8),
                      Text(
                        '+10 XP',
                        style: GoogleFonts.nunitoSans(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: _kPrimary,
                        ),
                      ),
                    ],
                  ),
                )
                .animate(delay: 300.ms)
                .fadeIn()
                .scale(begin: const Offset(0.9, 0.9)),
            const SizedBox(height: 12),
            // Streak row
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1EEE3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _kSurfaceVariant),
              ),
              child: Row(
                children: [
                  const Text('🔥', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Text(
                    '3 ngày liên tiếp!',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _kOnSurface,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: List.generate(
                      5,
                      (i) => Icon(
                        Icons.star_rounded,
                        size: 20,
                        color: i < 3 ? _kSecondaryContainer : _kSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate(delay: 400.ms).fadeIn(),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: FilledButton(
                onPressed: onDone,
                style: FilledButton.styleFrom(
                  backgroundColor: _kPrimary,
                  shape: const StadiumBorder(),
                  elevation: 4,
                  shadowColor: _kOnPrimaryFixedVariant.withValues(alpha: 0.5),
                ),
                child: Text(
                  'Tuyệt vời! 🎉',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ).animate(delay: 500.ms).fadeIn(),
          ],
        ),
      ),
    );
  }
}

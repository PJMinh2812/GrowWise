import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';
import '../../models/task_model.dart';
import '../../utils/age_group.dart';

class ChildTaskList extends StatefulWidget {
  const ChildTaskList({super.key});

  @override
  State<ChildTaskList> createState() => _ChildTaskListState();
}

class _ChildTaskListState extends State<ChildTaskList>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>().strings;
    return Consumer<AppState>(
      builder: (context, app, child) {
        final pending = app.pendingTasks;
        final submitted = app.submittedTasks;
        final approved = app.approvedTasks;
        final todo = [...pending, ...submitted];

        return Scaffold(
          backgroundColor: AppTheme.surfaceBright,
          body: Column(
            children: [
              _buildHeader(todo.length, approved.length, s),
              Expanded(
                child: TabBarView(
                  controller: _tabCtrl,
                  children: [
                    _TaskSection(tasks: todo, showAction: true),
                    _TaskSection(tasks: approved, showAction: false),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(int todoCount, int doneCount, dynamic s) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.tasksTitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    s.taskSubtitle(todoCount, doneCount),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.outline,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(s.parentOnlyMsg),
                    ),
                  );
                },
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryContainer,
                    shape: BoxShape.circle,
                    boxShadow: const [
                      BoxShadow(
                        color: AppTheme.onPrimaryFixedVariant,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.add,
                    color: AppTheme.onTertiaryContainer,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: TabBar(
              controller: _tabCtrl,
              dividerColor: Colors.transparent,
              indicator: BoxDecoration(
                color: AppTheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              labelColor: AppTheme.vibrantPrimary,
              unselectedLabelColor: AppTheme.outline,
              labelStyle: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
              unselectedLabelStyle: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              tabs: [
                Tab(text: '${s.tabTodo} ($todoCount)'),
                Tab(text: '${s.tabDone} ($doneCount)'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskSection extends StatelessWidget {
  final List<TaskModel> tasks;
  final bool showAction;

  const _TaskSection({required this.tasks, required this.showAction});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>().strings;
    if (tasks.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: AppTheme.surfaceContainer, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryFixed,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text('🎉', style: TextStyle(fontSize: 60)),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  showAction ? s.emptyTodo : s.tabDone,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  showAction ? s.noTasksSub : s.emptyDoneSub,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.outline,
                  ),
                ),
                if (showAction) ...[
                  const SizedBox(height: 32),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.vibrantPrimary,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: const [
                          BoxShadow(
                            color: AppTheme.onPrimaryFixedVariant,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.explore, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            s.exploreOther,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ).animate().scale(curve: Curves.easeOutBack, duration: 400.ms),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 100),
      itemCount: tasks.length,
      itemBuilder: (context, i) =>
          _TaskCardItem(task: tasks[i], showAction: showAction)
              .animate(delay: Duration(milliseconds: i * 50))
              .fadeIn()
              .slideY(begin: 0.1),
    );
  }
}

class _TaskCardItem extends StatelessWidget {
  final TaskModel task;
  final bool showAction;

  const _TaskCardItem({required this.task, required this.showAction});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>().strings;
    final statusColor = task.status == TaskStatus.pending
        ? AppTheme.vibrantPrimary
        : (task.status == TaskStatus.submitted
              ? AppTheme.vibrantSecondary
              : AppTheme.vibrantTertiary);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.surfaceContainerHigh, width: 2),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(task.icon, style: const TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          task.category,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            color: AppTheme.outline,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            taskDifficultyLabel(task.coinReward),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryFixed,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '+${task.coinReward} ${s.coins}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.onSecondaryFixed,
                  ),
                ),
              ),
            ],
          ),
          if (showAction && task.status == TaskStatus.pending) ...[
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => _SubmitProofSheet(task: task),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceBright,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.vibrantPrimary, width: 2),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.camera_alt_outlined,
                      color: AppTheme.vibrantPrimary,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      s.submitProofBtn,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.vibrantPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (task.status == TaskStatus.submitted) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppTheme.vibrantSecondary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  s.waitingReview,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.vibrantSecondary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ── Submit Proof Bottom Sheet ─────────────────────────────────────────────────

class _SubmitProofSheet extends StatefulWidget {
  final TaskModel task;
  const _SubmitProofSheet({required this.task});

  @override
  State<_SubmitProofSheet> createState() => _SubmitProofSheetState();
}

class _SubmitProofSheetState extends State<_SubmitProofSheet> {
  Uint8List? _photoBytes;
  bool _isSubmitting = false;
  final _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 75,
        maxWidth: 1280,
      );
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        setState(() => _photoBytes = bytes);
      }
    } catch (e) {
      if (!mounted) return;
      final s = context.read<AppState>().strings;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${s.errPickImage}${e.toString()}')),
      );
    }
  }

  Future<void> _submit() async {
    final s = context.read<AppState>().strings;
    if (_photoBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.errNoPhoto)),
      );
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      await context.read<AppState>().submitTask(
        widget.task.id,
        proofImageBytes: _photoBytes,
      );
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(s.submittedMsg),
          backgroundColor: AppTheme.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      final s2 = context.read<AppState>().strings;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${s2.errorPrefix}${e.toString()}'),
          backgroundColor: AppTheme.coral,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>().strings;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              s.submitProofTitle,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.task.title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: AppTheme.outline,
              ),
            ),
            const SizedBox(height: 20),

            // Photo preview
            GestureDetector(
              onTap: () => _pickImage(ImageSource.gallery),
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppTheme.primaryFixed,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _photoBytes != null
                        ? AppTheme.green
                        : AppTheme.vibrantPrimary.withValues(alpha: 0.35),
                    width: 2,
                  ),
                ),
                child: _photoBytes != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.memory(_photoBytes!, fit: BoxFit.cover),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.add_a_photo_outlined,
                            size: 44,
                            color: AppTheme.vibrantPrimary,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            s.photoHint,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.vibrantPrimary,
                            ),
                          ),
                          Text(
                            s.required_,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: AppTheme.outline,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 12),

            // Camera / Gallery buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt_outlined, size: 18),
                    label: Text(
                      s.takePhoto,
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: AppTheme.vibrantPrimary),
                      foregroundColor: AppTheme.vibrantPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_outlined, size: 18),
                    label: Text(
                      s.gallery,
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: AppTheme.vibrantPrimary),
                      foregroundColor: AppTheme.vibrantPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Submit button
            SizedBox(
              width: double.infinity,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: AppTheme.gradientGreen,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AppTheme.shadowMd(AppTheme.green),
                ),
                child: FilledButton.icon(
                  onPressed: _isSubmitting ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check_rounded, color: Colors.white),
                  label: Text(
                    _isSubmitting ? s.submitting : s.submitFinal,
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

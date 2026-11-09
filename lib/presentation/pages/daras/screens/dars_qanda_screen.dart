// ─────────────────────────────────────────────────────────────────────────────
// dars_qanda_screen.dart — Questions & answers for a specific lesson
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controller/dars_controller.dart';
import '../models/dars_models.dart';
import '../widgets/dars_widgets.dart';

class DarsQandAScreen extends StatefulWidget {
  final Dars dars;
  const DarsQandAScreen({super.key, required this.dars});

  @override
  State<DarsQandAScreen> createState() => _DarsQandAScreenState();
}

class _DarsQandAScreenState extends State<DarsQandAScreen> {
  late final DarsController _ctrl;
  final TextEditingController _questionCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _ctrl = DarsController.instance;
    _ctrl.loadQuestionsForDars(widget.dars.id);
  }

  @override
  void dispose() {
    _questionCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _questionCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() => _submitting = true);
    await _ctrl.submitQuestion(widget.dars.id, text);
    _questionCtrl.clear();
    setState(() => _submitting = false);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: cs.tertiary,
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: DarsIslamicBgPainter(
                primaryColor: cs.primary,
                surfaceColor: cs.surface,
                isDark: isDark,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _QandAAppBar(dars: widget.dars, cs: cs),
                Expanded(
                  child: Obx(() {
                    final questions =
                        _ctrl.state.questionsByDars[widget.dars.id] ?? [];
                    final approved = questions
                        .where(
                          (q) => q.status == QuestionStatus.approved,
                        )
                        .toList();
                    final pending = questions
                        .where(
                          (q) => q.status == QuestionStatus.pending,
                        )
                        .toList();

                    if (questions.isEmpty) {
                      return const DarsEmptyState(
                        title: 'No Questions Yet',
                        subtitle:
                            'Be the first to ask a question about this lesson.',
                        icon: Icons.question_answer_rounded,
                      );
                    }

                    return ListView(
                      padding:
                          EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 80.h),
                      children: [
                        if (pending.isNotEmpty) ...[
                          DarsSectionHeader(
                            title: 'Your Questions',
                            icon: Icons.pending_rounded,
                            color: kDarsGold,
                          ),
                          ...pending.map(
                            (q) => _QuestionCard(
                                question: q, cs: cs, isDark: isDark),
                          ),
                          SizedBox(height: 10.h),
                        ],
                        if (approved.isNotEmpty) ...[
                          DarsSectionHeader(
                            title: 'Questions & Answers',
                            arabicTitle: 'الأسئلة والأجوبة',
                            icon: Icons.question_answer_rounded,
                          ),
                          ...approved.map(
                            (q) => _QuestionCard(
                                question: q, cs: cs, isDark: isDark),
                          ),
                        ],
                      ],
                    );
                  }),
                ),

                // ── Ask a question input ─────────────────────────────────
                _AskBar(
                  controller: _questionCtrl,
                  submitting: _submitting,
                  onSubmit: _submit,
                  cs: cs,
                  isDark: isDark,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QandAAppBar extends StatelessWidget {
  final Dars dars;
  final ColorScheme cs;
  const _QandAAppBar({required this.dars, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 12.w, 10.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: Get.back,
            child: Icon(Icons.arrow_back_rounded,
                color: Theme.of(context).hintColor, size: 22.r),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Q&A',
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).hintColor,
                  ),
                ),
                Text(
                  dars.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 10.5.sp,
                    color: cs.primary.withValues(alpha: 0.65),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionCard extends StatefulWidget {
  final DarsQuestion question;
  final ColorScheme cs;
  final bool isDark;
  const _QuestionCard(
      {required this.question, required this.cs, required this.isDark});

  @override
  State<_QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<_QuestionCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final q = widget.question;
    final cs = widget.cs;
    final dateFmt = DateFormat('MMM d, yyyy');
    final isPending = q.status == QuestionStatus.pending;

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isPending
              ? kDarsGold.withValues(alpha: 0.20)
              : cs.primary.withValues(alpha: widget.isDark ? 0.09 : 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question header
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: EdgeInsets.all(12.r),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 28.r,
                    height: 28.r,
                    decoration: BoxDecoration(
                      color: isPending
                          ? kDarsGold.withValues(alpha: 0.12)
                          : cs.primary.withValues(alpha: 0.10),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.help_rounded,
                      size: 14.r,
                      color: isPending ? kDarsGold : cs.primary,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          q.questionText,
                          style: TextStyle(
                            fontFamily: 'kufi',
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).hintColor,
                            height: 1.4,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Row(
                          children: [
                            Text(
                              dateFmt.format(q.askedAt),
                              style: TextStyle(
                                fontFamily: 'kufi',
                                fontSize: 9.sp,
                                color: Theme.of(context)
                                    .hintColor
                                    .withValues(alpha: 0.38),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            if (isPending)
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 6.w, vertical: 2.h),
                                decoration: BoxDecoration(
                                  color: kDarsGold.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6.r),
                                ),
                                child: Text(
                                  'Pending review',
                                  style: TextStyle(
                                    fontFamily: 'kufi',
                                    fontSize: 8.5.sp,
                                    color: kDarsGold,
                                  ),
                                ),
                              ),
                            if (q.answers.isNotEmpty)
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 6.w, vertical: 2.h),
                                decoration: BoxDecoration(
                                  color:
                                      kDarsGreen.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6.r),
                                ),
                                child: Text(
                                  '${q.answers.length} answer${q.answers.length > 1 ? 's' : ''}',
                                  style: TextStyle(
                                    fontFamily: 'kufi',
                                    fontSize: 8.5.sp,
                                    color: kDarsGreen,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (q.answers.isNotEmpty)
                    Icon(
                      _expanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      size: 18.r,
                      color: Theme.of(context)
                          .hintColor
                          .withValues(alpha: 0.35),
                    ),
                ],
              ),
            ),
          ),

          // Answers
          if (_expanded && q.answers.isNotEmpty)
            ...q.answers.map(
              (a) => Container(
                margin: EdgeInsets.fromLTRB(12.w, 0, 12.w, 10.h),
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: a.isScholarAnswer
                      ? kDarsGold.withValues(alpha: 0.07)
                      : cs.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: a.isScholarAnswer
                        ? kDarsGold.withValues(alpha: 0.20)
                        : cs.primary.withValues(alpha: 0.12),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          a.isScholarAnswer
                              ? Icons.verified_rounded
                              : Icons.person_rounded,
                          size: 13.r,
                          color: a.isScholarAnswer
                              ? kDarsGold
                              : cs.primary.withValues(alpha: 0.60),
                        ),
                        SizedBox(width: 5.w),
                        Text(
                          a.answeredBy,
                          style: TextStyle(
                            fontFamily: 'kufi',
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w700,
                            color: a.isScholarAnswer
                                ? kDarsGold
                                : cs.primary,
                          ),
                        ),
                        if (a.isScholarAnswer) ...[
                          SizedBox(width: 5.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 5.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: kDarsGold.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(5.r),
                            ),
                            child: Text(
                              'Scholar',
                              style: TextStyle(
                                fontFamily: 'kufi',
                                fontSize: 8.sp,
                                color: kDarsGold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      a.answerText,
                      style: TextStyle(
                        fontFamily: 'kufi',
                        fontSize: 11.5.sp,
                        color: Theme.of(context)
                            .hintColor
                            .withValues(alpha: 0.72),
                        height: 1.6,
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

class _AskBar extends StatelessWidget {
  final TextEditingController controller;
  final bool submitting;
  final VoidCallback onSubmit;
  final ColorScheme cs;
  final bool isDark;
  const _AskBar(
      {required this.controller,
      required this.submitting,
      required this.onSubmit,
      required this.cs,
      required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 14.h),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        border: Border(
          top: BorderSide(
            color: cs.primary.withValues(alpha: isDark ? 0.12 : 0.08),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: cs.tertiary,
                borderRadius: BorderRadius.circular(14.r),
                border:
                    Border.all(color: cs.primary.withValues(alpha: 0.18)),
              ),
              child: TextField(
                controller: controller,
                maxLines: 3,
                minLines: 1,
                style: TextStyle(
                  fontFamily: 'kufi',
                  fontSize: 12.5.sp,
                  color: Theme.of(context).hintColor,
                ),
                decoration: InputDecoration(
                  hintText: 'Ask a question about this lesson…',
                  hintStyle: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 11.5.sp,
                    color: Theme.of(context).hintColor.withValues(alpha: 0.38),
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 8.h),
                ),
              ),
            ),
          ),
          SizedBox(width: 10.w),
          GestureDetector(
            onTap: submitting ? null : onSubmit,
            child: Container(
              width: 44.r,
              height: 44.r,
              decoration: BoxDecoration(
                color: cs.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: cs.primary.withValues(alpha: 0.30),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: submitting
                  ? Padding(
                      padding: EdgeInsets.all(12.r),
                      child: const CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Icon(Icons.send_rounded, color: Colors.white, size: 18.r),
            ),
          ),
        ],
      ),
    );
  }
}

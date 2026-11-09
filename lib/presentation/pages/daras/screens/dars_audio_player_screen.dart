// ─────────────────────────────────────────────────────────────────────────────
// dars_audio_player_screen.dart — Full-screen audio player
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controller/dars_controller.dart';
import '../models/dars_models.dart';
import '../widgets/dars_widgets.dart';

class DarsAudioPlayerScreen extends StatefulWidget {
  final Dars dars;
  const DarsAudioPlayerScreen({super.key, required this.dars});

  @override
  State<DarsAudioPlayerScreen> createState() => _DarsAudioPlayerScreenState();
}

class _DarsAudioPlayerScreenState extends State<DarsAudioPlayerScreen>
    with TickerProviderStateMixin {
  late final DarsController _ctrl;
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = DarsController.instance;
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    // Start playing if not already playing this dars
    if (_ctrl.state.currentAudioDars.value?.id != widget.dars.id) {
      _ctrl.playAudio(widget.dars);
    }
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final h = d.inHours;
    return h > 0 ? '${h.toString().padLeft(2, '0')}:$m:$s' : '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final dars = widget.dars;

    return Scaffold(
      backgroundColor: cs.primary,
      body: Stack(
        children: [
          // Background geometric pattern
          Positioned.fill(
            child: CustomPaint(
              painter: DarsIslamicBgPainter(
                primaryColor: Colors.white,
                surfaceColor: kDarsGold,
                isDark: true,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // ── Top bar ──────────────────────────────────────────────
                _TopBar(dars: dars, ctrl: _ctrl),

                const Spacer(),

                // ── Artwork / pulse animation ────────────────────────────
                Obx(
                  () => AnimatedBuilder(
                    animation: _pulseAnim,
                    builder: (_, child) => Transform.scale(
                      scale: _ctrl.state.isAudioPlaying.value
                          ? _pulseAnim.value
                          : 1.0,
                      child: child,
                    ),
                    child: Container(
                      width: 180.r,
                      height: 180.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.12),
                        border: Border.all(
                          color: kDarsGold.withValues(alpha: 0.35),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.20),
                            blurRadius: 30,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.headphones_rounded,
                        color: Colors.white,
                        size: 72.r,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 32.h),

                // ── Title & scholar ───────────────────────────────────────
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 28.w),
                  child: Column(
                    children: [
                      Text(
                        dars.title,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'kufi',
                          fontSize: 17.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.3,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        dars.scholar.name,
                        style: TextStyle(
                          fontFamily: 'kufi',
                          fontSize: 13.sp,
                          color: kDarsGold.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 28.h),

                // ── Seek bar ──────────────────────────────────────────────
                Obx(() => _SeekBar(ctrl: _ctrl, fmtFn: _fmt)),

                SizedBox(height: 20.h),

                // ── Playback controls ─────────────────────────────────────
                Obx(() => _PlaybackControls(ctrl: _ctrl)),

                SizedBox(height: 24.h),

                // ── Speed & extra row ─────────────────────────────────────
                _SpeedRow(ctrl: _ctrl),

                const Spacer(),

                SizedBox(height: 16.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final Dars dars;
  final DarsController ctrl;
  const _TopBar({required this.dars, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.white,
              size: 28.r,
            ),
            onPressed: Get.back,
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  'Now Playing',
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 11.sp,
                    color: Colors.white.withValues(alpha: 0.55),
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  dars.category.displayName,
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: kDarsGold,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.share_rounded, color: Colors.white, size: 22.r),
            onPressed: () => ctrl.shareDars(dars),
          ),
        ],
      ),
    );
  }
}

class _SeekBar extends StatefulWidget {
  final DarsController ctrl;
  final String Function(Duration) fmtFn;
  const _SeekBar({required this.ctrl, required this.fmtFn});

  @override
  State<_SeekBar> createState() => _SeekBarState();
}

class _SeekBarState extends State<_SeekBar> {
  bool _dragging = false;
  double _dragValue = 0.0;

  @override
  Widget build(BuildContext context) {
    final total = widget.ctrl.state.audioDuration.value;
    final pos = widget.ctrl.state.audioPosition.value;
    final progress = total.inSeconds == 0
        ? 0.0
        : pos.inSeconds / total.inSeconds;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 3.h,
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6.r),
              overlayShape: RoundSliderOverlayShape(overlayRadius: 14.r),
              activeTrackColor: kDarsGold,
              inactiveTrackColor: Colors.white.withValues(alpha: 0.20),
              thumbColor: Colors.white,
              overlayColor: kDarsGold.withValues(alpha: 0.20),
            ),
            child: Slider(
              value: _dragging ? _dragValue : progress.clamp(0.0, 1.0),
              onChangeStart: (v) {
                setState(() {
                  _dragging = true;
                  _dragValue = v;
                });
              },
              onChanged: (v) => setState(() => _dragValue = v),
              onChangeEnd: (v) {
                _dragging = false;
                final target = Duration(seconds: (v * total.inSeconds).round());
                widget.ctrl.seekAudio(target);
              },
            ),
          ),
          SizedBox(height: 2.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.fmtFn(pos),
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 10.sp,
                    color: Colors.white.withValues(alpha: 0.65),
                  ),
                ),
                Text(
                  widget.fmtFn(total),
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 10.sp,
                    color: Colors.white.withValues(alpha: 0.65),
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

class _PlaybackControls extends StatelessWidget {
  final DarsController ctrl;
  const _PlaybackControls({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Skip back 10s
        _ControlBtn(
          icon: Icons.replay_10_rounded,
          size: 28,
          color: Colors.white.withValues(alpha: 0.75),
          onTap: () => ctrl.skipBackwardAudio(seconds: 10),
        ),
        SizedBox(width: 20.w),
        // Play/Pause
        GestureDetector(
          onTap: () {
            final dars = ctrl.state.currentAudioDars.value;
            if (dars != null) ctrl.playAudio(dars);
          },
          child: Container(
            width: 64.r,
            height: 64.r,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.20),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ctrl.state.isAudioLoading.value
                ? Padding(
                    padding: EdgeInsets.all(18.r),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  )
                : Icon(
                    ctrl.state.isAudioPlaying.value
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    color: Theme.of(context).colorScheme.primary,
                    size: 32.r,
                  ),
          ),
        ),
        SizedBox(width: 20.w),
        // Skip forward 30s
        _ControlBtn(
          icon: Icons.forward_30_rounded,
          size: 28,
          color: Colors.white.withValues(alpha: 0.75),
          onTap: () => ctrl.skipForwardAudio(seconds: 30),
        ),
      ],
    );
  }
}

class _ControlBtn extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color color;
  final VoidCallback onTap;
  const _ControlBtn({
    required this.icon,
    required this.size,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(icon, color: color, size: size.r),
    );
  }
}

class _SpeedRow extends StatelessWidget {
  final DarsController ctrl;
  const _SpeedRow({required this.ctrl});

  static const speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Playback Speed',
          style: TextStyle(
            fontFamily: 'kufi',
            fontSize: 11.sp,
            color: Colors.white.withValues(alpha: 0.55),
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: speeds
              .map(
                (s) => Obx(
                  () => GestureDetector(
                    onTap: () => ctrl.setAudioSpeed(s),
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 4.w),
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 5.h,
                      ),
                      decoration: BoxDecoration(
                        color: ctrl.state.audioSpeed.value == s
                            ? kDarsGold
                            : Colors.white.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        '${s}x',
                        style: TextStyle(
                          fontFamily: 'kufi',
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                          color: ctrl.state.audioSpeed.value == s
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.70),
                        ),
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

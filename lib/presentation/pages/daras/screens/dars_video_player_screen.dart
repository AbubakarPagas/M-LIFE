// ─────────────────────────────────────────────────────────────────────────────
// dars_video_player_screen.dart — Video player with controls + quality selector
// Uses chewie/video_player if available; gracefully shows a placeholder
// since video_player is not yet in pubspec. Integration points are clearly
// marked for the developer to wire up the actual player.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controller/dars_controller.dart';
import '../models/dars_models.dart';
import '../widgets/dars_widgets.dart';

class DarsVideoPlayerScreen extends StatefulWidget {
  final Dars dars;
  const DarsVideoPlayerScreen({super.key, required this.dars});

  @override
  State<DarsVideoPlayerScreen> createState() => _DarsVideoPlayerScreenState();
}

class _DarsVideoPlayerScreenState extends State<DarsVideoPlayerScreen> {
  late final DarsController _ctrl;
  bool _isFullscreen = false;
  bool _showControls = true;

  // ── TODO: Initialise video_player + chewie here ───────────────────────────
  // VideoPlayerController? _videoCtrl;
  // ChewieController? _chewieCtrl;

  @override
  void initState() {
    super.initState();
    _ctrl = DarsController.instance;
    _ctrl.openVideo(widget.dars);
    _hideControlsAfterDelay();
  }

  void _hideControlsAfterDelay() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showControls = false);
    });
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
    if (_showControls) _hideControlsAfterDelay();
  }

  void _toggleFullscreen() {
    setState(() => _isFullscreen = !_isFullscreen);
    if (_isFullscreen) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    } else {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
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

    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // ── Video area ─────────────────────────────────────────────────
          GestureDetector(
            onTap: _toggleControls,
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // ── Actual video player widget goes here ───────────────
                  // Replace with Chewie(controller: _chewieCtrl!) once
                  // video_player + chewie packages are added to pubspec.yaml
                  Container(
                    color: const Color(0xff0a0a1a),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.play_circle_outline_rounded,
                          color: Colors.white.withValues(alpha: 0.35),
                          size: 48.r,
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Video player — wire up video_player + chewie',
                          style: TextStyle(
                            fontFamily: 'kufi',
                            fontSize: 10.sp,
                            color: Colors.white.withValues(alpha: 0.30),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Overlay controls ───────────────────────────────────
                  AnimatedOpacity(
                    opacity: _showControls ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0x88000000),
                            Colors.transparent,
                            Color(0xaa000000),
                          ],
                        ),
                      ),
                      child: Column(
                        children: [
                          // Top row
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 6.h,
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.arrow_back_rounded,
                                    color: Colors.white,
                                    size: 22.r,
                                  ),
                                  onPressed: Get.back,
                                ),
                                Expanded(
                                  child: Text(
                                    widget.dars.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: 'kufi',
                                      fontSize: 12.sp,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                _QualitySelector(ctrl: _ctrl),
                              ],
                            ),
                          ),
                          const Spacer(),
                          // Bottom controls
                          Padding(
                            padding: EdgeInsets.fromLTRB(8.w, 0, 8.w, 6.h),
                            child: Column(
                              children: [
                                // Seek bar
                                Obx(() {
                                  final pos = _ctrl.state.videoPosition.value;
                                  final total = _ctrl.state.videoDuration.value;
                                  final progress = total.inSeconds == 0
                                      ? 0.0
                                      : pos.inSeconds / total.inSeconds;
                                  return Column(
                                    children: [
                                      SliderTheme(
                                        data: SliderTheme.of(context).copyWith(
                                          trackHeight: 2.5.h,
                                          thumbShape: RoundSliderThumbShape(
                                            enabledThumbRadius: 5.r,
                                          ),
                                          activeTrackColor: kDarsGold,
                                          inactiveTrackColor: Colors.white
                                              .withValues(alpha: 0.25),
                                          thumbColor: Colors.white,
                                        ),
                                        child: Slider(
                                          value: progress.clamp(0.0, 1.0),
                                          onChanged: (v) {
                                            final target = Duration(
                                              seconds: (v * total.inSeconds)
                                                  .round(),
                                            );
                                            _ctrl.updateVideoProgress(
                                              target,
                                              total,
                                            );
                                          },
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 4.w,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              _fmt(pos),
                                              style: TextStyle(
                                                fontFamily: 'kufi',
                                                fontSize: 9.sp,
                                                color: Colors.white.withValues(
                                                  alpha: 0.65,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              _fmt(total),
                                              style: TextStyle(
                                                fontFamily: 'kufi',
                                                fontSize: 9.sp,
                                                color: Colors.white.withValues(
                                                  alpha: 0.65,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        Icons.replay_10_rounded,
                                        color: Colors.white,
                                        size: 26.r,
                                      ),
                                      onPressed: () {},
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        _ctrl.state.isVideoPlaying.value
                                            ? Icons.pause_circle_filled_rounded
                                            : Icons.play_circle_filled_rounded,
                                        color: Colors.white,
                                        size: 42.r,
                                      ),
                                      onPressed: () => setState(() {
                                        _ctrl.state.isVideoPlaying.value =
                                            !_ctrl.state.isVideoPlaying.value;
                                      }),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.forward_30_rounded,
                                        color: Colors.white,
                                        size: 26.r,
                                      ),
                                      onPressed: () {},
                                    ),
                                    const Spacer(),
                                    IconButton(
                                      icon: Icon(
                                        _isFullscreen
                                            ? Icons.fullscreen_exit_rounded
                                            : Icons.fullscreen_rounded,
                                        color: Colors.white,
                                        size: 22.r,
                                      ),
                                      onPressed: _toggleFullscreen,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Info panel (portrait only) ─────────────────────────────────
          if (!_isFullscreen)
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.dars.title,
                      style: TextStyle(
                        fontFamily: 'kufi',
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        ScholarAvatar(scholar: widget.dars.scholar, size: 32),
                        SizedBox(width: 8.w),
                        Text(
                          widget.dars.scholar.name,
                          style: TextStyle(
                            fontFamily: 'kufi',
                            fontSize: 12.sp,
                            color: cs.primary,
                          ),
                        ),
                        const Spacer(),
                        DarsCategoryChip(
                          category: widget.dars.category,
                          small: true,
                        ),
                      ],
                    ),
                    SizedBox(height: 14.h),
                    Text(
                      widget.dars.description,
                      style: TextStyle(
                        fontFamily: 'kufi',
                        fontSize: 12.sp,
                        color: Theme.of(
                          context,
                        ).hintColor.withValues(alpha: 0.65),
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

class _QualitySelector extends StatelessWidget {
  final DarsController ctrl;
  const _QualitySelector({required this.ctrl});

  static const qualities = ['360p', '480p', '720p', '1080p'];

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => PopupMenuButton<String>(
        initialValue: ctrl.state.selectedVideoQuality.value,
        color: const Color(0xff1a1a2e),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        onSelected: (q) => ctrl.state.selectedVideoQuality.value = q,
        itemBuilder: (_) => qualities
            .map(
              (q) => PopupMenuItem(
                value: q,
                child: Text(
                  q,
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 12.sp,
                    color: ctrl.state.selectedVideoQuality.value == q
                        ? kDarsGold
                        : Colors.white,
                  ),
                ),
              ),
            )
            .toList(),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                ctrl.state.selectedVideoQuality.value,
                style: TextStyle(
                  fontFamily: 'kufi',
                  fontSize: 10.sp,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 2.w),
              Icon(Icons.expand_more_rounded, color: Colors.white, size: 14.r),
            ],
          ),
        ),
      ),
    );
  }
}

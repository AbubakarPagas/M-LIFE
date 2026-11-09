// ─────────────────────────────────────────────────────────────────────────────
// dars_downloads_screen.dart — Downloaded lessons with progress + delete
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controller/dars_controller.dart';
import '../models/dars_models.dart';
import '../widgets/dars_widgets.dart';
import 'dars_audio_player_screen.dart';
import 'dars_video_player_screen.dart';

class DarsDownloadsScreen extends StatelessWidget {
  const DarsDownloadsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ctrl = DarsController.instance;

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
                _DownloadsAppBar(cs: cs),
                Expanded(
                  child: Obx(() {
                    final all = ctrl.state.downloads;
                    final downloaded = all
                        .where((d) => d.status == DownloadStatus.downloaded)
                        .toList();
                    final inProgress = all
                        .where((d) => d.status == DownloadStatus.downloading)
                        .toList();
                    final failed = all
                        .where((d) => d.status == DownloadStatus.failed)
                        .toList();

                    if (all.isEmpty) {
                      return const DarsEmptyState(
                        title: 'No Downloads',
                        subtitle:
                            'Download lessons to listen offline without internet.',
                        icon: Icons.download_rounded,
                      );
                    }

                    return ListView(
                      padding: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 80.h),
                      children: [
                        if (inProgress.isNotEmpty) ...[
                          DarsSectionHeader(
                            title: 'Downloading',
                            icon: Icons.downloading_rounded,
                            color: cs.primary,
                          ),
                          ...inProgress.map(
                            (d) => _DownloadTile(
                              download: d,
                              ctrl: ctrl,
                              cs: cs,
                              isDark: isDark,
                            ),
                          ),
                          SizedBox(height: 10.h),
                        ],
                        if (downloaded.isNotEmpty) ...[
                          DarsSectionHeader(
                            title: 'Downloaded',
                            arabicTitle: 'المنزّل',
                            icon: Icons.download_done_rounded,
                            color: kDarsGreen,
                          ),
                          ...downloaded.map(
                            (d) => _DownloadTile(
                              download: d,
                              ctrl: ctrl,
                              cs: cs,
                              isDark: isDark,
                            ),
                          ),
                        ],
                        if (failed.isNotEmpty) ...[
                          SizedBox(height: 10.h),
                          DarsSectionHeader(
                            title: 'Failed',
                            icon: Icons.error_outline_rounded,
                            color: kDarsRed,
                          ),
                          ...failed.map(
                            (d) => _DownloadTile(
                              download: d,
                              ctrl: ctrl,
                              cs: cs,
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ],
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DownloadsAppBar extends StatelessWidget {
  final ColorScheme cs;
  const _DownloadsAppBar({required this.cs});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 12.w, 10.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: Get.back,
            child: Icon(
              Icons.arrow_back_rounded,
              color: Theme.of(context).hintColor,
              size: 22.r,
            ),
          ),
          SizedBox(width: 12.w),
          Text(
            'Downloads',
            style: TextStyle(
              fontFamily: 'kufi',
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).hintColor,
            ),
          ),
          const Spacer(),
          Obx(() {
            final total = DarsController.instance.state.downloads
                .where((d) => d.status == DownloadStatus.downloaded)
                .fold(0, (sum, d) => sum + d.fileSizeBytes);
            if (total == 0) return const SizedBox.shrink();
            return Text(
              _fmt(total),
              style: TextStyle(
                fontFamily: 'kufi',
                fontSize: 10.sp,
                color: Theme.of(context).hintColor.withValues(alpha: 0.40),
              ),
            );
          }),
        ],
      ),
    );
  }

  String _fmt(int bytes) {
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}

class _DownloadTile extends StatelessWidget {
  final DarsDownload download;
  final DarsController ctrl;
  final ColorScheme cs;
  final bool isDark;
  const _DownloadTile({
    required this.download,
    required this.ctrl,
    required this.cs,
    required this.isDark,
  });

  Color get _statusColor {
    switch (download.status) {
      case DownloadStatus.downloaded:
        return kDarsGreen;
      case DownloadStatus.downloading:
        return cs.primary;
      case DownloadStatus.failed:
        return kDarsRed;
      default:
        return cs.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: cs.primary.withValues(alpha: isDark ? 0.09 : 0.06),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44.r,
                height: 44.r,
                decoration: BoxDecoration(
                  color: _statusColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(11.r),
                ),
                child: Icon(
                  download.darsType == DarsType.video
                      ? Icons.videocam_rounded
                      : Icons.headphones_rounded,
                  color: _statusColor,
                  size: 20.r,
                ),
              ),
              SizedBox(width: 11.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      download.darsTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'kufi',
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      download.scholarName,
                      style: TextStyle(
                        fontFamily: 'kufi',
                        fontSize: 10.sp,
                        color: cs.primary.withValues(alpha: 0.65),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        _StatusBadge(status: download.status),
                        if (download.fileSizeBytes > 0) ...[
                          SizedBox(width: 6.w),
                          Text(
                            download.fileSizeFormatted,
                            style: TextStyle(
                              fontFamily: 'kufi',
                              fontSize: 9.sp,
                              color: Theme.of(
                                context,
                              ).hintColor.withValues(alpha: 0.40),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // Actions
              if (download.status == DownloadStatus.downloaded) ...[
                GestureDetector(
                  onTap: () {
                    final dars = ctrl.getDarsById(download.darsId);
                    if (dars == null) return;
                    if (dars.type == DarsType.video) {
                      ctrl.openVideo(dars);
                      Get.to(() => DarsVideoPlayerScreen(dars: dars));
                    } else {
                      ctrl.playAudio(dars);
                      Get.to(() => DarsAudioPlayerScreen(dars: dars));
                    }
                  },
                  child: Container(
                    width: 34.r,
                    height: 34.r,
                    decoration: BoxDecoration(
                      color: kDarsGreen.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.play_arrow_rounded,
                      color: kDarsGreen,
                      size: 18.r,
                    ),
                  ),
                ),
                SizedBox(width: 6.w),
                GestureDetector(
                  onTap: () => _confirmDelete(context),
                  child: Container(
                    width: 34.r,
                    height: 34.r,
                    decoration: BoxDecoration(
                      color: kDarsRed.withValues(alpha: 0.10),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.delete_rounded,
                      color: kDarsRed,
                      size: 16.r,
                    ),
                  ),
                ),
              ] else if (download.status == DownloadStatus.failed) ...[
                GestureDetector(
                  onTap: () {
                    final dars = ctrl.getDarsById(download.darsId);
                    if (dars != null) ctrl.downloadDars(dars);
                  },
                  child: Container(
                    width: 34.r,
                    height: 34.r,
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.10),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.refresh_rounded,
                      color: cs.primary,
                      size: 16.r,
                    ),
                  ),
                ),
              ],
            ],
          ),

          // Progress bar for downloading
          if (download.status == DownloadStatus.downloading) ...[
            SizedBox(height: 8.h),
            Obx(() {
              final p =
                  ctrl.state.downloadProgress[download.darsId] ??
                  download.progress;
              return DarsProgressBar(value: p, height: 4, showLabel: true);
            }),
          ],
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'Delete Download',
          style: TextStyle(
            fontFamily: 'kufi',
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).hintColor,
          ),
        ),
        content: Text(
          'Remove "${download.darsTitle}" from your device?',
          style: TextStyle(
            fontFamily: 'kufi',
            fontSize: 12.sp,
            color: Theme.of(context).hintColor.withValues(alpha: 0.65),
          ),
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'kufi',
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              ctrl.deleteDownload(download);
              Get.back();
            },
            child: Text(
              'Delete',
              style: TextStyle(fontFamily: 'kufi', color: kDarsRed),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final DownloadStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    switch (status) {
      case DownloadStatus.downloaded:
        color = kDarsGreen;
        label = 'Downloaded';
        break;
      case DownloadStatus.downloading:
        color = Theme.of(context).colorScheme.primary;
        label = 'Downloading…';
        break;
      case DownloadStatus.failed:
        color = kDarsRed;
        label = 'Failed';
        break;
      default:
        color = Theme.of(context).hintColor;
        label = 'Pending';
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'kufi',
          fontSize: 9.sp,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

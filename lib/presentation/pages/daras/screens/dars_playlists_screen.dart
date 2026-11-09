// ─────────────────────────────────────────────────────────────────────────────
// dars_playlists_screen.dart — Create, view, manage personal playlists
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controller/dars_controller.dart';
import '../models/dars_models.dart';
import '../widgets/dars_widgets.dart';
import 'dars_detail_screen.dart';

class DarsPlaylistsScreen extends StatelessWidget {
  const DarsPlaylistsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ctrl = DarsController.instance;

    return Scaffold(
      backgroundColor: cs.tertiary,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(context, ctrl),
        backgroundColor: cs.primary,
        foregroundColor: Colors.white,
        icon: Icon(Icons.add_rounded, size: 20.r),
        label: Text(
          'New Playlist',
          style: TextStyle(fontFamily: 'kufi', fontSize: 12.sp),
        ),
      ),
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
                _PlaylistsAppBar(cs: cs),
                Expanded(
                  child: Obx(() {
                    final lists = ctrl.state.playlists;
                    if (lists.isEmpty) {
                      return DarsEmptyState(
                        title: 'No Playlists Yet',
                        subtitle:
                            'Create your first playlist to organise your lessons.',
                        icon: Icons.playlist_play_rounded,
                        actionLabel: 'Create Playlist',
                        onAction: () => _showCreateDialog(context, ctrl),
                      );
                    }
                    return ListView.builder(
                      padding: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 100.h),
                      itemCount: lists.length,
                      itemBuilder: (_, i) => _PlaylistCard(
                        playlist: lists[i],
                        ctrl: ctrl,
                        cs: cs,
                        isDark: isDark,
                      ),
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

  void _showCreateDialog(BuildContext context, DarsController ctrl) {
    final cs = Theme.of(context).colorScheme;
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cs.secondary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.20),
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                SizedBox(height: 14.h),
                Text(
                  'New Playlist',
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).hintColor,
                  ),
                ),
                SizedBox(height: 14.h),
                _InputField(controller: nameCtrl, hint: 'Playlist name'),
                SizedBox(height: 10.h),
                _InputField(
                  controller: descCtrl,
                  hint: 'Description (optional)',
                  maxLines: 2,
                ),
                SizedBox(height: 16.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (nameCtrl.text.trim().isEmpty) return;
                      await ctrl.createPlaylist(
                        nameCtrl.text.trim(),
                        description: descCtrl.text.trim().isEmpty
                            ? null
                            : descCtrl.text.trim(),
                      );
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cs.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 13.h),
                    ),
                    child: Text(
                      'Create',
                      style: TextStyle(fontFamily: 'kufi', fontSize: 13.sp),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlaylistsAppBar extends StatelessWidget {
  final ColorScheme cs;
  const _PlaylistsAppBar({required this.cs});

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
            'My Playlists',
            style: TextStyle(
              fontFamily: 'kufi',
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).hintColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaylistCard extends StatelessWidget {
  final DarsPlaylist playlist;
  final DarsController ctrl;
  final ColorScheme cs;
  final bool isDark;
  const _PlaylistCard({
    required this.playlist,
    required this.ctrl,
    required this.cs,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(() => _PlaylistDetailScreen(playlist: playlist)),
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: cs.surfaceContainer,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: cs.primary.withValues(alpha: isDark ? 0.10 : 0.07),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 52.r,
              height: 52.r,
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: isDark ? 0.16 : 0.09),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                Icons.playlist_play_rounded,
                color: cs.primary,
                size: 26.r,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    playlist.name,
                    style: TextStyle(
                      fontFamily: 'kufi',
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  if (playlist.description != null)
                    Text(
                      playlist.description!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'kufi',
                        fontSize: 10.sp,
                        color: Theme.of(
                          context,
                        ).hintColor.withValues(alpha: 0.50),
                      ),
                    ),
                  SizedBox(height: 3.h),
                  Text(
                    '${playlist.lessonCount} lessons',
                    style: TextStyle(
                      fontFamily: 'kufi',
                      fontSize: 10.sp,
                      color: cs.primary.withValues(alpha: 0.65),
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert_rounded,
                color: Theme.of(context).hintColor.withValues(alpha: 0.40),
                size: 18.r,
              ),
              onSelected: (v) {
                if (v == 'delete') ctrl.deletePlaylist(playlist.id);
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_rounded, color: kDarsRed, size: 16.r),
                      SizedBox(width: 8.w),
                      Text(
                        'Delete',
                        style: TextStyle(
                          fontFamily: 'kufi',
                          fontSize: 12.sp,
                          color: kDarsRed,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Playlist detail ───────────────────────────────────────────────────────────

class _PlaylistDetailScreen extends StatelessWidget {
  final DarsPlaylist playlist;
  const _PlaylistDetailScreen({required this.playlist});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ctrl = DarsController.instance;

    return Scaffold(
      backgroundColor: cs.tertiary,
      appBar: AppBar(
        backgroundColor: cs.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: Get.back,
        ),
        title: Text(
          playlist.name,
          style: const TextStyle(
            fontFamily: 'kufi',
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: ctrl.getPlaylistItems(playlist.id),
        builder: (_, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snap.data!;
          if (items.isEmpty) {
            return const DarsEmptyState(
              title: 'Playlist is Empty',
              subtitle: 'Add lessons from any lesson detail page.',
              icon: Icons.playlist_add_rounded,
            );
          }
          return ReorderableListView.builder(
            padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 80.h),
            itemCount: items.length,
            onReorder: (_, __) {},
            itemBuilder: (_, i) {
              final item = items[i];
              final darsId = item['dars_id'] as String;
              final dars = ctrl.getDarsById(darsId);
              return ListTile(
                key: ValueKey(darsId),
                leading: Container(
                  width: 38.r,
                  height: 38.r,
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.09),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    (item['dars_type'] as String) == 'video'
                        ? Icons.videocam_rounded
                        : Icons.headphones_rounded,
                    color: cs.primary,
                    size: 16.r,
                  ),
                ),
                title: Text(
                  item['dars_title'] as String,
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 12.sp,
                    color: Theme.of(context).hintColor,
                  ),
                ),
                subtitle: Text(
                  item['scholar_name'] as String,
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 10.sp,
                    color: cs.primary.withValues(alpha: 0.60),
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (dars != null)
                      GestureDetector(
                        onTap: () => Get.to(() => DarsDetailScreen(dars: dars)),
                        child: Icon(
                          Icons.open_in_new_rounded,
                          size: 16.r,
                          color: Theme.of(
                            context,
                          ).hintColor.withValues(alpha: 0.40),
                        ),
                      ),
                    SizedBox(width: 8.w),
                    GestureDetector(
                      onTap: () => ctrl.removeFromPlaylist(playlist, darsId),
                      child: Icon(
                        Icons.remove_circle_outline_rounded,
                        size: 18.r,
                        color: kDarsRed.withValues(alpha: 0.65),
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(
                      Icons.drag_handle_rounded,
                      size: 18.r,
                      color: Theme.of(
                        context,
                      ).hintColor.withValues(alpha: 0.30),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  const _InputField({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: cs.tertiary,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: cs.primary.withValues(alpha: 0.20)),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: TextStyle(
          fontFamily: 'kufi',
          fontSize: 13.sp,
          color: Theme.of(context).hintColor,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            fontFamily: 'kufi',
            fontSize: 12.sp,
            color: Theme.of(context).hintColor.withValues(alpha: 0.40),
          ),
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 8.h),
        ),
      ),
    );
  }
}

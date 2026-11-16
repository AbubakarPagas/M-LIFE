// ─────────────────────────────────────────────────────────────────────────────
// profile_header.dart  — Minimal centred profile header, no card background
// ─────────────────────────────────────────────────────────────────────────────

import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controller/profile_controller.dart';

// ── Shared colour tokens ───────────────────────────────────────────────────────
const kGold       = Color(0xffCDAD80);
const kGoldLight  = Color(0xffE8C97A);
const kGoldDeep   = Color(0xffA8873A);
const kGreen      = Color(0xff2E7D52);
const kGreenLight = Color(0xff4CAF50);
const kEmerald    = Color(0xff10B981);
const kDeepBlue   = Color(0xff1A2744);
const kParchment  = Color(0xffFDF6E3);

// ─────────────────────────────────────────────────────────────────────────────

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl   = Get.find<ProfileController>();
    final cs     = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final nameColor  = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final emailColor = (isDark ? Colors.white : Colors.black)
        .withValues(alpha: 0.42);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Obx(
        () => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Avatar ──────────────────────────────────────────────────
            AvatarGlow(
              duration: const Duration(seconds: 2),
              glowColor: kGold,
              glowRadiusFactor: 0.20,
              repeat: true,
              startDelay: const Duration(milliseconds: 400),
              child: _AvatarRing(),
            ),
            SizedBox(height: 10.h),

            // ── Name ────────────────────────────────────────────────────
            Text(
              ctrl.userName.value,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'kufi',
                fontSize: 20.sp,
                fontWeight: FontWeight.w800,
                color: nameColor,
                height: 1.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 4.h),

            // ── Email ────────────────────────────────────────────────────
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.email_outlined,
                  size: 11.r,
                  color: emailColor,
                ),
                SizedBox(width: 4.w),
                Flexible(
                  child: Text(
                    ctrl.userEmail.value,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'kufi',
                      fontSize: 11.sp,
                      color: emailColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 14.h),

            // ── Edit pill button ─────────────────────────────────────────
            _EditProfileButton(
              onTap: () => _showEditSheet(context, ctrl),
              cs: cs,
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }

  // ── Edit bottom sheet ──────────────────────────────────────────────────────

  void _showEditSheet(BuildContext context, ProfileController ctrl) {
    final nameCtrl  = TextEditingController(text: ctrl.userName.value);
    final emailCtrl = TextEditingController(text: ctrl.userEmail.value);
    final cs        = Theme.of(context).colorScheme;

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 32.h),
        decoration: BoxDecoration(
          color: cs.primaryContainer,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
          border: Border.all(color: kGold.withValues(alpha: 0.22), width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                margin: EdgeInsets.symmetric(vertical: 12.h),
                decoration: BoxDecoration(
                  color: kGold.withValues(alpha: 0.38),
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            ),
            Text(
              'تعديل الملف الشخصي',
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontFamily: 'naskh',
                fontSize: 13.sp,
                color: kGold,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Edit Profile',
              style: TextStyle(
                fontFamily: 'kufi',
                fontSize: 17.sp,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).hintColor,
              ),
            ),
            SizedBox(height: 20.h),
            _EditField(
              controller: nameCtrl,
              label: 'Full Name',
              icon: Icons.person_outline_rounded,
            ),
            SizedBox(height: 12.h),
            _EditField(
              controller: emailCtrl,
              label: 'Email Address',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 22.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.primary,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  ctrl.updateProfile(
                    name: nameCtrl.text,
                    email: emailCtrl.text,
                  );
                  Get.back();
                },
                child: Text(
                  'Save Changes',
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}

// ── Avatar ring ────────────────────────────────────────────────────────────────

class _AvatarRing extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Gold sweep ring
       /*  Container(
          width: 90.r,
          height: 90.r,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: SweepGradient(
              colors: [kGold, kGoldLight, kGold, kGoldDeep, kGold],
            ),
          ),
        ), */
        // Avatar
        Container(
          width: 95.r,
          height: 95.r,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: kGold.withValues(alpha: 0.45),
              width: 2,
            ),
          ),
          child: CircleAvatar(
            radius: 34.r,
            backgroundColor: kGold.withValues(alpha: 0.08),
            child: ClipOval(
              child: Image.asset(
                'assets/images/account.png',
                fit: BoxFit.cover,
                width: 90.r,
                height: 90.r,
                errorBuilder: (_, e, s) =>
                    Icon(Icons.person_rounded, size: 34.r, color: kGold),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Edit Profile pill button ───────────────────────────────────────────────────

class _EditProfileButton extends StatelessWidget {
  final VoidCallback onTap;
  final ColorScheme cs;
  final bool isDark;

  const _EditProfileButton({
    required this.onTap,
    required this.cs,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: cs.primary.withValues(alpha: isDark ? 0.18 : 0.08),
          borderRadius: BorderRadius.circular(30.r),
          border: Border.all(
            color: cs.primary.withValues(alpha: isDark ? 0.35 : 0.22),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.edit_rounded, color: cs.primary, size: 13.r),
            SizedBox(width: 6.w),
            Text(
              'Edit Profile',
              style: TextStyle(
                fontFamily: 'kufi',
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: cs.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Edit text field ────────────────────────────────────────────────────────────

class _EditField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;

  const _EditField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(
        fontFamily: 'kufi',
        fontSize: 14.sp,
        color: Theme.of(context).hintColor,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontFamily: 'kufi',
          fontSize: 13.sp,
          color: Theme.of(context).hintColor.withValues(alpha: 0.55),
        ),
        prefixIcon: Icon(icon, color: cs.primary, size: 18.r),
        filled: true,
        fillColor: cs.surfaceContainer,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(
            color: cs.primary.withValues(alpha: 0.18),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: kGold, width: 1.5),
        ),
      ),
    );
  }
}

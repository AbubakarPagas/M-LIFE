import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controller/profile_controller.dart';
import 'islamic_bg_painter.dart';

// ── Shared colour tokens ───────────────────────────────────────────────────────
const kGold = Color(0xffCDAD80);
const kGoldLight = Color(0xffE8C97A);
const kGoldDeep = Color(0xffA8873A);
const kGreen = Color(0xff2E7D52);
const kGreenLight = Color(0xff4CAF50);
const kEmerald = Color(0xff10B981);
const kDeepBlue = Color(0xff1A2744);
const kParchment = Color(0xffFDF6E3);

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ProfileController>();
    final cs = Theme.of(context).colorScheme;

    return SizedBox(
      height: 330.h,
      child: Stack(
        children: [
          // ── Gradient base ──────────────────────────────────────────────
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    cs.primary,
                    Color.lerp(cs.primary, kDeepBlue, 0.45)!,
                    Color.lerp(cs.primary, Colors.black, 0.22)!,
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
            ),
          ),

          // ── Islamic star lattice ───────────────────────────────────────
          const Positioned.fill(
            child: CustomPaint(
              painter: IslamicBgPainter(
                starColor: kGold,
                ringColor: kGold,
                starOpacity: 0.10,
                ringOpacity: 0.05,
                tileSize: 58,
              ),
            ),
          ),

          // ── Radial halo behind avatar ──────────────────────────────────
          const Positioned.fill(
            child: CustomPaint(
              painter: IslamicHaloPainter(color: kGold, opacity: 0.13),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 30.h),
              child: Obx(
                () => Column(
                  children: [
                    // Avatar row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Glowing avatar
                        AvatarGlow(
                          duration: const Duration(seconds: 2),
                          glowColor: kGold,
                          glowRadiusFactor: 0.28,
                          repeat: true,
                          startDelay: const Duration(milliseconds: 600),
                          child: _AvatarRing(),
                        ),
                        SizedBox(width: 16.w),

                        // Identity
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'السَّلامُ عَلَيْكُم',
                                textDirection: TextDirection.rtl,
                                style: TextStyle(
                                  fontFamily: 'naskh',
                                  fontSize: 13.sp,
                                  color: kGold.withValues(alpha: 0.85),
                                  height: 1.2,
                                ),
                              ),
                              SizedBox(height: 3.h),
                              Text(
                                ctrl.userName.value,
                                style: TextStyle(
                                  fontFamily: 'kufi',
                                  fontSize: 22.sp,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  height: 1.2,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.28,
                                      ),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 4.h),
                              Row(
                                children: [
                                  Icon(
                                    Icons.email_outlined,
                                    size: 11.r,
                                    color: Colors.white.withValues(alpha: 0.5),
                                  ),
                                  SizedBox(width: 4.w),
                                  Expanded(
                                    child: Text(
                                      ctrl.userEmail.value,
                                      style: TextStyle(
                                        fontFamily: 'kufi',
                                        fontSize: 10.5.sp,
                                        color: Colors.white.withValues(
                                          alpha: 0.58,
                                        ),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Edit button
                        _EditBtn(onTap: () => _showEditSheet(context, ctrl)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditSheet(BuildContext context, ProfileController ctrl) {
    final nameCtrl = TextEditingController(text: ctrl.userName.value);
    final emailCtrl = TextEditingController(text: ctrl.userEmail.value);
    final cs = Theme.of(context).colorScheme;

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
            // Handle
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
        // Outer sweep ring
        Container(
          width: 86.r,
          height: 86.r,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: SweepGradient(
              colors: [kGold, kGoldLight, kGold, kGoldDeep, kGold],
            ),
          ),
        ),
        // Avatar
        Container(
          width: 78.r,
          height: 78.r,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: kGold.withValues(alpha: 0.55), width: 2),
          ),
          child: CircleAvatar(
            radius: 39.r,
            backgroundColor: Colors.white.withValues(alpha: 0.1),
            child: ClipOval(
              child: Image.asset(
                'assets/images/account.png',
                fit: BoxFit.cover,
                width: 78.r,
                height: 78.r,
                errorBuilder: (_, __, ___) =>
                    Icon(Icons.person_rounded, size: 38.r, color: kGold),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Edit button ────────────────────────────────────────────────────────────────

class _EditBtn extends StatelessWidget {
  final VoidCallback onTap;
  const _EditBtn({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(9.r),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          shape: BoxShape.circle,
          border: Border.all(color: kGold.withValues(alpha: 0.45), width: 1),
        ),
        child: Icon(Icons.edit_rounded, color: kGold, size: 18.r),
      ),
    );
  }
}

// ── Small pill action button ───────────────────────────────────────────────────

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

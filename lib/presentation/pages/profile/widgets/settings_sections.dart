import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/utils/toast/islamic_toast.dart';
import '../../../../presentation/controllers/theme_controller.dart';
import '../controller/profile_controller.dart';
import 'profile_header.dart' show kGold, kGreen;
import 'profile_section_card.dart';

// ─── Account Settings ─────────────────────────────────────────────────────────

class AccountSettingsSection extends StatelessWidget {
  const AccountSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ProfileController>();
    final cs = Theme.of(context).colorScheme;

    return ProfileSectionCard(
      title: 'Account Settings',
      arabicTitle: null,
      titleIcon: Icons.manage_accounts_rounded,
      children: [
        ProfileTile(
          icon: Icons.person_outline_rounded,
          title: 'Edit Profile',
          subtitle: 'Update your name and email',
          onTap: () => _showEditDialog(context, ctrl),
        ),
        ProfileTile(
          icon: Icons.lock_outline_rounded,
          title: 'Change Password',
          subtitle: 'Update your account password',
          onTap: () => _showPasswordDialog(context),
        ),
        ProfileTile(
          icon: Icons.language_rounded,
          title: 'Language',
          subtitle: ctrl.currentLanguageName,
          onTap: () => _showLanguageSheet(context, ctrl),
        ),
        ProfileTile(
          icon: Icons.palette_outlined,
          title: 'App Theme',
          subtitle: _themeName(ctrl.themeCtrl.currentTheme),
          onTap: () => _showThemeSheet(context, ctrl),
        ),
        Obx(
          () => ProfileTile(
            icon: Icons.notifications_none_rounded,
            title: 'Notifications',
            subtitle: ctrl.notificationsOn.value ? 'Enabled' : 'Disabled',
            trailing: Switch.adaptive(
              value: ctrl.notificationsOn.value,
              onChanged: (_) => ctrl.toggleNotifications(),
              activeThumbColor: cs.primary,
              activeTrackColor: cs.primary.withValues(alpha: 0.3),
            ),
            onTap: ctrl.toggleNotifications,
          ),
        ),
        ProfileTile(
          icon: Icons.security_rounded,
          title: 'Privacy & Security',
          subtitle: 'Manage your data and privacy',
          onTap: () {},
        ),
      ],
    );
  }

  String _themeName(AppTheme t) {
    switch (t) {
      case AppTheme.blue:
        return 'Blue (Default)';
      case AppTheme.brown:
        return 'Brown (Warm)';
      case AppTheme.green:
        return 'Classic (Green)';
      case AppTheme.dark:
        return 'Dark Mode';
    }
  }

  void _showEditDialog(BuildContext context, ProfileController ctrl) {
    final nameCtrl = TextEditingController(text: ctrl.userName.value);
    final emailCtrl = TextEditingController(text: ctrl.userEmail.value);
    final cs = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: cs.primaryContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
          side: BorderSide(color: kGold.withValues(alpha: 0.25), width: 1),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'تعديل الملف',
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontFamily: 'naskh',
                fontSize: 12.sp,
                color: kGold,
              ),
            ),
            Text(
              'Edit Profile',
              style: TextStyle(
                fontFamily: 'kufi',
                fontSize: 16.sp,
                color: Theme.of(context).hintColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DialogField(ctrl: nameCtrl, label: 'Full Name'),
            SizedBox(height: 10.h),
            _DialogField(
              ctrl: emailCtrl,
              label: 'Email',
              keyboard: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'kufi',
                fontSize: 13.sp,
                color: Theme.of(context).hintColor.withValues(alpha: 0.5),
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: cs.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            onPressed: () {
              ctrl.updateProfile(name: nameCtrl.text, email: emailCtrl.text);
              Navigator.pop(context);
            },
            child: Text(
              'Save',
              style: TextStyle(
                fontFamily: 'kufi',
                fontSize: 13.sp,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPasswordDialog(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: cs.primaryContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
          side: BorderSide(color: kGold.withValues(alpha: 0.2), width: 1),
        ),
        title: Text(
          'Change Password',
          style: TextStyle(
            fontFamily: 'kufi',
            fontSize: 16.sp,
            color: Theme.of(context).hintColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Password change requires Firebase Authentication.',
          style: TextStyle(
            fontFamily: 'kufi',
            fontSize: 12.sp,
            color: Theme.of(context).hintColor.withValues(alpha: 0.65),
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: TextStyle(
                fontFamily: 'kufi',
                fontSize: 13.sp,
                color: cs.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguageSheet(BuildContext context, ProfileController ctrl) {
    final cs = Theme.of(context).colorScheme;
    Get.bottomSheet(
      _IslamicSheet(
        title: 'Select Language',
        arabicTitle: 'اختر اللغة',
        child: SizedBox(
          height: 320.h,
          child: ListView.builder(
            itemCount: ctrl.availableLanguages.length,
            itemBuilder: (context, i) {
              final lang = ctrl.availableLanguages[i];
              final isCurrent = lang.languageName == ctrl.currentLanguageName;
              return _SheetTile(
                title: lang.languageName,
                subtitle: lang.appLang,
                isSelected: isCurrent,
                cs: cs,
                onTap: () {
                  ctrl.changeLanguage(lang);
                  Get.back();
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _showThemeSheet(BuildContext context, ProfileController ctrl) {
    final cs = Theme.of(context).colorScheme;
    final themes = [
      (
        AppTheme.blue,
        'Blue (Default)',
        Icons.water_drop_rounded,
        const Color(0xff404C6E),
      ),
      (
        AppTheme.brown,
        'Brown (Warm)',
        Icons.local_fire_department_rounded,
        const Color(0xff583623),
      ),
      (
        AppTheme.green,
        'Classic (Green)',
        Icons.eco_rounded,
        const Color(0xff232c13),
      ),
      (
        AppTheme.dark,
        'Dark Mode',
        Icons.dark_mode_rounded,
        const Color(0xff1E1E1E),
      ),
    ];
    Get.bottomSheet(
      _IslamicSheet(
        title: 'Choose Theme',
        arabicTitle: 'اختر السمة',
        child: Wrap(
          spacing: 10.w,
          runSpacing: 10.h,
          children: themes.map((t) {
            final sel = ctrl.themeCtrl.currentTheme == t.$1;
            return GestureDetector(
              onTap: () {
                ctrl.changeTheme(t.$1);
                Get.back();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: sel
                      ? t.$4.withValues(alpha: 0.15)
                      : cs.surfaceContainer,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                    color: sel
                        ? t.$4.withValues(alpha: 0.6)
                        : cs.primary.withValues(alpha: 0.1),
                    width: sel ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(t.$3, color: t.$4, size: 16.r),
                    SizedBox(width: 6.w),
                    Text(
                      t.$2,
                      style: TextStyle(
                        fontFamily: 'kufi',
                        fontSize: 12.sp,
                        fontWeight: sel ? FontWeight.w700 : FontWeight.normal,
                        color: sel ? t.$4 : Theme.of(context).hintColor,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ─── Islamic Preferences ──────────────────────────────────────────────────────

class IslamicPreferencesSection extends StatelessWidget {
  const IslamicPreferencesSection({super.key});

  static const _calcMethods = [
    'Muslim World League',
    'Egyptian Authority',
    'Umm al-Qura, Makkah',
    'University of Islamic Sciences, Karachi',
    'ISNA (North America)',
    'Institute of Geophysics, Tehran',
    'Union des Organisations Islamiques de France',
  ];
  static const _madhabs = ["Shafi'i", 'Hanafi', 'Maliki', 'Hanbali'];
  static const _translations = [
    'Sahih International',
    'Pickthall',
    'Yusuf Ali',
    'Dr. Mustafa Khattab',
    'Transliteration',
    'Arabic Only',
  ];
  static const _azanVoices = [
    'Makkah Azan',
    'Madinah Azan',
    'Al-Aqsa Azan',
    'Egyptian Azan',
    'Turkish Azan',
  ];

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ProfileController>();
    return ProfileSectionCard(
      title: 'Islamic Preferences',
      arabicTitle: 'التفضيلات الإسلامية',
      titleIcon: Icons.mosque_rounded,
      iconColor: kGreen,
      children: [
        Obx(
          () => ProfileTile(
            icon: Icons.calculate_rounded,
            title: 'Prayer Calculation Method',
            subtitle: ctrl.calcMethod.value,
            onTap: () => _showOpts(
              context,
              'Calculation Method',
              _calcMethods,
              ctrl.calcMethod.value,
              ctrl.setCalcMethod,
            ),
          ),
        ),
        Obx(
          () => ProfileTile(
            icon: Icons.school_rounded,
            title: 'Madhab (Fiqh School)',
            subtitle: ctrl.madhab.value,
            onTap: () => _showOpts(
              context,
              'Madhab',
              _madhabs,
              ctrl.madhab.value,
              ctrl.setMadhab,
            ),
          ),
        ),
        Obx(
          () => ProfileTile(
            icon: Icons.translate_rounded,
            title: 'Quran Translation',
            subtitle: ctrl.translation.value,
            onTap: () => _showOpts(
              context,
              'Translation',
              _translations,
              ctrl.translation.value,
              ctrl.setTranslation,
            ),
          ),
        ),
        Obx(
          () => ProfileTile(
            icon: Icons.volume_up_rounded,
            title: 'Azan Voice',
            subtitle: ctrl.azanVoice.value,
            onTap: () => _showOpts(
              context,
              'Azan Voice',
              _azanVoices,
              ctrl.azanVoice.value,
              ctrl.setAzanVoice,
            ),
          ),
        ),
        ProfileTile(
          icon: Icons.alarm_rounded,
          title: 'Dhikr Reminders',
          subtitle: 'Morning & Evening reminders',
          onTap: () {},
        ),
        ProfileTile(
          icon: Icons.format_quote_rounded,
          title: 'Daily Quote Preferences',
          subtitle: 'Quran Ayah, Hadith, or Both',
          onTap: () {},
        ),
      ],
    );
  }

  void _showOpts(
    BuildContext ctx,
    String title,
    List<String> opts,
    String current,
    void Function(String) onSel,
  ) {
    final cs = Theme.of(ctx).colorScheme;
    Get.bottomSheet(
      _IslamicSheet(
        title: title,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 300.h),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: opts.length,
            itemBuilder: (_, i) => _SheetTile(
              title: opts[i],
              isSelected: opts[i] == current,
              cs: cs,
              onTap: () {
                onSel(opts[i]);
                Get.back();
              },
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Support & Info ───────────────────────────────────────────────────────────

class SupportSection extends StatelessWidget {
  const SupportSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfileSectionCard(
      title: 'Support & Information',
      arabicTitle: 'الدعم والمعلومات',
      titleIcon: Icons.info_outline_rounded,
      iconColor: const Color(0xff6C63FF),
      children: [
        ProfileTile(
          icon: Icons.info_rounded,
          title: 'About App',
          subtitle: 'Version 1.0.0',
          iconColor: const Color(0xff6C63FF),
          onTap: () => _aboutDialog(context),
        ),
        ProfileTile(
          icon: Icons.support_agent_rounded,
          title: 'Contact Support',
          iconColor: kGreen,
          onTap: () => _launch('mailto:support@mishabapp.com'),
        ),
        ProfileTile(icon: Icons.quiz_rounded, title: 'FAQ', onTap: () {}),
        ProfileTile(
          icon: Icons.description_outlined,
          title: 'Terms & Conditions',
          onTap: () {},
        ),
        ProfileTile(
          icon: Icons.privacy_tip_outlined,
          title: 'Privacy Policy',
          onTap: () {},
        ),
        ProfileTile(
          icon: Icons.star_rate_rounded,
          title: 'Rate App',
          iconColor: kGold,
          onTap: () {},
        ),
        ProfileTile(
          icon: Icons.share_rounded,
          title: 'Share App',
          iconColor: const Color(0xff4CAF50),
          onTap: () {},
        ),
      ],
    );
  }

  void _aboutDialog(BuildContext ctx) {
    showAboutDialog(
      context: ctx,
      applicationName: 'Mishab Path',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2026 Mishab Path. All rights reserved.',
      children: [
        SizedBox(height: 12.h),
        Text(
          'A comprehensive Islamic app for Quran, Prayer Times, Tasbih, Adhkar and more.',
          style: TextStyle(
            fontFamily: 'kufi',
            fontSize: 12.sp,
            color: Theme.of(ctx).hintColor.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }
}

// ─── Logout ───────────────────────────────────────────────────────────────────

class LogoutSection extends StatelessWidget {
  const LogoutSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.red.withValues(alpha: 0.40), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withValues(alpha: isDark ? 0.10 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20.r),
        child: InkWell(
          onTap: () => _confirm(context),
          borderRadius: BorderRadius.circular(20.r),
          splashColor: Colors.red.withValues(alpha: 0.06),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.logout_rounded, color: Colors.red, size: 20.r),
                SizedBox(width: 10.w),
                Text(
                  'Log Out',
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.red,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirm(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: cs.primaryContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
          side: BorderSide(color: Colors.red.withValues(alpha: 0.3), width: 1),
        ),
        title: Row(
          children: [
            const Icon(Icons.logout_rounded, color: Colors.red),
            SizedBox(width: 8.w),
            Text(
              'Log Out',
              style: TextStyle(
                fontFamily: 'kufi',
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).hintColor,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to log out? Your local data will be preserved.',
          style: TextStyle(
            fontFamily: 'kufi',
            fontSize: 12.sp,
            color: Theme.of(context).hintColor.withValues(alpha: 0.7),
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'kufi',
                fontSize: 13.sp,
                color: Theme.of(context).hintColor.withValues(alpha: 0.5),
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            onPressed: () async {
              Navigator.pop(context);
              final ctrl = Get.find<ProfileController>();
              await ctrl.logout();
              if (context.mounted) {
                IslamicToast.show(
                  context,
                  message: 'You have been logged out successfully',
                  arabicMessage: 'تم تسجيل الخروج بنجاح',
                  type: IslamicToastType.success,
                );
              }
            },
            child: Text(
              'Log Out',
              style: TextStyle(
                fontFamily: 'kufi',
                fontSize: 13.sp,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared bottom-sheet container ───────────────────────────────────────────

class _IslamicSheet extends StatelessWidget {
  final String title;
  final String? arabicTitle;
  final Widget child;

  const _IslamicSheet({
    required this.title,
    this.arabicTitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        border: Border.all(color: kGold.withValues(alpha: 0.2), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              margin: EdgeInsets.symmetric(vertical: 10.h),
              decoration: BoxDecoration(
                color: kGold.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
          ),
          if (arabicTitle != null)
            Text(
              arabicTitle!,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontFamily: 'naskh',
                fontSize: 14.sp,
                color: kGold.withValues(alpha: 0.8),
              ),
            ),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'kufi',
              fontSize: 17.sp,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).hintColor,
            ),
          ),
          SizedBox(height: 14.h),
          child,
        ],
      ),
    );
  }
}

class _SheetTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool isSelected;
  final ColorScheme cs;
  final VoidCallback onTap;

  const _SheetTile({
    required this.title,
    this.subtitle,
    required this.isSelected,
    required this.cs,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'kufi',
          fontSize: 13.sp,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
          color: isSelected ? cs.primary : Theme.of(context).hintColor,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: TextStyle(
                fontFamily: 'kufi',
                fontSize: 10.sp,
                color: Theme.of(context).hintColor.withValues(alpha: 0.5),
              ),
            )
          : null,
      trailing: isSelected
          ? Icon(Icons.check_circle_rounded, color: kGold, size: 18.r)
          : null,
      onTap: onTap,
    );
  }
}

class _DialogField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final TextInputType? keyboard;

  const _DialogField({required this.ctrl, required this.label, this.keyboard});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboard,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontFamily: 'kufi', fontSize: 13.sp),
      ),
      style: TextStyle(fontFamily: 'kufi', fontSize: 13.sp),
    );
  }
}

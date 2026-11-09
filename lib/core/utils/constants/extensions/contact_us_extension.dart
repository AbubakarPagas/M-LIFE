import 'dart:developer' show log;
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

extension ContactUsExtension on void {
  Future<void> contactUs({required BuildContext context}) async {
    final info = await PackageInfo.fromPlatform();
    const String stringText =
        '| يرجى كتابة أي ملاحظة أو إستفسار دون حذف المعلومات التي في الأعلى، جزاكم الله خيرًا |';
    final String text =
        '''-----------------------------------\n'''
        '''تطبيق: ${info.appName}\n'''
        '''الإصدار: ${info.version}\n'''
        '''النظام: ${Platform.operatingSystem}-${Platform.operatingSystemVersion}\n'''
        '''-----------------------------------\n'''
        '''$stringText\n\n\n''';
    final String uri =
        'mailto:abubakarpagas@gmail.com?subject=${Uri.encodeComponent(info.appName)}&body=${Uri.encodeComponent(text)}';
    if (await canLaunchUrl(Uri.parse(uri))) {
      await launchUrl(Uri.parse(uri));
    } else {
      log('No email client found');
    }
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../flutter_statusbarcolor_ns.dart';

void setStatusBarColor(BuildContext context) async {
  var prefs = await SharedPreferences.getInstance();
  var darkModeOn = prefs.getBool('darkMode') ?? true;
  // final theme = ThemeService.getTheme(context);
  if (Platform.isAndroid) {
    // FlutterStatusbarcolor.setNavigationBarColor(
    //     // ignore: use_build_context_synchronously
    //     Theme.of(context).colorScheme.background);
    if (darkModeOn) {
      // FlutterStatusbarcolor.setStatusBarColor(Colors.black);
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: Colors.white,
        ),
      );
      /*  SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          systemNavigationBarColor: Colors.black,
          statusBarColor: Colors.transparent.withValues(alpha: 0.5),
          statusBarIconBrightness: Brightness.light,
        ),
      ); */
    } else {
      // FlutterStatusbarcolor.setStatusBarColor(Colors.white);/*
      // */
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          systemNavigationBarColor: Colors.transparent,
          statusBarColor: Colors.transparent.withValues(alpha: 0.5),
          statusBarIconBrightness: Brightness.light,
        ),
      );
      /*  SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: Colors.white.withValues(alpha: 0.5),
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: Colors.white,
        ),
      ); */
    }
  } else if (Platform.isIOS) {
    if (darkModeOn) {
      FlutterStatusbarcolor.setStatusBarColor(
        Colors.white.withValues(alpha: 0.5),
      );
      FlutterStatusbarcolor.setStatusBarWhiteForeground(false);
    } else {
      FlutterStatusbarcolor.setStatusBarColor(const Color(0xcc111111));
      FlutterStatusbarcolor.setStatusBarWhiteForeground(true);
    }
  }
}

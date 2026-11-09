import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

final ThemeData blueTheme = ThemeData.light(useMaterial3: false).copyWith(
  colorScheme: const ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xff404C6E),
    onPrimary: Color(0xff404C6E),
    secondary: Color(0xffffffff),
    onSecondary: Color(0xffCDAD80),
    error: Color(0xffE0E1E0),
    onError: Color(0xffE0E1E0),
    surface: Color(0xffCDAD80),
    onSurface: Color(0xffE0E1E0),
    inversePrimary: Color(0xff000000),
    inverseSurface: Color(0xffCD9974),
    primaryContainer: Color(0xffFFFFFF),
    onPrimaryContainer: Color(0xfff3efdf),
    onInverseSurface: Color(0xff000000),
    surfaceContainer: Color(0xfffaf7f3),
  ),
  primaryColor: const Color(0xff404C6E),
  primaryColorLight: const Color(0xff53618c),
  primaryColorDark: const Color(0xff404C6E),
  dividerColor: const Color(0xffCDAD80),
  highlightColor: const Color(0xffCDAD80).withValues(alpha: 0.25),
  scaffoldBackgroundColor: const Color(0xffffffff),
  canvasColor: const Color(0xffFFFFFF),
  hoverColor: const Color(0xffFFFFFF).withValues(alpha: 0.3),
  disabledColor: const Color(0Xff000000),
  hintColor: const Color(0xff404C6E),
  focusColor: const Color(0xffE0E1E0),
  secondaryHeaderColor: const Color(0xff53618c),
  cardColor: const Color(0xff404C6E),
  dividerTheme: const DividerThemeData(color: Color(0xffCDAD80)),
  textSelectionTheme: TextSelectionThemeData(
    selectionColor: const Color(0xffE0E1E0).withValues(alpha: 0.3),
    selectionHandleColor: const Color(0xffE0E1E0),
  ),
  cupertinoOverrideTheme: const CupertinoThemeData(
    primaryColor: Color(0xff53618c),
  ),
  timePickerTheme: TimePickerThemeData(
    backgroundColor: const Color(0xffCDAD80),
    dialBackgroundColor: const Color(0xffFFFFFF),
    dialHandColor: const Color(0xffCDAD80),
    dialTextColor: const Color(0xff000000).withValues(alpha: .6),
    entryModeIconColor: const Color(0xff000000).withValues(alpha: .6),
    hourMinuteTextColor: const Color(0xff000000).withValues(alpha: .6),
    dayPeriodTextColor: const Color(0xff000000).withValues(alpha: .6),
    cancelButtonStyle: ButtonStyle(
      backgroundColor: WidgetStateProperty.all(
        const Color(0xff000000).withValues(alpha: .6),
      ),
      foregroundColor: WidgetStateProperty.all(const Color(0xffFFFFFF)),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
      textStyle: WidgetStateProperty.all(
        const TextStyle(fontFamily: 'kufi', fontSize: 16),
      ),
    ),
    confirmButtonStyle: ButtonStyle(
      backgroundColor: WidgetStateProperty.all(
        const Color(0xff000000).withValues(alpha: .8),
      ),
      foregroundColor: WidgetStateProperty.all(const Color(0xffFFFFFF)),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
      textStyle: WidgetStateProperty.all(
        const TextStyle(fontFamily: 'kufi', fontSize: 16),
      ),
    ),
  ),
);

final ThemeData brownTheme = ThemeData(
  useMaterial3: false,
  colorScheme: const ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xff583623),
    onPrimary: Color(0xff583623),
    secondary: Color(0xffffffff),
    onSecondary: Color(0xff854621),
    error: Color(0xffcf8e55),
    onError: Color(0xffcf8e55),
    surface: Color(0xffcf8e55),
    onSurface: Color(0xffcf8e55),
    inversePrimary: Color(0xff000000),
    inverseSurface: Color(0xffcf8e55),
    primaryContainer: Color(0xffFDF7F4),
    onPrimaryContainer: Color(0xffFDF7F4),
    onInverseSurface: Color(0xff000000),
    surfaceContainer: Color(0xffFDF7F4),
  ),
  primaryColor: const Color(0xff583623),
  primaryColorLight: const Color(0xff854621),
  primaryColorDark: const Color(0xff583623),
  dividerColor: const Color(0xff854621),
  highlightColor: const Color(0xffcf8e55).withValues(alpha: 0.25),
  scaffoldBackgroundColor: const Color(0xff583623),
  canvasColor: const Color(0xffF2E5D5),
  hoverColor: const Color(0xffF2E5D5).withValues(alpha: 0.3),
  disabledColor: const Color(0xff000000),
  hintColor: const Color(0xff000000),
  focusColor: const Color(0xff583623),
  secondaryHeaderColor: const Color(0xff583623),
  cardColor: const Color(0xff583623),
  textSelectionTheme: TextSelectionThemeData(
    selectionColor: const Color(0xffcf8e55).withValues(alpha: 0.3),
    selectionHandleColor: const Color(0xffcf8e55),
  ),
  cupertinoOverrideTheme: const CupertinoThemeData(
    primaryColor: Color(0xffcf8e55),
  ),
  timePickerTheme: TimePickerThemeData(
    backgroundColor: const Color(0xffcf8e55),
    dialBackgroundColor: const Color(0xffFDF7F4),
    dialHandColor: const Color(0xffcf8e55),
    dialTextColor: const Color(0xff000000).withValues(alpha: .6),
    entryModeIconColor: const Color(0xff000000).withValues(alpha: .6),
    hourMinuteTextColor: const Color(0xff000000).withValues(alpha: .6),
    dayPeriodTextColor: const Color(0xff000000).withValues(alpha: .6),
    cancelButtonStyle: ButtonStyle(
      backgroundColor: WidgetStateProperty.all(
        const Color(0xff000000).withValues(alpha: .6),
      ),
      foregroundColor: WidgetStateProperty.all(const Color(0xffFDF7F4)),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
      textStyle: WidgetStateProperty.all(
        const TextStyle(fontFamily: 'kufi', fontSize: 16),
      ),
    ),
    confirmButtonStyle: ButtonStyle(
      backgroundColor: WidgetStateProperty.all(
        const Color(0xff000000).withValues(alpha: .8),
      ),
      foregroundColor: WidgetStateProperty.all(const Color(0xffFDF7F4)),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
      textStyle: WidgetStateProperty.all(
        const TextStyle(fontFamily: 'kufi', fontSize: 16),
      ),
    ),
  ),
);

final ThemeData oldTheme = ThemeData.light(useMaterial3: false).copyWith(
  colorScheme: const ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xff232c13),
    onPrimary: Color(0xff161f07),
    secondary: Color(0xfff3efdf),
    onSecondary: Color(0xff91a57d),
    error: Color(0xffE0E1E0),
    onError: Color(0xffE0E1E0),
    surface: Color(0xff91a57d),
    onSurface: Color(0xffE0E1E0),
    inversePrimary: Color(0xff000000),
    inverseSurface: Color(0xffCD9974),
    primaryContainer: Color(0xfff3efdf),
    onPrimaryContainer: Color(0xfff3efdf),
    onInverseSurface: Color(0xff000000),
    surfaceContainer: Color(0xfff3efdf),
  ),
  primaryColor: const Color(0xff232c13),
  primaryColorLight: const Color(0xff53618c),
  primaryColorDark: const Color(0xff161f07),
  dividerColor: const Color(0xff91a57d),
  highlightColor: const Color(0xff91a57d).withValues(alpha: 0.25),
  scaffoldBackgroundColor: const Color(0xff232c13),
  canvasColor: const Color(0xfff3efdf),
  hoverColor: const Color(0xfff3efdf).withValues(alpha: 0.3),
  disabledColor: const Color(0xff000000),
  hintColor: const Color(0xff232c13),
  focusColor: const Color(0xffE0E1E0),
  secondaryHeaderColor: const Color(0xff53618c),
  cardColor: const Color(0xff232c13),
  dividerTheme: const DividerThemeData(color: Color(0xff91a57d)),
  textSelectionTheme: TextSelectionThemeData(
    selectionColor: const Color(0xffE0E1E0).withValues(alpha: 0.3),
    selectionHandleColor: const Color(0xffE0E1E0),
  ),
  cupertinoOverrideTheme: const CupertinoThemeData(
    primaryColor: Color(0xff53618c),
  ),
  timePickerTheme: TimePickerThemeData(
    backgroundColor: const Color(0xff91a57d),
    dialBackgroundColor: const Color(0xfff3efdf),
    dialHandColor: const Color(0xff91a57d),
    dialTextColor: const Color(0xff000000).withValues(alpha: .6),
    entryModeIconColor: const Color(0xff000000).withValues(alpha: .6),
    hourMinuteTextColor: const Color(0xff000000).withValues(alpha: .6),
    dayPeriodTextColor: const Color(0xff000000).withValues(alpha: .6),
    cancelButtonStyle: ButtonStyle(
      backgroundColor: WidgetStateProperty.all(
        const Color(0xff000000).withValues(alpha: .6),
      ),
      foregroundColor: WidgetStateProperty.all(const Color(0xfff3efdf)),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
      textStyle: WidgetStateProperty.all(
        const TextStyle(fontFamily: 'kufi', fontSize: 16),
      ),
    ),
    confirmButtonStyle: ButtonStyle(
      backgroundColor: WidgetStateProperty.all(
        const Color(0xff000000).withValues(alpha: .8),
      ),
      foregroundColor: WidgetStateProperty.all(const Color(0xfff3efdf)),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
      textStyle: WidgetStateProperty.all(
        const TextStyle(fontFamily: 'kufi', fontSize: 16),
      ),
    ),
  ),
);

final ThemeData darkTheme = ThemeData.dark(useMaterial3: false).copyWith(
  colorScheme: const ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xff404C6E),
    onPrimary: Color(0xff000000),
    secondary: Color(0xffffffff),
    onSecondary: Color(0xff373737),
    error: Color(0xff404C6E),
    onError: Color(0xff404C6E),
    surface: Color(0xffCDAD80),
    onSurface: Color(0xff404C6E),
    inversePrimary: Color(0xffffffff),
    inverseSurface: Color(0xffCD9974),
    primaryContainer: Color(0xff1E1E1E),
    onPrimaryContainer: Color(0xff1E1E1E),
    onInverseSurface: Color(0xff000000),
    surfaceContainer: Color(0xff1E1E1E),
  ),
  primaryColor: const Color(0xff1E1E1E),
  primaryColorLight: const Color(0xff373737),
  primaryColorDark: const Color(0xff010101),
  dividerColor: const Color(0xff404C6E),
  highlightColor: const Color(0xff404C6E).withValues(alpha: 0.25),
  scaffoldBackgroundColor: const Color(0xff000000),
  canvasColor: const Color(0xffF6F6EE),
  hoverColor: const Color(0xffF6F6EE).withValues(alpha: 0.3),
  disabledColor: const Color(0xff000000),
  hintColor: const Color(0xffffffff),
  focusColor: const Color(0xff404C6E),
  secondaryHeaderColor: const Color(0xff404C6E),
  cardColor: const Color(0xffF6F6EE),
  textSelectionTheme: TextSelectionThemeData(
    selectionColor: const Color(0xff404C6E).withValues(alpha: 0.3),
    selectionHandleColor: const Color(0xff404C6E),
  ),
  cupertinoOverrideTheme: const CupertinoThemeData(
    primaryColor: Color(0xff404C6E),
  ),
  timePickerTheme: TimePickerThemeData(
    backgroundColor: const Color(0xffCDAD80),
    dialBackgroundColor: const Color(0xff1E1E1E),
    dialHandColor: const Color(0xffCDAD80),
    dialTextColor: const Color(0xffF6F6EE).withValues(alpha: .6),
    entryModeIconColor: const Color(0xffF6F6EE).withValues(alpha: .6),
    hourMinuteTextColor: const Color(0xffF6F6EE).withValues(alpha: .6),
    dayPeriodTextColor: const Color(0xffF6F6EE).withValues(alpha: .6),
    dayPeriodColor: const Color(0xff1E1E1E),
    cancelButtonStyle: ButtonStyle(
      backgroundColor: WidgetStateProperty.all(
        const Color(0xffF6F6EE).withValues(alpha: .6),
      ),
      foregroundColor: WidgetStateProperty.all(const Color(0xff1E1E1E)),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
      textStyle: WidgetStateProperty.all(
        const TextStyle(fontFamily: 'kufi', fontSize: 16),
      ),
    ),
    confirmButtonStyle: ButtonStyle(
      backgroundColor: WidgetStateProperty.all(
        const Color(0xffF6F6EE).withValues(alpha: .8),
      ),
      foregroundColor: WidgetStateProperty.all(const Color(0xff1E1E1E)),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
      textStyle: WidgetStateProperty.all(
        const TextStyle(fontFamily: 'kufi', fontSize: 16),
      ),
    ),
  ),
  dialogTheme: const DialogThemeData(backgroundColor: Color(0xff1E1E1E)),
  tabBarTheme: const TabBarThemeData(indicatorColor: Color(0xff404C6E)),
);


// ─────────────────────────────────────────────────────────────────────────────
// darkTheme — Islamic emerald & gold palette
// Background: deep emerald-green  (#0C1E15 → #112219)
// Accent:     gold                (#CDAD80 / #E8C97A)
// Text:       white / soft-white
// ─────────────────────────────────────────────────────────────────────────────


// final ThemeData brownTheme = ThemeData(
//   useMaterial3: true,
//   colorScheme: const ColorScheme(
//     brightness: Brightness.light,
//     primary: Color(0xff77554B),
//     onPrimary: Color(0xff77554B),
//     secondary: Color(0xffffffff),
//     onSecondary: Color(0xffFFEEDC),
//     error: Color(0xffCD9974),
//     onError: Color(0xffCD9974),
//     tertiary: Color(0xffFFFBF8),
//     // onBackground: Color(0xffFFFBF8),
//     surface: Color(0xffCD9974),
//     onSurface: Color(0xffCD9974),
//     inversePrimary: Color(0xff000000),
//     inverseSurface: Color(0xffCD9974),
//   ),
//   primaryColor: const Color(0xff77554B),
//   primaryColorLight: const Color(0xffFFEEDC),
//   primaryColorDark: const Color(0xff77554B),
//   // dialogBackgroundColor: const Color(0xffFFFBF8),
//   dividerColor: const Color(0xffFFEEDC),
//   highlightColor: const Color(0xffCD9974).withValues(alpha: 0.25),
//   indicatorColor: const Color(0xffFFEEDC),
//   scaffoldBackgroundColor: const Color(0xff77554B),
//   canvasColor: const Color(0xffF2E5D5),
//   hoverColor: const Color(0xffF2E5D5).withValues(alpha: 0.3),
//   disabledColor: const Color(0Xffffffff),
//   hintColor: const Color(0xff000000),
//   focusColor: const Color(0xff77554B),
//   secondaryHeaderColor: const Color(0xff77554B),
//   cardColor: const Color(0xff77554B),
//   textSelectionTheme: TextSelectionThemeData(
//       selectionColor: const Color(0xffCD9974).withValues(alpha: 0.3),
//       selectionHandleColor: const Color(0xffCD9974)),
//   cupertinoOverrideTheme: const CupertinoThemeData(
//     primaryColor: Color(0xffCD9974),
//   ),
// );

// final ThemeData oldTheme = ThemeData.light(
//   useMaterial3: true,
// ).copyWith(
//   colorScheme: const ColorScheme(
//     brightness: Brightness.light,
//     primary: Color(0xff232c13),
//     onPrimary: Color(0xff161f07),
//     secondary: Color(0xfff3efdf),
//     onSecondary: Color(0xff91a57d),
//     error: Color(0xffE0E1E0),
//     onError: Color(0xffE0E1E0),
//     tertiary: Color(0xfff3efdf),
//     // onBackground: Color(0xfff3efdf),
//     surface: Color(0xff91a57d),
//     onSurface: Color(0xffE0E1E0),
//     inversePrimary: Color(0xff000000),
//     inverseSurface: Color(0xff232c13),
//   ),
//   primaryColor: const Color(0xff232c13),
//   primaryColorLight: const Color(0xff53618c),
//   primaryColorDark: const Color(0xff161f07),
//   // dialogBackgroundColor: const Color(0xfff3efdf),
//   dividerColor: const Color(0xff91a57d),
//   highlightColor: const Color(0xff91a57d).withValues(alpha: 0.25),
//   indicatorColor: const Color(0xff91a57d),
//   scaffoldBackgroundColor: const Color(0xff232c13),
//   canvasColor: const Color(0xfff3efdf),
//   hoverColor: const Color(0xfff3efdf).withValues(alpha: 0.3),
//   disabledColor: const Color(0xfff3efdf),
//   hintColor: const Color(0xff232c13),
//   focusColor: const Color(0xffE0E1E0),
//   secondaryHeaderColor: const Color(0xff53618c),
//   cardColor: const Color(0xff232c13),
//   dividerTheme: const DividerThemeData(
//     color: Color(0xff91a57d),
//   ),
//   textSelectionTheme: TextSelectionThemeData(
//       selectionColor: const Color(0xffE0E1E0).withValues(alpha: 0.3),
//       selectionHandleColor: const Color(0xffE0E1E0)),
//   cupertinoOverrideTheme: const CupertinoThemeData(
//     primaryColor: Color(0xff53618c),
//   ),
// );

// final ThemeData darkTheme = ThemeData.dark(
//   useMaterial3: true,
// ).copyWith(
//   colorScheme: const ColorScheme(
//     brightness: Brightness.light,
//     primary: Color(0xffCDAD80),
//     onPrimary: Color(0xffCDAD80),
//     secondary: Color(0xffffffff),
//     onSecondary: Color(0xff373737),
//     error: Color(0xff404C6E),
//     onError: Color(0xff404C6E),
//     tertiary: Color(0xff1E1E1E),
//     // onBackground: Color(0xff1E1E1E),
//     surface: Color(0xffCDAD80),
//     onSurface: Color(0xff404C6E),
//     inversePrimary: Color(0xffffffff),
//     inverseSurface: Color(0xff41644A),
//   ),
//   primaryColor: const Color(0xffCDAD80),
//   primaryColorLight: const Color(0xff373737),
//   primaryColorDark: const Color(0xff010101),
//   // dialogBackgroundColor: const Color(0xff1E1E1E),
//   dividerColor: const Color(0xff404C6E),
//   highlightColor: const Color(0xff404C6E).withValues(alpha: 0.25),
//   indicatorColor: const Color(0xff404C6E),
//   scaffoldBackgroundColor: const Color(0xff000000),
//   canvasColor: const Color(0xffF6F6EE),
//   hoverColor: const Color(0xffF6F6EE).withValues(alpha: 0.3),
//   disabledColor: const Color(0Xffffffff),
//   hintColor: const Color(0xffffffff),
//   focusColor: const Color(0xff404C6E),
//   secondaryHeaderColor: const Color(0xff404C6E),
//   cardColor: const Color(0xffF6F6EE),
//   textSelectionTheme: TextSelectionThemeData(
//       selectionColor: const Color(0xff404C6E).withValues(alpha: 0.3),
//       selectionHandleColor: const Color(0xff404C6E)),
//   cupertinoOverrideTheme: const CupertinoThemeData(
//     primaryColor: Color(0xff404C6E),
//   ),
// );

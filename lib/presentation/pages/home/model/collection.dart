import 'package:flutter/material.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';
import 'package:misbah_path/apps/routes/route_name.dart';

class Collection {
  final IconData assetName;
  final String title;
  final String routeName;
  final String svgName;

  /// Whether this collection tile requires a premium subscription.
  final bool isPremium;

  Collection(
    this.assetName,
    this.title,
    this.routeName,
    this.svgName, {
    this.isPremium = false,
  });
}

List<Collection> collections = [
  Collection(FlutterIslamicIcons.quran, 'Hadith', RoutesName.hadith, "hadith"),
  Collection(FlutterIslamicIcons.prayer, 'Athkar', RoutesName.azkar, "azkar"),
  Collection(FlutterIslamicIcons.prayer, 'Dua', RoutesName.dua, "duaa"),
  Collection(
    FlutterIslamicIcons.wudhu,
    'Tafsir Library',
    RoutesName.books,
    "tafsir",
  ),
  Collection(
    FlutterIslamicIcons.wudhu,
    'Daras',
    RoutesName.daras,
    "daras",
    isPremium: true,
  ),
  Collection(
    FlutterIslamicIcons.wudhu,
    'Fanar AI',
    RoutesName.fanarAi,
    "ai",
    isPremium: true,
  ),
  Collection(
    FlutterIslamicIcons.allah99,
    'Names of Allah',
    RoutesName.name,
    "name",
  ),
  Collection(
    FlutterIslamicIcons.qibla,
    'Qabah Direction',
    RoutesName.direction,
    "qibla",
  ),
  Collection(
    FlutterIslamicIcons.wudhu,
    'Calendar',
    RoutesName.calendar,
    "calendar",
  ),
  Collection(
    FlutterIslamicIcons.wudhu,
    'Quiz topic',
    RoutesName.quizTopic,
    "quiz",
    isPremium: true,
  ),
  // Collection(
  //   FlutterIslamicIcons.wudhu,
  //   'Islamic Live',
  //   RoutesName.islamicLive,
  //   "daras",
  //   isPremium: true,
  // ),
  Collection(
    FlutterIslamicIcons.tasbih,
    'Tasbih',
    RoutesName.tasbih,
    "tasbih",
  ),
  Collection(
    FlutterIslamicIcons.prayingPerson,
    'Prayer Times',
    RoutesName.prayerTime,
    "prayertime",
  ),
];

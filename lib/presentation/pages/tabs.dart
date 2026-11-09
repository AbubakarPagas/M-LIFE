import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';
import 'package:provider/provider.dart';

import '../../core/utils/toast/islamic_toast.dart';
import '../../provider/app_init_provider.dart';
import '../../provider/dependencies/GlobalDependencyProvider.dart';
import '../../provider/dependencies/tabProvider.dart';
import '../../provider/locationProvider.dart';
import '../../status_bar_color.dart';
import 'adhan/adhanScreen.dart';
import 'home/view/home_page.dart';
import 'profile/profile.dart';
import 'quran_page/quran_ page.dart';
import 'ummah_feed/ui/screens/ummah_feed_screen.dart';
import 'welcome/welcomeScreen.dart';

class Tabs extends StatefulWidget {
  const Tabs({super.key});

  @override
  State<Tabs> createState() => _TabsState();
}

class _TabsState extends State<Tabs> {
  final List<Widget> _pages = [
    const HomePage(),
    const AdhanScreen(),
    const UmmahFeedScreen(),
    const Quran(),
    const Profile(),
  ];

  // Double-exit state
  bool _exitWarningShown = false;
  Timer? _exitTimer;

  @override
  void initState() {
    super.initState();
    context.read<LocationProvider>().updateLocationWithGPS(background: true);
  }

  @override
  void dispose() {
    _exitTimer?.cancel();
    super.dispose();
  }

  /// Called on every Android back gesture / button press.
  /// Returns true  → allow pop (i.e. exit)
  /// Returns false → consume the back press
  Future<bool> _onWillPop() async {
    // If not on the home tab, navigate back to it instead of exiting
    final tabIndex = context.read<TabProvider>();
    if (tabIndex.tabChange != 0) {
      tabIndex.onChangingTab(0);
      return false;
    }

    if (_exitWarningShown) {
      // Second press — exit
      _exitTimer?.cancel();
      SystemNavigator.pop();
      return true;
    }

    // First press — show toast and arm the timer
    _exitWarningShown = true;
    _showExitToast();

    _exitTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _exitWarningShown = false);
      }
    });

    return false;
  }

  void _showExitToast() {
    IslamicToast.showExit(context);
  }

  @override
  Widget build(BuildContext context) {
    setStatusBarColor(context);
    Provider.of<AppInitProvider>(context, listen: true);
    final tabIndex = context.watch<TabProvider>();
    final globalDependency = context.watch<GlobalDependencyProvider>();

    return globalDependency.welcomeScreenShown
        ? PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, _) async {
              if (didPop) return;
              await _onWillPop();
            },
            child: Scaffold(
              body: IndexedStack(index: tabIndex.tabChange, children: _pages),
              bottomNavigationBar: _BottomNav(tabIndex: tabIndex),
            ),
          )
        : const WelcomeScreen(showWarning: false, build: 'Stable');
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom navigation bar (extracted for cleanliness)
// ─────────────────────────────────────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final TabProvider tabIndex;
  const _BottomNav({required this.tabIndex});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      color: colorScheme.secondary,
      padding: const EdgeInsets.only(left: 5, right: 5),
      child: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(FlutterIslamicIcons.solidMosque),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(FlutterIslamicIcons.solidPrayingPerson),
            label: 'Prayer',
          ),
          BottomNavigationBarItem(
            icon: Icon(FlutterIslamicIcons.solidCommunity),
            label: 'Ummah',
          ),
          BottomNavigationBarItem(
            icon: Icon(FlutterIslamicIcons.solidQuran2),
            label: 'Quran',
          ),
          BottomNavigationBarItem(
            icon: Icon(FlutterIslamicIcons.solidMuslim),
            label: 'Mine',
          ),
        ],
        selectedItemColor: colorScheme.primary,
        backgroundColor: colorScheme.secondary,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        type: BottomNavigationBarType.fixed,
        selectedIconTheme: const IconThemeData(size: 29.0),
        unselectedItemColor: Theme.of(
          context,
        ).disabledColor.withValues(alpha: 0.5),
        showUnselectedLabels: true,
        elevation: 0.0,
        unselectedLabelStyle: const TextStyle(color: Colors.black45),
        currentIndex: tabIndex.tabChange,
        onTap: (index) => context.read<TabProvider>().onChangingTab(index),
      ),
    );
  }
}

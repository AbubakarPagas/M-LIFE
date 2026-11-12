import 'package:flexible_sheet/flexible_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


import '../../presentation/pages/books/books.dart';
import '../../presentation/pages/quran_page/quran.dart';
import '../../presentation/pages/quran_page/screens/quran_settings.dart';
import '../../presentation/pages/quran_page/widgets/search/controller/quran_search_controller.dart' show QuranSearchController;
import '/core/utils/constants/extensions/bottom_sheet_extension.dart';
import '/core/utils/constants/svg_constants.dart';
import '../services/services_locator.dart';
import '../utils/constants/extensions/extensions.dart';
import 'container_button.dart';
import 'local_notification/notification_screen.dart';

import 'settings_list.dart';

enum TopBarType { none, search, settings }

class TopBarWidget extends StatelessWidget {
  final bool isHomeChild;
  final Widget? centerChild;
  final bool? isQuranSetting;
  final bool isNotification;
  final bool? isCalendarSetting;
  final void Function()? settingOnTap;
  final bool? isDraggable;
  final Widget? bodyChild;
  final bool? isBackButton;
  final Color? squareColor;
  final FlexibleSheetController tabBarController;
  TopBarWidget({
    super.key,
    required this.isHomeChild,
    this.centerChild,
    this.isQuranSetting,
    required this.isNotification,
    this.settingOnTap,
    this.isCalendarSetting = false,
    this.isDraggable = true,
    this.bodyChild,
    this.isBackButton = false,
    this.squareColor,
    required this.tabBarController,
  });

  final quranCtrl = QuranController.instance;
  final booksCtrl = BooksController.instance;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final surface = Theme.of(context).colorScheme.primaryContainer;

    return LayoutBuilder(
      builder: (context, constraints) {
        return FlexibleSheet(
          maxHeight: context.customOrientation(
            constraints.maxHeight - 150,
            constraints.maxHeight - 70,
          ),
          minHeight: 0,
          initialHeight: 0,
          isDraggable: isDraggable ?? true,
          alignment: context.customOrientation(
            Alignment.topCenter,
            AlignmentDirectional.topEnd,
          ),
          width: context.customOrientation(Get.width, Get.width * 0.5),
          direction: SheetDirection.topToBottom,
          snapBehavior: SheetSnapBehavior.snapToEdge,
          controller: tabBarController,
          onStateChanged: (state) {
            if (!tabBarController.isOpen) {
              quranCtrl.state.topBarType.value = TopBarType.none.name;
              // أعد ضبط وضع AI عند إغلاق الـ sheet.
              final searchCtrl = QuranSearchController.instance;
              if (searchCtrl.state.isAiMode.value) {
                searchCtrl.state.isAiMode.value = false;
                searchCtrl.state.searchTextEditing.clear();
              }
            } else {
              quranCtrl.state.isPlayExpanded.value = false;
            }
          },
          handleBuilder: (currentHeight) {
            final isExpanded = currentHeight >= 155;
            return _AppBarHandle(
              isExpanded: isExpanded,
              isHomeChild: isHomeChild,
              isNotification: isNotification,
              isBackButton: isBackButton ?? false,
              centerChild: centerChild,
              settingOnTap: settingOnTap,
              squareColor: squareColor,
              primary: primary,
              surface: surface,
              tabBarController: tabBarController,
              quranCtrl: quranCtrl,
              booksCtrl: booksCtrl,
              onAiToggle: () => _buildAiToggleButton(context),
            );
          },
          childBuilder: (currentHeight) {
            if (quranCtrl.getTopBarType(TopBarType.search)) {
              return Material(
                elevation: 8,
                color: Colors.transparent,
                child: bodyChild ?? QuranSearch(),
              );
            } else {
              return Material(
                elevation: 8,
                color: Colors.transparent,
                child: QuranSettingsList(
                  isQuranSetting: isQuranSetting,
                  isCalendarSetting: isCalendarSetting,
                ),
              );
            }
          },
        );
      },
    );
  }

  /// زر التبديل بين البحث العادي والـ AI — يظهر فقط في وضع بحث القرآن.
  Widget _buildAiToggleButton(BuildContext context) {
    final searchCtrl = QuranSearchController.instance;
    return Obx(() {
      final isAi =
          searchCtrl.state.isAiMode.value || booksCtrl.state.isAiMode.value;
      return _AppBarActionButton(
        onTap: () {
          searchCtrl.state.isAiMode.value = !isAi;
          booksCtrl.state.isAiMode.value = !isAi;
          searchCtrl.state.searchTextEditing.clear();
          searchCtrl.state.ayahList.clear();
          searchCtrl.state.surahList.clear();
        },
        svgPath: SvgPath.svgHomeAiMcp,
        color: isAi
            ? context.theme.colorScheme.primary
            : context.theme.colorScheme.primary.withValues(alpha: 0.4),
        isActive: isAi,
      );
    });
  }
}

// ─── AppBar handle rendered inside the FlexibleSheet ────────────────────────
class _AppBarHandle extends StatelessWidget {
  final bool isExpanded;
  final bool isHomeChild;
  final bool isNotification;
  final bool isBackButton;
  final Widget? centerChild;
  final VoidCallback? settingOnTap;
  final Color? squareColor;
  final Color primary;
  final Color surface;
  final FlexibleSheetController tabBarController;
  final QuranController quranCtrl;
  final BooksController booksCtrl;
  final Widget Function() onAiToggle;

  const _AppBarHandle({
    required this.isExpanded,
    required this.isHomeChild,
    required this.isNotification,
    required this.isBackButton,
    required this.centerChild,
    required this.settingOnTap,
    required this.squareColor,
    required this.primary,
    required this.surface,
    required this.tabBarController,
    required this.quranCtrl,
    required this.booksCtrl,
    required this.onAiToggle,
  });

  @override
  Widget build(BuildContext context) {
    final barColor = squareColor ?? primary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Main AppBar row ───────────────────────────────────────────────
        Container(
          height: 56,
          width: double.infinity,
          decoration: BoxDecoration(
            color: surface,
            border: Border(
              bottom: BorderSide(
                color: barColor.withValues(alpha: 0.18),
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: barColor.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(width: 4),
              // ── Leading action ────────────────────────────────────────
              SizedBox(
                width: 44,
                height: 44,
                child: isHomeChild
                    ? Obx(() {
                        if (quranCtrl.getTopBarType(TopBarType.search)) {
                          return onAiToggle();
                        }
                        return _AppBarActionButton(
                          onTap: () async {
                            if (isBackButton) {
                              quranCtrl.setTopBarType = TopBarType.none;
                              Get.back();
                              return;
                            }
                            quranCtrl.setTopBarType = TopBarType.none;
                            sl<QuranController>()
                                .state
                                .selectedAyahIndexes
                                .clear();
                          },
                          svgPath: isBackButton
                              ? SvgPath.svgHomeArrowBack
                              : SvgPath.svgHomeHome,
                          color: primary,
                        );
                      })
                    : isNotification
                    ? _AppBarActionButton(
                        onTap: () => customBottomSheet(NotificationsScreen()),
                        svgPath: SvgPath.svgHomeHome,
                        color: primary,
                      )
                    : const SizedBox.shrink(),
              ),
              // ── Center content ────────────────────────────────────────
              Expanded(
                child: centerChild ?? const SizedBox.shrink(),
              ),
              // ── Trailing: settings / close ────────────────────────────
              SizedBox(
                width: 44,
                height: 44,
                child: _AppBarActionButton(
                  onTap: settingOnTap ??
                      () {
                        quranCtrl.setTopBarType = TopBarType.settings;
                        tabBarController.toggle();
                        quranCtrl.state.isPlayExpanded.value = false;
                      },
                  svgPath: isExpanded
                      ? SvgPath.svgHomeClose
                      : SvgPath.svgHomeSetting,
                  color: primary,
                ),
              ),
              const SizedBox(width: 4),
            ],
          ),
        ),
        // ── Thin accent line below AppBar ─────────────────────────────────
        Container(
          height: 3,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                barColor.withValues(alpha: 0),
                barColor.withValues(alpha: 0.5),
                barColor,
                barColor.withValues(alpha: 0.5),
                barColor.withValues(alpha: 0),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Reusable icon button for the AppBar ─────────────────────────────────────
class _AppBarActionButton extends StatelessWidget {
  final VoidCallback onTap;
  final String svgPath;
  final Color color;
  final bool isActive;

  const _AppBarActionButton({
    required this.onTap,
    required this.svgPath,
    required this.color,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: isActive
            ? BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              )
            : null,
        child: ContainerButton(
          onPressed: onTap,
          svgHeight: 26,
          svgWidth: 26,
          horizontalMargin: 0,
          verticalMargin: 0,
          horizontalPadding: 0,
          verticalPadding: 0,
          backgroundColor: Colors.transparent,
          svgColor: color,
          svgWithColorPath: svgPath,
        ),
      ),
    );
  }
}

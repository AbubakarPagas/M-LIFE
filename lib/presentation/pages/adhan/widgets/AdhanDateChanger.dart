import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../extensions.dart';
import '../../../../provider/adhanProvider.dart';
import 'adhan_theme.dart';

const centerPage = 20000;

class AdhanDateChanger extends StatelessWidget {
  final PageController _adhanListPageController;

  const AdhanDateChanger(this._adhanListPageController, {super.key});

  Future<void> _moveToDate(BuildContext context, DateTime currentDate) async {
    final date = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2070),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Theme.of(context).colorScheme.onPrimary,
              surface: Theme.of(context).colorScheme.surface,
              onSurface: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      final days = DateTime.now().daysFrom(date);
      _adhanListPageController.animateToPage(
        centerPage + days,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final adhanProvider = context.watch<AdhanProvider>();
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.primary.withValues(alpha: 0.12), width: 1),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Previous day
          IconButton(
            onPressed: () {
              _adhanListPageController.animateToPage(
                _adhanListPageController.page!.toInt() - 1,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
              );
            },
            icon: Icon(Icons.chevron_left, color: cs.primary, size: 30),
            style: IconButton.styleFrom(
              backgroundColor: cs.primary.withValues(alpha: 0.08),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          // Date display
          Expanded(
            child: InkWell(
              onTap: () => _moveToDate(context, adhanProvider.currentDate),
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AutoSizeText(
                      DateFormat(
                        'EEEE, dd MMM yyyy',
                        Localizations.localeOf(context).languageCode,
                      ).format(adhanProvider.currentDate),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: theme.hintColor,
                        fontFamily: 'kufi',
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 1.5,
                      width: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            kAdhanGold.withValues(alpha: 0.55),
                            Colors.transparent,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      adhanProvider.currentDate.getHizriDateForLocale(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: kAdhanGold,
                        fontFamily: 'naskh',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Next day
          IconButton(
            onPressed: () {
              _adhanListPageController.animateToPage(
                _adhanListPageController.page!.toInt() + 1,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
              );
            },
            icon: Icon(Icons.chevron_right, color: cs.primary, size: 30),
            style: IconButton.styleFrom(
              backgroundColor: cs.primary.withValues(alpha: 0.08),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

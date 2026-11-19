import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/utils/formatters.dart';

class MonthCalendar extends StatelessWidget {
  const MonthCalendar({
    super.key,
    required this.visibleMonth,
    required this.selectedDate,
    required this.firstDate,
    required this.lastDate,
    required this.onDateSelected,
    this.onPreviousMonth,
    this.onNextMonth,
  });

  final DateTime visibleMonth;
  final DateTime selectedDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final ValueChanged<DateTime> onDateSelected;
  final VoidCallback? onPreviousMonth;
  final VoidCallback? onNextMonth;

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(
      visibleMonth.year,
      visibleMonth.month + 1,
      0,
    ).day;
    final leadingBlanks =
        DateTime(visibleMonth.year, visibleMonth.month, 1).weekday % 7;
    final totalCells = ((leadingBlanks + daysInMonth) / 7).ceil() * 7;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _NavButton(
                icon: Icons.chevron_left_rounded,
                enabled: onPreviousMonth != null,
                onTap: onPreviousMonth,
              ),
              Expanded(
                child: Center(
                  child: Text(
                    DateFormats.monthTitle(visibleMonth),
                    style: AppTextStyles.body(
                      size: 12,
                      weight: FontWeight.w600,
                      letterSpacing: 2.2,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              _NavButton(
                icon: Icons.chevron_right_rounded,
                enabled: onNextMonth != null,
                onTap: onNextMonth,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: DateFormats.weekdayInitials
                .map(
                  (label) => Expanded(
                    child: Center(
                      child: Text(
                        label,
                        style: AppTextStyles.body(
                          size: 10.5,
                          weight: FontWeight.w600,
                          letterSpacing: 1,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 6),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: totalCells,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.02,
            ),
            itemBuilder: (context, index) {
              final dayNumber = index - leadingBlanks + 1;
              if (dayNumber < 1 || dayNumber > daysInMonth) {
                return const SizedBox.shrink();
              }

              final date = DateTime(
                visibleMonth.year,
                visibleMonth.month,
                dayNumber,
              );
              final normalizedFirst = DateFormats.dateOnly(firstDate);
              final normalizedLast = DateFormats.dateOnly(lastDate);
              final enabled =
                  !date.isBefore(normalizedFirst) &&
                  !date.isAfter(normalizedLast);
              final isSelected = DateFormats.isSameDay(date, selectedDate);
              final isToday = DateFormats.isSameDay(date, DateFormats.today());

              return _DayCell(
                day: dayNumber,
                enabled: enabled,
                isSelected: isSelected,
                isToday: isToday,
                onTap: enabled ? () => onDateSelected(date) : null,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.enabled,
    required this.isSelected,
    required this.isToday,
    this.onTap,
  });

  final int day;
  final bool enabled;
  final bool isSelected;
  final bool isToday;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color textColor;
    if (isSelected) {
      textColor = AppColors.ink;
    } else if (!enabled) {
      textColor = AppColors.textMuted.withValues(alpha: 0.5);
    } else if (isToday) {
      textColor = AppColors.gold;
    } else {
      textColor = AppColors.textPrimary;
    }

    return Center(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: 36,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: isSelected ? AppColors.goldGradient : null,
            color: isSelected ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: !isSelected && isToday
                ? Border.all(color: AppColors.gold.withValues(alpha: 0.55))
                : null,
          ),
          child: Text(
            '$day',
            style: AppTextStyles.body(
              size: 12.5,
              weight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.icon, required this.enabled, this.onTap});

  final IconData icon;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceElevated,
      borderRadius: BorderRadius.circular(9),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(9),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(9),
            border: Border.all(color: AppColors.border),
          ),
          child: Icon(
            icon,
            size: 18,
            color: enabled ? AppColors.gold : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}

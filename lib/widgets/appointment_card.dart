import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/utils/formatters.dart';
import '../models/appointment.dart';

class AppointmentCard extends StatelessWidget {
  const AppointmentCard({super.key, required this.appointment});

  final Appointment appointment;

  @override
  Widget build(BuildContext context) {
    final faded = appointment.isPast || appointment.isCancelled;

    return Opacity(
      opacity: faded ? 0.65 : 1,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: appointment.isPast ? AppColors.border : AppColors.goldDim,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DateBadge(date: appointment.date),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          appointment.serviceName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.display(
                            size: 16,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        Money.format(appointment.totalPrice),
                        style: AppTextStyles.price(size: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    appointment.barberName,
                    style: AppTextStyles.body(
                      size: 11.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_rounded,
                        size: 12,
                        color: AppColors.gold,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        DateFormats.formattedLong(appointment.date),
                        style: AppTextStyles.body(
                          size: 11,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.schedule_rounded,
                        size: 12,
                        color: AppColors.gold,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        appointment.timeRange,
                        style: AppTextStyles.body(
                          size: 11,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      _StatusChip(status: appointment.status),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateBadge extends StatelessWidget {
  const _DateBadge({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 66,
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${date.day}',
            style: AppTextStyles.display(size: 22, letterSpacing: 0),
          ),
          const SizedBox(height: 2),
          Text(
            DateFormats.monthShort(date.month).toUpperCase(),
            style: AppTextStyles.label(size: 8.5, letterSpacing: 1.2),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final label = switch (status) {
      'cancelled' => 'CANCELADO',
      'completed' => 'CONCLUÍDO',
      _ => 'CONFIRMADO',
    };
    final color = status == 'cancelled' ? AppColors.textMuted : AppColors.gold;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: AppTextStyles.body(
          size: 8,
          weight: FontWeight.w700,
          letterSpacing: 0.8,
          color: color,
        ),
      ),
    );
  }
}

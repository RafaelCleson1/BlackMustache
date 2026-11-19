import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/utils/formatters.dart';
import '../models/appointment.dart';
import '../providers/app_providers.dart';
import '../widgets/buttons.dart';

class BookingConfirmedScreen extends ConsumerWidget {
  const BookingConfirmedScreen({super.key, required this.appointment});

  final Appointment appointment;

  void _finish(BuildContext context, WidgetRef ref, int tabIndex) {
    ref.read(rootTabProvider.notifier).select(tabIndex);
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
          child: Column(
            children: [
              Container(
                width: 86,
                height: 86,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.gold.withValues(alpha: 0.1),
                  border: Border.all(
                    color: AppColors.gold.withValues(alpha: 0.6),
                    width: 1.4,
                  ),
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: AppColors.gold,
                  size: 42,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'AGENDAMENTO CONFIRMADO',
                textAlign: TextAlign.center,
                style: AppTextStyles.display(
                  size: 21,
                  letterSpacing: 2.2,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Seu horário está reservado. Estamos ansiosos para cuidar do seu estilo.',
                textAlign: TextAlign.center,
                style: AppTextStyles.body(
                  size: 12.5,
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 30),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SUA PRÓXIMA EXPERIÊNCIA',
                      style: AppTextStyles.label(size: 9.5, letterSpacing: 2.2),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      appointment.serviceName.toUpperCase(),
                      style: AppTextStyles.display(
                        size: 21,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Divider(height: 1, color: AppColors.border),
                    const SizedBox(height: 16),
                    _ReceiptRow(
                      label: 'Profissional',
                      value: appointment.barberName,
                    ),
                    const SizedBox(height: 12),
                    _ReceiptRow(
                      label: 'Data',
                      value: DateFormats.formattedLong(appointment.date),
                    ),
                    const SizedBox(height: 12),
                    _ReceiptRow(label: 'Horário', value: appointment.timeRange),
                    const SizedBox(height: 16),
                    const Divider(height: 1, color: AppColors.border),
                    const SizedBox(height: 14),
                    _ReceiptRow(
                      label: 'Valor',
                      value: Money.format(appointment.totalPrice),
                      highlight: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 14,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Chegue com 5 minutos de antecedência. Seu tempo e seu estilo merecem cuidado.',
                      style: AppTextStyles.body(
                        size: 11,
                        color: AppColors.textMuted,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              GoldButton(
                label: 'Ver meus agendamentos',
                icon: Icons.calendar_month_rounded,
                onPressed: () => _finish(context, ref, 1),
              ),
              const SizedBox(height: 10),
              GhostButton(
                label: 'Voltar ao início',
                icon: Icons.home_rounded,
                onPressed: () => _finish(context, ref, 0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  const _ReceiptRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.body(size: 11.5, color: AppColors.textSecondary),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: AppTextStyles.body(
              size: highlight ? 15 : 12.5,
              weight: highlight ? FontWeight.w700 : FontWeight.w600,
              color: highlight ? AppColors.gold : AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

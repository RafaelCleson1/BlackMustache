import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/utils/error_messages.dart';
import '../providers/app_providers.dart';
import '../widgets/app_states.dart';
import '../widgets/appointment_card.dart';
import '../widgets/buttons.dart';
import '../widgets/demo_mode_notice.dart';
import '../widgets/logout_button.dart';
import 'services_screen.dart';

class AppointmentsScreen extends ConsumerWidget {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointments = ref.watch(appointmentsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('MEUS AGENDAMENTOS'),
        titleTextStyle: AppTextStyles.display(size: 16, letterSpacing: 2.4),
        actions: const [LogoutButton()],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.border),
        ),
      ),
      body: SafeArea(
        top: false,
        child: appointments.when(
          loading: () => const AppLoader(
            height: 400,
            label: 'Carregando seus agendamentos',
          ),
          error: (error, stackTrace) => AppErrorView(
            height: 400,
            message: describeError(error),
            onRetry: () => ref.invalidate(appointmentsProvider),
          ),
          data: (items) {
            final upcoming = items
                .where((item) => !item.isPast && !item.isCancelled)
                .toList();
            final history =
                items.where((item) => item.isPast || item.isCancelled).toList()
                  ..sort((a, b) => b.startsAt.compareTo(a.startsAt));

            return RefreshIndicator(
              color: AppColors.gold,
              backgroundColor: AppColors.surface,
              onRefresh: () async => ref.invalidate(appointmentsProvider),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const DemoModeNotice(),
                  if (items.isEmpty)
                    _EmptyAppointments(
                      onSchedule: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ServicesScreen(),
                        ),
                      ),
                    )
                  else ...[
                    if (upcoming.isNotEmpty) ...[
                      const _SectionLabel('PRÓXIMOS'),
                      const SizedBox(height: 10),
                      ...upcoming.map(
                        (item) => AppointmentCard(appointment: item),
                      ),
                    ],
                    if (history.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      const _SectionLabel('ANTERIORES'),
                      const SizedBox(height: 10),
                      ...history.map(
                        (item) => AppointmentCard(appointment: item),
                      ),
                    ],
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyles.label(
        size: 10,
        color: AppColors.textSecondary,
        letterSpacing: 2.2,
      ),
    );
  }
}

class _EmptyAppointments extends StatelessWidget {
  const _EmptyAppointments({required this.onSchedule});

  final VoidCallback onSchedule;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 70),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surface,
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(
              Icons.event_available_rounded,
              color: AppColors.gold,
              size: 30,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Nenhum agendamento ainda',
            style: AppTextStyles.display(size: 19, letterSpacing: 0.6),
          ),
          const SizedBox(height: 8),
          Text(
            'Seu próximo corte começa com um toque.\nEscolha seu serviço e reserve seu horário.',
            textAlign: TextAlign.center,
            style: AppTextStyles.body(
              size: 12,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 24),
          GoldButton(
            label: 'Agendar agora',
            icon: Icons.arrow_forward_rounded,
            onPressed: onSchedule,
          ),
        ],
      ),
    );
  }
}

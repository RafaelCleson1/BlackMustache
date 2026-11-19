import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/utils/error_messages.dart';
import '../core/utils/formatters.dart';
import '../models/barber.dart';
import '../models/service.dart';
import '../providers/app_providers.dart';
import '../widgets/app_states.dart';
import '../widgets/barber_tile.dart';
import '../widgets/buttons.dart';
import '../widgets/network_photo.dart';
import '../widgets/section_header.dart';
import 'schedule_screen.dart';

class ServiceDetailsScreen extends ConsumerStatefulWidget {
  const ServiceDetailsScreen({super.key, required this.service});

  final Service service;

  @override
  ConsumerState<ServiceDetailsScreen> createState() =>
      _ServiceDetailsScreenState();
}

class _ServiceDetailsScreenState extends ConsumerState<ServiceDetailsScreen> {
  String? _selectedBarberId;

  Barber? _selectedBarber(List<Barber> barbers) {
    for (final barber in barbers) {
      if (barber.id == _selectedBarberId) return barber;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final barbersAsync = ref.watch(barbersProvider);
    final service = widget.service;

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 64,
        leading: const Padding(
          padding: EdgeInsets.only(left: 20),
          child: Center(child: CircleBackButton()),
        ),
        title: const Text('DETALHES DO AGENDAMENTO'),
        titleTextStyle: AppTextStyles.display(size: 13.5, letterSpacing: 1.8),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: SizedBox(
                height: 178,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    NetworkPhoto(url: service.imageUrl, iconSize: 38),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: AppColors.heroGradient,
                      ),
                    ),
                    const Positioned(
                      top: 14,
                      left: 14,
                      child: StepBadge(label: '01  |  SERVIÇO'),
                    ),
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 16,
                      child: Text(
                        service.name.toUpperCase(),
                        style: AppTextStyles.display(
                          size: 24,
                          letterSpacing: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.description,
                    style: AppTextStyles.body(
                      size: 12.5,
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Divider(height: 1, color: AppColors.border),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Text(
                        Money.format(service.price),
                        style: AppTextStyles.display(
                          size: 23,
                          color: AppColors.gold,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.schedule_rounded,
                        size: 15,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '${service.durationMinutes} min',
                        style: AppTextStyles.body(
                          size: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            const SectionHeader(title: 'ESCOLHA SEU BARBEIRO'),
            const SizedBox(height: 6),
            Text(
              'Cada profissional tem o seu talento. Escolha quem combina com você.',
              style: AppTextStyles.body(
                size: 11.5,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            barbersAsync.when(
              loading: () => const AppLoader(
                height: 150,
                label: 'Carregando profissionais',
              ),
              error: (error, stackTrace) => AppErrorView(
                height: 170,
                message: describeError(error),
                onRetry: () => ref.invalidate(barbersProvider),
              ),
              data: (barbers) {
                if (barbers.isEmpty) {
                  return Text(
                    'Nenhum profissional disponível no momento.',
                    style: AppTextStyles.body(
                      size: 12,
                      color: AppColors.textSecondary,
                    ),
                  );
                }
                return Column(
                  children: barbers
                      .map(
                        (barber) => BarberTile(
                          barber: barber,
                          selected: barber.id == _selectedBarberId,
                          onTap: () =>
                              setState(() => _selectedBarberId = barber.id),
                        ),
                      )
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        decoration: const BoxDecoration(
          color: AppColors.background,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SafeArea(
          top: false,
          child: GoldButton(
            label: 'Escolher horário',
            icon: Icons.arrow_forward_rounded,
            onPressed: _selectedBarberId == null
                ? null
                : () {
                    final barbers = barbersAsync.value ?? const <Barber>[];
                    final barber = _selectedBarber(barbers);
                    if (barber == null) return;
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            ScheduleScreen(service: service, barber: barber),
                      ),
                    );
                  },
          ),
        ),
      ),
    );
  }
}

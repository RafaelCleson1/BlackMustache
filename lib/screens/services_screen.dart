import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/utils/error_messages.dart';
import '../providers/app_providers.dart';
import '../widgets/app_states.dart';
import '../widgets/buttons.dart';
import '../widgets/service_list_card.dart';
import 'service_details_screen.dart';

class ServicesScreen extends ConsumerWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final services = ref.watch(servicesProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleBackButton(),
                      Expanded(
                        child: Center(
                          child: Text(
                            'NOSSOS SERVIÇOS',
                            style: AppTextStyles.display(
                              size: 18,
                              letterSpacing: 2.4,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Escolha o cuidado que combina com você.',
                    style: AppTextStyles.body(
                      size: 12.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 18),
                ],
              ),
            ),
            Expanded(
              child: services.when(
                loading: () =>
                    const AppLoader(height: 320, label: 'Carregando serviços'),
                error: (error, stackTrace) => AppErrorView(
                  height: 340,
                  message: describeError(error),
                  onRetry: () => ref.invalidate(servicesProvider),
                ),
                data: (items) {
                  if (items.isEmpty) {
                    return Center(
                      child: Text(
                        'Nenhum serviço disponível no momento.',
                        style: AppTextStyles.body(
                          size: 12.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: AppColors.gold,
                    backgroundColor: AppColors.surface,
                    onRefresh: () async => ref.invalidate(servicesProvider),
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 2, 20, 24),
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final service = items[index];
                        return ServiceListCard(
                          service: service,
                          onSelected: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  ServiceDetailsScreen(service: service),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_images.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/utils/error_messages.dart';
import '../providers/app_providers.dart';
import '../widgets/app_states.dart';
import '../widgets/buttons.dart';
import '../widgets/demo_mode_notice.dart';
import '../widgets/featured_service_card.dart';
import '../widgets/logout_button.dart';
import '../widgets/network_photo.dart';
import '../widgets/section_header.dart';
import 'service_details_screen.dart';
import 'services_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final featured = ref.watch(featuredServicesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('BLACK MUSTACHE'),
        actions: const [LogoutButton()],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.border),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const DemoModeNotice(),
              const _HeroBanner(),
              const SizedBox(height: 28),
              Text(
                'ESTILO E IDENTIDADE',
                style: AppTextStyles.label(size: 11, letterSpacing: 3),
              ),
              const SizedBox(height: 10),
              Text(
                'SEU ESTILO\nCOMEÇA AQUI.',
                style: AppTextStyles.display(
                  size: 33,
                  letterSpacing: 1.6,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Cortes precisos, barba impecável e um ambiente feito para você '
                'desacelerar. Agende seu horário e viva a experiência Black Mustache.',
                style: AppTextStyles.body(
                  size: 13,
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 22),
              GoldButton(
                label: 'Agendar horário',
                icon: Icons.arrow_forward_rounded,
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ServicesScreen()),
                ),
              ),
              const SizedBox(height: 34),
              SectionHeader(
                title: 'NOSSOS DESTAQUES',
                actionLabel: 'Ver todos',
                onAction: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ServicesScreen()),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 180,
                child: featured.when(
                  loading: () => const AppLoader(
                    height: 180,
                    label: 'Carregando destaques',
                  ),
                  error: (error, stackTrace) => AppErrorView(
                    height: 180,
                    message: describeError(error),
                    onRetry: () => ref.invalidate(featuredServicesProvider),
                  ),
                  data: (services) {
                    if (services.isEmpty) {
                      return Center(
                        child: Text(
                          'Nenhum destaque disponível no momento.',
                          style: AppTextStyles.body(
                            size: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      );
                    }
                    return ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: services.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final service = services[index];
                        return FeaturedServiceCard(
                          service: service,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  ServiceDetailsScreen(service: service),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 28),
              const _InfoStrip(),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: SizedBox(
        height: 208,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const NetworkPhoto(url: AppImages.hero, iconSize: 42),
            const DecoratedBox(
              decoration: BoxDecoration(gradient: AppColors.heroGradient),
            ),
            Positioned(
              left: 18,
              right: 18,
              bottom: 18,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'BARBEARIA PREMIUM',
                    style: AppTextStyles.label(size: 9.5, letterSpacing: 2.6),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tradição e atitude em cada detalhe.',
                    style: AppTextStyles.display(
                      size: 19,
                      letterSpacing: 0.4,
                      height: 1.2,
                    ),
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

class _InfoStrip extends StatelessWidget {
  const _InfoStrip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const _InfoItem(
            icon: Icons.schedule_rounded,
            title: 'SEG — SÁB',
            subtitle: '09h às 19h',
          ),
          Container(
            width: 1,
            height: 36,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            color: AppColors.border,
          ),
          const _InfoItem(
            icon: Icons.location_on_outlined,
            title: 'CENTRO',
            subtitle: 'Rua da Barbearia, 128',
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.gold),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.body(
                    size: 10,
                    weight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body(
                    size: 10.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

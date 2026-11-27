import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/navigation/app_navigator.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/utils/error_messages.dart';
import '../providers/app_providers.dart';
import '../providers/auth_providers.dart';
import '../widgets/buttons.dart';
import 'login_screen.dart';
import 'root_shell.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    ref.listen(authStateProvider, (previous, next) {
      final previousUserId = previous?.value?.session?.user.id;
      final nextUserId = next.value?.session?.user.id;

      if (previousUserId != nextUserId) {
        ref.invalidate(appointmentsProvider);
      }
      if (previousUserId != null && nextUserId == null) {
        AppNavigator.rootKey.currentState?.popUntil((route) => route.isFirst);
      }
    });

    return authState.when(
      loading: () => const _AuthSplash(),
      error: (error, _) => _AuthError(
        message: describeAuthError(error),
        onRetry: () => ref.invalidate(authStateProvider),
      ),
      data: (state) {
        final user = state?.session?.user;
        if (user == null) return const LoginScreen();
        return const RootShell();
      },
    );
  }
}

class _AuthSplash extends StatelessWidget {
  const _AuthSplash();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 34,
              height: 34,
              child: CircularProgressIndicator(strokeWidth: 2.4),
            ),
            SizedBox(height: 22),
            Text(
              'BLACK MUSTACHE',
              style: TextStyle(
                color: AppColors.gold,
                fontSize: 11,
                letterSpacing: 3.4,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthError extends StatelessWidget {
  const _AuthError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_rounded,
                size: 40,
                color: AppColors.gold,
              ),
              const SizedBox(height: 18),
              Text(
                'Não foi possível verificar sua sessão',
                textAlign: TextAlign.center,
                style: AppTextStyles.display(size: 19, letterSpacing: 0.4),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppTextStyles.body(
                  size: 12,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              GoldButton(
                label: 'Tentar novamente',
                icon: Icons.refresh_rounded,
                onPressed: onRetry,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/navigation/app_navigator.dart';
import '../core/utils/error_messages.dart';
import '../providers/app_providers.dart';

class LogoutButton extends ConsumerWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      tooltip: 'Sair',
      icon: const Icon(Icons.logout_rounded),
      onPressed: () async {
        final client = ref.read(supabaseClientProvider);
        if (client == null) return;

        try {
          await client.auth.signOut();
          AppNavigator.rootKey.currentState?.popUntil((route) => route.isFirst);
        } catch (error) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(describeAuthError(error))));
        }
      },
    );
  }
}

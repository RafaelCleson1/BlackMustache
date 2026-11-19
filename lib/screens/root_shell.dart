import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_colors.dart';
import '../providers/app_providers.dart';
import 'appointments_screen.dart';
import 'home_screen.dart';

class RootShell extends ConsumerWidget {
  const RootShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(rootTabProvider);

    return Scaffold(
      body: IndexedStack(
        index: index,
        children: const [HomeScreen(), AppointmentsScreen()],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SafeArea(
          top: false,
          child: BottomNavigationBar(
            currentIndex: index,
            onTap: (value) => ref.read(rootTabProvider.notifier).select(value),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined, size: 22),
                activeIcon: Icon(Icons.home_rounded, size: 22),
                label: 'Início',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_month_outlined, size: 21),
                activeIcon: Icon(Icons.calendar_month_rounded, size: 21),
                label: 'Agendamentos',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

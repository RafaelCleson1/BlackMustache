import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/navigation/app_navigator.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'screens/auth_gate.dart';

class BlackMustacheApp extends StatelessWidget {
  const BlackMustacheApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.surface,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    return MaterialApp(
      title: 'Black Mustache',
      debugShowCheckedModeBanner: false,
      navigatorKey: AppNavigator.rootKey,
      theme: buildAppTheme(),
      home: const AuthGate(),
    );
  }
}

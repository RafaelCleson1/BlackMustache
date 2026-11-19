import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/config/app_config.dart';
import 'providers/app_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppConfig.load();

  var supabaseReady = false;
  if (AppConfig.isSupabaseConfigured) {
    try {
      await Supabase.initialize(
        url: AppConfig.supabaseUrl,
        publishableKey: AppConfig.supabaseAnonKey,
      );
      supabaseReady = true;
    } catch (error) {
      debugPrint('Falha ao inicializar o Supabase: $error');
    }
  }

  runApp(
    ProviderScope(
      overrides: [
        isSupabaseConfiguredProvider.overrideWithValue(supabaseReady),
      ],
      child: const BlackMustacheApp(),
    ),
  );
}

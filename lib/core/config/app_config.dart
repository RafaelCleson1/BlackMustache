import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract final class AppConfig {
  static const String _placeholderUrl = 'SEU-PROJETO';
  static const String _placeholderKey = 'SUA_ANON_KEY';

  static String get supabaseUrl => dotenv.maybeGet('SUPABASE_URL') ?? '';

  static String get supabaseAnonKey =>
      dotenv.maybeGet('SUPABASE_ANON_KEY') ?? '';

  static Future<void> load() async {
    try {
      await dotenv.load(fileName: '.env');
    } catch (_) {}
  }

  static bool get isSupabaseConfigured {
    final url = supabaseUrl.trim();
    final key = supabaseAnonKey.trim();
    return url.startsWith('https://') &&
        !url.contains(_placeholderUrl) &&
        key.isNotEmpty &&
        !key.contains(_placeholderKey) &&
        key.length > 30;
  }

  static const String clientNameFallback = 'Cliente Black Mustache';
}

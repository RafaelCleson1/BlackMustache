import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/demo_store.dart';
import '../models/service.dart';

class ServiceRepository {
  ServiceRepository({this.client, required this.demoStore});

  final SupabaseClient? client;
  final DemoStore demoStore;

  Future<List<Service>> fetchServices() async {
    final supabase = client;
    if (supabase == null) {
      await _simulateLatency();
      return demoStore.services;
    }

    final rows = await supabase.from('services').select().order('price');
    return rows
        .map((row) => Service.fromMap(Map<String, dynamic>.from(row)))
        .toList();
  }

  Future<List<Service>> fetchFeaturedServices() async {
    final supabase = client;
    if (supabase == null) {
      await _simulateLatency();
      return demoStore.services.where((service) => service.isFeatured).toList();
    }

    final rows = await supabase
        .from('services')
        .select()
        .eq('is_featured', true)
        .order('price');
    return rows
        .map((row) => Service.fromMap(Map<String, dynamic>.from(row)))
        .toList();
  }

  Future<void> _simulateLatency() =>
      Future<void>.delayed(const Duration(milliseconds: 450));
}

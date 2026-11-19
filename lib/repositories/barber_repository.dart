import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/demo_store.dart';
import '../models/barber.dart';

class BarberRepository {
  BarberRepository({this.client, required this.demoStore});

  final SupabaseClient? client;
  final DemoStore demoStore;

  Future<List<Barber>> fetchBarbers() async {
    final supabase = client;
    if (supabase == null) {
      await Future<void>.delayed(const Duration(milliseconds: 450));
      return demoStore.barbers.where((barber) => barber.active).toList();
    }

    final rows = await supabase
        .from('barbers')
        .select()
        .eq('active', true)
        .order('name');
    return rows
        .map((row) => Barber.fromMap(Map<String, dynamic>.from(row)))
        .toList();
  }
}

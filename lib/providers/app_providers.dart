import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/demo_store.dart';
import '../models/appointment.dart';
import '../models/barber.dart';
import '../models/service.dart';
import '../repositories/appointment_repository.dart';
import '../repositories/barber_repository.dart';
import '../repositories/service_repository.dart';

final isSupabaseConfiguredProvider = Provider<bool>(
  (ref) => throw UnimplementedError('Sobrescrito no main()'),
);

final supabaseClientProvider = Provider<SupabaseClient?>((ref) {
  if (!ref.watch(isSupabaseConfiguredProvider)) return null;
  return Supabase.instance.client;
});

final demoStoreProvider = Provider<DemoStore>((ref) => DemoStore.seeded());

final serviceRepositoryProvider = Provider<ServiceRepository>((ref) {
  return ServiceRepository(
    client: ref.watch(supabaseClientProvider),
    demoStore: ref.watch(demoStoreProvider),
  );
});

final barberRepositoryProvider = Provider<BarberRepository>((ref) {
  return BarberRepository(
    client: ref.watch(supabaseClientProvider),
    demoStore: ref.watch(demoStoreProvider),
  );
});

final appointmentRepositoryProvider = Provider<AppointmentRepository>((ref) {
  return AppointmentRepository(
    client: ref.watch(supabaseClientProvider),
    demoStore: ref.watch(demoStoreProvider),
  );
});

final servicesProvider = FutureProvider<List<Service>>((ref) {
  return ref.watch(serviceRepositoryProvider).fetchServices();
});

final featuredServicesProvider = FutureProvider<List<Service>>((ref) {
  return ref.watch(serviceRepositoryProvider).fetchFeaturedServices();
});

final barbersProvider = FutureProvider<List<Barber>>((ref) {
  return ref.watch(barberRepositoryProvider).fetchBarbers();
});

final appointmentsProvider = FutureProvider<List<Appointment>>((ref) {
  return ref.watch(appointmentRepositoryProvider).fetchAppointments();
});

class RootTabController extends Notifier<int> {
  @override
  int build() => 0;

  void select(int index) => state = index;
}

final rootTabProvider = NotifierProvider<RootTabController, int>(
  RootTabController.new,
);

import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/config/app_config.dart';
import '../core/utils/formatters.dart';
import '../data/demo_store.dart';
import '../models/appointment.dart';
import '../models/barber.dart';
import '../models/service.dart';

class AppointmentRepository {
  AppointmentRepository({this.client, required this.demoStore});

  static const _select =
      '*, services(name, duration_minutes, price, image_url), barbers(name, avatar_url)';

  final SupabaseClient? client;
  final DemoStore demoStore;

  Future<List<Appointment>> fetchAppointments() async {
    final supabase = client;
    if (supabase == null) {
      await _simulateLatency();
      final list = [...demoStore.appointments];
      list.sort(_compareAppointments);
      return list;
    }

    final rows = await supabase
        .from('appointments')
        .select(_select)
        .order('appointment_date')
        .order('start_time');

    return rows
        .map((row) => Appointment.fromMap(Map<String, dynamic>.from(row)))
        .toList();
  }

  Future<List<Appointment>> fetchBookingsFor({
    required String barberId,
    required DateTime date,
  }) async {
    final supabase = client;
    if (supabase == null) {
      await _simulateLatency();
      return demoStore.appointmentsFor(barberId, date);
    }

    final rows = await supabase
        .from('appointments')
        .select(_select)
        .eq('barber_id', barberId)
        .eq('appointment_date', DateFormats.isoDate(date))
        .neq('status', 'cancelled');

    return rows
        .map((row) => Appointment.fromMap(Map<String, dynamic>.from(row)))
        .toList();
  }

  Future<Appointment> createAppointment({
    required Service service,
    required Barber barber,
    required DateTime date,
    required String startTime,
    String clientName = AppConfig.clientNameFallback,
  }) async {
    final supabase = client;
    final endTime = DateFormats.addMinutes(startTime, service.durationMinutes);

    if (supabase == null) {
      await _simulateLatency();
      return demoStore.addAppointment(
        service: service,
        barber: barber,
        date: date,
        startTime: startTime,
        clientName: clientName,
      );
    }

    final row = await supabase
        .from('appointments')
        .insert({
          'client_name': clientName,
          'service_id': service.id,
          'barber_id': barber.id,
          'appointment_date': DateFormats.isoDate(date),
          'start_time': startTime,
          'end_time': endTime,
          'total_price': service.price,
          'status': 'confirmed',
        })
        .select(_select)
        .single();

    return Appointment.fromMap(Map<String, dynamic>.from(row));
  }

  static int _compareAppointments(Appointment a, Appointment b) {
    final dateCompare = a.date.compareTo(b.date);
    if (dateCompare != 0) return dateCompare;
    return DateFormats.toMinutes(a.startTime)
        .compareTo(DateFormats.toMinutes(b.startTime));
  }

  Future<void> _simulateLatency() =>
      Future<void>.delayed(const Duration(milliseconds: 500));
}

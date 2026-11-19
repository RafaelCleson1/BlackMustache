import 'package:black_mustache/core/utils/formatters.dart';
import 'package:black_mustache/data/demo_store.dart';
import 'package:black_mustache/models/appointment.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DateFormats', () {
    test('formata data por extenso em português', () {
      final date = DateTime(2026, 11, 10);
      expect(DateFormats.formattedLong(date), 'Terça, 10 de novembro');
      expect(DateFormats.formattedShort(date), 'Terça, 10 nov');
      expect(DateFormats.isoDate(date), '2026-11-10');
      expect(DateFormats.monthTitle(date), 'NOVEMBRO 2026');
    });

    test('soma minutos ao horário', () {
      expect(DateFormats.addMinutes('10:00', 40), '10:40');
      expect(DateFormats.addMinutes('23:45', 30), '00:15');
      expect(DateFormats.toMinutes('19:00'), 1140);
    });

    test('normaliza horários vindos do Supabase', () {
      expect(DateFormats.parseTime('10:00:00'), '10:00');
      expect(DateFormats.parseTime(null), '');
    });
  });

  group('Money', () {
    test('formata valores em reais', () {
      final formatted = Money.format(40).replaceAll('\u00A0', ' ');
      expect(formatted, 'R\$ 40,00');
    });
  });

  group('Appointment', () {
    test('interpreta registro com joins do Supabase', () {
      final appointment = Appointment.fromMap({
        'id': 'abc',
        'client_name': 'Cliente',
        'service_id': 'service-1',
        'barber_id': 'barber-1',
        'appointment_date': '2026-11-10',
        'start_time': '10:00:00',
        'end_time': '10:40:00',
        'total_price': 40,
        'status': 'confirmed',
        'services': {'name': 'Corte degradê', 'duration_minutes': 40},
        'barbers': {'name': 'Lucas', 'avatar_url': ''},
      });

      expect(appointment.startTime, '10:00');
      expect(appointment.endTime, '10:40');
      expect(appointment.timeRange, '10:00 - 10:40');
      expect(appointment.serviceName, 'Corte degradê');
      expect(appointment.barberName, 'Lucas');
      expect(appointment.totalPrice, 40);
    });
  });

  group('DemoStore', () {
    test('cria agendamento e bloqueia conflito no mesmo barbeiro', () {
      final store = DemoStore.seeded();
      final service = store.services.first;
      final barber = store.barbers.first;
      final date = DateFormats.today().add(const Duration(days: 5));

      final created = store.addAppointment(
        service: service,
        barber: barber,
        date: date,
        startTime: '11:00',
        clientName: 'Cliente Teste',
      );

      expect(created.endTime, DateFormats.addMinutes('11:00', 30));
      expect(store.appointmentsFor(barber.id, date), hasLength(1));

      expect(
        () => store.addAppointment(
          service: service,
          barber: barber,
          date: date,
          startTime: '11:15',
          clientName: 'Cliente Teste',
        ),
        throwsException,
      );
    });
  });
}

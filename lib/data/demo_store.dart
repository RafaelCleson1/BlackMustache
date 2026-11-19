import '../core/utils/formatters.dart';
import '../models/appointment.dart';
import '../models/barber.dart';
import '../models/service.dart';

class DemoStore {
  DemoStore({
    required List<Service> services,
    required List<Barber> barbers,
    List<Appointment> appointments = const [],
  }) : services = List.unmodifiable(services),
       barbers = List.unmodifiable(barbers),
       _appointments = [...appointments];

  factory DemoStore.seeded() {
    final tomorrow = DateFormats.today().add(const Duration(days: 1));
    final store = DemoStore(
      services: const [
        Service(
          id: '11111111-1111-1111-1111-111111111101',
          name: 'Corte tradicional',
          description: 'Tesoura e máquina na medida certa, com acabamento preciso e finalização impecável.',
          price: 35,
          durationMinutes: 30,
          imageUrl: 'https://images.unsplash.com/photo-1599351431202-1e0f0137899a?auto=format&fit=crop&w=800&q=80',
          isFeatured: false,
        ),
        Service(
          id: '11111111-1111-1111-1111-111111111102',
          name: 'Corte degradê',
          description: 'Laterais em degradê e transição suave para um visual moderno e marcante.',
          price: 40,
          durationMinutes: 40,
          imageUrl: 'https://images.unsplash.com/photo-1622286342621-4bd786c2447c?auto=format&fit=crop&w=800&q=80',
          isFeatured: true,
        ),
        Service(
          id: '11111111-1111-1111-1111-111111111103',
          name: 'Barba',
          description:
              'Modelagem completa com toalha quente, navalha e óleo essencial.',
          price: 25,
          durationMinutes: 25,
          imageUrl: 'https://images.unsplash.com/photo-1621605815971-fbc98d665033?auto=format&fit=crop&w=800&q=80',
          isFeatured: false,
        ),
        Service(
          id: '11111111-1111-1111-1111-111111111104',
          name: 'Corte + barba',
          description: 'A experiência completa: corte sob medida e barba alinhada ao seu estilo.',
          price: 60,
          durationMinutes: 45,
          imageUrl: 'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?auto=format&fit=crop&w=800&q=80',
          isFeatured: true,
        ),
      ],
      barbers: const [
        Barber(
          id: '22222222-2222-2222-2222-222222222201',
          name: 'Lucas',
          specialty: 'Especialista em degradês',
          avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=400&q=80',
          active: true,
        ),
        Barber(
          id: '22222222-2222-2222-2222-222222222202',
          name: 'Gabriel',
          specialty: 'Precisão nos cortes clássicos',
          avatarUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=400&q=80',
          active: true,
        ),
        Barber(
          id: '22222222-2222-2222-2222-222222222203',
          name: 'Rafael',
          specialty: 'Expert em barba e visagismo',
          avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=400&q=80',
          active: true,
        ),
      ],
    );

    store._seedAppointment(
      service: store.services[3],
      barber: store.barbers[0],
      date: tomorrow,
      startTime: '10:00',
    );
    store._seedAppointment(
      service: store.services[1],
      barber: store.barbers[1],
      date: tomorrow,
      startTime: '14:00',
    );
    store._seedAppointment(
      service: store.services[2],
      barber: store.barbers[2],
      date: tomorrow,
      startTime: '09:00',
    );

    return store;
  }

  final List<Service> services;
  final List<Barber> barbers;
  final List<Appointment> _appointments;

  List<Appointment> get appointments => List.unmodifiable(_appointments);

  List<Appointment> appointmentsFor(String barberId, DateTime date) {
    return _appointments
        .where(
          (appointment) =>
              appointment.barberId == barberId &&
              appointment.status != 'cancelled' &&
              DateFormats.isSameDay(appointment.date, date),
        )
        .toList();
  }

  Appointment addAppointment({
    required Service service,
    required Barber barber,
    required DateTime date,
    required String startTime,
    required String clientName,
  }) {
    final endTime = DateFormats.addMinutes(startTime, service.durationMinutes);

    final conflict = _appointments.any((appointment) {
      if (appointment.barberId != barber.id ||
          appointment.status == 'cancelled' ||
          !DateFormats.isSameDay(appointment.date, date)) {
        return false;
      }
      return DateFormats.toMinutes(startTime) <
              DateFormats.toMinutes(appointment.endTime) &&
          DateFormats.toMinutes(endTime) >
              DateFormats.toMinutes(appointment.startTime);
    });

    if (conflict) {
      throw Exception('Horário indisponível para este profissional');
    }

    final appointment = Appointment(
      id: 'demo-${DateTime.now().microsecondsSinceEpoch}',
      clientName: clientName,
      serviceId: service.id,
      barberId: barber.id,
      date: date,
      startTime: startTime,
      endTime: endTime,
      totalPrice: service.price,
      status: 'confirmed',
      serviceName: service.name,
      serviceDurationMinutes: service.durationMinutes,
      barberName: barber.name,
      barberAvatarUrl: barber.avatarUrl,
    );

    _appointments.add(appointment);
    return appointment;
  }

  void _seedAppointment({
    required Service service,
    required Barber barber,
    required DateTime date,
    required String startTime,
  }) {
    _appointments.add(
      Appointment(
        id: 'seed-${barber.id}-$startTime',
        clientName: 'Cliente Exemplo',
        serviceId: service.id,
        barberId: barber.id,
        date: date,
        startTime: startTime,
        endTime: DateFormats.addMinutes(startTime, service.durationMinutes),
        totalPrice: service.price,
        status: 'confirmed',
        serviceName: service.name,
        serviceDurationMinutes: service.durationMinutes,
        barberName: barber.name,
        barberAvatarUrl: barber.avatarUrl,
      ),
    );
  }
}

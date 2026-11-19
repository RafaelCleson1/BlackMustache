import '../core/utils/formatters.dart';

class Appointment {
  const Appointment({
    required this.id,
    required this.clientName,
    required this.serviceId,
    required this.barberId,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.totalPrice,
    required this.status,
    this.serviceName = 'Serviço',
    this.serviceDurationMinutes = 0,
    this.barberName = 'Profissional',
    this.barberAvatarUrl = '',
  });

  final String id;
  final String clientName;
  final String serviceId;
  final String barberId;
  final DateTime date;
  final String startTime;
  final String endTime;
  final double totalPrice;
  final String status;
  final String serviceName;
  final int serviceDurationMinutes;
  final String barberName;
  final String barberAvatarUrl;

  bool get isCancelled => status == 'cancelled';

  DateTime get startsAt {
    final startMinutes = DateFormats.toMinutes(startTime);
    return DateTime(
      date.year,
      date.month,
      date.day,
      startMinutes ~/ 60,
      startMinutes % 60,
    );
  }

  bool get isPast => startsAt.isBefore(DateTime.now());

  String get timeRange => '$startTime - $endTime';

  factory Appointment.fromMap(Map<String, dynamic> map) {
    final service = map['services'];
    final barber = map['barbers'];
    final serviceMap = service is Map<String, dynamic> ? service : null;
    final barberMap = barber is Map<String, dynamic> ? barber : null;

    return Appointment(
      id: map['id']?.toString() ?? '',
      clientName: (map['client_name'] as String?) ?? '',
      serviceId: map['service_id']?.toString() ?? '',
      barberId: map['barber_id']?.toString() ?? '',
      date: DateTime.parse(map['appointment_date'].toString()),
      startTime: DateFormats.parseTime(map['start_time']),
      endTime: DateFormats.parseTime(map['end_time']),
      totalPrice: (map['total_price'] as num?)?.toDouble() ?? 0,
      status: (map['status'] as String?) ?? 'confirmed',
      serviceName: (serviceMap?['name'] as String?) ?? 'Serviço',
      serviceDurationMinutes:
          (serviceMap?['duration_minutes'] as num?)?.toInt() ?? 0,
      barberName: (barberMap?['name'] as String?) ?? 'Profissional',
      barberAvatarUrl: (barberMap?['avatar_url'] as String?) ?? '',
    );
  }
}

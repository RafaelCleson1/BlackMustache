import 'package:intl/intl.dart';

abstract final class Money {
  static final NumberFormat _format = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: r'R$',
    decimalDigits: 2,
  );

  static String format(num value) => _format.format(value);
}

abstract final class DateFormats {
  static const List<String> _months = [
    'Janeiro',
    'Fevereiro',
    'Março',
    'Abril',
    'Maio',
    'Junho',
    'Julho',
    'Agosto',
    'Setembro',
    'Outubro',
    'Novembro',
    'Dezembro',
  ];

  static const List<String> _monthsShort = [
    'jan',
    'fev',
    'mar',
    'abr',
    'mai',
    'jun',
    'jul',
    'ago',
    'set',
    'out',
    'nov',
    'dez',
  ];

  static const List<String> _weekdays = [
    'Domingo',
    'Segunda',
    'Terça',
    'Quarta',
    'Quinta',
    'Sexta',
    'Sábado',
  ];

  static const List<String> weekdayInitials = [
    'D',
    'S',
    'T',
    'Q',
    'Q',
    'S',
    'S',
  ];

  static DateTime dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  static DateTime today() => dateOnly(DateTime.now());

  static String isoDate(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }

  static String monthName(int month) => _months[month - 1];

  static String monthShort(int month) => _monthsShort[month - 1];

  static String weekdayName(DateTime date) => _weekdays[date.weekday % 7];

  static String monthTitle(DateTime date) =>
      '${_months[date.month - 1].toUpperCase()} ${date.year}';

  static String formattedLong(DateTime date) =>
      '${weekdayName(date)}, ${date.day} de ${_months[date.month - 1].toLowerCase()}';

  static String formattedShort(DateTime date) =>
      '${weekdayName(date)}, ${date.day} ${_monthsShort[date.month - 1]}';

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static String parseTime(Object? value) {
    final raw = value?.toString() ?? '';
    if (raw.isEmpty) return '';
    return raw.length >= 5 ? raw.substring(0, 5) : raw;
  }

  static int toMinutes(String time) {
    final parts = time.split(':');
    if (parts.length < 2) return 0;
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;
    return hour * 60 + minute;
  }

  static String fromMinutes(int minutes) {
    final normalized = ((minutes % 1440) + 1440) % 1440;
    final hour = (normalized ~/ 60).toString().padLeft(2, '0');
    final minute = (normalized % 60).toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  static String addMinutes(String time, int minutes) =>
      fromMinutes(toMinutes(time) + minutes);

  static int weekdayIndexSundayFirst(DateTime date) => date.weekday % 7;
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/utils/error_messages.dart';
import '../core/utils/formatters.dart';
import '../models/appointment.dart';
import '../models/barber.dart';
import '../models/service.dart';
import '../providers/app_providers.dart';
import '../widgets/app_states.dart';
import '../widgets/buttons.dart';
import '../widgets/month_calendar.dart';
import 'booking_confirmed_screen.dart';

class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({
    super.key,
    required this.service,
    required this.barber,
  });

  final Service service;
  final Barber barber;

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  static const int _openMinutes = 9 * 60;
  static const int _closeMinutes = 19 * 60;
  static const int _slotStepMinutes = 30;

  late DateTime _selectedDate;
  late DateTime _visibleMonth;
  late Future<List<Appointment>> _bookingsFuture;
  String? _selectedSlot;
  bool _submitting = false;

  DateTime get _firstDate => DateFormats.today();
  DateTime get _lastDate => DateFormats.today().add(const Duration(days: 60));

  @override
  void initState() {
    super.initState();
    _selectedDate = DateFormats.today();
    _visibleMonth = DateTime(_selectedDate.year, _selectedDate.month);
    _bookingsFuture = _loadBookings();
  }

  Future<List<Appointment>> _loadBookings() {
    return ref
        .read(appointmentRepositoryProvider)
        .fetchBookingsFor(barberId: widget.barber.id, date: _selectedDate);
  }

  void _reloadBookings() {
    setState(() => _bookingsFuture = _loadBookings());
  }

  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = DateFormats.dateOnly(date);
      _visibleMonth = DateTime(date.year, date.month);
      _selectedSlot = null;
      _bookingsFuture = _loadBookings();
    });
  }

  void _changeMonth(int delta) {
    final target = DateTime(_visibleMonth.year, _visibleMonth.month + delta);
    final firstMonth = DateTime(_firstDate.year, _firstDate.month);
    final lastMonth = DateTime(_lastDate.year, _lastDate.month);
    if (target.isBefore(firstMonth) || target.isAfter(lastMonth)) return;
    setState(() => _visibleMonth = target);
  }

  bool get _canGoPrevious =>
      _visibleMonth.isAfter(DateTime(_firstDate.year, _firstDate.month));

  bool get _canGoNext =>
      _visibleMonth.isBefore(DateTime(_lastDate.year, _lastDate.month));

  List<_SlotData> _buildSlots(List<Appointment> bookings) {
    final duration = widget.service.durationMinutes;
    final now = DateTime.now();
    final isToday = DateFormats.isSameDay(_selectedDate, now);
    final nowMinutes = now.hour * 60 + now.minute;
    final slots = <_SlotData>[];

    for (
      var start = _openMinutes;
      start + duration <= _closeMinutes;
      start += _slotStepMinutes
    ) {
      final startTime = DateFormats.fromMinutes(start);
      final endTime = DateFormats.addMinutes(startTime, duration);

      final conflicts = bookings.any((appointment) {
        return start < DateFormats.toMinutes(appointment.endTime) &&
            start + duration > DateFormats.toMinutes(appointment.startTime);
      });
      final expired = isToday && start <= nowMinutes;

      slots.add(
        _SlotData(
          start: startTime,
          end: endTime,
          enabled: !conflicts && !expired,
        ),
      );
    }

    return slots;
  }

  Future<void> _confirm() async {
    final slot = _selectedSlot;
    if (slot == null || _submitting) return;

    setState(() => _submitting = true);
    try {
      final appointment = await ref
          .read(appointmentRepositoryProvider)
          .createAppointment(
            service: widget.service,
            barber: widget.barber,
            date: _selectedDate,
            startTime: slot,
          );

      ref.invalidate(appointmentsProvider);
      if (!mounted) return;

      await Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => BookingConfirmedScreen(appointment: appointment),
        ),
        (route) => route.isFirst,
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(describeError(error))));
      _reloadBookings();
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final service = widget.service;
    final barber = widget.barber;

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 64,
        leading: const Padding(
          padding: EdgeInsets.only(left: 20),
          child: Center(child: CircleBackButton()),
        ),
        title: const Text('ESCOLHA SEU HORÁRIO'),
        titleTextStyle: AppTextStyles.display(size: 15, letterSpacing: 2),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'O próximo passo é reservar um tempo para você.',
              style: AppTextStyles.body(
                size: 12.5,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(
                        color: AppColors.gold.withValues(alpha: 0.35),
                      ),
                    ),
                    child: const Icon(
                      Icons.content_cut_rounded,
                      size: 18,
                      color: AppColors.gold,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${service.name} - ${barber.name}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.body(
                            size: 13.5,
                            weight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${service.durationMinutes} min de cuidado',
                          style: AppTextStyles.body(
                            size: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    Money.format(service.price),
                    style: AppTextStyles.price(size: 15),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            MonthCalendar(
              visibleMonth: _visibleMonth,
              selectedDate: _selectedDate,
              firstDate: _firstDate,
              lastDate: _lastDate,
              onDateSelected: _selectDate,
              onPreviousMonth: _canGoPrevious ? () => _changeMonth(-1) : null,
              onNextMonth: _canGoNext ? () => _changeMonth(1) : null,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Text(
                  'HORÁRIOS DISPONÍVEIS',
                  style: AppTextStyles.label(
                    size: 10,
                    color: AppColors.textSecondary,
                    letterSpacing: 2,
                  ),
                ),
                const Spacer(),
                Text(
                  DateFormats.formattedShort(_selectedDate),
                  style: AppTextStyles.body(
                    size: 10.5,
                    color: AppColors.goldSoft,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            FutureBuilder<List<Appointment>>(
              future: _bookingsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const AppLoader(
                    height: 100,
                    label: 'Consultando a agenda',
                  );
                }
                if (snapshot.hasError) {
                  return AppErrorView(
                    height: 140,
                    message: describeError(snapshot.error!),
                    onRetry: _reloadBookings,
                  );
                }

                final slots = _buildSlots(snapshot.data ?? const []);
                final available = slots.where((slot) => slot.enabled).toList();

                if (available.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 22,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      'Nenhum horário livre nesta data. Escolha outro dia.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body(
                        size: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  );
                }

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: slots.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    mainAxisExtent: 44,
                  ),
                  itemBuilder: (context, index) {
                    final slot = slots[index];
                    return _SlotChip(
                      label: slot.start,
                      selected: slot.start == _selectedSlot,
                      enabled: slot.enabled,
                      onTap: slot.enabled
                          ? () => setState(() => _selectedSlot = slot.start)
                          : null,
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 24),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _selectedSlot == null
                  ? Text(
                      'Selecione um horário para continuar.',
                      key: const ValueKey('hint'),
                      style: AppTextStyles.body(
                        size: 11.5,
                        color: AppColors.textMuted,
                      ),
                    )
                  : Container(
                      key: const ValueKey('summary'),
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.gold.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.event_available_rounded,
                            size: 16,
                            color: AppColors.gold,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${DateFormats.formattedShort(_selectedDate)} · '
                              '$_selectedSlot às '
                              '${DateFormats.addMinutes(_selectedSlot!, service.durationMinutes)}',
                              style: AppTextStyles.body(
                                size: 12,
                                weight: FontWeight.w500,
                                color: AppColors.goldSoft,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
            const SizedBox(height: 14),
            GoldButton(
              label: 'Confirmar agendamento',
              icon: Icons.check_rounded,
              isLoading: _submitting,
              onPressed: _selectedSlot == null ? null : _confirm,
            ),
          ],
        ),
      ),
    );
  }
}

class _SlotData {
  const _SlotData({
    required this.start,
    required this.end,
    required this.enabled,
  });

  final String start;
  final String end;
  final bool enabled;
}

class _SlotChip extends StatelessWidget {
  const _SlotChip({
    required this.label,
    required this.selected,
    required this.enabled,
    this.onTap,
  });

  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color textColor;
    if (selected) {
      textColor = AppColors.ink;
    } else if (!enabled) {
      textColor = AppColors.textMuted.withValues(alpha: 0.55);
    } else {
      textColor = AppColors.textPrimary;
    }

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(11),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(11),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 170),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: selected ? AppColors.goldGradient : null,
            color: selected ? null : AppColors.surface,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(
              color: selected
                  ? Colors.transparent
                  : enabled
                  ? AppColors.border
                  : AppColors.border.withValues(alpha: 0.5),
            ),
          ),
          child: Text(
            label,
            style: AppTextStyles.body(
              size: 12,
              weight: selected ? FontWeight.w700 : FontWeight.w500,
              letterSpacing: 0.3,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}

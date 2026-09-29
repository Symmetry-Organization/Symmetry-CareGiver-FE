import 'dart:math' as math;

import 'package:clinician_app/core/constant/constant_import.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Clock-face time picker used by the Availability screen.
///
/// Shows the hour and minute as tappable fields with an AM/PM switch and a
/// dial below; tapping a field chooses what the dial edits. Closing returns
/// the selected [TimeOfDay] — the dialog has no separate confirm action.
Future<TimeOfDay?> showClockTimePicker({TimeOfDay? initialTime}) {
  return Get.dialog<TimeOfDay>(
    ClockTimePickerDialog(initialTime: initialTime),
  );
}

enum _DialMode { hour, minute }

class ClockTimePickerDialog extends StatefulWidget {
  const ClockTimePickerDialog({super.key, this.initialTime});

  final TimeOfDay? initialTime;

  @override
  State<ClockTimePickerDialog> createState() => _ClockTimePickerDialogState();
}

class _ClockTimePickerDialogState extends State<ClockTimePickerDialog> {
  static final double _fieldHeight = 84.h;

  late int _hourOfPeriod;
  late int _minute;
  late DayPeriod _period;
  _DialMode _mode = _DialMode.hour;

  @override
  void initState() {
    super.initState();
    final TimeOfDay initial = widget.initialTime ?? const TimeOfDay(hour: 7, minute: 0);
    _hourOfPeriod = initial.hourOfPeriod == 0 ? 12 : initial.hourOfPeriod;
    _minute = initial.minute;
    _period = initial.period;
  }

  TimeOfDay get _value {
    final int base = _hourOfPeriod == 12 ? 0 : _hourOfPeriod;
    return TimeOfDay(
      hour: _period == DayPeriod.am ? base : base + 12,
      minute: _minute,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  "Time",
                  style: AppTextStyle.bold14style.copyWith(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Get.back<TimeOfDay>(result: _value),
                  child: Icon(
                    Icons.close,
                    size: 26.sp,
                    color: AppColors.timePickerClose,
                  ),
                ),
              ],
            ),
            customHeight(24.h),
            // Fixed height so the AM/PM toggle can stretch to match the
            // number fields — stretching inside an unbounded row would ask
            // its children for an infinite height.
            SizedBox(
              height: _fieldHeight,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _numberField(
                      text: _hourOfPeriod.toString(),
                      isActive: _mode == _DialMode.hour,
                      onTap: () => setState(() => _mode = _DialMode.hour),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child: Center(
                      child: Text(
                        ":",
                        style: AppTextStyle.bold14style.copyWith(
                          fontSize: 34.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: _numberField(
                      text: _minute.toString().padLeft(2, '0'),
                      isActive: _mode == _DialMode.minute,
                      onTap: () => setState(() => _mode = _DialMode.minute),
                    ),
                  ),
                  customWidth(10.w),
                  _periodToggle(),
                ],
              ),
            ),
            customHeight(28.h),
            Center(
              child: _Dial(
                mode: _mode,
                hourOfPeriod: _hourOfPeriod,
                minute: _minute,
                onHour: (hour) => setState(() {
                  _hourOfPeriod = hour;
                  // Move straight on to minutes, the way the stock picker does.
                  _mode = _DialMode.minute;
                }),
                onMinute: (minute) => setState(() => _minute = minute),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _numberField({
    required String text,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.timePickerSurface,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          text,
          style: AppTextStyle.bold14style.copyWith(
            fontSize: 46.sp,
            fontWeight: FontWeight.w700,
            color: isActive ? AppColors.timePickerAccent : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _periodToggle() {
    return Container(
      width: 56.w,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderGrey),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          _periodCell(DayPeriod.am, "AM"),
          Divider(height: 1, color: AppColors.borderGrey),
          _periodCell(DayPeriod.pm, "PM"),
        ],
      ),
    );
  }

  Widget _periodCell(DayPeriod period, String label) {
    final bool isSelected = _period == period;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => setState(() => _period = period),
        child: Container(
          alignment: Alignment.center,
          color: isSelected ? AppColors.timePickerSurface : Colors.white,
          child: Text(
            label,
            style: AppTextStyle.normal14style.copyWith(
              fontWeight: FontWeight.w600,
              color: isSelected
                  ? AppColors.timePickerAccent
                  : AppColors.defaultTxtGrey,
            ),
          ),
        ),
      ),
    );
  }
}

/// The lavender clock face: twelve labels, a hand pointing at the current
/// value and a filled puck behind the label it lands on.
class _Dial extends StatelessWidget {
  const _Dial({
    required this.mode,
    required this.hourOfPeriod,
    required this.minute,
    required this.onHour,
    required this.onMinute,
  });

  final _DialMode mode;
  final int hourOfPeriod;
  final int minute;
  final ValueChanged<int> onHour;
  final ValueChanged<int> onMinute;

  /// Which of the twelve positions (0 = top, clockwise) is selected.
  int get _selectedSlot =>
      mode == _DialMode.hour ? hourOfPeriod % 12 : (minute ~/ 5) % 12;

  void _handlePointer(Offset local, double size) {
    final Offset center = Offset(size / 2, size / 2);
    final Offset delta = local - center;
    if (delta.distance < 8) return;
    // atan2 measures from the positive x-axis; shift a quarter turn so slot 0
    // sits at twelve o'clock, then fold into 0..11.
    final double angle = math.atan2(delta.dy, delta.dx) + math.pi / 2;
    final int slot = ((angle / (math.pi / 6)).round() % 12 + 12) % 12;
    if (mode == _DialMode.hour) {
      onHour(slot == 0 ? 12 : slot);
    } else {
      onMinute(slot * 5);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double size = 280.w;
    return SizedBox(
      width: size,
      height: size,
      child: GestureDetector(
        onTapDown: (details) => _handlePointer(details.localPosition, size),
        onPanUpdate: (details) => _handlePointer(details.localPosition, size),
        child: CustomPaint(
          painter: _DialPainter(
            selectedSlot: _selectedSlot,
            labels: List<String>.generate(
              12,
              (slot) => mode == _DialMode.hour
                  ? (slot == 0 ? '12' : '$slot')
                  : (slot * 5).toString().padLeft(2, '0'),
            ),
          ),
        ),
      ),
    );
  }
}

class _DialPainter extends CustomPainter {
  _DialPainter({required this.selectedSlot, required this.labels});

  final int selectedSlot;
  final List<String> labels;

  static const double _labelInset = 34;
  static const double _puckRadius = 28;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final double radius = size.width / 2;
    final double labelRadius = radius - _labelInset;

    canvas.drawCircle(
      center,
      radius,
      Paint()..color = AppColors.timePickerSurface,
    );

    final Offset selected = _slotOffset(center, labelRadius, selectedSlot);
    final Paint accent = Paint()..color = AppColors.timePickerAccent;
    canvas.drawLine(
      center,
      selected,
      Paint()
        ..color = AppColors.timePickerAccent
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(center, 5, accent);
    canvas.drawCircle(selected, _puckRadius, accent);

    for (int slot = 0; slot < 12; slot++) {
      final bool isSelected = slot == selectedSlot;
      final TextPainter painter = TextPainter(
        text: TextSpan(
          text: labels[slot],
          style: TextStyle(
            fontFamily: AppTextStyle.fontFamily,
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final Offset position = _slotOffset(center, labelRadius, slot);
      painter.paint(
        canvas,
        position - Offset(painter.width / 2, painter.height / 2),
      );
    }
  }

  Offset _slotOffset(Offset center, double radius, int slot) {
    final double angle = slot * (math.pi / 6) - math.pi / 2;
    return center + Offset(math.cos(angle) * radius, math.sin(angle) * radius);
  }

  @override
  bool shouldRepaint(covariant _DialPainter oldDelegate) =>
      oldDelegate.selectedSlot != selectedSlot ||
      !listEquals(oldDelegate.labels, labels);
}

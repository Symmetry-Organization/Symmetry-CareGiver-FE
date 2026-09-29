import 'package:clinician_app/core/constant/constant_import.dart';
import 'package:flutter/material.dart';

import 'calendar_style.dart';
import 'calendar_visit_tile.dart';

/// One hour of the day — the `09 / AM` gutter plus an optional visit.
class CalendarTimeSlot {
  const CalendarTimeSlot({
    required this.hour,
    required this.meridiem,
    this.visits = const [],
  });

  /// Two digit hour exactly as Figma renders it, e.g. `09`, `12`, `01`.
  final String hour;

  /// `AM` / `PM`.
  final String meridiem;

  /// Visits starting inside this hour; several share the row side by side.
  final List<CalendarVisit> visits;
}

/// Figma `Frame 1984078639` — a 343 px wide column of 44 px rows separated by
/// 20 px, each row closed off with a 0.18 px `#D9D9D9` hairline.
class CalendarDayTimeline extends StatelessWidget {
  const CalendarDayTimeline({super.key, required this.slots});

  final List<CalendarTimeSlot> slots;

  static const double rowHeight = 44;
  static const double rowGap = 20;
  static const double gutterWidth = 32; // visit starts at x = 32 inside the row
  static const double rowTrailing = 7; // 343 − 32 − 304
  static const double visitGap = 6;

  /// Height of one row plus its gap — used to scroll straight to an hour.
  static double get rowExtent => (rowHeight + rowGap).h;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < slots.length; i++) ...[
          if (i > 0) SizedBox(height: rowGap.h),
          _CalendarTimeRow(slot: slots[i]),
        ],
      ],
    );
  }
}

class _CalendarTimeRow extends StatelessWidget {
  const _CalendarTimeRow({required this.slot});

  final CalendarTimeSlot slot;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: CalendarDayTimeline.rowHeight.h,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.borderGrey, width: 0.18.h),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: CalendarDayTimeline.gutterWidth.w,
            child: Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: 17.w,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      slot.hour,
                      textAlign: TextAlign.center,
                      style: CalendarStyle.slotHour,
                    ),
                    SizedBox(height: 1.83.h),
                    Text(
                      slot.meridiem,
                      textAlign: TextAlign.center,
                      style: CalendarStyle.slotMeridiem,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                for (int i = 0; i < slot.visits.length; i++) ...[
                  if (i > 0) SizedBox(width: CalendarDayTimeline.visitGap.w),
                  Expanded(child: CalendarVisitTile(visit: slot.visits[i])),
                ],
              ],
            ),
          ),
          SizedBox(width: CalendarDayTimeline.rowTrailing.w),
        ],
      ),
    );
  }
}

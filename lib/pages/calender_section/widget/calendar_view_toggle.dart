import 'package:clinician_app/core/constant/constant_import.dart';
import 'package:flutter/material.dart';

import 'calendar_style.dart';

/// The two visible calendar modes of Figma frame `160`.
enum CalendarViewMode { list, calendar }

/// Figma `Segmented Control` — 352 × 40 wrapper (2 px padding) holding two
/// 83 × 36 buttons with a 6 px radius and 10 / 3 padding.
class CalendarViewToggle extends StatelessWidget {
  const CalendarViewToggle({
    super.key,
    required this.mode,
    required this.onChanged,
  });

  final CalendarViewMode mode;
  final ValueChanged<CalendarViewMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40.h,
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _segment('List', CalendarViewMode.list),
            _segment('Calendar', CalendarViewMode.calendar),
          ],
        ),
      ),
    );
  }

  Widget _segment(String label, CalendarViewMode value) {
    final bool selected = mode == value;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onChanged(value),
      child: Container(
        width: 83.w,
        height: 36.h,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryAppColor : Colors.white,
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: selected
              ? CalendarStyle.segmentActive
              : CalendarStyle.segmentInactive,
        ),
      ),
    );
  }
}

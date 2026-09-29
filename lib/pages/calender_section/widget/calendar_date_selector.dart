import 'package:clinician_app/core/constant/constant_import.dart';
import 'package:flutter/material.dart';

import 'calendar_style.dart';

/// Figma `Frame 1984078843` header block — the `‹ Today ›` control row
/// (34 px tall) followed by the five-day strip (53.85 px tall).
class CalendarDateSelector extends StatelessWidget {
  const CalendarDateSelector({
    super.key,
    required this.days,
    required this.selectedDay,
    required this.onDaySelected,
    this.onPrevious,
    this.onNext,
    this.onToday,
    this.onTodayLongPress,
    this.label,
    this.isRangeLabel = false,
    this.showDayStrip = true,
    this.trailing = const [],
  });

  /// The five days rendered in the strip, left to right.
  final List<DateTime> days;
  final DateTime selectedDay;
  final ValueChanged<DateTime> onDaySelected;

  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final VoidCallback? onToday;

  /// Long-pressing "Today" opens the full date picker dialog.
  final VoidCallback? onTodayLongPress;

  /// Replaces the "Today" pill text — used to show a picked date. The pill
  /// widens to fit it instead of keeping the fixed "Today" width.
  final String? label;

  /// True only for a two-ended range, which is too wide for the centred
  /// layout. A single date keeps the same shape as "Today".
  final bool isRangeLabel;

  /// List mode hides the five-day strip and shows only the navigation row.
  final bool showDayStrip;

  /// Controls pinned to the right edge of the navigation row (filter, date
  /// picker) — the `‹ Today ›` group stays centred regardless.
  final List<Widget> trailing;

  // Figma metrics for the strip.
  static const double _padTop = 15.38;
  static const double _padLeft = 34.62;
  static const double _colWidth = 45;
  static const double _colGap = 25;
  static const double _stripHeight = 53.85;
  static const double _pillWidth = 67.31;
  static const double _pillHeight = 54;
  static const double _pillLeft = 25; // left of the first day's highlight
  static const double _trailingInset = 16;
  static const double _trailingGap = 8;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _navigationRow(),
        if (showDayStrip) ...[SizedBox(height: 1.h), _dayStrip()],
      ],
    );
  }

  // ---------------------------------------------------------------- nav row
  /// Width the trailing buttons occupy on the right. The centred group is
  /// inset by this much on *both* sides so it stays on the true centre of the
  /// bar while never reaching the buttons. Matches `_HeaderIconButton._size`.
  static const double _trailingButton = 28;

  /// Breathing room between the `›` arrow and the first trailing button.
  static const double _arrowTrailingGap = 7;

  double get _centerInset {
    if (trailing.isEmpty) return 0;
    return trailing.length * _trailingButton +
        (trailing.length - 1) * _trailingGap +
        _trailingInset +
        _arrowTrailingGap;
  }

  Widget _navigationRow() {
    // Two shapes: the short "Today" pill sits on the true centre of the bar,
    // while a date range is too wide for that and instead fills the row with
    // the arrows and trailing buttons laid out beside it.
    if (label != null && isRangeLabel) return _rangeNavigationRow();

    return SizedBox(
      height: 34.h,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: _centerInset.w),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _IconButtonMaster(
                  icon: Icons.chevron_left_rounded,
                  roundedSide: _RoundedSide.left,
                  onTap: onPrevious,
                ),
                SizedBox(width: 10.w),
                Flexible(child: _datePill()),
                SizedBox(width: 10.w),
                _IconButtonMaster(
                  icon: Icons.chevron_right_rounded,
                  roundedSide: _RoundedSide.right,
                  onTap: onNext,
                ),
              ],
            ),
          ),
          if (trailing.isNotEmpty)
            Positioned(
              right: _trailingInset.w,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (int i = 0; i < trailing.length; i++) ...[
                    if (i > 0) SizedBox(width: _trailingGap.w),
                    trailing[i],
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _rangeNavigationRow() {
    return SizedBox(
      height: 34.h,
      width: double.infinity,
      // The row fills the bar, so it carries its own gutter: the same inset
      // on both ends as the trailing buttons keep in the centred layout.
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: _trailingInset.w),
        child: Row(
          children: [
            _IconButtonMaster(
              icon: Icons.chevron_left_rounded,
              roundedSide: _RoundedSide.left,
              onTap: onPrevious,
            ),
            SizedBox(width: 8.w),
            Expanded(child: _datePill()),
            SizedBox(width: 8.w),
            _IconButtonMaster(
              icon: Icons.chevron_right_rounded,
              roundedSide: _RoundedSide.right,
              onTap: onNext,
            ),
            for (int i = 0; i < trailing.length; i++) ...[
              SizedBox(width: i == 0 ? _arrowTrailingGap.w : _trailingGap.w),
              trailing[i],
            ],
          ],
        ),
      ),
    );
  }

  Widget _datePill() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onToday,
      onLongPress: onTodayLongPress,
      child: Container(
        width: label == null ? 68.w : null,
        height: 34.h,
        padding:
            label == null ? null : EdgeInsets.symmetric(horizontal: 10.w),
        decoration: BoxDecoration(
          color: AppColors.containerBakGColor,
          borderRadius: BorderRadius.circular(6.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.calendarTodayShadow,
              blurRadius: 1.r,
            ),
          ],
        ),
        // `widthFactor: 1` centres the text without letting the pill stretch
        // to the whole bar: a plain `alignment` fills whatever width it is
        // offered, which swallowed the row once the label became a date.
        // Under the range row's tight width it still fills, as intended.
        child: Center(
          widthFactor: 1,
          child: Text(
            label ?? 'Today',
            maxLines: 1,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: label == null
                ? CalendarStyle.todayText
                : AppTextStyle.regular12style.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1,
                    letterSpacing: 0,
                    color: AppColors.defaultTxtGrey,
                  ),
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------- day strip
  Widget _dayStrip() {
    final int selectedIndex = days.indexWhere(_isSelected);

    return SizedBox(
      height: _pillHeight.h,
      child: Stack(
        children: [
          if (selectedIndex >= 0)
            Positioned(
              top: 0,
              left: (_pillLeft + selectedIndex * (_colWidth + _colGap)).w,
              child: Container(
                width: _pillWidth.w,
                height: _pillHeight.h,
                decoration: BoxDecoration(
                  color: AppColors.calendarSelectedDayBg,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(3.85.r),
                  ),
                ),
              ),
            ),
          Padding(
            padding: EdgeInsets.only(top: _padTop.h, left: _padLeft.w),
            child: SizedBox(
              height: (_stripHeight - _padTop).h,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (int i = 0; i < days.length; i++) ...[
                    if (i > 0) SizedBox(width: _colGap.w),
                    _dayColumn(days[i]),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dayColumn(DateTime day) {
    final bool selected = _isSelected(day);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onDaySelected(day),
      child: SizedBox(
        width: _colWidth.w,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              day.day.toString(),
              textAlign: TextAlign.center,
              style:
                  selected
                      ? CalendarStyle.dayNumber
                      : CalendarStyle.dayNumberMuted,
            ),
            SizedBox(height: 1.92.h),
            Text(
              _weekdayLabels[day.weekday - 1],
              textAlign: TextAlign.center,
              style: CalendarStyle.dayLabel,
            ),
          ],
        ),
      ),
    );
  }

  bool _isSelected(DateTime day) =>
      day.year == selectedDay.year &&
      day.month == selectedDay.month &&
      day.day == selectedDay.day;

  static const List<String> _weekdayLabels = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];
}

enum _RoundedSide { left, right }

/// Figma `Icon Button Master` — 32 × 32, `gray/100` fill, 6 px radius on the
/// outward facing corners only (the left button is the same component
/// rotated 180°).
class _IconButtonMaster extends StatelessWidget {
  const _IconButtonMaster({
    required this.icon,
    required this.roundedSide,
    this.onTap,
  });

  final IconData icon;
  final _RoundedSide roundedSide;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Radius r = Radius.circular(6.r);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 32.w,
        height: 32.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.containerBakGColor,
          borderRadius:
              roundedSide == _RoundedSide.left
                  ? BorderRadius.only(topLeft: r, bottomLeft: r)
                  : BorderRadius.only(topRight: r, bottomRight: r),
        ),
        child: Icon(icon, size: 20.w, color: AppColors.defaultTxtGrey),
      ),
    );
  }
}

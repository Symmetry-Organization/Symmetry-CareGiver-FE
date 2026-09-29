import 'package:clinician_app/core/constant/constant_import.dart';
import 'package:flutter/material.dart';

import 'calendar_style.dart';

/// A single appointment placed inside an hour row.
class CalendarVisit {
  const CalendarVisit({
    required this.title,
    required this.color,
    this.isMoving = false,
    this.trailing,
    this.onTap,
  });

  final String title;

  /// Employee-type colour — drives the side bar and title; the surface is the
  /// same colour at 10% (Figma: `#0EA5E9 @ 10%`, `#FEF6E7` for amber).
  final Color color;

  /// The grey "being moved" appearance: `#C5C4C4 @ 80%` surface, no bar,
  /// white title.
  final bool isMoving;

  /// Optional end-of-row adornment — Figma shows the drag/move glyph here on
  /// the moving tile.
  final Widget? trailing;

  final VoidCallback? onTap;
}

/// Figma `Event` — 304 × 44, 6 px radius, a 2.74 px full-height colour bar and
/// a `Body` (5.49 px padding, 3.66 px inner gap) holding the title.
class CalendarVisitTile extends StatelessWidget {
  const CalendarVisitTile({super.key, required this.visit});

  final CalendarVisit visit;

  static const double height = 44;
  static const double _surfaceAlpha = 0.1;

  @override
  Widget build(BuildContext context) {
    final Color surface = visit.isMoving
        ? AppColors.calendarMovingSurface
        : visit.color.withValues(alpha: _surfaceAlpha);
    final Color title = visit.isMoving ? Colors.white : visit.color;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: visit.onTap,
      child: Container(
        height: height.h,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Row(
          children: [
            if (!visit.isMoving)
              Container(width: 2.74.w, height: height.h, color: visit.color),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(5.49.w),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        visit.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: CalendarStyle.visitTitle(title),
                      ),
                    ),
                    if (visit.trailing != null) ...[
                      SizedBox(width: 3.66.w),
                      visit.trailing!,
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

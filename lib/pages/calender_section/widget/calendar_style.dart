import 'package:clinician_app/core/constant/constant_import.dart';
import 'package:flutter/material.dart';

/// Text styles read 1:1 from Figma `Pro Health Referral app / Clinician App /
/// 160` (frame 375 × 812) that don't already exist in [AppTextStyle] — every
/// size here (19.23, 14.64, …) is a Figma-exact value the shared style sheet
/// doesn't carry. Every color and the font family are still pulled from the
/// project's existing [AppColors] / [AppTextStyle], nothing is redefined.
///
/// The app's ScreenUtil design size is also 375 × 812, so every Figma pixel
/// maps directly onto `.w` / `.h` / `.sp` / `.r`.
class CalendarStyle {
  const CalendarStyle._();

  /// Figma reports a box height for every text layer. Fira Sans' own line box
  /// is taller than that, so each style pins `height` to the Figma box
  /// (box ÷ font-size) and distributes the leading evenly — which is how Figma
  /// centres the glyphs inside the box.
  static TextStyle _t(
    double size,
    FontWeight weight,
    Color color, {
    required double box,
  }) => TextStyle(
    fontFamily: AppTextStyle.fontFamily,
    fontSize: size.sp,
    fontWeight: weight,
    color: color,
    height: box / size,
    leadingDistribution: TextLeadingDistribution.even,
  );

  /// "Symmetry" word-mark — 16 / SemiBold, box 19.
  static TextStyle get wordMarkText =>
      _t(16, FontWeight.w600, AppColors.secondaryAppColor, box: 19);

  /// Active segment ("Calendar") — 12 / SemiBold, box 15.
  static TextStyle get segmentActive =>
      _t(12, FontWeight.w600, Colors.white, box: 15);

  /// Inactive segment ("List") — 12 / Light, box 15.
  static TextStyle get segmentInactive =>
      _t(12, FontWeight.w300, AppColors.defaultTxtGrey, box: 15);

  /// "Today" pill — 14 / Bold, box 17.
  static TextStyle get todayText =>
      _t(14, FontWeight.w700, AppColors.defaultTxtGrey, box: 17);

  /// Day number "18" — 19.23 / SemiBold, box 23.08.
  static TextStyle get dayNumber =>
      _t(19.23, FontWeight.w600, AppColors.defaultTxtGrey, box: 23.08);

  /// Un-selected day number — same style at 60% opacity.
  static TextStyle get dayNumberMuted => _t(
    19.23,
    FontWeight.w600,
    AppColors.defaultTxtGrey.withValues(alpha: 0.6),
    box: 23.08,
  );

  /// Week-day label "Mon" — 12 / Regular, box 13.46.
  static TextStyle get dayLabel =>
      _t(12, FontWeight.w400, AppColors.defaultTxtGrey, box: 13.46);

  /// Hour "09" — 12 / Bold, box 14.
  static TextStyle get slotHour =>
      _t(12, FontWeight.w700, AppColors.defaultTxtGrey, box: 14);

  /// Meridiem "AM" — 12 / Regular, box 14.
  static TextStyle get slotMeridiem =>
      _t(12, FontWeight.w400, AppColors.defaultTxtGrey, box: 14);

  /// Visit title — 12 / SemiBold, explicit 14.64 line height.
  static TextStyle visitTitle(Color color) =>
      _t(12, FontWeight.w600, color, box: 14.64);

  /// Bottom bar label — 10 / Regular, box 12.
  static TextStyle bottomBarLabel(Color color) =>
      _t(10, FontWeight.w400, color, box: 12);

  /// "Live" label inside the centre FAB — 12 / Regular, box 16.
  static TextStyle get liveLabel =>
      _t(12, FontWeight.w400, Colors.white, box: 16);
}

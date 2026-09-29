import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryAppColor = Color(0xff50B5E5);
  static const Color secondaryAppColor = Color(0xff3979B2);
  // static const Color primaryAppLightColor = Color.fromRGBO(189, 30, 81, 0.5);
  // static const Color primaryExtraLightColor = Color.fromRGBO(189, 30, 81, 0.1);
  static const Color primaryLightBackGColor = Color(0xffE9FAF9);
  static const Color redLightBackGColor = Color(0xffFFE4E4);
  static const Color containerBakGColor = Color(0xffF4F4F5);
  static Color greyShade400 = Colors.grey.shade400;
  static Color blackfaint = Color(0xFF333333);
  static Color mediumgrey = Color(0xFF686464);
  static const Color navyBlueColor = Color(0xff2A76B2);
  static const Color textGreyColor = Color.fromRGBO(107, 114, 123, 1);
  static const Color textFieldBackGColor = Color(0xFFF9FAFB);
  static const Color textFieldBorderColor = Color(0xFFD1D5DB);
  static const Color requiredRedColor = Color(0xFFD03030);
  static const Color iconGreyColor = Color(0xff848484);
  static const Color profileAppbarColor = Color(0xff18223B);
  static const Color appYellowColor = Color(0xFFDD9D34);
  static const Color warningBackgColor = Color(0xffB26322);
  static const Color appBgColor = Color(0xFF03152F);
  static const Color pdfThemeColor = Color(0xFF163853);
  static const Color calenderTxtBlack = Color(0xFF1B1B1B);
  static const Color chatGreenColor = Color(0xCC6CBB80);
  static const Color chatBlueColor = Color(0xFFB3D8FF);
  static const Color chatRedColor = Color(0xFFF6928A);
  static const Color chatPrimaryBlueColor = Color(0xFF2EA3D4);

  static const Color greyColor = Color(0xffC0C0C0);
  static const Color grey = Color(0xff999999);
  static const Color iconGrey = Color(0xffE2E9E9);
  static const Color backGrndGrey = Color(0xffF4F5F6);
  static const Color settingsIconGrey = Color(0xff6B727B);
  static const Color defaultTxtGrey = Color(0xff686464);
  static const Color hintGrey = Color(0xff9CA3AF);
  static const Color borderGrey = Color(0xffD9D9D9);

  static const Color redColor = Color(0xffFF3333);
  static const Color rejectionRedColor = Color(0xffF6928A);
  static const Color redTextColor = Color(0xFFFF4242);
  static const Color redBackGColor = Color(0xFFFF5C5C);
  static const Color orangeColor = Color(0xFFFF744F);
  static const Color purpleColor = Color(0xFF7C64DB);
  static const Color greenColor = Color(0xFF008000);

  // Patient list card (Figma: Clinician App / CLINICIAN MOBILE FLOW (NEW) / Patient List)
  static const Color visitTagEvaluation = Color(0xFF203878);
  static const Color visitTagSOC = Color(0xFFBF6066);
  static const Color visitTagRecert = Color(0xFF4682A7);
  static const Color priceTagGreen = Color(0xFF4CB050);
  static const Color outOfZoneBlue = accentBlue;
  static const Color cardBorderColor = Color(0x24000000);

  /// Brand blue used for out-of-zone labels, time-off hours and visit charges.
  static const Color accentBlue = Color(0xFF2A93C0);

  // Time off
  static const Color timeOffAvailableBlue = accentBlue;

  // Availability screen + its clock-face time picker
  static const Color timePickerAccent = Color(0xFF4DC5B9);
  static const Color timePickerSurface = Color(0xFFF8F1FB);
  static const Color timePickerClose = Color(0xFFE53935);
  static const Color availabilityFieldFill = Color(0x122A93C0);
  static const Color availabilityFieldBorder = Color(0xFF008ABD);
  static const Color availabilityFieldText = Color(0xFF535353);
  static const Color availabilitySlotBorder = Color(0xFFD7D7D7);

  // Visit week detail
  static const Color socTagGreen = Color(0xFF87C38A);
  static const Color visitAddFill = Color(0x212A93C0);
  static const Color visitActionBlue = Color(0xFF1696C8);
  static const Color visitDarkText = Color(0xFF2A2A2A);
  static const Color imageOptionCaption = Color(0xFF9F9F9F);
  static const Color audioUploadFill = Color(0x1FB8B8B8);
  static const Color audioUploadText = Color(0xFF767676);
  static const Color availabilityWeekSurface = Color(0xFFF4F4F4);
  static const Color availabilityDayName = Color(0x6E050505);
  static const Color availabilityDayDate = Color(0xC4050505);

  // Time off history status chips (background = text hue @ 10%)
  static const Color statusApprovedText = Color(0xFF2D9632);
  static const Color statusApprovedBg = Color(0x1A008000);
  static const Color statusPendingText = Color(0xFFCE9E2F);
  static const Color statusPendingBg = Color(0x1ACE9E2F);
  static const Color statusRejectedText = Color(0xFFA10505);
  static const Color statusRejectedBg = Color(0x1AA10505);

  // Calendar day view (Figma: Clinician App / CLINICIAN MOBILE FLOW (NEW) / 160)
  static const Color calendarSelectedDayBg = Color(0xFFD9F3FF);
  static const Color calendarAmberSurface = Color(0xFFFEF6E7);
  static const Color calendarAmberText = Color(0xFFB45309);
  static const Color calendarSkySurface = Color(0x1A0EA5E9); // #0EA5E9 @ 10%
  static const Color calendarSkyBar = Color(0xFF0EA5E9);
  static const Color calendarSkyText = Color(0xFF0369A1);
  static const Color calendarMovingSurface = Color(0xCCC5C4C4); // #C5C4C4 @ 80%
  static const Color calendarLiveShadow = Color(0x40007B9B); // #007B9B @ 25%
  static const Color calendarBottomBarShadow = Color(0x21000000); // #000 @ 13%
  static const Color calendarTodayShadow = Color(0x40000000); // #000 @ 25%

  // Plan-of-care chips (Figma). Same hex as some reds/blues above, but a
  // separate concept — these track the design's discipline colours.
  static const Color planOfCareOt = Color(0xFFFEBD4D);
  static const Color planOfCarePt = Color(0xFFF6928A);
  static const Color planOfCareSt = Color(0xFF527FB9);

  // Live map marker (Figma: map pin, assets/svg/map_marker_icon.svg)
  static const Color mapMarkerGreen = Color(0xFF3A9A40);
  static const Color mapMarkerLabel = Color(0xFF008ABD);
  static const Color saveButtonBlue = Color(0xFF1696C8);

  // Request list search field
  static const Color searchFieldFill = Color(0xFFE9E9E9);
  static const Color searchFieldBorder = Color(0xFFDDDDE3);
}

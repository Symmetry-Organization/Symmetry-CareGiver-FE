import 'dart:io';

import 'package:clinician_app/core/constant/api_app_constant.dart';
import 'package:clinician_app/core/constant/app_colors.dart';
import 'package:clinician_app/model/request/request_data_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

final logger = Logger();

class CommonMethods {
  static Color getTextColorForBackground(
    Color backgroundColor, {
    Color? darkColor,
    Color? lightColor,
  }) {
    // Calculate the luminance of the background color.
    // This formula is based on the relative luminance calculation for sRGB colors.
    // double luminance =
    //     (0.299 * backgroundColor.r +
    //         0.587 * backgroundColor.g +
    //         0.114 * backgroundColor.b) /
    //     255;
    final hslColor = HSLColor.fromColor(backgroundColor);
    final luminance = hslColor.lightness;
    // Choose white if the luminance is high (light background),
    // and black if the luminance is low (dark background).
    // log('lumi:$luminance');
    return luminance > 0.6
        ? (darkColor ?? AppColors.defaultTxtGrey)
        : (lightColor ?? Colors.white);
  }

  static void getXSnackBar(String title, String message, Color? color) {
    Get.snackbar(
      title,
      message,
      backgroundColor: color,
      colorText: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      duration: const Duration(seconds: 2),
      borderRadius: 10,
      barBlur: 10,
    );
  }

  static String formatDateWithDate(DateTime dateTime) {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    final dateFormatter = DateFormat(
      ', d MMMM yyyy',
    ); // Format: , 16 April 2025

    if (dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day) {
      return 'Today${dateFormatter.format(dateTime)}';
    } else if (dateTime.year == yesterday.year &&
        dateTime.month == yesterday.month &&
        dateTime.day == yesterday.day) {
      return 'Yesterday${dateFormatter.format(dateTime)}';
    } else {
      final weekdayFormatter = DateFormat('EEEE'); // Format: Monday
      return '${weekdayFormatter.format(dateTime)}${dateFormatter.format(dateTime)}';
    }
  }

  static String getFormattedDay(DateTime date) {
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final selectedDate = DateTime(date.year, date.month, date.day);

    if (selectedDate == DateTime(now.year, now.month, now.day)) {
      return 'Today';
    } else if (selectedDate ==
        DateTime(yesterday.year, yesterday.month, yesterday.day)) {
      return 'Yesterday';
    } else if (selectedDate ==
        DateTime(tomorrow.year, tomorrow.month, tomorrow.day)) {
      return 'Tomorrow';
    } else {
      return DateFormat('MMMM dd, yyyy').format(date);
    }
  }

  static String getZoneName(ZoneType type) {
    switch (type) {
      case ZoneType.warning:
        return 'Warning';
      case ZoneType.inZone:
        return 'In Zone';
      case ZoneType.outOfZone:
        return 'Out of Zone';
      default: ZoneType.unknown;
        return '';
    }
  }

  /// Left-edge visit-type tag color on the patient list card
  /// (Figma: Clinician App / Patient List — Evaluation / SOC / Recert).
  static Color getVisitTypeColor(String visitType) {
    switch (visitType.trim().toLowerCase()) {
      case 'evaluation':
        return AppColors.visitTagEvaluation;
      case 'soc':
        return AppColors.visitTagSOC;
      case 'recert':
      case 're-cert':
      case 'recertification':
      case 'revisit':
        return AppColors.visitTagRecert;
      default:
        return AppColors.secondaryAppColor;
    }
  }

  /// Plan-of-care chip colour. The design fixes OT / PT / ST; anything else
  /// (RN, and so on) keeps whatever colour the API sent.
  static Color getPlanOfCareColor(String abbreviation, Color fallback) {
    switch (abbreviation.trim().toUpperCase()) {
      case 'OT':
        return AppColors.planOfCareOt;
      case 'PT':
        return AppColors.planOfCarePt;
      case 'ST':
        return AppColors.planOfCareSt;
      default:
        return fallback;
    }
  }

  static Color getJobStatusColour(String jobStatus) {
    switch (jobStatus.toLowerCase()) {
      case 'pending':
        return const Color(0xff3AA3EE);
      case 'cancelled':
        return AppColors.primaryAppColor;
      case 'approved':
        return const Color(0xff43B678);
      default:
        return AppColors.primaryAppColor;
    }
  }

  static Future<String?> getStorageDirectory() async {
    if (Platform.isAndroid) {
      return "/storage/emulated/0/Download"; // For Downloads folder
    } else if (Platform.isIOS) {
      Directory? directory = await getApplicationDocumentsDirectory();
      return directory.path;
    }
    return null;
  }

  // static String getAddress(LocationData address) {
  //   var list = [
  //     address.houseNo ?? "",
  //     address.street ?? "",
  //     address.city ?? "",
  //     address.state ?? "",
  //     address.pincode ?? "",
  //   ];
  //   list.removeWhere((element) => element.isEmpty);
  //   return list.join(', ');
  // }

  static double calculateMRP(double offerPrice, double discountPercentage) {
    if (discountPercentage >= 100) {
      return 0;
    }
    return offerPrice * 100 / (100 - discountPercentage);
  }

  static String ensureFullUrl(String url) {
    if (url.isEmpty) {
      return '';
    }
    final uri = Uri.tryParse(url);

    if (uri == null || (!uri.hasScheme && !uri.hasAuthority)) {
      // If the URL is just a path, attach it to the given domain
      return Uri.parse(ApiAppConstant.clinicialBaseUrl).resolve(url).toString();
    }

    return url; // Return the original URL if it's already valid
  }

  static String formatWeekday(int weekday) {
    switch (weekday) {
      case 1:
        return 'Mo';
      case 2:
        return 'Tu';
      case 3:
        return 'We';
      case 4:
        return 'Th';
      case 5:
        return 'Fr';
      case 6:
        return 'Sa';
      case 0:
        return 'Su';
      default:
        return ''; // Or handle invalid input as needed
    }
  }
}

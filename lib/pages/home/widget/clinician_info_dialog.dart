import 'dart:ui';

import 'package:clinician_app/core/constant/constant_import.dart';
import 'package:clinician_app/model/key_value_model.dart';
import 'package:clinician_app/utils/common_methods.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../controller/live_map_controller.dart';
import '../../../model/liveMap/live_data_model.dart';

class ClinicianInfoDialog extends StatefulWidget {
  final int viditId;
  final VisitDashboardDetailsModel data;
  const ClinicianInfoDialog({super.key, required this.data, required this.viditId});

  @override
  State<ClinicianInfoDialog> createState() => _ClinicianInfoDialogState();
}

class _ClinicianInfoDialogState extends State<ClinicianInfoDialog> {
   LiveMapController liveMapController = Get.put(LiveMapController());
  @override
  initState() {

    super.initState();
  }
  Color hexToColor(String? hex) {
    if (hex == null || hex.trim().isEmpty) return AppColors.chatRedColor;

    String value = hex.trim();

    // Accept "#RRGGBB"
    if (value.startsWith("#")) {
      value = value.replaceFirst("#", "");
      return Color(int.parse("0xFF$value"));
    }

    // Accept "0xffRRGGBB" or "0xFFRRGGBB"
    if (value.startsWith("0x") || value.startsWith("0X")) {
      return Color(int.parse(value));
    }

    // fallback: raw "RRGGBB"
    if (value.length == 6) {
      return Color(int.parse("0xFF$value"));
    }

    return AppColors.chatRedColor;
  }
  @override
  Widget build(BuildContext context) {
    return Center(
      child:Obx(() => liveMapController.isDetailsLoading.value ? Center(
        child: CircularProgressIndicator(
          color: AppColors.primaryAppColor,
        ),
      ) :Material(
        type: MaterialType.transparency,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child:  Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    onTap: () {
                      Get.back();
                    },
                    child: Container(
                      width: 20.w,
                      height: 20.h,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: AppColors.hintGrey),
                      child: SvgPicture.asset(
                        AppAsset.closeSvgIcon,
                        colorFilter: Colors.white.getSvgColor,
                      ),
                    ),
                  ),
                ),
                customHeight(10.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 11.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,

                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 42.w,
                            height: 45.h,
                            decoration: BoxDecoration(shape: BoxShape.circle),
                            clipBehavior: Clip.hardEdge,
                            child: liveMapController.visitDashboardDetails.value.patient.imageUrl.isEmpty ? Image.asset(
                              AppAsset.profilePicImg,
                              fit: BoxFit.cover,
                            ): Image.network(
                              liveMapController.visitDashboardDetails.value.patient.imageUrl,
                              fit: BoxFit.cover,
                            ),
                          ),
                          customWidth(10.w),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                liveMapController.visitDashboardDetails.value.patient.name,
                                style: AppTextStyle.regular12style.copyWith(
                                  fontWeight: FontWeight.w600,
                                  height: 1.5,
                                  letterSpacing: 0,
                                  color: AppColors.defaultTxtGrey,
                                ),
                              ),
                              Text(
                                liveMapController.visitDashboardDetails.value.patient.primaryDiagnosis,
                                style: AppTextStyle.regular12style.copyWith(
                                  fontWeight: FontWeight.w300,
                                  height: 1.5,
                                  letterSpacing: 0,
                                  color: AppColors.defaultTxtGrey,
                                ),
                              ),
                            ],
                          ),
                          Spacer(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '2x4    | ${liveMapController.visitDashboardDetails.value.visit.distanceInMiles}',
                                textAlign: TextAlign.right,
                                style: AppTextStyle.regular12style.copyWith(
                                  fontWeight: FontWeight.w700,
                                  height: 23 / 12,
                                  letterSpacing: 0,
                                  color: AppColors.defaultTxtGrey,
                                ),
                              ),
                              Text(
                                '\$${liveMapController.visitDashboardDetails.value.visit.visitCharge}',
                                textAlign: TextAlign.right,
                                style: AppTextStyle.regular16style.copyWith(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w600,
                                  height: 1.5,
                                  letterSpacing: 0,
                                  color: AppColors.accentBlue,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Text(
                        'Distance ${liveMapController.visitDashboardDetails.value.visit.distanceKm ?? "--"}',
                        style: AppTextStyle.regular12style.copyWith(
                          fontWeight: FontWeight.w400,
                          height: 1,
                          letterSpacing: 0,
                          color: AppColors.defaultTxtGrey,
                        ),
                      ),
                      customHeight(6.h),
                      Row(
                        children: [
                          Text(
                            'Visit  ${liveMapController.visitDashboardDetails.value.visit.visitCount}',
                            style: AppTextStyle.regular12style.copyWith(
                              fontWeight: FontWeight.w400,
                              height: 1,
                              letterSpacing: 0,
                              color: AppColors.defaultTxtGrey,
                            ),
                          ),
                          Spacer(),
                          Text(
                            'Time to reach',
                            textAlign: TextAlign.right,
                            style: AppTextStyle.regular12style.copyWith(
                              fontWeight: FontWeight.w700,
                              height: 23 / 12,
                              letterSpacing: 0,
                              color: AppColors.defaultTxtGrey,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          SvgPicture.asset(AppAsset.locationFillSvgIcon),
                          customWidth(4.w),
                          Expanded(
                            child: Text(
                              liveMapController.visitDashboardDetails.value.patient.address,
                              style: AppTextStyle.regular12style.copyWith(
                                fontWeight: FontWeight.w400,
                                height: 1,
                                letterSpacing: 0,
                                color: AppColors.defaultTxtGrey,
                              ),
                            ),
                          ),
                          customWidth(8.w),
                          Text(
                            liveMapController
                                .visitDashboardDetails.value.visit.timeToReach,
                            textAlign: TextAlign.right,
                            style: AppTextStyle.regular12style.copyWith(
                              fontWeight: FontWeight.w700,
                              height: 23 / 12,
                              letterSpacing: 0,
                              color: AppColors.defaultTxtGrey,
                            ),
                          ),
                        ],
                      ),
                      customHeight(2.h),
                      Text(
                        liveMapController.visitDashboardDetails.value.patient.about,
                        style: AppTextStyle.normal12style.copyWith(
                          color: AppColors.defaultTxtGrey,
                        ),
                      ),
                      customHeight(8.h),
                      Text(
                        'Plan Of Care',
                        style: AppTextStyle.regular12style.copyWith(
                          fontWeight: FontWeight.w700,
                          height: 1,
                          letterSpacing: 0,
                          color: AppColors.defaultTxtGrey,
                        ),
                      ),
                      customHeight(10.h),
                      Row(
                        children: [
                          ...List.generate(liveMapController.visitDashboardDetails.value.planOfCare.length, (index) {
                            var list = liveMapController.visitDashboardDetails.value.planOfCare[index];
                            return Container(
                              width: 20.w,
                              height: 20.h,
                              alignment: Alignment.center,
                              margin: EdgeInsets.only(right: 2.w),
                              decoration: BoxDecoration(
                                color: CommonMethods.getPlanOfCareColor(
                                  list.abbreviation,
                                  hexToColor(list.color),
                                ),
                                borderRadius: BorderRadius.circular(2.r),
                              ),
                              child: Text(
                                list.abbreviation,
                                style: AppTextStyle.normal10style.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      )),
    );
  }
}

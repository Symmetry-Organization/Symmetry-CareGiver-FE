import 'package:clinician_app/model/request/request_data_model.dart';
import 'package:clinician_app/utils/common_methods.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/constant/constant_import.dart';
import '../../model/calender/list_model.dart';

/// Patient list card — pixel match for Figma "Clinician App" page,
/// CLINICIAN MOBILE FLOW (NEW) / Patient List (List tab), frame "200".
class AppointmentListWidget extends StatefulWidget {
  final VisitsListData dataList;
  AppointmentListWidget({super.key, required this.dataList});

  @override
  State<AppointmentListWidget> createState() => _AppointmentListWidgetState();
}

class _AppointmentListWidgetState extends State<AppointmentListWidget> {
  static const double _cardRadius = 10;
  static const double _cardShadowBlur = 4;
  static const double _cardShadowOffset = 1;

  @override
  Widget build(BuildContext context) {
    final tagColor = CommonMethods.getVisitTypeColor(widget.dataList.visitType);
    final zoneColor =
        widget.dataList.inZone ? AppColors.greenColor : AppColors.outOfZoneBlue;
    final zoneLabel = CommonMethods.getZoneName(
      widget.dataList.inZone ? ZoneType.inZone : ZoneType.outOfZone,
    );

    final Radius radius = Radius.circular(_cardRadius.r);

    // Shadow lives on the outer box and the rounded clip on the inner one, so
    // the clip never trims the shadow and no border gets painted over the
    // coloured edge tags.
    return Container(
      height: 106.h,
      margin: EdgeInsets.only(bottom: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(radius),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardBorderColor,
            blurRadius: _cardShadowBlur.r,
            offset: Offset(0, _cardShadowOffset.h),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.all(radius),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ---- left edge tag: visit type (Evaluation / SOC / Recert) ----
            Container(
              width: 24.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: tagColor,
                borderRadius: BorderRadius.only(
                  topLeft: radius,
                  bottomLeft: radius,
                ),
              ),
              child: RotatedBox(
                quarterTurns: 3,
                child: Text(
                  widget.dataList.visitType,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.regular10style.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            // ---- main content ----
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 10.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 21.r,
                          backgroundColor: Colors.transparent,
                          backgroundImage:
                              widget.dataList.patientImgUrl.isEmpty
                                  ? AssetImage(AppAsset.profilePicImg)
                                      as ImageProvider
                                  : NetworkImage(widget.dataList.patientImgUrl),
                        ),
                        customWidth(8.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.dataList.patientName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyle.regular12style.copyWith(
                                  fontWeight: FontWeight.w600,
                                  height: 1.5,
                                  color: AppColors.calenderTxtBlack,
                                ),
                              ),
                              Text(
                                widget.dataList.primaryDiagnosis,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyle.regular12style.copyWith(
                                  fontWeight: FontWeight.w300,
                                  height: 1.5,
                                  color: AppColors.defaultTxtGrey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        customWidth(6.w),
                        Container(
                          height: 19.h,
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: zoneColor.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(12.5.r),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            zoneLabel,
                            style: AppTextStyle.regular10style.copyWith(
                              fontWeight: FontWeight.w600,
                              height: 1.5,
                              color: zoneColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    customHeight(8.h),
                    Text(
                      '2x4  |  ${widget.dataList.distance} miles',
                      style: AppTextStyle.regular10style.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppColors.defaultTxtGrey,
                      ),
                    ),
                    customHeight(4.h),
                    Row(
                      children: [
                        SvgPicture.asset(
                          AppAsset.locationFillSvgIcon,
                          width: 10.w,
                          height: 10.w,
                          colorFilter: const ColorFilter.mode(
                            AppColors.primaryAppColor,
                            BlendMode.srcIn,
                          ),
                        ),
                        customWidth(4.w),
                        Expanded(
                          child: Text(
                            widget.dataList.address,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyle.regular10style.copyWith(
                              fontWeight: FontWeight.w500,
                              color: AppColors.primaryAppColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ---- right edge tag: price ----
            Container(
              width: 25.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.priceTagGreen,
                borderRadius: BorderRadius.only(
                  topRight: radius,
                  bottomRight: radius,
                ),
              ),
              child: RotatedBox(
                quarterTurns: 1,
                child: Text(
                  '\$${widget.dataList.visitCharge.toStringAsFixed(2)}',
                  style: AppTextStyle.regular12style.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

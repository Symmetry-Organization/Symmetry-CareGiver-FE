import 'package:clinician_app/core/common/hex_color_decoder.dart';
import 'package:clinician_app/core/constant/constant_import.dart';
import 'package:clinician_app/core/ui/buttons/primary_button.dart';
import 'package:clinician_app/core/ui/buttons/primary_outlined_button.dart';
import 'package:clinician_app/model/request/request_data_model.dart';
import 'package:clinician_app/pages/request/request_detail_page.dart';
import 'package:clinician_app/pages/request/widget/accept_dialog_widget.dart';
import 'package:clinician_app/pages/request/widget/reject_dialog_widget.dart';
import 'package:clinician_app/pages/request/widget/reschedule_dialog_widget.dart';
import 'package:clinician_app/pages/request/widget/schedule_row_widget.dart';
import 'package:clinician_app/utils/common_methods.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_stack/image_stack.dart';
import 'package:get/route_manager.dart';

import '../../../model/request/requestList_model.dart';

/// Request card — Figma "Request" list: zone-coloured outline, note/warning
/// banner, patient block, schedule rows and the Reject / Reschedule / Accept
/// actions for pending visits.
class RequestInfoWidget extends StatefulWidget {
  const RequestInfoWidget({
    super.key,
    required this.data,
    required this.filterStatus,
  });
  final String filterStatus;
  final PatientVisitModel data;

  @override
  State<RequestInfoWidget> createState() => _RequestInfoWidgetState();
}

class _RequestInfoWidgetState extends State<RequestInfoWidget> {
  static const int _collapsedVisitCount = 3;
  static const double _cardRadius = 8;
  static const double _borderWidth = 1.5;
  static const double _avatarRadius = 26;
  static const double _bannerIconSize = 11;

  ZoneType get _zone {
    if (widget.data.warning.isNotEmpty) return ZoneType.warning;
    if (widget.data.inZone == "true") return ZoneType.inZone;
    if (widget.data.inZone == "false") return ZoneType.outOfZone;
    return ZoneType.unknown;
  }

  Color _zoneColor(ZoneType type) {
    switch (type) {
      case ZoneType.warning:
        return AppColors.appYellowColor;
      case ZoneType.inZone:
        return AppColors.greenColor;
      case ZoneType.outOfZone:
        return AppColors.primaryAppColor;
      case ZoneType.unknown:
        return AppColors.borderGrey;
    }
  }

  /// The list is always filtered to one status, so the selected filter is what
  /// the card should render — the mocked API reports every record as
  /// "pending", which would otherwise collapse all four variants into one.
  String get _status => widget.filterStatus.trim().toLowerCase();

  bool get _isPending => _status == 'pending';

  void _openDetail() {
    Get.to(
      () => RequestDetailPage(
        chartNo: 1,
        visitId: widget.data.visitId,
        noteText: widget.data.visitNote,
        filterText: widget.data.visitStatus,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalVisits = widget.data.visitList.length;
    final visibleCount = totalVisits > _collapsedVisitCount
        ? _collapsedVisitCount
        : totalVisits;
    final remaining = totalVisits - visibleCount;
    final zone = _zone;
    final zoneColor = _zoneColor(zone);

    return InkWell(
      onTap: widget.filterStatus != "pending" ? _openDetail : null,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 6.h),
        padding: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: zoneColor, width: _borderWidth.w),
          borderRadius: BorderRadius.circular(_cardRadius.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _BannerRow(
              showBanner: _isPending,
              note: widget.data.visitNote,
              warning: widget.data.warning,
              zoneLabel: CommonMethods.getZoneName(zone),
              staffCount: widget.data.visitList.length,
            ),
            customHeight(6.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              child: _PatientRow(data: widget.data),
            ),
            customHeight(8.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SvgPicture.asset(AppAsset.locationFillSvgIcon),
                  customWidth(4.w),
                  Expanded(
                    child: Text(
                      widget.data.patientAddress,
                      style: AppTextStyle.normal12style.copyWith(
                        color: AppColors.defaultTxtGrey,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            customHeight(4.h),
            if (_isPending)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ListView.builder(
                      itemCount: visibleCount,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) => ScheduleRowWidget(
                        listData: widget.data.visitList[index],
                      ),
                    ),
                    if (totalVisits > _collapsedVisitCount) ...[
                      customHeight(4.h),
                      Align(
                        alignment: Alignment.centerRight,
                        child: InkWell(
                          onTap: _openDetail,
                          child: Text(
                            '$remaining+ More',
                            style: AppTextStyle.normal12style.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryAppColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                    customHeight(10.h),
                    _ActionRow(visitId: widget.data.visitId),
                  ],
                ),
              )
            else
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.w),
                child: _StatusLine(data: widget.data, status: _status),
              ),
          ],
        ),
      ),
    );
  }
}

/// Top strip: the dark-orange note / warning banner on the left and the zone
/// label on the right.
class _BannerRow extends StatelessWidget {
  const _BannerRow({
    required this.showBanner,
    required this.note,
    required this.warning,
    required this.zoneLabel,
    required this.staffCount,
  });

  /// The note / warning chip is only part of the pending card; the zone label
  /// and avatars stay on every status.
  final bool showBanner;
  final String note;
  final String warning;
  final String zoneLabel;

  /// How many people are on the visit — drives the avatar stack. The list API
  /// does not return their photos yet, so each one falls back to the
  /// placeholder avatar.
  final int staffCount;

  static const Color _bannerColor = Color(0xffB26322);

  @override
  Widget build(BuildContext context) {
    final bool hasWarning = warning.isNotEmpty;
    final String text = showBanner ? (hasWarning ? warning : note) : '';

    return Row(
      children: [
        Expanded(
          child: text.isEmpty
              ? const SizedBox.shrink()
              : Container(
                  margin: EdgeInsets.only(left: 4.w, top: 4.h),
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: _bannerColor,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        hasWarning
                            ? Icons.warning_amber_rounded
                            : Icons.edit_note_rounded,
                        size: _RequestInfoWidgetState._bannerIconSize.w,
                        color: Colors.white,
                      ),
                      customWidth(4.w),
                      Expanded(
                        child: Text(
                          text,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyle.normal10style.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
        customWidth(12.w),
        Padding(
          padding: EdgeInsets.only(top: 4.h, right: 12.w),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (staffCount > 0) ...[
                ImageStack.providers(
                  providers: List<ImageProvider>.filled(
                    staffCount.clamp(1, 3),
                    const AssetImage(AppAsset.profilePicImg),
                  ),
                  totalCount: staffCount,
                  imageCount: 2,
                  imageRadius: 18.r,
                  imageBorderWidth: 1.5,
                  imageBorderColor: Colors.white,
                  showTotalCount: false,
                ),
                customWidth(6.w),
              ],
              Text(
                zoneLabel,
                style: AppTextStyle.normal12style.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.appYellowColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PatientRow extends StatelessWidget {
  const _PatientRow({required this.data});

  final PatientVisitModel data;

  @override
  Widget build(BuildContext context) {
    final VisitDetailsModel? firstVisit =
        data.visitList.isEmpty ? null : data.visitList.first;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: _RequestInfoWidgetState._avatarRadius.r,
          backgroundColor: Colors.transparent,
          backgroundImage: data.patientImage.isEmpty
              ? AssetImage(AppAsset.profilePicImg) as ImageProvider
              : NetworkImage(data.patientImage),
        ),
        customWidth(10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      data.patientName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.normal12style.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.defaultTxtGrey,
                      ),
                    ),
                  ),
                  if (firstVisit != null) ...[
                    customWidth(6.w),
                    _EmployeeTypeChip(
                      abbreviation: firstVisit.employeeTypeAbbreviation,
                      colorHex: firstVisit.employeeTypeColor,
                    ),
                  ],
                ],
              ),
              Text(
                '${data.genderName} | ${data.patientAge}y',
                style: AppTextStyle.normal12style.copyWith(
                  fontWeight: FontWeight.w300,
                  color: AppColors.defaultTxtGrey,
                ),
              ),
              Text(
                data.primaryDiagnosisName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.normal12style.copyWith(
                  fontWeight: FontWeight.w300,
                  color: AppColors.defaultTxtGrey,
                ),
              ),
            ],
          ),
        ),
        customWidth(8.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '2x4    | ${data.distance} miles',
              style: AppTextStyle.normal12style.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.defaultTxtGrey,
              ),
            ),
            Text(
              '\$${data.visitCharge.toStringAsFixed(2)}',
              style: AppTextStyle.normal12style.copyWith(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryAppColor,
              ),
            ),
            Text(
              data.zoneName,
              style: AppTextStyle.normal12style.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primaryAppColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _EmployeeTypeChip extends StatelessWidget {
  const _EmployeeTypeChip({required this.abbreviation, required this.colorHex});

  final String abbreviation;
  final String colorHex;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: hexToColor(colorHex),
        borderRadius: BorderRadius.circular(3.r),
      ),
      child: Text(
        abbreviation,
        style: AppTextStyle.normal10style.copyWith(
          fontSize: 8.sp,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({required this.visitId});

  final int visitId;

  static const double _buttonHeight = 30;
  static const double _buttonRadius = 6;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _buttonHeight.h,
      child: Row(
        children: [
          Expanded(
            child: PrimaryOutlinedButton(
              radius: _buttonRadius.r,
              height: _buttonHeight.h,
              borderWidth: 1.w,
              text: 'Reject',
              buttonColor: AppColors.rejectionRedColor,
              onPressed: () => Get.dialog(
                RejectDialogWidget(visitId: visitId),
                barrierColor: Colors.transparent,
                useSafeArea: false,
              ),
              textStyle: AppTextStyle.normal12style.copyWith(
                color: AppColors.rejectionRedColor,
              ),
            ),
          ),
          customWidth(8.w),
          Expanded(
            child: PrimaryOutlinedButton(
              radius: _buttonRadius.r,
              height: _buttonHeight.h,
              borderWidth: 1.w,
              text: 'Reschedule',
              buttonColor: AppColors.primaryAppColor,
              onPressed: () => Get.dialog(
                const RescheduleDialogWidget(),
                barrierColor: Colors.transparent,
                useSafeArea: false,
              ),
              textStyle: AppTextStyle.normal12style.copyWith(
                color: AppColors.primaryAppColor,
              ),
            ),
          ),
          customWidth(8.w),
          Expanded(
            child: PrimaryButton(
              onTap: () => Get.dialog(
                AcceptDialogWidget(visitId: visitId),
                barrierColor: const Color(0x4DDDDDDD),
                useSafeArea: false,
              ),
              padding: EdgeInsets.zero,
              label: 'Accept',
              height: _buttonHeight.h,
              borderRadius: _buttonRadius.r,
              labelStyle: AppTextStyle.normal12style.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Outcome line under a non-pending card: an icon, what happened and when,
/// plus the re-assignment action a rejected visit offers.
class _StatusLine extends StatelessWidget {
  const _StatusLine({required this.data, required this.status});

  final PatientVisitModel data;
  final String status;

  bool get _isRejected => status == 'rejected';

  /// A reschedule that has been asked for but not yet actioned reads as a
  /// request rather than a completed change.
  bool get _isRescheduleRequested => status == 'pending to reschedule';

  String get _label {
    if (_isRescheduleRequested) {
      return 'Pending to reschedule. Request has been generated on '
          '${data.visitTime}, ${data.visitDateTime}';
    }
    final String name = status.isEmpty
        ? ''
        : '${status[0].toUpperCase()}${status.substring(1)}';
    return '$name on ${data.visitTime}, ${data.visitDateTime}';
  }

  String get _icon {
    if (_isRejected) return AppAsset.rejectedSvgIcon;
    if (_isRescheduleRequested) return AppAsset.clockSvgIcon;
    return AppAsset.acceptedSvgIcon;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sized by height, not width: the bin is portrait (12x16) and the
            // check landscape (20x18), so a shared width makes the bin tower.
            SvgPicture.asset(_icon, height: 13.h),
            customWidth(4.w),
            Expanded(
              child: Text(
                _label,
                style: AppTextStyle.normal10style.copyWith(
                  color: AppColors.defaultTxtGrey,
                ),
              ),
            ),
          ],
        ),
        if (_isRejected) ...[
          customHeight(10.h),
          Align(
            alignment: Alignment.centerRight,
            child: PrimaryOutlinedButton(
              width: 190.w,
              height: 32.h,
              radius: 6,
              borderWidth: 1,
              text: 'Request for Re-assignment',
              buttonColor: AppColors.primaryAppColor,
              textStyle: AppTextStyle.normal12style.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.primaryAppColor,
              ),
              onPressed: () {},
            ),
          ),
        ],
      ],
    );
  }
}

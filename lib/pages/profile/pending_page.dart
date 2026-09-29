import 'package:clinician_app/core/constant/constant_import.dart';
import 'package:clinician_app/core/ui/common_appbar.dart';
import 'package:clinician_app/pages/calender_section/widget/calender_date_pick_dialog_widget.dart';
import 'package:clinician_app/pages/request/visit_detail_page.dart';
import 'package:clinician_app/utils/common_methods.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../controller/profile_controller.dart';
import '../../model/profile/patient_visitsnote_model.dart';

class PendingVisits extends StatefulWidget {
  const PendingVisits({super.key});

  @override
  State<PendingVisits> createState() => _PendingVisitsState();
}

class _PendingVisitsState extends State<PendingVisits> {
  final ProfileController controller = Get.put(ProfileController());

  @override
  void initState() {
    super.initState();
    controller.fetchPatientNoteRecord(
      empId: controller.employeeIdByEmail.value.employeeId,
      date: controller.formattedDate, // should be yyyy-MM-dd from controller getter
    );
  }

  void _fetchForCurrentDate() {
    controller.fetchPatientNoteRecord(
      empId: controller.employeeIdByEmail.value.employeeId,
      date: controller.formattedDate,
    );
  }

  DateTime? _parsePickedDate(dynamic result) {
    if (result == null) return null;
    if (result is DateTime) return result;
    if (result is String) {
      // Expecting "yyyy-MM-dd"
      return DateTime.tryParse(result);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            CommonAppbar(
              label: "Pending Visit Notes",
              padding: EdgeInsets.only(
                left: 20.w,
                right: 20.w,
                top: 15.h,
                bottom: 8.h,
              ),
            ),
            const Divider(),
            customHeight(10.h),

            // ✅ No Obx here (was causing "improper use" because no Rx was read in this builder)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: SizedBox(
                height: 34.h,
                child: Row(
                  children: [
                    customWidth(33.w),
                    const Spacer(),

                    InkWell(
                      onTap: () {
                        controller.changeDate(-1);
                        _fetchForCurrentDate();
                      },
                      child: Container(
                        width: 32.h,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.backGrndGrey,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(6.r),
                            bottomLeft: Radius.circular(6.r),
                          ),
                        ),
                        child: SvgPicture.asset(AppAsset.leftArrowSvgIcon),
                      ),
                    ),

                    customWidth(10.w),

                    Container(
                      height: 35.h,
                      padding: EdgeInsets.symmetric(
                        horizontal: 17.w,
                        vertical: 8.h,
                      ),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.backGrndGrey,
                        borderRadius: BorderRadius.circular(6.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 1.r,
                            offset: const Offset(0, 0),
                          ),
                        ],
                      ),
                      // ✅ Only Obx where Rx is actually read
                      child: Obx(
                            () => Text(
                          CommonMethods.getFormattedDay(controller.currentDate.value),
                          style: AppTextStyle.normal12style.copyWith(
                            color: AppColors.defaultTxtGrey,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),

                    customWidth(10.w),

                    InkWell(
                      onTap: () {
                        controller.changeDate(1);
                        _fetchForCurrentDate();
                      },
                      child: Container(
                        width: 32.h,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.backGrndGrey,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(6.r),
                            bottomRight: Radius.circular(6.r),
                          ),
                        ),
                        child: SvgPicture.asset(AppAsset.rightArrowSvgIcon),
                      ),
                    ),

                    const Spacer(),
                    customWidth(5.w),

                    InkWell(
                      onTap: () async {
                        final result = await Get.dialog(
                          CalenderDatePickDialogWidget(),
                        );

                        final picked = _parsePickedDate(result);
                        if (picked == null) return;

                        controller.currentDate.value = picked;

                        // If you want calendar to follow date in calendar mode
                        if (controller.contentTypeInx.value == 1) {
                          controller.calController.value.displayDate = picked;
                        }

                        _fetchForCurrentDate();
                      },
                      child: Container(
                        width: 28.w,
                        height: 28.h,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6.r),
                          border: Border.all(color: AppColors.borderGrey),
                        ),
                        child: SvgPicture.asset(
                          AppAsset.pickScheduleSvgIcon,
                          width: 14.w,
                          colorFilter: AppColors.defaultTxtGrey.getSvgColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            customHeight(10.h),

            // Example: show some header text only when list mode selected
            Obx(
                  () => Visibility(
                visible: controller.contentTypeInx.value == 0,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ✅ Use current date instead of hardcoded string
                      Text(
                        controller.formattedDateReadable, // yyyy-MM-dd
                        style: AppTextStyle.normal12style.copyWith(
                          fontWeight: FontWeight.w300,
                          color: AppColors.defaultTxtGrey,
                        ),
                      ),
                      customHeight(10.h),
                    ],
                  ),
                ),
              ),
            ),

            // Main list area
            Obx(() {
              if (controller.isEmployeeLoading.value) {
                return Expanded(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryAppColor,
                    ),
                  ),
                );
              }

              final items = controller.patientVisitNoteData.value.items;
              if (items.isEmpty) {
                return const Expanded(
                  child: Center(child: Text("No Records Found!")),
                );
              }

              return Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: ListView.builder(
                    itemCount: items.length,
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.only(bottom: 20.h),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      // TODO: You can bind real data from items[index] here
                      var visitsItem = items[index];
                      return InkWell(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        onTap: () {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            Get.to(() => VisitDetailPage(
                              isSecondLastEpisodeVisit: visitsItem.isSecondLastEpisodeVisit,
                              visitId: visitsItem.visitId,
                              employeeTypeId: visitsItem.employeeTypeId,
                              visitStatus: visitsItem.isVisitAccepted == true ? 'accepted': 'pending',
                            ));
                          });
                        },
                        child: _PendingVisitCard(visit: visitsItem),
                      );
                    },
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

/// Pending visit row: colour-coded visit-type tag down the left edge, the
/// patient and appointment time in the middle, and the visit charge on a green
/// tag down the right edge — same card language as the calendar's patient list.
class _PendingVisitCard extends StatelessWidget {
  const _PendingVisitCard({required this.visit});

  final PatientVisitItems visit;

  static const double _cardRadius = 6;

  @override
  Widget build(BuildContext context) {
    final Radius radius = Radius.circular(_cardRadius.r);
    final Color tagColor = CommonMethods.getVisitTypeColor(visit.visitType.name);

    // The shadow sits on the outer box and the rounded clip on the inner one,
    // so the clip never trims the shadow and the edge tags stay square.
    return Container(
      height: 78.h,
      margin: EdgeInsets.only(bottom: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(radius),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardBorderColor,
            blurRadius: 4.r,
            offset: Offset(0, 1.h),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.all(radius),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _edgeTag(
              color: tagColor,
              quarterTurns: 3,
              text: visit.visitType.name,
              radius: BorderRadius.only(topLeft: radius, bottomLeft: radius),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 23.r,
                      backgroundColor: Colors.transparent,
                      backgroundImage: visit.imageUrl.isEmpty
                          ? AssetImage(AppAsset.profilePicImg) as ImageProvider
                          : NetworkImage(visit.imageUrl),
                    ),
                    customWidth(10.w),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            visit.patientName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyle.regular12style.copyWith(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              height: 1.4,
                              color: AppColors.calenderTxtBlack,
                            ),
                          ),
                          Text(
                            visit.primaryDiagnosis.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyle.regular12style.copyWith(
                              fontWeight: FontWeight.w300,
                              height: 1.4,
                              color: AppColors.defaultTxtGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    customWidth(8.w),
                    Text(
                      '${visit.visiteDateTimeFrom}-${visit.visitDateTimeTo}',
                      style: AppTextStyle.regular12style.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppColors.calenderTxtBlack,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _edgeTag(
              color: AppColors.priceTagGreen,
              quarterTurns: 1,
              text: '\$${visit.visitCharge.toStringAsFixed(2)}',
              radius: BorderRadius.only(topRight: radius, bottomRight: radius),
            ),
          ],
        ),
      ),
    );
  }

  Widget _edgeTag({
    required Color color,
    required int quarterTurns,
    required String text,
    required BorderRadiusGeometry radius,
  }) {
    return Container(
      width: 25.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: color, borderRadius: radius),
      child: RotatedBox(
        quarterTurns: quarterTurns,
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyle.regular10style.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

import 'package:clinician_app/core/common/hex_color_decoder.dart';
import 'package:clinician_app/core/constant/constant_import.dart';
import 'package:clinician_app/core/ui/buttons/primary_button.dart';
import 'package:clinician_app/core/ui/buttons/primary_outlined_button.dart';
import 'package:clinician_app/core/ui/common_divider.dart';
import 'package:clinician_app/pages/home/widget/chat_fab_widget.dart';
import 'package:clinician_app/pages/request/widget/accept_dialog_widget.dart';
import 'package:clinician_app/pages/request/widget/assign_assistant_dialog_widget.dart';
import 'package:clinician_app/pages/request/visit_week_detail_page.dart';
import 'package:clinician_app/pages/request/widget/reject_dialog_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../controller/profile_controller.dart';
import '../../core/common/calling_class.dart';

class VisitDetailPage extends StatefulWidget {
  final int visitId;
  final int employeeTypeId;
  final String visitStatus;
  final bool isSecondLastEpisodeVisit;
  const VisitDetailPage({super.key, required this.visitId, required this.employeeTypeId, required this.visitStatus, required this.isSecondLastEpisodeVisit});

  @override
  State<VisitDetailPage> createState() => _VisitDetailPageState();
}

class _VisitDetailPageState extends State<VisitDetailPage> {
   ProfileController controller = Get.put(ProfileController());
  @override
  void initState() {
    // TODO: implement initState
   controller.fetchVisitDetails(visitId: widget.visitId);
   controller.fetchAssistanceDropdown(clinicianEmployeeTypeId: widget.employeeTypeId);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            customHeight(14.h),
            Row(
              children: [
                customWidth(24.w),
                InkWell(
                  onTap: () {
                    Get.back();
                  },
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: AppColors.defaultTxtGrey,
                  ),
                ),
                customWidth(15.w),
                Text(
                  'Visit Details',
                  style: AppTextStyle.normal14style.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.defaultTxtGrey,
                  ),
                ),
              ],
            ),
            customHeight(14.h),
            CommonDivider(),
            customHeight(14.h),
          Obx(() {
            if (controller.isEmployeedetailsLoading.value) {
        return Expanded(
          child: Center(
            child: CircularProgressIndicator(
              color: AppColors.primaryAppColor,
            ),
          ),
        );
            }
            
            // Guard the Rxn's value, not the Rxn itself — the wrapper is
            // never null, so the old check let a null model through to the
            // `!` uses below.
            if (controller.visitDetailModel.value == null) {
        return const Expanded(
          child: Center(child: Text("No Details Found!")),
        );
            }
          return  Expanded(
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 56.w,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                  ),
                                  clipBehavior: Clip.hardEdge,
                                  child: controller.visitDetailModel.value!.patient.imageUrl.isEmpty ?
                                  Image.asset(
                                    AppAsset.profilePicImg,
                                    fit: BoxFit.cover,
                                  ):Image.network(
                                    controller.visitDetailModel.value!.patient.imageUrl,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                customWidth(10.w),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      controller.visitDetailModel.value!.patient.name,
                                      style: AppTextStyle.normal12style
                                          .copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.defaultTxtGrey,
                                          ),
                                    ),
                                    Text(
                                      controller.visitDetailModel.value!.patient.primaryDiagnosis,
                                      style: AppTextStyle.normal12style
                                          .copyWith(
                                            fontWeight: FontWeight.w300,
                                            color: AppColors.defaultTxtGrey,
                                          ),
                                    ),
                                  ],
                                ),
                                Spacer(),
                                Text(
                                  '2x4',
                                  style: AppTextStyle.normal12style.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.defaultTxtGrey,
                                  ),
                                ),
                              ],
                            ),
                            customHeight(10.h),
                            Text(
                              controller.visitDetailModel.value!.patient.summary,
                              style: AppTextStyle.normal12style,
                            ),
                            customHeight(10.h),
                            Row(
                              children: [
                                SvgPicture.asset(AppAsset.locationFillSvgIcon),
                                customWidth(4.w),
                                Expanded(
                                  child: Text(
                                    controller.visitDetailModel.value!.patient.address,
                                    style: AppTextStyle.normal12style.copyWith(
                                      color: AppColors.defaultTxtGrey,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            customHeight(10.h),
                            Text(
                              'Plan Of Care',
                              style: AppTextStyle.normal12style.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.textGreyColor,
                              ),
                            ),
                            Row(
                              children: [
                                ...List.generate(controller.visitDetailModel.value!.planOfCare.length, (index) {
                                  var list = controller.visitDetailModel.value!.planOfCare[index];
                                  return Container(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 3.h,
                                      horizontal: 3.w,
                                    ),
                                    width: 23.w,
                                    alignment: Alignment.center,
                                    margin: EdgeInsets.only(right: 2.w),
                                    decoration: BoxDecoration(
                                      color: hexToColor(list.color),
                                      borderRadius: BorderRadius.circular(2.r),
                                    ),
                                    child: Text(
                                      list.abbreviation,
                                      style: AppTextStyle.normal10style
                                          .copyWith(color: Colors.white),
                                    ),
                                  );
                                }),
                                Spacer(),
                                controller.visitDetailModel.value!.isAssistantUser == false ?
                                widget.isSecondLastEpisodeVisit == false ? PrimaryOutlinedButton(
                                  height: 35.h,
                                  onPressed: () {
                                    Get.dialog(AssignAssistantDialogWidget(visitId: widget.visitId,));
                                  },
                                  radius: 6.r,
                                  width: 155.w,
                                  borderWidth: 0.8.w,
                                  text: 'Assign to Assistant',
                                  textStyle: AppTextStyle.normal12style.copyWith(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primaryAppColor,
                                  ),
                                  padding: EdgeInsets.symmetric(),
                                  // padding: EdgeInsets.symmetric(
                                  //   horizontal: 6.w,
                                  //   vertical: 6.h,
                                  // ),
                                  icon: Icon(
                                    Icons.add,
                                    color: AppColors.primaryAppColor,
                                    size: 18,
                                  ),
                                ) : Offstage() : Offstage(),
                              ],
                            ),
                            customHeight(10.h),
                          ],
                        ),
                      ),
                    ), 
                    Container(
                      width: double.maxFinite,
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 10.h,
                      ),
                      decoration: BoxDecoration(color: Color(0xffEFF9FD)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Visit Instructions / Precautions',
                            style: AppTextStyle.normal14style.copyWith(
                              color: Colors.black,
                            ),
                          ),
                          customWidth(10.w),
                          ...List.generate(4, (index) {
                            var list = [
                              '🔒 Gate Might Be Locked – Call for Access',
                              '🚫 Avoid Strong Perfumes or Scents',
                              '🧴 Sanitize Hands Before Entry',
                              '👟 Remove Shoes Before Entering',
                            ];
                            return Text(
                              list[index],
                              style: AppTextStyle.normal12style.copyWith(
                                fontSize: 11.sp,
                                color: Color(0xff686464),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    Flexible(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 10.h,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Other Clinicians',
                              style: AppTextStyle.normal12style.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textGreyColor,
                              ),
                            ),
                            customHeight(10.h),
                            Flexible(
                              child: ListView.separated(
                                itemCount:  controller.visitDetailModel.value!.otherClinicians.length,
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                separatorBuilder: (context, index) {
                                  return customHeight(10.h);
                                },
                                itemBuilder: (context, index) {
                                  var otherClinicianData = controller.visitDetailModel.value!.otherClinicians[index];
                                  return Row(
                                    children: [
                                      SizedBox(
                                        height: 51.h,
                                        child: Stack(
                                          clipBehavior: Clip.none,
                                          children: [
                                            Container(
                                              height: 46.h,
                                              width: 46.w,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                              ),
                                              clipBehavior: Clip.hardEdge,
                                              child: otherClinicianData.imageUrl.isEmpty ?
                                              Image.asset(
                                                AppAsset.profilePicImg,
                                                fit: BoxFit.cover,
                                              ):Image.network(
                                                otherClinicianData.imageUrl,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            Positioned(
                                              right: 0,
                                              bottom: 0,
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 2.5.w,
                                                  vertical: 2.h,
                                                ),
                                                decoration: BoxDecoration(
                                                  boxShadow: [
                                                    BoxShadow(
                                                      offset: Offset(0, 0.75.h),
                                                      blurRadius: 1.5.r,
                                                      color: Colors.black
                                                          .withValues(
                                                            alpha: 0.25,
                                                          ),
                                                    ),
                                                  ],
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        3.r,
                                                      ),
                                                  color:
                                                      hexToColor(otherClinicianData.employeeTypeColor),
                                                ),
                                                child: Text(
                                                  otherClinicianData.employeeTypeAbbreviation,
                                                  style: AppTextStyle
                                                      .normal10style
                                                      .copyWith(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Colors.white,
                                                      ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      customWidth(15.w),
                                      Expanded(
                                        child: Text(
                                          otherClinicianData.name,
                                          style: AppTextStyle.normal12style
                                              .copyWith(
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.defaultTxtGrey,
                                              ),
                                        ),
                                      ),
                                      customWidth(8.h),
                                      InkWell(
                                        onTap:(){
                                          InitiateClass().CallInitiateFunction(
                                            context: context,
                                            participentId: [
                                              otherClinicianData.userId
                                            ],
                                            callType: 'ONE_TO_ONE',
                                            isVideo: false,
                                          );
                                         },
                                        child: SvgPicture.asset(
                                          AppAsset.callFillSvgIcon,
                                          width: 19.w,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),

                            // TODO Assign clinitian
                            // customHeight(12.h),
                            // Align(
                            //   alignment: Alignment.centerRight,
                            //   child: PrimaryOutlinedButton(
                            //     height: 35.h,
                            //     borderWidth: 0.8.w,
                            //     onPressed: () {
                            //       Get.dialog(AssignRequestClinitianDialogWidget());
                            //     },
                            //     radius: 6.r,
                            //     width: 150.w,
                            //     text: 'Request For Clinician',
                            //     padding: EdgeInsets.symmetric(),
                            //     // padding: EdgeInsets.symmetric(
                            //     //   horizontal: 6.w,
                            //     //   vertical: 6.h,
                            //     // ),
                            //     icon: Icon(
                            //       Icons.add,
                            //       color: AppColors.primaryAppColor,
                            //       size: 15,
                            //     ),
                            //   ),
                            // ),
                            customHeight(12.h),
            
                            Flexible(
                              child: ListView.separated(
                                itemCount:  controller.visitDetailModel.value!.weeks.length,
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                separatorBuilder: (context, index) {
                                  return CommonDivider();
                                },
                                itemBuilder: (context, index) {
                                  var weekData = controller.visitDetailModel.value!.weeks[index];
                                  return InkWell(
                                    onTap: () {
                                      // if (index < 2) {
                                      //   Get.to(() => VisitDocUploadPage());
                                      // }
                                    },
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        customHeight(8.h),
                                        Row(
                                          children: [
                                            Text(
                                              'Week ${weekData.weekNo}',
                                              style: AppTextStyle.normal12style
                                                  .copyWith(
                                                    fontWeight: FontWeight.w600,
                                                    color:
                                                        AppColors
                                                            .defaultTxtGrey,
                                                  ),
                                            ),
                                            customWidth(5.w),
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                vertical: 2.h,
                                                horizontal: 8.w,
                                              ),
                                              // width: 15.w,
                                              alignment: Alignment.center,
                                              margin: EdgeInsets.only(
                                                right: 2.w,
                                              ),
                                              decoration: BoxDecoration(
                                                color: AppColors.chatGreenColor,
                                                borderRadius:
                                                    BorderRadius.circular(2.r),
                                              ),
                                              child: Text(
                                                weekData.socLabel,
                                                style: AppTextStyle
                                                    .normal10style
                                                    .copyWith(
                                                      fontSize: 7.sp,
                                                      color: Colors.white,
                                                    ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        customHeight(8.h),
                                        ...List.generate(weekData.items.length, (inx) {
                                          return InkWell(
                                            onTap: () => Get.to(
                                              () => VisitWeekDetailPage(
                                                visitNumber: inx + 1,
                                                weekNumber: weekData.weekNo,
                                                socLabel: weekData.socLabel,
                                                patient: controller
                                                    .visitDetailModel
                                                    .value!
                                                    .patient,
                                                visitId:
                                                    weekData.items[inx].visitId,
                                              ),
                                            ),
                                            child: Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 4.w,
                                              vertical: 4.h,
                                            ),
                                            child: Row(
                                              children: [
                                                SvgPicture.asset(
                                                  AppAsset.scheduleSvgIcon,
                                                  width: 15.w,
                                                  colorFilter:
                                                      AppColors
                                                              .greenColor
                                                              .getSvgColor
            
                                                ),
                                                customWidth(8.5.w),
                                                Text(
                                                  weekData.items[inx].date,
                                                  style: AppTextStyle
                                                      .normal12style
                                                      .copyWith(
                                                        color:
                                                        inx > 2
                                                                ? AppColors
                                                                    .defaultTxtGrey
                                                                : inx == 2
                                                                ? AppColors
                                                                    .greenColor
                                                                : AppColors
                                                                    .greyColor,
                                                      ),
                                                ),
                                                customWidth(7.w),
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                    vertical: 3.h,
                                                    horizontal: 3.w,
                                                  ),
                                                  width: 17.w,
                                                  alignment: Alignment.center,
                                                  margin: EdgeInsets.only(
                                                    right: 2.w,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        AppColors
                                                            .appYellowColor,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          2.r,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    weekData.items[inx].employeeTypeAbbreviation,
                                                    style: AppTextStyle
                                                        .normal10style
                                                        .copyWith(
                                                          fontSize: 7.sp,
                                                          color: Colors.white,
                                                        ),
                                                  ),
                                                ),
                                                Spacer(),
                                                  weekData.items[inx].isCompleted ?  SvgPicture.asset(
                                                    AppAsset.checkDoneSvgIcon,
                                                    colorFilter:
                                                        ColorFilter.mode(
                                                          AppColors.hintGrey,
                                                          BlendMode.srcIn,
                                                        ),
                                                  ) : Offstage(),
                                                  customWidth(5.w),
                                                Text(
                                                  weekData.items[inx].timeRange,
                                                  style: AppTextStyle
                                                      .normal12style
                                                      .copyWith(
                                                        color:
                                                        inx > 2
                                                                ? AppColors
                                                                    .defaultTxtGrey
                                                                : inx == 2
                                                                ? AppColors
                                                                    .greenColor
                                                                : AppColors
                                                                    .greyColor,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          );
                                        }),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );}),
          ],
        ),
      ),
      floatingActionButton: ChatFABWidget(),
      bottomNavigationBar: widget.visitStatus == 'pending' ? Container(
        height: 100.h,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.defaultTxtGrey)),
        ),
        alignment: Alignment.topCenter,
        child: Container(
          height: 38.h,
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          margin: EdgeInsets.only(top: 10.h),
          child: Row(
            children: [
              Expanded(
                child: PrimaryOutlinedButton(
                  radius: 6.r,
                  text: 'Reject',
                  buttonColor: AppColors.rejectionRedColor,
                  onPressed: () {
                    Get.dialog(
                      RejectDialogWidget(visitId: widget.visitId),
                      barrierColor: Colors.transparent,
                      useSafeArea: false,
                    );
                  },
                  textStyle: AppTextStyle.normal12style.copyWith(
                    color: AppColors.rejectionRedColor,
                  ),
                ),
              ),
              customWidth(5.w),
              // Expanded(
              //   child: PrimaryOutlinedButton(
              //     radius: 6.r,
              //     text: 'Reschedule',
              //     buttonColor: AppColors.primaryAppColor,
              //     onPressed: () {
              //       Get.dialog(RescheduleDialogWidget());
              //     },
              //     textStyle: AppTextStyle.normal12style.copyWith(
              //       color: AppColors.primaryAppColor,
              //     ),
              //   ),
              // ),
              customWidth(5.w),
              Expanded(
                child: PrimaryButton(
                  onTap: () {
                    Get.dialog(
                      AcceptDialogWidget(visitId: widget.visitId),
                      barrierColor: const Color(0x4DDDDDDD),
                      useSafeArea: false,
                    );
                  },
                  padding: EdgeInsets.all(0),
                  label: 'Accept',
                  borderRadius: 6.r,
                  labelStyle: AppTextStyle.normal12style.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  buttonColor: Color(0xff2ED8B6),
                ),
              ),
            ],
          ),
        ),
      ) : Offstage(),
    );
  }
}

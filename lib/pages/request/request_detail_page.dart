import 'package:clinician_app/core/constant/constant_import.dart';
import 'package:clinician_app/core/ui/buttons/primary_button.dart';
import 'package:clinician_app/core/ui/buttons/primary_outlined_button.dart';
import 'package:clinician_app/core/ui/common_divider.dart';
import 'package:clinician_app/model/request/request_data_model.dart';
import 'package:clinician_app/pages/home/widget/chat_fab_widget.dart';
import 'package:clinician_app/pages/request/widget/accept_dialog_widget.dart';
import 'package:clinician_app/pages/request/widget/reject_dialog_widget.dart';
import 'package:clinician_app/pages/request/widget/reschedule_dialog_widget.dart';
import 'package:clinician_app/pages/request/widget/schedule_row_widget.dart';
import 'package:clinician_app/pages/request/widget/start_or_miss_visit_dialog_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../controller/home_controller.dart';
import '../../controller/profile_controller.dart';
import '../../core/common/hex_color_decoder.dart';
import '../../main.dart';
import '../../services/token_manager/token_manager_service.dart';
import '../oasis_form_builder/model/chart_patient_referral_data_model.dart';
import '../oasis_form_builder/model/patient_form_model.dart';
import '../oasis_form_builder/oasis_form_mapper.dart';
import '../oasis_form_builder/services/api/managers/patient_form_manager.dart';

class RequestDetailPage extends StatefulWidget {
  const RequestDetailPage({super.key, required this.visitId, required this.noteText, required this.filterText, required this.chartNo});
  final int visitId;
  final String filterText;
  final String noteText;
  final int chartNo;


  @override
  State<RequestDetailPage> createState() => _RequestDetailPageState();
}

class _RequestDetailPageState extends State<RequestDetailPage> with RouteAware {
  // ProfileController controller = Get.put(ProfileController());
   HomeController homeController = Get.put(HomeController());
  @override
  void initState() {
    // TODO: implement initState
    // controller.fetchVisitDetails(visitId: widget.visitId);
    homeController.fetchPatientScheduleData(visitId: widget.visitId);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // Called whenever a route pushed on top of this page is popped and this
    // page becomes visible again — reload so the list reflects any changes
    // made on the screen that was just closed.
    homeController.fetchPatientScheduleData(visitId: widget.visitId);
  }
   Future<void> _onTap({
     required int patientFormId,
     required int ptId,
     required int chartNo,
   }) async {
     // setState(() => _isStartingVisit = true);

     try {
       final result = await getPatientFormByPatientID(
         context,
         patientFormId: patientFormId,
       );
       // String userRole = await TokenManager.getUserStatus();

       // if (!mounted) return;
       // setState(() => _isStartingVisit = false);

       // ✅ Guard: bail out if result or critical data is null
       if (result == null) {
         debugPrint('_onTap: result is null — aborting navigation');
         // _showErrorSnackbar('Could not load patient form. Please try again.');
         return;
       }

       print('patinet DOB ${result.referralData.patientDob }');
       Navigator.pop(context);
       Navigator.push(
         context,
         MaterialPageRoute(
           builder: (_) => OasisFormMapper(
             form: PatientForm(
               formID: result.formId,
               formName: result.formName,
               fillStatus: result.status,
               subForms: result.subForms
                   .map((e) => PatientSubForm(
                   formID: result.formId,
                   subFormID: e.id,
                   subFormName: e.subFormName,
                   patientFormID: result.patientFormId,
                   fillStatus: e.isFilled,
                   commentCount: e.comment_count
               ))
                   .toList(),
             ),
             subForm: PatientSubForm(
               formID: result.formId,
               subFormID: result.subForms.isNotEmpty ? result.subForms.first.id : 0,
               subFormName: result.subForms.isNotEmpty ? result.subForms.first.subFormName : '',
               patientFormID: result.patientFormId,
               commentCount: result.subForms.isNotEmpty ? result.subForms.first.comment_count : 0,
               fillStatus: result.subForms.isNotEmpty ? result.subForms.first.isFilled : false,
             ),
             patient: ChartPatientReferral(
               patientId: ptId,
               firstName: result.referralData.patientFirstname,
               lastName: result.referralData.patientLastname,
               contactNumber: result.referralData.patientPhone,
               address: result.referralData.patientAddress,
               imageUrl: result.referralData.patientImageUrl,
               gender: Gender(genderID: 1, genderName: 'Male'),
               dateOfBirth: DateTime.tryParse(result.referralData.patientDob ?? '') ?? DateTime.now(),
               chartNo: result.referralData.patientChartNo,
               episodes: [],
             ),
             appBarString: 'EMR - Clinical',
             userRole: 'Clinical',
           ),
         ),
       );
     } catch (e, stack) {
       debugPrint('_onTap error: $e\n$stack');
       // if (mounted) setState(() => _isStartingVisit = false);
     }
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
            (widget.noteText ?? "").isNotEmpty
                ? Container(
                  width: double.maxFinite,
                  decoration: BoxDecoration(color: AppColors.warningBackgColor),
                  padding: EdgeInsets.symmetric(vertical: 5.h),
                  child: Text(
                    widget.noteText ?? "",
                    textAlign: TextAlign.center,
                    style: AppTextStyle.regular10style.copyWith(
                      fontWeight: FontWeight.w600,
                      height: 1,
                      letterSpacing: 0,
                      color: Colors.white,
                    ),
                  ),
                )
                : CommonDivider(),
            customHeight(9.h),
          Obx((){
            if (homeController.isScheduleLoading.value) {
              return Expanded(
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryAppColor,
                  ),
                ),
              );
            }
            
            final items = homeController.patientScheduleModel == null;
            if (items == true) {
              return const Expanded(
                child: Center(child: Text("No Details Found!")),
              );
            }
            return Expanded(
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 56.w,
                          decoration: BoxDecoration(shape: BoxShape.circle),
                          clipBehavior: Clip.hardEdge,
                           child:
                           homeController.patientScheduleModel.value.imageUrl.isEmpty ?
                          Image.asset(
                            AppAsset.profilePicImg,
                            fit: BoxFit.cover,
                          )
                              :Image.network(
                             homeController.patientScheduleModel.value.imageUrl,
                            fit: BoxFit.cover,
                          ),
                        ),
                        customWidth(10.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              homeController.patientScheduleModel.value.patientName,
                              style: AppTextStyle.normal12style.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.defaultTxtGrey,
                              ),
                            ),
                            Text(
                              homeController.patientScheduleModel.value.diagnosisName,
                              style: AppTextStyle.normal12style.copyWith(
                                fontWeight: FontWeight.w300,
                                color: AppColors.defaultTxtGrey,
                              ),
                            ),
                          ],
                        ),
                        Spacer(),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.backGrndGrey,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 7.w,
                            vertical: 4.h,
                          ),
                          child: Row(
                            children: [
                              Text(
                                '1x55=',
                                style: AppTextStyle.normal10style.copyWith(
                                  color: AppColors.grey,
                                ),
                              ),
                              customWidth(5.w),
                              Text(
                                '\$${homeController.patientScheduleModel.value.visitCharge}',
                                style: AppTextStyle.normal10style.copyWith(
                                  fontSize: 22.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.navyBlueColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Column(
                        //   crossAxisAlignment: CrossAxisAlignment.end,
                        //   children: [
                        //     Text(
                        //       '2x4    | 2.5 miles',
                        //       style: AppTextStyle.normal12style.copyWith(
                        //         fontWeight: FontWeight.w600,
                        //         color: AppColors.defaultTxtGrey,
                        //       ),
                        //     ),
                        //     Text(
                        //       '\$55.00',
                        //       style: AppTextStyle.normal12style.copyWith(
                        //         fontSize: 20.sp,
                        //         fontWeight: FontWeight.w600,
                        //         color: AppColors.primaryAppColor,
                        //       ),
                        //     ),
                        //   ],
                        // ),
                      ],
                    ),
                    customHeight(7.h),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          child: RichText(
                            text: TextSpan(
                              text: homeController.patientScheduleModel.value.zoneName,
                              style: AppTextStyle.regular12style.copyWith(
                                fontWeight: FontWeight.w600,
                                height: 1.5,
                                letterSpacing: 0,
                                color: AppColors.visitActionBlue,
                              ),
                              children: [
                                homeController.patientScheduleModel.value.inZone
                                    ? TextSpan(
                                  text: ' (In Zone)',
                                  style: AppTextStyle.regular12style.copyWith(
                                    fontWeight: FontWeight.w300,
                                    height: 1.5,
                                    letterSpacing: 0,
                                    color: AppColors.visitActionBlue,
                                  ),
                                )
                                    : TextSpan(
                                  text: ' (Out of Zone)',
                                  style: AppTextStyle.regular12style.copyWith(
                                    fontWeight: FontWeight.w300,
                                    height: 1.5,
                                    letterSpacing: 0,
                                    color: AppColors.appYellowColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    customHeight(12.h),
                    Row(
                      children: [
                        SvgPicture.asset(AppAsset.locationFillSvgIcon),
                        customWidth(4.w),
                        Text(
                          homeController.patientScheduleModel.value.address,
                          style: AppTextStyle.regular12style.copyWith(
                            fontWeight: FontWeight.w400,
                            height: 1,
                            letterSpacing: 0,
                            color: AppColors.defaultTxtGrey,
                          ),
                        ),
                      ],
                    ),
                    customHeight(10.h),
                    ListView.separated(
                      itemCount: homeController.patientScheduleModel.value.weeks.length,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      separatorBuilder: (context, index) {
                        return CommonDivider();
                      },
                      itemBuilder: (context, index) {
                        var weekItem = homeController.patientScheduleModel.value.weeks[index];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            customHeight(8.h),
                            Row(
                              children: [
                                Text(
                                  'Week ${weekItem.week}',
                                  style: AppTextStyle.regular12style.copyWith(
                                    fontWeight: FontWeight.w600,
                                    height: 1.5,
                                    letterSpacing: 0,
                                    color: AppColors.defaultTxtGrey,
                                  ),
                                ),
                                // customWidth(5.w),
                                // Container(
                                //   padding: EdgeInsets.symmetric(
                                //     vertical: 2.h,
                                //     horizontal: 8.w,
                                //   ),
                                //   // width: 15.w,
                                //   alignment: Alignment.center,
                                //   margin: EdgeInsets.only(right: 2.w),
                                //   decoration: BoxDecoration(
                                //     color: AppColors.chatGreenColor,
                                //     borderRadius: BorderRadius.circular(2.r),
                                //   ),
                                //   child: Text(
                                //     weekItem.socLabel,
                                //     style: AppTextStyle.normal10style.copyWith(
                                //       fontSize: 7.sp,
                                //       color: Colors.white,
                                //     ),
                                //   ),
                                // ),
                              ],
                            ),
                            customHeight(8.h),
                            ...List.generate(weekItem.visits.length, (index) {
                              final visit = weekItem.visits[index];
                              final isCompleted = visit.isVisitCompleted;
                              final isMissed = visit.isVisitMissed;
                              final isDisabled = isCompleted || isMissed;
                              final statusColor = isCompleted
                                  ? AppColors.chatGreenColor
                                  : isMissed
                                      ? AppColors.rejectionRedColor
                                      : null;
                              return Padding(
                                padding: EdgeInsets.only(bottom: 8.h),
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
                                  decoration: isDisabled
                                      ? BoxDecoration(
                                          color: statusColor!.withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(6.r),
                                        )
                                      : null,
                                  child: InkWell(
                                    splashColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    onTap: isDisabled
                                        ? null
                                        : widget.filterText == "accepted"  ? (){
                                            Get.dialog(StartOrMissVisitDialogWidget(visitId: weekItem.visits[index].visitId,
                                              chartNo: weekItem.chartId,patientId: weekItem.patientId,visitData: weekItem.visits[index],));
                                          } : null,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        Text(
                                          visit.visitName,
                                          style: AppTextStyle.regular12style.copyWith(
                                            fontWeight: FontWeight.w600,
                                            height: 1,
                                            letterSpacing: 0,
                                            color: isDisabled ? statusColor : AppColors.defaultTxtGrey,
                                          ),
                                        ),
                                        customHeight(8.h),
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
                                          child: Row(
                                            children: [
                                              SvgPicture.asset(AppAsset.scheduleSvgIcon, width: 15.w),
                                              customWidth(8.5.w),
                                              Text(
                                                visit.visitDate,
                                                style: AppTextStyle.regular12style.copyWith(
                                                  fontWeight: FontWeight.w400,
                                                  height: 1.5,
                                                  letterSpacing: 0,
                                                  color: AppColors.defaultTxtGrey,
                                                ),
                                              ),
                                              customWidth(2.w),
                                              Container(
                                                width: 17.w,
                                                height: 17.h,
                                                alignment: Alignment.center,
                                                margin: EdgeInsets.only(right: 2.w),
                                                decoration: BoxDecoration(
                                                  color: hexToColor(visit.employeeTypeColor),
                                                  borderRadius: BorderRadius.circular(3.r),
                                                ),
                                                child: Text(
                                                  visit.employeeTypeAbbreviation,
                                                  style: AppTextStyle.normal10style.copyWith(
                                                    fontSize: 9.sp,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              Spacer(),
                                              Text(
                                                '${visit.visitTimeFrom}-${visit.visitTimeTo}',
                                                textAlign: TextAlign.right,
                                                style: AppTextStyle.regular12style.copyWith(
                                                  fontWeight: FontWeight.w400,
                                                  height: 23 / 12,
                                                  letterSpacing: 0,
                                                  color: AppColors.defaultTxtGrey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            );}),
          ],
        ),
      ),
      floatingActionButton: ChatFABWidget(),
      bottomNavigationBar: widget.filterText == "pending" ? Container(
        height: 100.h,
        decoration: const BoxDecoration(color: Colors.white),
        alignment: Alignment.topCenter,
        child: Container(
          height: 30.h,
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
              Expanded(
                child: PrimaryOutlinedButton(
                  radius: 6.r,
                  text: 'Reschedule',
                  buttonColor: AppColors.primaryAppColor,
                  onPressed: () {
                    Get.dialog(
                      const RescheduleDialogWidget(),
                      barrierColor: Colors.transparent,
                      useSafeArea: false,
                    );
                  },
                  textStyle: AppTextStyle.normal12style.copyWith(
                    color: AppColors.primaryAppColor,
                  ),
                ),
              ),
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
      ) : Offstage()
    );
  }
}

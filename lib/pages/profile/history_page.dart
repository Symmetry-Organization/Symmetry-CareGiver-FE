import 'package:clinician_app/core/constant/app_asset.dart';
import 'package:clinician_app/core/constant/app_colors.dart';
import 'package:clinician_app/core/constant/app_text_style.dart';
import 'package:clinician_app/core/constant/static_decoration.dart';
import 'package:clinician_app/core/ui/common_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controller/time_off_controller.dart';

class HistoryPage extends StatefulWidget {
  final int employeeId;
  const HistoryPage({super.key, required this.employeeId});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final TimeController timeController = Get.put(TimeController());
  @override
  void initState() {
    timeController.fetchEmpHistoryTimeOff(employeeId: widget.employeeId);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            CommonAppbar(
              label: "View History",

              padding: EdgeInsets.only(
                left: 20.w,
                right: 20.w,
                top: 15.h,
                bottom: 8.h,
              ),
            ),
            Divider(),
            Obx(() {
              if (timeController.isLoading.value) {
                return Expanded(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryAppColor,
                    ),
                  ),
                );
              }

              final items = timeController.timeOffHistory.value.timeOffData;
              if (items.isEmpty) {
                return const Expanded(
                  child: Center(child: Text("No History Found!")),
                );
              }
           return Expanded(
              child: ListView.builder(
                itemCount:  timeController.timeOffHistory.value.timeOffData.length,
                padding: EdgeInsets.only(left: 20.w, right: 20.w, bottom: 20.h),
                itemBuilder: (context, index) {
                  final historydata = timeController.timeOffHistory.value.timeOffData[index];
                  final String status = historydata.status.toLowerCase();
                  final Color statusTextColor = status == 'approved'
                      ? AppColors.statusApprovedText
                      : status == 'rejected'
                          ? AppColors.statusRejectedText
                          : AppColors.statusPendingText;
                  final Color statusBgColor = status == 'approved'
                      ? AppColors.statusApprovedBg
                      : status == 'rejected'
                          ? AppColors.statusRejectedBg
                          : AppColors.statusPendingBg;
                  return Padding(
                    padding: EdgeInsets.only(top: 12.h),
                    child: Container(
                      padding: EdgeInsetsDirectional.symmetric(
                        horizontal: 19.w,
                        vertical: 9.h,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          width: 1,
                          color: AppColors.borderGrey,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Image.asset(AppAsset.user, height: 16.h),
                              customWidth(15.w),
                              Expanded(
                                child: Text(
                                  historydata.employeeName,
                                  style: AppTextStyle.normal12style.copyWith(
                                    color: AppColors.defaultTxtGrey,
                                  ),
                                ),
                              ),
                              Container(
                                width: 100.w,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 2.h,
                                ),

                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  color: statusBgColor,
                                ),
                                child: Center(
                                  child: Text(
                                    historydata.status.isNotEmpty
                                        ? '${historydata.status[0].toUpperCase()}${historydata.status.substring(1).toLowerCase()}'
                                        : historydata.status,
                                    textAlign: TextAlign.center,
                                    style: AppTextStyle.normal10style.copyWith(
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w500,
                                      height: 2.3,
                                      letterSpacing: 0,
                                      color: statusTextColor,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          customHeight(9.h),
                          Row(
                            children: [
                              Image.asset(AppAsset.others, height: 16.h),
                              customWidth(15.w),
                              Text(
                                historydata.timeOffTypeName,
                                style: AppTextStyle.normal12style.copyWith(
                                  color: AppColors.primaryAppColor,
                                ),
                              ),
                            ],
                          ),
                          customHeight(9.h),
                          Row(
                            children: [
                              Image.asset(AppAsset.calander, height: 16.h),
                              customWidth(15.w),
                              Expanded(
                                child:historydata.endDate.isEmpty && historydata.startDate.isEmpty ?Text(
                               "${historydata.createdAt}",
                                  style: AppTextStyle.normal12style.copyWith(
                                    color: AppColors.defaultTxtGrey,
                                  ),
                                ) :Text(
                                  historydata.endDate.isEmpty ? "${historydata.startDate}"
                                      :
                                  "${historydata.startDate}  to ${historydata.endDate}",
                                  style: AppTextStyle.normal12style.copyWith(
                                    color: AppColors.defaultTxtGrey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );}),
          ],
        ),
      ),
    );
  }
}

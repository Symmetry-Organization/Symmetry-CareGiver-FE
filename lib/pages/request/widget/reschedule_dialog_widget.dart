import 'dart:ui';

import 'package:clinician_app/core/constant/constant_import.dart';
import 'package:clinician_app/core/ui/buttons/primary_button.dart';
import 'package:clinician_app/core/ui/buttons/primary_outlined_button.dart';
import 'package:clinician_app/core/ui/primary_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class RescheduleDialogWidget extends StatefulWidget {
  const RescheduleDialogWidget({super.key});

  @override
  State<RescheduleDialogWidget> createState() => _RescheduleDialogWidgetState();
}

class _RescheduleDialogWidgetState extends State<RescheduleDialogWidget> {
  final dateTextController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
      child: ColoredBox(
        color: Colors.white30,
        child: Center(
          child: Material(
            type: MaterialType.transparency,
            child: Container(
              width: (Get.width / 1.3).w,
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: Color(0xffF9FAFB),
                borderRadius: BorderRadius.circular(6.r),
              ),

              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Reschedule',
                        style: AppTextStyle.normal12style.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Spacer(),
                      InkWell(
                        onTap: () {
                          Get.back();
                        },
                        child: SvgPicture.asset(AppAsset.closeSvgIcon),
                      ),
                    ],
                  ),
                  customHeight(18.h),
                  Text(
                    'Do you really want to \nreschedule it ?',
                    textAlign: TextAlign.center,
                    style: AppTextStyle.normal10style.copyWith(
                      fontSize: 12.sp,
                      color: AppColors.defaultTxtGrey,
                    ),
                  ),
                  customHeight(13.h),
                  SizedBox(
                    height: 35.h,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        PrimaryOutlinedButton(
                          width: 80.w,
                          height: 35.h,
                          text: 'Cancel',
                          radius: 6.r,
                          borderWidth: 1.r,
                          onPressed: () {
                            Get.back();
                          },
                          textStyle: AppTextStyle.normal10style.copyWith(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryAppColor,
                          ),
                        ),
                        customWidth(6.w),
                        PrimaryButton(
                          width: 80.w,
                          height: 35.h,
                          label: 'Save',
                          borderRadius: 6.r,
                          onTap: () {},
                          padding: EdgeInsets.zero,
                          labelStyle: AppTextStyle.normal10style.copyWith(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  customHeight(12.h),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Reason*',
                      style: AppTextStyle.normal10style.copyWith(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.defaultTxtGrey,
                      ),
                    ),
                  ),
                  customHeight(3.h),
                  PrimaryTextField(),
                  customHeight(12.h),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Scheduled on',
                      style: AppTextStyle.normal10style.copyWith(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.defaultTxtGrey,
                      ),
                    ),
                  ),
                  customHeight(3.h),
                  PrimaryTextField(
                    controller: dateTextController,
                    style: AppTextStyle.normal12style.copyWith(
                      color: AppColors.defaultTxtGrey,
                    ),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.all(12),
                      child: SvgPicture.asset(AppAsset.pickScheduleSvgIcon),
                    ),
                    onTap: () async {
                      primaryFocus?.unfocus();
                      var date = await showDatePicker(
                        context: context,
                        firstDate: DateTime(1950),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        dateTextController.text = DateFormat(
                          'dd-MM-yyyy',
                        ).format(date);
                      }
                      primaryFocus?.unfocus();
                    },
                  ),
                  customHeight(12.h),
                  PrimaryButton(
                    label: 'Submit',
                    height: 35.h,
                    width: 80.w,
                    borderRadius: 6.r,
                    onTap: () {
                      Get.back();
                    },
                    padding: EdgeInsets.all(0),
                    labelStyle: AppTextStyle.normal10style.copyWith(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

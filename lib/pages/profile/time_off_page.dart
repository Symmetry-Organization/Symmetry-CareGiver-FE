import 'package:clinician_app/controller/time_off_controller.dart';
import 'package:clinician_app/core/constant/constant_import.dart';
import 'package:clinician_app/core/ui/buttons/primary_outlined_button.dart';
import 'package:clinician_app/core/ui/common_appbar.dart';
import 'package:clinician_app/core/ui/primary_dropdown.dart';
import 'package:clinician_app/core/ui/primary_textfield.dart';
import 'package:clinician_app/pages/profile/history_page.dart';
import 'package:clinician_app/pages/time_sheet/widget/radio_button.dart';
import 'package:clinician_app/services/token_manager/token_manager_service.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/ui/const_sucess_popup.dart';
import '../../utils/validator.dart';
import '../calender_section/widget/calender_date_pick_dialog_widget.dart';

class TimeOffPage extends StatefulWidget {
  final int employeeId;
  const TimeOffPage({super.key, required this.employeeId});

  @override
  State<TimeOffPage> createState() => _TimeOffPageState();
}

class _TimeOffPageState extends State<TimeOffPage> {
  TimeController timeController = Get.put(TimeController());
  TextEditingController fullNameController = TextEditingController();
  TextEditingController pickDate = TextEditingController();
  TextEditingController lastDate = TextEditingController();
  TextEditingController reasonController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // ✅ Manual validation state for the two dropdowns.
  // We intentionally do NOT let PrimaryDropDown's internal `errorText`
  // render (validator is a no-op below). That's because dropdown_button2's
  // popup menu position is calculated using the field's rendered size —
  // when the internal errorText adds height below the button, the menu
  // opens offset by that extra height, causing it to appear far below the
  // field instead of right under it. Showing the error as a separate Text
  // widget keeps the dropdown's own height constant, so the menu always
  // opens in the right place.
  final RxnString timeOffTypeError = RxnString(null);
  final RxnString leaveTypeError = RxnString(null);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CommonAppbar(
                label: "Time Off",
                trailing: InkWell(
                  onTap: () {},
                  child: InkWell(
                    onTap: () {
                      Get.to(() => HistoryPage(employeeId:widget.employeeId,));
                    },
                    child: Row(
                      children: [
                        Icon(
                          Icons.history,
                          size: 20,
                          color: AppColors.defaultTxtGrey,
                        ),
                        customWidth(5.w),
                        Text(
                          "View history ",
                          style: TextStyle(color: AppColors.defaultTxtGrey),
                        ),
                      ],
                    ),
                  ),
                ),
                padding: EdgeInsets.only(
                  left: 20.w,
                  right: 20.w,
                  top: 15.h,
                  bottom: 8.h,
                ),
              ),
              Divider(),
              customHeight(15.h),
              Obx(
                    () => Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15.w),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 50.h,
                            decoration: BoxDecoration(
                              color: AppColors.primaryAppColor.withValues(
                                alpha: 0.2,
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: Text(
                                    "Available Time Off",
                                    style: AppTextStyle.bold14style.copyWith(
                                      color: AppColors.timeOffAvailableBlue,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                                customWidth(10.w),
                                Text(
                                  "36.0 hours",
                                  style: AppTextStyle.bold14style.copyWith(
                                    color: AppColors.timeOffAvailableBlue,
                                    fontSize: 24.sp,
                                    fontWeight: FontWeight.w700,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          customHeight(24.h),
                          Text(
                            "Request time off",
                            style: AppTextStyle.bold14style.copyWith(
                              fontSize: 18.sp,
                            ),
                          ),
                          customHeight(20.h),
                          Text("Full Name", style: AppTextStyle.bold14style),
                          customHeight(4.h),
                          PrimaryTextField(hintText: "Enter full name",
                            readonly: true,
                            controller: TextEditingController(text: TokenManager.getUserName()),
                            validator: (value) => Validators.validateRequired(value!,'Full Name'),),
                          customHeight(18.h),
                          Text("Time off type", style: AppTextStyle.bold14style),
                          customHeight(4.h),
                          SizedBox(
                            width: double.infinity,
                            child: Obx(() {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  PrimaryDropDown(
                                    // No FormField errorText here on purpose —
                                    // see comment above on why.
                                    validator: (value) => null,
                                    contentPadding: EdgeInsets.zero,
                                    filled: false,
                                    value: timeController.timeOfType.value,
                                    buttonStyleData: ButtonStyleData(
                                      width: 120.w,
                                      height: 44.h,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: AppColors.borderGrey),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                    hintText:  "Select time off type",
                                    items: timeController.timeOfftype.map((item) {
                                      return DropdownMenuItem<String>(
                                        value: item.name ?? '',
                                        child: Padding(
                                          padding:  EdgeInsets.all(8.h),
                                          child: Text(
                                            item.name,
                                            style: AppTextStyle.normal12style
                                                .copyWith(
                                              fontWeight: FontWeight.w400,
                                              color: AppColors.defaultTxtGrey,
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      for (var a in timeController.timeOfftype) {
                                        if (a.name == value) {
                                          timeController.timeOfType.value = value ?? '';
                                          timeController.timeOfTypeId.value = a.id ?? 0;
                                        }
                                      }
                                      if (value != null && value.isNotEmpty) {
                                        timeOffTypeError.value = null;
                                      }
                                    },
                                  ),
                                  if (timeOffTypeError.value != null) ...[
                                    SizedBox(height: 6.h),
                                    Text(
                                      timeOffTypeError.value!,
                                      style: AppTextStyle.normal12style.copyWith(
                                        fontSize: 10.sp,
                                        color: AppColors.redColor,
                                      ),
                                    ),
                                  ],
                                ],
                              );
                            }),
                          ),
                          customHeight(18.h),
                          Text("Leave Type", style: AppTextStyle.bold14style),
                          customHeight(4.h),
                          SizedBox(
                            width: double.infinity,
                            child: Obx(() {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  PrimaryDropDown(
                                    validator: (value) => null,
                                    contentPadding: EdgeInsets.zero,
                                    filled: false,
                                    value: timeController.leaveType.value,
                                    buttonStyleData: ButtonStyleData(
                                      width: 120.w,
                                      height: 44.h,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: AppColors.borderGrey),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                    hintText:  "Select leave type",
                                    items: timeController.leaveTypeRecord.map((item) {
                                      return DropdownMenuItem<String>(
                                        value: item.name ?? '',
                                        child: Padding(
                                          padding:  EdgeInsets.all(8.h),
                                          child: Text(
                                            item.name,
                                            style: AppTextStyle.normal12style
                                                .copyWith(
                                              fontWeight: FontWeight.w400,
                                              color: AppColors.defaultTxtGrey,
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      for (var a in timeController.leaveTypeRecord) {
                                        if (a.name == value) {
                                          timeController.leaveType.value = value ?? '';
                                          timeController.leaveTypeId.value = a.id ?? 0;
                                        }
                                      }
                                      if (value != null && value.isNotEmpty) {
                                        leaveTypeError.value = null;
                                      }
                                    },
                                  ),
                                  if (leaveTypeError.value != null) ...[
                                    SizedBox(height: 6.h),
                                    Text(
                                      leaveTypeError.value!,
                                      style: AppTextStyle.normal12style.copyWith(
                                        fontSize: 10.sp,
                                        color: AppColors.redColor,
                                      ),
                                    ),
                                  ],
                                ],
                              );
                            }),
                          ),

                          if (timeController.leaveType.value == "One day") ...[
                            customHeight(18.h),
                            Text("Date", style: AppTextStyle.bold14style),
                            customHeight(4.h),

                            PrimaryTextField(
                              validator: (value) => Validators.validateRequired(value!,'Date'),
                              hintText: "YYYY/MM/DD",
                              controller: pickDate,
                              onTap: () async{
                                final String? selectedDate =
                                await Get.dialog(CalenderDatePickDialogWidget());
                                if (selectedDate != null) {
                                  pickDate.text = selectedDate;
                                }
                              },
                              suffixIcon: Icon(Icons.calendar_month_rounded),
                            ),
                          ],
                          if (timeController.leaveType.value == "Multi days") ...[
                            customHeight(18.h),
                            Text("Date", style: AppTextStyle.bold14style),
                            customHeight(4.h),
                            Row(
                              children: [
                                Expanded(
                                  child: PrimaryTextField(
                                    hintText: "YYYY/MM/DD",
                                    validator: (value) => Validators.validateRequired(value!,'From Date'),
                                    controller: pickDate,
                                    onTap: () async{
                                      final String? selectedDate =
                                      await Get.dialog(CalenderDatePickDialogWidget());
                                      if (selectedDate != null) {
                                        pickDate.text = selectedDate;
                                      }
                                    },
                                    suffixIcon: Icon(
                                      Icons.calendar_month_rounded,
                                    ),
                                  ),
                                ),
                                customWidth(6.w),
                                Text(
                                  "To",
                                  style: AppTextStyle.bold12style.copyWith(
                                    color: AppColors.defaultTxtGrey,
                                  ),
                                ),
                                customWidth(6.w),
                                Expanded(
                                  child: PrimaryTextField(
                                    validator: (value) => Validators.validateRequired(value!,'To Date'),
                                    hintText: "YYYY/MM/DD",
                                    controller: lastDate,
                                    onTap: () async{
                                      final String? selectedDate =
                                      await Get.dialog(CalenderDatePickDialogWidget());
                                      if (selectedDate != null) {
                                        lastDate.text = selectedDate;
                                      }
                                    },
                                    suffixIcon: Icon(
                                      Icons.calendar_month_rounded,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                          if (timeController.leaveType.value == "Half day")
                            ...[
                              customHeight(18.h),
                              Container(
                                height: 36.h,
                                decoration: BoxDecoration(
                                  color: AppColors.grey.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                                  child: Row(
                                    children: [
                                      AppRadioButton(
                                        color: AppColors.primaryAppColor,
                                        groupValue: timeController.recordType.value,
                                        value: "SOC",
                                        onChanged: (v) {
                                          timeController.halfDayaLeave.value = true;
                                          timeController.recordType.value = v!;
                                        },
                                      ),
                                      customWidth(5.w),
                                      Text(
                                        "First half",
                                        style: AppTextStyle.bold14style.copyWith(
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      customWidth(20.w),
                                      AppRadioButton(
                                        color: AppColors.primaryAppColor,
                                        groupValue: timeController.recordType.value,
                                        value: "Revisit",
                                        onChanged: (v) {
                                          timeController.halfDayaLeave.value = false;
                                          timeController.recordType.value = v!;
                                        },
                                      ),
                                      customWidth(5.w),
                                      Text(
                                        "Second half",
                                        style: AppTextStyle.bold14style.copyWith(
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          customHeight(18.h),
                          Text(
                            "Reason for time off (optional) ",
                            style: AppTextStyle.bold14style,
                          ),
                          customHeight(4.h),
                          PrimaryTextField(hintText: "Enter your reason",
                              controller: reasonController),
                          customHeight(24.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: PrimaryOutlinedButton(
                                  text: "Cancel",
                                  onPressed: () {
                                    Get.back();
                                  },
                                  fillColor: Colors.white,
                                  textStyle: AppTextStyle.bold14style.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primaryAppColor,
                                  ),
                                  borderWidth: 1.5,
                                  width: double.infinity,
                                  radius: 6,
                                  height: 30.h,
                                ),
                              ),
                              customWidth(10.w),
                              Expanded(
                                child:Obx(() => timeController.isTimeOffSaveLoading.value ? Center(
                                  child: SizedBox(
                                    height: 25.h,
                                    width: 25.w,
                                    child: CircularProgressIndicator(
                                      color: AppColors.primaryAppColor,
                                    ),
                                  ),
                                ) :PrimaryOutlinedButton(
                                  text: "Submit",
                                  onPressed: () async{
                                    // Manual validation for the two dropdowns.
                                    timeOffTypeError.value =
                                    timeController.timeOfType.value.trim().isEmpty
                                        ? 'Time off Type is required'
                                        : null;
                                    leaveTypeError.value =
                                    timeController.leaveType.value.trim().isEmpty
                                        ? 'Leave Type is required'
                                        : null;

                                    final bool isFormValid = _formKey.currentState!.validate();
                                    final bool isDropdownValid = timeOffTypeError.value == null &&
                                        leaveTypeError.value == null;

                                    if (isFormValid && isDropdownValid){
                                      var response = await timeController.postTimeOffData(
                                          empId: widget.employeeId,
                                          timeOffTypeId: timeController.timeOfTypeId.value,
                                          leaveTypeId: timeController.leaveTypeId.value,
                                          startDate: pickDate.text,
                                          endDate: lastDate.text,
                                          reason: reasonController.text,
                                          leaveType: timeController.leaveType.value,
                                          firstHalf: timeController.halfDayaLeave.value
                                      );
                                      if(response.success){
                                        Navigator.pop(context);
                                        showSucessDialog(context: context,
                                            message: 'Time off added successfully',
                                            title: 'Successfully');
                                        fullNameController.clear();
                                        reasonController.clear();
                                        timeController.leaveTypeId.value = 0;
                                        timeController.leaveType.value = '';
                                        timeController.timeOfTypeId.value = 0;
                                        timeController.timeOfType.value = '';
                                        pickDate.clear();
                                        lastDate.clear();
                                        timeOffTypeError.value = null;
                                        leaveTypeError.value = null;
                                      }else{
                                        showDocErrorDialog(context: context,
                                            message: response.message,
                                            title: 'Error');
                                      }
                                    }
                                  },
                                  fillColor: AppColors.primaryAppColor,
                                  textStyle: AppTextStyle.normal14style.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                  borderWidth: 1.5,
                                  width: double.infinity,
                                  radius: 6,
                                  height: 30.h,
                                ) ),
                              ),
                            ],
                          ),
                          customHeight(48.h),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
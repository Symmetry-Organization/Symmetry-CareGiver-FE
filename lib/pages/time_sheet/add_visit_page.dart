import 'package:clinician_app/controller/visit_controller.dart';
import 'package:clinician_app/core/constant/constant_import.dart';
import 'package:clinician_app/core/ui/buttons/primary_outlined_button.dart';
import 'package:clinician_app/core/ui/common_appbar.dart';
import 'package:clinician_app/core/ui/primary_dropdown.dart';
import 'package:clinician_app/core/ui/primary_textfield.dart';
import 'package:clinician_app/pages/time_sheet/widget/radio_button.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/profile_controller.dart';
import '../../controller/timesheet_controller.dart';
import '../../core/ui/const_sucess_popup.dart';
import '../../core/ui/overlay_primary_textfield.dart';
import '../../utils/validator.dart';
import '../auth/widget/error_dailog.dart';
import '../calender_section/widget/calender_date_pick_dialog_widget.dart';

class AddVisitPage extends StatefulWidget {
  final String visitStatus;
  const AddVisitPage({super.key, required this.visitStatus});

  @override
  State<AddVisitPage> createState() => _AddVisitPageState();
}

class _AddVisitPageState extends State<AddVisitPage> {
  // Figma: labels Fira Sans 600 / 14px / 150%; inputs 400 / 12px / 19px #686464
  static const double _labelLineHeight = 1.5;
  static const double _inputFontSize = 12;
  static const double _inputLineHeight = 19;

  TextStyle get _labelStyle => AppTextStyle.bold14style.copyWith(
    fontWeight: FontWeight.w600,
    height: _labelLineHeight,
    color: AppColors.defaultTxtGrey,
  );

  TextStyle get _inputStyle => AppTextStyle.normal12style.copyWith(
    fontSize: _inputFontSize.sp,
    fontWeight: FontWeight.w400,
    height: _inputLineHeight / _inputFontSize,
    color: AppColors.defaultTxtGrey,
  );

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final addVisitController = Get.put(TimeSheetController());
  VisitController visitController = Get.find<VisitController>();
  TextEditingController visitData = TextEditingController();
  TextEditingController visitRateController = TextEditingController();
  TextEditingController visitStartTimeController = TextEditingController();
  TextEditingController visitEndTimeController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController patientNameController = TextEditingController();
  final ProfileController profileController = Get.put(ProfileController());
  bool get _isLockedRecordType =>
      widget.visitStatus == "Case Conference" ||
      widget.visitStatus == "Miscellaneous";

  @override
  void initState() {
    super.initState();
    if (_isLockedRecordType) {
      // Wait for recordTypes to be loaded, then set the value
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final match = addVisitController.recordTypes.firstWhereOrNull(
          (item) => item.recordName == widget.visitStatus,
        );
        if (match != null) {
          addVisitController.selectedRecordName.value = match.recordName ?? '';
          addVisitController.selectedRecordTypeId.value = match.recordId ?? 0;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            CommonAppbar(
              label: "Add Visit",
              labelStyle: _labelStyle,
              onTap: () {
                addVisitController.selectedRecordTypeId.value = 0;
                addVisitController.selectedRecordName.value = '';
                addVisitController.selectedMasterVisitId.value = 0;
                addVisitController.selectedMasterVisitName.value = '';
                addVisitController.selectedPatientId.value = 0;
                addVisitController.selectedPatientName.value = '';
                visitData.clear();
                visitStartTimeController.clear();
                visitEndTimeController.clear();
                locationController.clear();
                patientNameController.clear();
                visitController.status.value = '';
                visitRateController.clear();
                Get.back();
              },
            ),
            customHeight(10.h),
            Obx(
              () => Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15.w),
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      //autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _ClinicianHeader(controller: profileController),
                          customHeight(18.h),
                          Text("Record Type", style: _labelStyle),
                          customHeight(4.h),
                          SizedBox(
                            width: double.infinity,
                            child: Obx(() {
                              final isLocked =
                                  widget.visitStatus == "Case Conference" ||
                                  widget.visitStatus == "Miscellaneous";

                              return IgnorePointer(
                                ignoring: isLocked, // blocks taps when locked
                                child: PrimaryDropDown(
                                  style: _inputStyle,
                                  validator:
                                      (value) => Validators.validateRequired(
                                        addVisitController
                                            .selectedRecordName
                                            .value,
                                        'Record Type',
                                      ),
                                  contentPadding: EdgeInsets.zero,
                                  filled: false,
                                  value:
                                      addVisitController
                                              .selectedRecordName
                                              .value
                                              .isEmpty
                                          ? null
                                          : addVisitController
                                              .selectedRecordName
                                              .value,
                                  buttonStyleData: ButtonStyleData(
                                    width: 120.w,
                                    height: 44.h,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: AppColors.borderGrey,
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                  // hide arrow icon when locked
                                  iconStyleData:
                                      isLocked
                                          ? const IconStyleData(
                                            icon: SizedBox.shrink(),
                                            iconSize: 0,
                                          )
                                          : const IconStyleData(),
                                  hintText: "Select record type",
                                  items:
                                      addVisitController.recordTypes.map((
                                        item,
                                      ) {
                                        return DropdownMenuItem<String>(
                                          value: item.recordName ?? '',
                                          child: Padding(
                                            padding: EdgeInsets.all(8.h),
                                            child: Text(
                                              item.recordName,
                                              style: AppTextStyle.normal12style
                                                  .copyWith(
                                                    fontWeight: FontWeight.w400,
                                                    color:
                                                        AppColors
                                                            .defaultTxtGrey,
                                                  ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                  onChanged:
                                      isLocked
                                          ? null
                                          : (value) {
                                            for (var a
                                                in addVisitController
                                                    .recordTypes) {
                                              if (a.recordName == value) {
                                                addVisitController
                                                    .selectedRecordName
                                                    .value = value ?? '';
                                                addVisitController
                                                    .selectedRecordTypeId
                                                    .value = a.recordId ?? 0;
                                              }
                                            }
                                          },
                                ),
                              );
                            }),
                          ),
                          customHeight(18.h),
                          // Row(
                          //   children: [
                          //     AppRadioButton(
                          //       groupValue: visitController.recordType.value,
                          //       value: "SOC",
                          //       onChanged: (v) {
                          //         visitController.recordType.value = v!;
                          //       },
                          //     ),
                          //     customWidth(5.w),
                          //     Text("SOC", style: AppTextStyle.bold12style),
                          //     customWidth(12.w),
                          //     AppRadioButton(
                          //       groupValue: visitController.recordType.value,
                          //       value: "Revisit",
                          //       onChanged: (v) {
                          //         visitController.recordType.value = v!;
                          //       },
                          //     ),
                          //     customWidth(5.w),
                          //     Text("Revisit", style: AppTextStyle.bold12style),
                          //     customWidth(12.w),
                          //     AppRadioButton(
                          //       groupValue: visitController.recordType.value,
                          //       value: "Evaluation",
                          //       onChanged: (v) {
                          //         visitController.recordType.value = v!;
                          //       },
                          //     ),
                          //     customWidth(5.w),
                          //     Text("Evaluation", style: AppTextStyle.bold12style),
                          //   ],
                          // ),
                          // customHeight(18.h),

                          /// TODO Visit type commented as per requirement
                          // Text("Visit Type", style: AppTextStyle.bold14style),
                          // customHeight(4.h),
                          // SizedBox(
                          //   width: double.infinity,
                          //   child: Obx(() {
                          //     return PrimaryDropDown(
                          //       validator: (value) => Validators.validateRequired(addVisitController.selectedMasterVisitName.value,'Visit Type'),
                          //       contentPadding: EdgeInsets.zero,
                          //       filled: false,
                          //       buttonStyleData: ButtonStyleData(
                          //         width: 120.w,
                          //         height: 44.h,
                          //
                          //         decoration: BoxDecoration(
                          //           border: Border.all(color: AppColors.borderGrey),
                          //           borderRadius: BorderRadius.circular(6),
                          //         ),
                          //       ),
                          //       hintText:  "Select visit type",
                          //       // value: addVisitController.selectedRecordName.value == ''
                          //       //     ? 'Select type'
                          //       //     : addVisitController.selectedRecordName.value,
                          //       items: addVisitController.visitMaster.map((item) {
                          //         return DropdownMenuItem<String>(
                          //           value: item.typeOfVisit ?? '',
                          //           child: Padding(
                          //             padding:  EdgeInsets.all(8.h),
                          //             child: Text(
                          //               item.typeOfVisit,
                          //               style: AppTextStyle.normal12style
                          //                   .copyWith(
                          //                 fontWeight: FontWeight.w400,
                          //                 color: AppColors.defaultTxtGrey,
                          //               ),
                          //             ),
                          //           ),
                          //         );
                          //       }).toList(),
                          //       onChanged: (value) {
                          //         for (var a in addVisitController.visitMaster) {
                          //           if (a.typeOfVisit == value) {
                          //             addVisitController.selectedMasterVisitName.value = value ?? '';
                          //             addVisitController.selectedMasterVisitId.value = a.visitMasterId ?? 0;
                          //           }
                          //         }
                          //         //
                          //
                          //       },
                          //     );
                          //   }),
                          // ),
                          // customHeight(18.h),
                          widget.visitStatus == "Case Conference"
                              ? Text("Patient Name", style: _labelStyle)
                              : Offstage(),
                          widget.visitStatus == "Case Conference"
                              ? customHeight(4.h)
                              : Offstage(),
                          widget.visitStatus == "Case Conference"
                              ? SizedBox(
                                width: double.infinity,
                                child: Obx(() {
                                  return PrimarySearchOverlayField(
                                    style: _inputStyle,
                                    // show selected value in field
                                    controller: TextEditingController(
                                      text:
                                          addVisitController
                                              .selectedPatientName
                                              .value,
                                    ),
                                    validator:
                                        (_) => Validators.validateRequired(
                                          addVisitController
                                              .selectedPatientName
                                              .value,
                                          'Patient Name',
                                        ),
                                    items: addVisitController.patientMaster,

                                    // what to show in overlay row + what gets filled on select
                                    itemText: (item) => item.ptName ?? '',

                                    hintText: "Search patient",

                                    // show overlay even when empty? (optional)
                                    showWhenEmpty: true,

                                    // optional: custom filter (better safety for nulls)
                                    filter: (item, query) {
                                      final name =
                                          (item.ptName ?? '').toLowerCase();
                                      return name.contains(
                                        query.toLowerCase().trim(),
                                      );
                                    },

                                    // prefixIcon: Padding(
                                    //   padding: const EdgeInsets.all(6.0),
                                    //   child: Icon(Icons.search, size: 20), // or your svg
                                    // ),
                                    filledColor: Colors.transparent,

                                    // on select
                                    onItemSelected: (item) {
                                      addVisitController
                                          .selectedPatientName
                                          .value = item.ptName ?? '';
                                      addVisitController
                                          .selectedPatientId
                                          .value = item.ptId ?? 0;
                                      patientNameController.text = item.ptName;
                                      locationController.text =
                                          item.ptAddress ?? '';
                                    },
                                  );
                                }),
                              )
                              : Offstage(),
                          widget.visitStatus == "Case Conference"
                              ? customHeight(18.h)
                              : Offstage(),
                          widget.visitStatus == "Case Conference"
                              ? Text("Location", style: _labelStyle)
                              : Offstage(),
                          widget.visitStatus == "Case Conference"
                              ? customHeight(4.h)
                              : Offstage(),
                          widget.visitStatus == "Case Conference"
                              ? PrimaryTextField(
                                controller: locationController,
                                validator:
                                    (value) => Validators.validateRequired(
                                      value!,
                                      'Location',
                                    ),
                              )
                              : Offstage(),
                          widget.visitStatus == "Case Conference"
                              ? customHeight(18.h)
                              : Offstage(),
                          Text("Visit Date", style: _labelStyle),
                          customHeight(4.h),
                          PrimaryTextField(
                            style: _inputStyle,
                            controller: visitData,
                            validator:
                                (value) => Validators.validateRequired(
                                  value!,
                                  'Visit Date',
                                ),
                            onTap: () async {
                              final String? selectedDate = await Get.dialog(
                                CalenderDatePickDialogWidget(),
                              );
                              if (selectedDate != null) {
                                visitData.text = selectedDate;
                              }
                            },
                            suffixIcon: Icon(Icons.calendar_month_rounded),
                          ),
                          customHeight(18.h),
                          // Row(
                          //   children: [
                          //     AppRadioButton(
                          //       groupValue: visitController.zoneType.value,
                          //       value: "In",
                          //       onChanged: (v) {
                          //         visitController.zoneType.value = v!;
                          //       },
                          //     ),
                          //     customWidth(5.w),
                          //     Text("In Zone", style: AppTextStyle.bold12style),
                          //     customWidth(12.w),
                          //     AppRadioButton(
                          //       groupValue: visitController.zoneType.value,
                          //       value: "Out",
                          //       onChanged: (v) {
                          //         visitController.zoneType.value = v!;
                          //       },
                          //     ),
                          //     customWidth(5.w),
                          //     Text("Out Zone", style: AppTextStyle.bold12style),
                          //     customWidth(12.w),
                          //   ],
                          // ),
                          //
                          // customHeight(18.h),
                          Text("Visit Rate", style: _labelStyle),
                          customHeight(4.h),
                          PrimaryTextField(
                            style: _inputStyle,
                            validator:
                                (value) => Validators.validateRequired(
                                  value!,
                                  'Visit Rate',
                                ),
                            controller: visitRateController,
                          ),
                          customHeight(18.h),
                          Text("Start Time", style: _labelStyle),
                          customHeight(4.h),
                          PrimaryTextField(
                            style: _inputStyle,
                            onTap:
                                () => addVisitController.selectStartTime(
                                  context,
                                  visitStartTimeController,
                                ),
                            // onChanged: (value)=>
                            validator:
                                (value) => Validators.validateRequired(
                                  value!,
                                  'Start Time',
                                ),
                            controller: visitStartTimeController,
                            suffixIcon: Icon(
                              Icons.timer_outlined,
                              color: AppColors.primaryAppColor,
                            ),
                          ),
                          customHeight(18.h),
                          Text("End Time", style: _labelStyle),
                          customHeight(4.h),
                          PrimaryTextField(
                            style: _inputStyle,
                            onTap:
                                () => addVisitController.selectStartTime(
                                  context,
                                  visitEndTimeController,
                                ),
                            validator:
                                (value) => Validators.validateRequired(
                                  value!,
                                  'End Time',
                                ),
                            controller: visitEndTimeController,
                            suffixIcon: Icon(
                              Icons.timer_outlined,
                              color: AppColors.primaryAppColor,
                            ),
                          ),
                          customHeight(18.h),
                          Text("Status", style: _labelStyle),
                          customHeight(4.h),
                          SizedBox(
                            width: double.infinity,
                            child: PrimaryDropDown(
                              style: _inputStyle,
                              validator:
                                  (value) => Validators.validateRequired(
                                    visitController.status.value,
                                    'Status',
                                  ),
                              value: visitController.status.value,
                              hintText: 'Select status',
                              buttonStyleData: ButtonStyleData(
                                width: 120.w,
                                height: 44.h,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: AppColors.borderGrey,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              contentPadding: EdgeInsets.zero,
                              filled: false,

                              items: [
                                ...List.generate(2, (index) {
                                  var list = ['Completed', 'Ongoing'];
                                  return DropdownMenuItem(
                                    value: list[index],
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        list[index],
                                        style: AppTextStyle.normal12style
                                            .copyWith(
                                              fontWeight: FontWeight.w400,
                                              color: AppColors.defaultTxtGrey,
                                            ),
                                      ),
                                    ),
                                  );
                                }),
                              ],
                              onChanged: (value) {
                                visitController.status.value = value ?? "";
                              },
                            ),
                          ),
                          customHeight(48.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: PrimaryOutlinedButton(
                                  text: "Cancel",
                                  onPressed: () {
                                    addVisitController
                                        .selectedRecordTypeId
                                        .value = 0;
                                    addVisitController
                                        .selectedRecordName
                                        .value = '';
                                    addVisitController
                                        .selectedMasterVisitId
                                        .value = 0;
                                    addVisitController
                                        .selectedMasterVisitName
                                        .value = '';
                                    addVisitController.selectedPatientId.value =
                                        0;
                                    addVisitController
                                        .selectedPatientName
                                        .value = '';
                                    visitData.clear();
                                    visitStartTimeController.clear();
                                    visitEndTimeController.clear();
                                    locationController.clear();
                                    patientNameController.clear();
                                    visitController.status.value = '';
                                    visitRateController.clear();
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
                              customWidth(15.w),
                              Expanded(
                                child: Obx(
                                  () =>
                                      addVisitController
                                              .isVisitSaveLoading
                                              .value
                                          ? Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 17.h,
                                            ),
                                            child: CircularProgressIndicator(
                                              color: AppColors.primaryAppColor,
                                            ),
                                          )
                                          : PrimaryOutlinedButton(
                                            text: "Save",
                                            onPressed: () async {
                                              if (_formKey.currentState!
                                                  .validate()) {
                                                print(
                                                  'Select visit master id: ${addVisitController.selectedMasterVisitId.value}',
                                                );
                                                var response = await addVisitController.postAddVisitData(
                                                  data:
                                                      widget.visitStatus ==
                                                              "Case Conference"
                                                          ? {
                                                            "pt_id":
                                                                addVisitController
                                                                    .selectedPatientId
                                                                    .value,
                                                            "recordTypeId":
                                                                addVisitController
                                                                    .selectedRecordTypeId
                                                                    .value,
                                                            // "visitMasterId": addVisitController.selectedMasterVisitId.value,
                                                            "visitDate":
                                                                visitData.text,
                                                            "startTime":
                                                                visitStartTimeController
                                                                    .text,
                                                            "endTime":
                                                                visitEndTimeController
                                                                    .text,
                                                            "status":
                                                                visitController
                                                                    .status
                                                                    .value,
                                                            "location":
                                                                locationController
                                                                    .text,
                                                          }
                                                          : {
                                                            // "pt_id": addVisitController.selectedPatientId.value,
                                                            "recordTypeId":
                                                                addVisitController
                                                                    .selectedRecordTypeId
                                                                    .value,
                                                            // "visitMasterId": addVisitController.selectedMasterVisitId.value,
                                                            "visitDate":
                                                                visitData.text,
                                                            "startTime":
                                                                visitStartTimeController
                                                                    .text,
                                                            "endTime":
                                                                visitEndTimeController
                                                                    .text,
                                                            "status":
                                                                visitController
                                                                    .status
                                                                    .value,
                                                            "visitRate": int.parse(
                                                              visitRateController
                                                                  .text,
                                                            ),
                                                          },
                                                  // ptId: addVisitController.selectedPatientId.value,
                                                  // recordTypeId: addVisitController.selectedRecordTypeId.value,
                                                  // visitMasterId: addVisitController.selectedMasterVisitId.value,
                                                  // visitDate: visitData.text,
                                                  // startTime: visitStartTimeController.text,
                                                  // endTime: visitEndTimeController.text,
                                                  // status: visitController.status.value
                                                );
                                                if (response.success) {
                                                  Get.back();
                                                  showSucessDialog(
                                                    context: context,
                                                    message:
                                                        'Visit added successfully',
                                                    title: 'Successfully',
                                                  );
                                                  addVisitController
                                                      .selectedRecordTypeId
                                                      .value = 0;
                                                  addVisitController
                                                      .selectedRecordName
                                                      .value = '';
                                                  addVisitController
                                                      .selectedMasterVisitId
                                                      .value = 0;
                                                  addVisitController
                                                      .selectedMasterVisitName
                                                      .value = '';
                                                  addVisitController
                                                      .selectedPatientId
                                                      .value = 0;
                                                  addVisitController
                                                      .selectedPatientName
                                                      .value = '';
                                                  locationController.clear();
                                                  visitData.clear();
                                                  visitStartTimeController
                                                      .clear();
                                                  visitEndTimeController
                                                      .clear();
                                                  visitRateController.clear();
                                                  patientNameController.clear();
                                                  visitController.status.value =
                                                      '';
                                                } else {
                                                  showErrorDialog(
                                                    context: context,
                                                    subtitle: response.message,
                                                    title: 'Error',
                                                  );
                                                }
                                              } else {}
                                            },
                                            fillColor:
                                                AppColors.primaryAppColor,

                                            textStyle: AppTextStyle
                                                .normal14style
                                                .copyWith(
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                ),
                                            borderWidth: 1.5,
                                            width: double.infinity,
                                            radius: 6,
                                            height: 30.h,
                                          ),
                                ),
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
            ),
          ],
        ),
      ),
    );
  }
}

/// Clinician avatar + name + discipline shown above the form (Figma header).
class _ClinicianHeader extends StatelessWidget {
  const _ClinicianHeader({required this.controller});

  final ProfileController controller;

  static const double _avatarSize = 48;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final data = controller.clinitinaLoginDataModel.value;
      return Row(
        children: [
          CircleAvatar(
            radius: (_avatarSize / 2).w,
            backgroundColor: Colors.transparent,
            backgroundImage:
                data.imageUrl.isEmpty
                    ? AssetImage(AppAsset.profilePicImg) as ImageProvider
                    : NetworkImage(data.imageUrl),
          ),
          customWidth(10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.clinicianFullName,
                  style: AppTextStyle.normal12style.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.defaultTxtGrey,
                  ),
                ),
                Text(
                  data.employeeType,
                  style: AppTextStyle.normal12style.copyWith(
                    fontWeight: FontWeight.w300,
                    color: AppColors.defaultTxtGrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}

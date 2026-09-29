import 'package:clinician_app/core/constant/constant_import.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:clinician_app/core/ui/buttons/primary_button.dart';
import 'package:clinician_app/core/ui/primary_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../controller/live_map_controller.dart';
import '../../../core/ui/primary_textfield.dart';
import '../../../utils/validator.dart';

class SeeRouteDialog extends StatefulWidget {
  const SeeRouteDialog({super.key});

  @override
  State<SeeRouteDialog> createState() => _SeeRouteDialogState();
}

class _SeeRouteDialogState extends State<SeeRouteDialog> {
  final LiveMapController liveMapController = Get.put(LiveMapController());

  // ✅ Create controller once, not inside build (avoids memory leaks)
  late final TextEditingController sourceController;

  @override
  void initState() {
    super.initState();
    sourceController = TextEditingController(
      text: liveMapController.clinicianStats.value.clinician.name,
    );
  }

  @override
  void dispose() {
    sourceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        type: MaterialType.transparency,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
          margin: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.r),
            color: Colors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Select the Source and Destination \nto view the route.',
                      style: AppTextStyle.regular16style.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  customWidth(8.w),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: SvgPicture.asset(AppAsset.closeSvgIcon, width: 14.w),
                  ),
                ],
              ),
              customHeight(20.h),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(3, (index) {
                  if (index == 1) {
                    return Row(
                      children: [
                        customWidth(86.w),
                        SizedBox(
                          height: 40.h,
                          width: 2.w,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Positioned.fill(
                                top: -8.h,
                                bottom: -10.h,
                                child: Dash(
                                  length: 56.h,
                                  dashBorderRadius: 4.r,
                                  dashThickness: 2.w,
                                  direction: Axis.vertical,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }
                  return Row(
                    children: [
                      SizedBox(
                        width: 78.w,
                        child: Text(
                          index == 0 ? 'Source' : 'Destination',
                          textAlign: TextAlign.right,
                          maxLines: 1,
                          style: AppTextStyle.normal10style.copyWith(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textGreyColor,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 18.w,
                        child: index == 0
                            ? SizedBox(
                          height: 18.h,
                          child: Radio(
                            value: true,
                            groupValue: true,
                            onChanged: (value) {},
                            fillColor: const WidgetStatePropertyAll(
                              Color(0xff3A9A40),
                            ),
                            activeColor: const Color(0xff3A9A40),
                          ),
                        )
                            : SvgPicture.asset(AppAsset.locationPinSvgIcon),
                      ),
                      customWidth(12.w),
                      index == 0
                      // ================= SOURCE FIELD =================
                          ? Expanded(
                        child: SizedBox(
                          height: 37.h, // ✅ same height as dropdown
                          child: PrimaryTextField(
                            controller: sourceController,
                            readonly: true,
                            // ✅ same padding as dropdown
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 0,
                              horizontal: 8.w,
                            ),
                            // ✅ same border as dropdown
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: AppColors.borderGrey,
                                width: 1.w,
                              ),
                            ),
                            // ✅ same text style as dropdown
                            style: AppTextStyle.normal12style.copyWith(
                              fontWeight: FontWeight.w400,
                              color: AppColors.defaultTxtGrey,
                            ),
                            validator: (value) =>
                                Validators.validateRequired(
                                    value!, 'Location'),
                          ),
                        ),
                      )
                      // ================= DESTINATION FIELD =================
                          : Expanded(
                        child: Obx(() {
                          final visits = liveMapController
                              .visitsMapModel.value.visits;

                          // Keep only first occurrence of each name
                          // + remove empty/null names
                          final seen = <String>{};
                          final uniqueVisits = visits.where((v) {
                            final name = (v.patientName ?? '').trim();
                            if (name.isEmpty) return false;
                            if (seen.contains(name)) return false;
                            seen.add(name);
                            return true;
                          }).toList();

                          final names = uniqueVisits
                              .map((e) => e.patientName!)
                              .toList();
                          final selectedName = liveMapController
                              .selectedPatientName.value;
                          final safeValue = names.contains(selectedName)
                              ? selectedName
                              : null;

                          return SizedBox(
                            height: 37.h, // ✅ same height as textfield
                            child: PrimaryDropDown(
                              // ✅ same padding as textfield
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 0,
                                horizontal: 8.w,
                              ),
                              // ✅ same border as textfield
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: AppColors.borderGrey,
                                  width: 1.w,
                                ),
                              ),
                              hintText: "Select Patient",
                              value: safeValue,
                              dropdownStyleData: DropdownStyleData(
                                offset: Offset(0, -4.h),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                    color: AppColors.borderGrey,
                                  ),
                                  borderRadius: BorderRadius.vertical(
                                    bottom: Radius.circular(6.r),
                                  ),
                                ),
                              ),
                              items: [
                                for (int i = 0;
                                    i < uniqueVisits.length;
                                    i++)
                                  DropdownMenuItem<String>(
                                    value: uniqueVisits[i].patientName!,
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 20.w,
                                          child: Text(
                                            '${i + 1}',
                                            style: AppTextStyle.normal12style
                                                .copyWith(
                                              fontWeight: FontWeight.w400,
                                              color: AppColors.hintGrey,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            uniqueVisits[i].patientName!,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            // ✅ same text style as textfield
                                            style: AppTextStyle.normal12style
                                                .copyWith(
                                              fontWeight: FontWeight.w400,
                                              color: AppColors.defaultTxtGrey,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                              onChanged: (value) {
                                if (value == null) return;
                                liveMapController
                                    .selectedPatientName.value = value;

                                // If multiple visits have same name,
                                // this picks the first
                                final first = visits.firstWhere(
                                        (e) => e.patientName == value);
                                liveMapController.selectedPatientId
                                    .value = first.patientId ?? 0;
                              },
                            ),
                          );
                        }),
                      ),
                    ],
                  );
                }),
              ),
              customHeight(20.h),
              Obx(
                    () => liveMapController.isSeeRouteLoading.value
                    ? Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: 17.h, vertical: 1.h),
                  child: SizedBox(
                    width: 21.w,
                    height: 21.h,
                    child: CircularProgressIndicator(
                      color: AppColors.primaryAppColor,
                    ),
                  ),
                )
                    : PrimaryButton(
                  width: 90.w,
                  padding: EdgeInsets.symmetric(
                      horizontal: 7.w, vertical: 4.h),
                  label: 'View Route',
                  labelStyle: AppTextStyle.normal10style.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  onTap: () async {
                    if (liveMapController
                        .selectedPatientName.value.isEmpty) {
                      return;
                    }
                    await liveMapController.fetchViewRoutetMap(
                      clinitianId: liveMapController
                          .clinicianStats.value.clinician.clinicianId,
                      patientId:
                      liveMapController.selectedPatientId.value,
                    );

                    // ✅ after source/dest are set in controller
                    await liveMapController.drawRoute();

                    Get.back();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
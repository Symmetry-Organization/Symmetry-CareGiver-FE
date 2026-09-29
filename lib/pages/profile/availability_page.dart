import 'package:clinician_app/core/constant/constant_import.dart';
import 'package:clinician_app/core/ui/common_appbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controller/availability_controller.dart';
import '../../controller/profile_controller.dart';
import '../../core/common/hex_color_decoder.dart';
import 'edit_profile.dart';
import 'widgets/clock_time_picker_dialog.dart';

/// Availability — pick the days and hours the clinician can be scheduled.
class AvailabilityPage extends StatelessWidget {
  AvailabilityPage({super.key});

  final AvailabilityController controller = Get.put(AvailabilityController());
  final ProfileController profileController = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            CommonAppbar(
              label: "Availability",
              padding: EdgeInsets.only(
                left: 20.w,
                right: 20.w,
                top: 15.h,
                bottom: 8.h,
              ),
              trailing: InkWell(
                onTap: () => Get.to(
                  () => EditProfilePage(
                    employeeId: profileController.employeeId.value,
                  ),
                ),
                child: Text(
                  "Edit Profile",
                  style: AppTextStyle.regular12style.copyWith(
                    fontWeight: FontWeight.w400,
                    height: 1,
                    letterSpacing: 0,
                    color: AppColors.defaultTxtGrey,
                  ),
                ),
              ),
            ),
            const Divider(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _profileHeader(),
                    customHeight(22.h),
                    _weekStrip(),
                    customHeight(20.h),
                    _timeFields(),
                    Obx(() {
                      if (controller.formError.value.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: EdgeInsets.only(top: 8.h),
                        child: Text(
                          controller.formError.value,
                          style: AppTextStyle.normal12style.copyWith(
                            fontSize: 11.sp,
                            color: AppColors.redColor,
                          ),
                        ),
                      );
                    }),
                    customHeight(20.h),
                    _saveButton(),
                    customHeight(24.h),
                    _slotList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileHeader() {
    return Obx(() {
      final profile = profileController.clinitinaLoginDataModel.value;
      return Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 34.r,
                backgroundColor: Colors.white,
                backgroundImage: profile.imageUrl.isEmpty
                    ? AssetImage(AppAsset.profilePicImg) as ImageProvider
                    : NetworkImage(profile.imageUrl),
              ),
              Positioned(
                right: -4.w,
                bottom: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: hexToColor(profile.color),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    profile.abbreviation,
                    style: AppTextStyle.normal10style.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          customWidth(18.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.clinicianFullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.regular16style.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                    letterSpacing: 0,
                    color: AppColors.defaultTxtGrey,
                  ),
                ),
                Text(
                  "${profile.gender} | ${profile.age}y",
                  style: AppTextStyle.regular16style.copyWith(
                    fontWeight: FontWeight.w300,
                    height: 1.5,
                    letterSpacing: 0,
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

  Widget _weekStrip() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.availabilityWeekSurface,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Obx(
        () => Column(
          children: [
            Text(
              controller.monthLabel,
              style: AppTextStyle.regular12style.copyWith(
                fontWeight: FontWeight.w400,
                height: 1.5,
                letterSpacing: 0.24,
                color: Colors.black,
              ),
            ),
            customHeight(12.h),
            Row(
              children: [
                for (final DateTime date in controller.weekDates)
                  Expanded(child: _dayCell(date)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _dayCell(DateTime date) {
    final bool isSelected = controller.isWeekdaySelected(date.weekday);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => controller.toggleWeekday(date.weekday),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 2.w),
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.cardBorderColor,
                    blurRadius: 4.r,
                    offset: Offset(0, 1.h),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Text(
              DateFormat('EEE').format(date),
              style: AppTextStyle.regular10style.copyWith(
                fontWeight: FontWeight.w400,
                height: 1,
                letterSpacing: 0,
                color: AppColors.availabilityDayName,
              ),
            ),
            customHeight(8.h),
            Text(
              '${date.day}',
              style: AppTextStyle.regular10style.copyWith(
                fontWeight: FontWeight.w400,
                height: 1,
                letterSpacing: 0,
                color: AppColors.availabilityDayDate,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _timeFields() {
    return Obx(
      () => Row(
        children: [
          Expanded(
            child: _timeField(
              label: "From",
              time: controller.fromTime.value,
              onTap: () async {
                final TimeOfDay? picked = await showClockTimePicker(
                  initialTime: controller.fromTime.value,
                );
                if (picked != null) controller.fromTime.value = picked;
              },
            ),
          ),
          customWidth(14.w),
          Expanded(
            child: _timeField(
              label: "To",
              time: controller.toTime.value,
              onTap: () async {
                final TimeOfDay? picked = await showClockTimePicker(
                  initialTime: controller.toTime.value,
                );
                if (picked != null) controller.toTime.value = picked;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _timeField({
    required String label,
    required TimeOfDay? time,
    required VoidCallback onTap,
  }) {
    final bool hasValue = time != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 34.h,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          color: AppColors.availabilityFieldFill,
          border: Border.all(
            color: AppColors.availabilityFieldBorder,
            width: 0.5,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.access_time,
              size: 15.sp,
              color: AppColors.availabilityFieldText,
            ),
            customWidth(8.w),
            Text(
              label,
              style: AppTextStyle.regular10style.copyWith(
                fontWeight: FontWeight.w600,
                height: 1,
                letterSpacing: 0,
                color: AppColors.availabilityFieldText,
              ),
            ),
            customWidth(8.w),
            Container(
              width: 1,
              height: 16.h,
              color: AppColors.availabilityFieldText,
            ),
            customWidth(8.w),
            Expanded(
              child: Text(
                hasValue ? AvailabilityController.formatTime(time) : "00:00",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.regular10style.copyWith(
                  // Fira Sans has no 350 weight; 300 is the nearest it ships.
                  fontWeight: FontWeight.w300,
                  height: 1,
                  letterSpacing: 0,
                  color: hasValue
                      ? AppColors.availabilityFieldText
                      : AppColors.hintGrey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _saveButton() {
    return Obx(() {
      final bool isEditing = controller.editingSlot.value != null;
      return GestureDetector(
        onTap: controller.saveSlot,
        child: Container(
          height: 45.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.primaryAppColor,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            isEditing ? "Update" : "+ Add New",
            style: AppTextStyle.regular12style.copyWith(
              fontWeight: FontWeight.w600,
              height: 1,
              letterSpacing: 0,
              color: Colors.white,
            ),
          ),
        ),
      );
    });
  }

  Widget _slotList() {
    return Obx(
      () => Column(
        children: [
          for (final AvailabilitySlot slot in controller.slots)
            Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: _slotRow(slot),
            ),
        ],
      ),
    );
  }

  Widget _slotRow(AvailabilitySlot slot) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 38.h,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.availabilitySlotBorder),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Text(
                  slot.weekdaysLabel,
                  style: AppTextStyle.regular12style.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 1,
                    letterSpacing: 0,
                    color: AppColors.availabilityFieldText,
                  ),
                ),
                const Spacer(),
                Text(
                  slot.hoursLabel,
                  style: AppTextStyle.regular10style.copyWith(
                    // Fira Sans has no 350 weight; 300 is the nearest it ships.
                    fontWeight: FontWeight.w300,
                    height: 1,
                    letterSpacing: 0,
                    color: AppColors.availabilityFieldText,
                  ),
                ),
              ],
            ),
          ),
        ),
        PopupMenuButton<String>(
          padding: EdgeInsets.zero,
          color: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          icon: Icon(Icons.more_vert, color: AppColors.defaultTxtGrey),
          onSelected: (value) {
            if (value == 'edit') {
              controller.startEditing(slot);
            } else {
              controller.deleteSlot(slot);
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem<String>(
              value: 'edit',
              child: _menuRow(Icons.edit_outlined, "Edit"),
            ),
            PopupMenuItem<String>(
              value: 'delete',
              child: _menuRow(Icons.delete_outline, "Delete"),
            ),
          ],
        ),
      ],
    );
  }

  Widget _menuRow(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 18.sp, color: AppColors.defaultTxtGrey),
        customWidth(12.w),
        Text(
          label,
          style: AppTextStyle.normal14style.copyWith(
            color: AppColors.defaultTxtGrey,
          ),
        ),
      ],
    );
  }
}

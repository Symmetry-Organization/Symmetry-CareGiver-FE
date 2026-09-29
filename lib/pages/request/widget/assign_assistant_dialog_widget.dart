import 'package:clinician_app/core/common/hex_color_decoder.dart';
import 'package:clinician_app/core/constant/constant_import.dart';
import 'package:clinician_app/core/ui/buttons/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../controller/profile_controller.dart';
import '../../../core/ui/const_sucess_popup.dart';
import '../../../model/profile/visit_details_model.dart';

/// Figma "Assign Visit To Assistant" — a pick-list of assistants (avatar with
/// discipline badge + name); the chosen row is tinted, then Assign submits.
class AssignAssistantDialogWidget extends StatefulWidget {
  final int visitId;
  const AssignAssistantDialogWidget({super.key, required this.visitId});

  @override
  State<AssignAssistantDialogWidget> createState() =>
      _AssignAssistantDialogWidgetState();
}

class _AssignAssistantDialogWidgetState
    extends State<AssignAssistantDialogWidget> {
  ProfileController controller = Get.put(ProfileController());

  static const double _dialogRadius = 8;
  static const double _listMaxHeight = 320;

  @override
  void initState() {
    controller.emailAssistenseController.value.clear();
    controller.selectedDataId.value = 0;
    controller.selectedDataName.value = '';
    super.initState();
  }

  void _select(AssistantModel assistant) {
    controller.selectedDataId.value = assistant.employeeId;
    controller.selectedDataName.value = assistant.userName;
    controller.emailAssistenseController.value.text = assistant.personalEmail;
  }

  Future<void> _assign() async {
    final response = await controller.PostAssignAssistance(
      visitId: widget.visitId,
      EmployeeId: controller.selectedDataId.value,
    );
    if (!mounted) return;
    if (response.statusCode == 200 || response.statusCode == 201) {
      Get.back();
      showSucessDialog(
        context: context,
        message: 'Assistant assigned successfully',
        title: 'Successfully',
      );
      controller.selectedDataName.value = '';
      controller.selectedDataId.value = 0;
      controller.emailAssistenseController.value.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        type: MaterialType.transparency,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 40.w),
          padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 16.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(_dialogRadius.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Text(
                    'Assign Visit To Assistant',
                    style: AppTextStyle.normal14style.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.calenderTxtBlack,
                    ),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: Get.back,
                    child: SvgPicture.asset(AppAsset.closeSvgIcon, width: 12.w),
                  ),
                ],
              ),
              customHeight(14.h),
              Obx(() {
                final entries = <_AssistantEntry>[
                  for (final type in controller.employeeAssistantTypeModel)
                    for (final a in type.assistants)
                      _AssistantEntry(assistant: a, type: type),
                ];
                final selectedId = controller.selectedDataId.value;

                if (entries.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.h),
                    child: Center(
                      child: Text(
                        'No assistants available',
                        style: AppTextStyle.normal12style.copyWith(
                          color: AppColors.defaultTxtGrey,
                        ),
                      ),
                    ),
                  );
                }

                return ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: _listMaxHeight.h),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: entries.length,
                    separatorBuilder: (_, __) => customHeight(6.h),
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      return _AssistantRow(
                        entry: entry,
                        selected: entry.assistant.employeeId == selectedId,
                        onTap: () => _select(entry.assistant),
                      );
                    },
                  ),
                );
              }),
              customHeight(40.h),
              Obx(() {
                final bool isSelected = controller.selectedDataId.value != 0;
                if (controller.isAssistantAssignLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryAppColor,
                    ),
                  );
                }
                return Opacity(
                  opacity: isSelected ? 1.0 : 0.5,
                  child: PrimaryButton(
                    onTap: isSelected ? _assign : () {},
                    label: 'Assign',
                    width: double.infinity,
                    borderRadius: 6.r,
                    padding: EdgeInsets.symmetric(vertical: 6.h),
                    labelStyle: AppTextStyle.normal12style.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _AssistantEntry {
  const _AssistantEntry({required this.assistant, required this.type});

  final AssistantModel assistant;
  final EmployeeAssistantTypeModel type;
}

class _AssistantRow extends StatelessWidget {
  const _AssistantRow({
    required this.entry,
    required this.selected,
    required this.onTap,
  });

  final _AssistantEntry entry;
  final bool selected;
  final VoidCallback onTap;

  static const double _avatarSize = 40;
  static const double _badgeSize = 16;
  static const Color _selectedBg = Color(0xffE8F7FE);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: selected ? _selectedBg : Colors.transparent,
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Row(
          children: [
            SizedBox(
              width: _avatarSize.w,
              height: _avatarSize.w,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: (_avatarSize / 2).w,
                    backgroundImage: AssetImage(AppAsset.profilePicImg),
                  ),
                  Positioned(
                    right: -2.w,
                    bottom: -2.h,
                    child: Container(
                      width: _badgeSize.w,
                      height: _badgeSize.w,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: hexToColor(entry.type.color),
                        borderRadius: BorderRadius.circular(3.r),
                        border: Border.all(color: Colors.white, width: 1.w),
                      ),
                      child: Text(
                        entry.type.abbreviation,
                        style: AppTextStyle.normal10style.copyWith(
                          fontSize: 7.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            customWidth(12.w),
            Expanded(
              child: Text(
                entry.assistant.userName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.normal12style.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.calenderTxtBlack,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

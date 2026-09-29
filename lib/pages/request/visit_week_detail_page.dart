import 'dart:io';

import 'package:clinician_app/core/constant/constant_import.dart';
import 'package:clinician_app/core/ui/common_appbar.dart';
import 'package:clinician_app/core/ui/buttons/primary_button.dart';
import 'package:clinician_app/core/ui/buttons/primary_outlined_button.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../model/profile/visit_details_model.dart';
import '../profile/widgets/document_scan_screen.dart';

/// One visit inside a week of the plan of care, opened from a date row on the
/// visit detail screen.
class VisitWeekDetailPage extends StatefulWidget {
  const VisitWeekDetailPage({
    super.key,
    required this.visitNumber,
    required this.weekNumber,
    required this.socLabel,
    required this.patient,
    required this.visitId,
  });

  final int visitNumber;
  final int weekNumber;
  final String socLabel;
  final Patient patient;
  final int visitId;

  @override
  State<VisitWeekDetailPage> createState() => _VisitWeekDetailPageState();
}

class _VisitWeekDetailPageState extends State<VisitWeekDetailPage> {
  /// Photos captured for this visit. Local only — there is no attachment
  /// endpoint yet.
  final List<File> _photos = <File>[];
  final List<File> _physicianOrders = <File>[];
  final TextEditingController _noteController = TextEditingController();
  File? _audio;
  bool _showNote = false;
  bool _showPhysicianOrder = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            CommonAppbar(
              label: "Visit - ${widget.visitNumber}",
              padding: EdgeInsets.only(
                left: 20.w,
                right: 20.w,
                top: 15.h,
                bottom: 8.h,
              ),
            ),
            const Divider(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    customHeight(16.h),
                    Text(
                      "Visit ${widget.visitNumber} (Week - ${widget.weekNumber})",
                      style: AppTextStyle.regular10style.copyWith(
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                        letterSpacing: 0,
                        color: AppColors.defaultTxtGrey,
                      ),
                    ),
                    customHeight(14.h),
                    _patientRow(),
                    customHeight(18.h),
                    _addButton(),
                    if (_photos.isNotEmpty) ...[
                      customHeight(20.h),
                      _attachmentGrid(
                        files: _photos,
                        onAdd: _showImageOptions,
                        onRemove: (file) => setState(() => _photos.remove(file)),
                      ),
                    ],
                    if (_showNote) ...[
                      customHeight(20.h),
                      _noteSection(),
                    ],
                    if (_showPhysicianOrder) ...[
                      customHeight(20.h),
                      _physicianOrderSection(),
                    ],
                    customHeight(20.h),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
              child: _footerActions(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _patientRow() {
    return Row(
      children: [
        SizedBox(
          width: 38.w,
          height: 41.h,
          child: ClipOval(
            child: widget.patient.imageUrl.isEmpty
                ? Image.asset(AppAsset.profilePicImg, fit: BoxFit.cover)
                : Image.network(widget.patient.imageUrl, fit: BoxFit.cover),
          ),
        ),
        customWidth(10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.patient.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.regular12style.copyWith(
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                  letterSpacing: 0,
                  color: AppColors.defaultTxtGrey,
                ),
              ),
              Text(
                widget.patient.primaryDiagnosis,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.regular12style.copyWith(
                  fontWeight: FontWeight.w300,
                  height: 1.5,
                  letterSpacing: 0,
                  color: AppColors.defaultTxtGrey,
                ),
              ),
            ],
          ),
        ),
        customWidth(10.w),
        Container(
          width: 100.w,
          height: 22.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.socTagGreen,
            borderRadius: BorderRadius.circular(2),
          ),
          child: Text(
            widget.socLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyle.regular10style.copyWith(
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  /// What "+ Add" attaches to this visit. The options only close the sheet
  /// for now — their destinations are not defined yet.
  static const List<String> _addOptions = ['Image', 'Note', 'Physician order'];

  void _showAddOptions() {
    Get.bottomSheet(
      Container(
        color: Colors.white,
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final String option in _addOptions)
                InkWell(
                  onTap: () {
                    Get.back();
                    if (option == 'Image') _showImageOptions();
                    if (option == 'Note') setState(() => _showNote = true);
                    if (option == 'Physician order') {
                      setState(() => _showPhysicianOrder = true);
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 16.h,
                    ),
                    child: Text(
                      option,
                      style: AppTextStyle.regular16style.copyWith(
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                        letterSpacing: 0,
                        color: AppColors.visitDarkText,
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

  /// Second step of "+ Add" → Image: which kind of photo is being attached.
  /// Both tiles only close the sheet for now.
  void _showImageOptions() {
    Get.bottomSheet(
      Container(
        color: Colors.white,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Row(
              children: [
                Expanded(child: _imageOptionTile("Wound Img")),
                customWidth(16.w),
                Expanded(child: _imageOptionTile("Other Img")),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Closes the sheet, opens the camera, and keeps whatever comes back.
  Future<void> _capturePhoto() async {
    Get.back();
    final File? photo = await Get.to<File>(
      () => const DocumentScanScreen(actionLabel: "Capture"),
    );
    if (photo != null) setState(() => _photos.add(photo));
  }

  Widget _imageOptionTile(String label) {
    return InkWell(
      onTap: _capturePhoto,
      child: DottedBorder(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        borderType: BorderType.RRect,
        dashPattern: [6, 4],
        color: Color(0xffBEBEBE),
        radius: Radius.circular(6),
        strokeWidth: 1,
        child: SizedBox(
          height: 140.h,
          child: Center(
          child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 52.h,
              width: 52.w,
              decoration: BoxDecoration(
                color: Color(0xffF2F2F2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: SvgPicture.asset(
                  AppAsset.galleyImageSvgIcon,
                  height: 26.h,
                  width: 26.h,
                ),
              ),
            ),
            customHeight(10.h),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyle.regular10style.copyWith(
                fontWeight: FontWeight.w500,
                height: 1.5,
                letterSpacing: 0,
                color: AppColors.imageOptionCaption,
              ),
            ),
          ],
          ),
          ),
        ),
      ),
    );
  }

  /// Attachments two to a row, each removable, with a dashed tile to add
  /// another. Shared by the photo and physician-order sections.
  Widget _attachmentGrid({
    required List<File> files,
    required VoidCallback onAdd,
    required void Function(File file) onRemove,
  }) {
    final double tileWidth = (1.sw - 40.w - 20.w) / 2;
    return Wrap(
      spacing: 20.w,
      runSpacing: 20.h,
      children: [
        for (final File file in files)
          SizedBox(
            width: tileWidth,
            height: 140.h,
            child: _attachmentTile(file, () => onRemove(file)),
          ),
        SizedBox(
          width: tileWidth,
          height: 140.h,
          child: _addAttachmentTile(onAdd),
        ),
      ],
    );
  }

  Widget _attachmentTile(File file, VoidCallback onRemove) {
    return Stack(
      children: [
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.file(file, fit: BoxFit.cover),
          ),
        ),
        Positioned(
          top: 6.h,
          right: 6.w,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onRemove,
            child: Container(
              height: 22.w,
              width: 22.w,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close,
                size: 14.sp,
                color: AppColors.redColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _addAttachmentTile(VoidCallback onAdd) {
    return InkWell(
      onTap: onAdd,
      child: DottedBorder(
        padding: EdgeInsets.zero,
        borderType: BorderType.RRect,
        dashPattern: [6, 4],
        color: Color(0xffBEBEBE),
        radius: Radius.circular(6),
        strokeWidth: 1,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _iconPlate(size: 52, iconSize: 26),
              customHeight(10.h),
              Text(
                "+ Add New",
                style: AppTextStyle.regular10style.copyWith(
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                  letterSpacing: 0,
                  color: AppColors.imageOptionCaption,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _iconPlate({required double size, required double iconSize}) {
    return Container(
      height: size.h,
      width: size.w,
      decoration: BoxDecoration(
        color: Color(0xffF2F2F2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Center(
        child: SvgPicture.asset(
          AppAsset.galleyImageSvgIcon,
          height: iconSize.h,
          width: iconSize.h,
        ),
      ),
    );
  }

  /// Physician order upload, revealed by "+ Add" → Physician order. Shows a
  /// full-width drop zone until something is attached, then the usual grid.
  Future<void> _pickPhysicianOrder() async {
    final FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.image);
    final String? path = result?.files.single.path;
    if (path != null) setState(() => _physicianOrders.add(File(path)));
  }

  Widget _physicianOrderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "Physician Order",
          style: AppTextStyle.regular14style.copyWith(
            fontWeight: FontWeight.w500,
            height: 1.5,
            letterSpacing: 0,
            color: AppColors.visitDarkText,
          ),
        ),
        customHeight(10.h),
        if (_physicianOrders.isEmpty)
          InkWell(
            onTap: _pickPhysicianOrder,
            child: DottedBorder(
              padding: EdgeInsets.zero,
              borderType: BorderType.RRect,
              dashPattern: [6, 4],
              color: Color(0xffBEBEBE),
              radius: Radius.circular(6),
              strokeWidth: 1,
              child: SizedBox(
                height: 117.h,
                width: double.infinity,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _iconPlate(size: 78, iconSize: 38),
                      customHeight(8.h),
                      Text(
                        "Upload here",
                        style: AppTextStyle.regular10style.copyWith(
                          fontWeight: FontWeight.w500,
                          height: 1.5,
                          letterSpacing: 0,
                          color: AppColors.imageOptionCaption,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        else
          _attachmentGrid(
            files: _physicianOrders,
            onAdd: _pickPhysicianOrder,
            onRemove: (file) => setState(() => _physicianOrders.remove(file)),
          ),
      ],
    );
  }

  /// Free-text note plus an audio attachment slot, revealed by "+ Add" → Note.
  Widget _noteSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "Note",
          style: AppTextStyle.regular14style.copyWith(
            fontWeight: FontWeight.w500,
            height: 1.5,
            letterSpacing: 0,
            color: AppColors.visitDarkText,
          ),
        ),
        customHeight(10.h),
        Container(
          height: 76.h,
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.availabilitySlotBorder),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: _noteController,
            maxLines: null,
            expands: true,
            textAlignVertical: TextAlignVertical.top,
            style: AppTextStyle.regular12style.copyWith(
              color: AppColors.visitDarkText,
            ),
            decoration: InputDecoration.collapsed(
              hintText: "Add Note",
              hintStyle: AppTextStyle.regular12style.copyWith(
                color: AppColors.audioUploadText,
              ),
            ),
          ),
        ),
        customHeight(12.h),
        _audioRow(),
      ],
    );
  }

  Future<void> _pickAudio() async {
    final FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.audio);
    final String? path = result?.files.single.path;
    if (path != null) setState(() => _audio = File(path));
  }

  /// Prompt until a file is attached, then the file name in its place.
  Widget _audioRow() {
    final File? audio = _audio;
    final bool hasAudio = audio != null;
    return GestureDetector(
      onTap: _pickAudio,
      child: Container(
        height: 37.h,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          color: AppColors.audioUploadFill,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment:
              hasAudio ? MainAxisAlignment.start : MainAxisAlignment.center,
          children: [
            Icon(
              Icons.mic_none,
              size: 14.sp,
              color: AppColors.audioUploadText,
            ),
            customWidth(6.w),
            Flexible(
              child: Text(
                hasAudio
                    ? audio.path.split('/').last
                    : "Upload your audio here",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.regular10style.copyWith(
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                  letterSpacing: 0,
                  color: hasAudio
                      ? AppColors.visitDarkText
                      : AppColors.audioUploadText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _addButton() {
    return GestureDetector(
      onTap: _showAddOptions,
      child: Container(
        height: 45.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.visitAddFill,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          "+ Add",
          style: AppTextStyle.regular12style.copyWith(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.availabilityFieldBorder,
          ),
        ),
      ),
    );
  }

  Widget _footerActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PrimaryOutlinedButton(
          height: 44.h,
          radius: 6,
          borderWidth: 1,
          text: "Fill Oasis Form",
          buttonColor: AppColors.visitActionBlue,
          textStyle: AppTextStyle.regular14style.copyWith(
            fontWeight: FontWeight.w400,
            height: 1,
            letterSpacing: 0,
            color: AppColors.visitActionBlue,
          ),
          onPressed: () {},
        ),
        customHeight(12.h),
        Row(
          children: [
            Expanded(
              child: PrimaryOutlinedButton(
                height: 31.h,
                radius: 6,
                borderWidth: 1,
                text: "Cancel",
                buttonColor: AppColors.visitActionBlue,
                textStyle: AppTextStyle.regular14style.copyWith(
                  fontWeight: FontWeight.w400,
                  height: 1,
                  letterSpacing: 0,
                  color: AppColors.visitActionBlue,
                ),
                onPressed: () => Get.back(),
              ),
            ),
            customWidth(12.w),
            Expanded(
              child: PrimaryButton(
                height: 31.h,
                padding: EdgeInsets.zero,
                borderRadius: 6,
                label: "Save",
                labelStyle: AppTextStyle.regular14style.copyWith(
                  fontWeight: FontWeight.w600,
                  height: 23 / 14,
                  letterSpacing: 0,
                  color: Colors.white,
                ),
                onTap: () => Get.back(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

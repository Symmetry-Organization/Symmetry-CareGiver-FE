import 'dart:io';

import 'package:clinician_app/core/constant/constant_import.dart';
import 'package:clinician_app/core/ui/buttons/primary_button.dart';
import 'package:clinician_app/core/ui/buttons/primary_outlined_button.dart';
import 'package:clinician_app/core/ui/primary_textfield.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../controller/update_documents_controller.dart';
import '../../../core/ui/const_sucess_popup.dart';
import '../../../core/ui/primary_dropdown.dart';
import '../../calender_section/widget/calender_date_pick_dialog_widget.dart';
import 'document_scan_screen.dart';

void showAddDocumentDialog(BuildContext context,int empId) {
  UpdateDocumentsController docCtrl = Get.put(UpdateDocumentsController());
  TextEditingController expDateController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  // Manual validation state for the two dropdowns — independent of
  // Form/FormField internals, so it works regardless of how
  // PrimaryDropDown is implemented under the hood.
  final RxnString docDropdownError = RxnString(null);
  final RxnString subDocDropdownError = RxnString(null);
  Future<void> pickDocument() async {
    await docCtrl.pickPdf();
    // ✅ Clear this upload validation once a document has actually
    // been selected.
    if (docCtrl.fileName.value.isNotEmpty) {
      docCtrl.fileNameValidation.value = '';
    }
  }

  Future<void> captureDocument() async {
    final File? page = await Get.to<File>(() => const DocumentScanScreen());
    if (page != null) {
      docCtrl.addCapturedPage(page);
    }
  }

  docCtrl.clearAll();
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        insetPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        contentPadding: EdgeInsets.all(20),
        scrollable: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: StatefulBuilder(
          builder: (context, setState) {
            return SizedBox(
              width: 400,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Add New Document",
                      style: AppTextStyle.normal16style.copyWith(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.defaultTxtGrey,
                      ),
                    ),
                    SizedBox(height: 28.h),

                    Row(
                      children: [
                        Expanded(child: _docSourceLabel("Upload document")),
                        SizedBox(width: _orColumnWidth),
                        Expanded(child: _docSourceLabel("Capture document")),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        Expanded(
                          child: _docSourceBox(
                            icon: AppAsset.upload,
                            actionLabel: "Upload here",
                            onTap: pickDocument,
                          ),
                        ),
                        SizedBox(
                          width: _orColumnWidth,
                          child: Text(
                            "or",
                            textAlign: TextAlign.center,
                            style: AppTextStyle.normal14style.copyWith(
                              color: AppColors.defaultTxtGrey,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Obx(
                            () => docCtrl.capturedPages.isEmpty
                                ? _docSourceBox(
                                    icon: AppAsset.cameraSvgIcon,
                                    isSvgIcon: true,
                                    actionLabel: "Capture here",
                                    onTap: captureDocument,
                                  )
                                : _capturedPagesGrid(
                                    pages: docCtrl.capturedPages,
                                    onRemove: docCtrl.removeCapturedPage,
                                    onAdd: captureDocument,
                                  ),
                          ),
                        ),
                      ],
                    ),
                    // Selected file name, or the upload validation message —
                    // kept out of the two labels above so they stay on one
                    // line and the boxes stay aligned with each other.
                    Obx(() {
                      final bool hasError =
                          docCtrl.fileNameValidation.value.isNotEmpty;
                      final String message = hasError
                          ? docCtrl.fileNameValidation.value
                          : docCtrl.fileName.value;
                      if (message.isEmpty) return SizedBox.shrink();
                      return Padding(
                        padding: EdgeInsets.only(top: 8.h),
                        child: SizedBox(
                          width: double.infinity,
                          child: Text(
                            message,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyle.normal12style.copyWith(
                              fontSize: 11.sp,
                              color: hasError
                                  ? AppColors.redColor
                                  : AppColors.defaultTxtGrey,
                            ),
                          ),
                        ),
                      );
                    }),
                    SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: Obx(() {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            PrimaryDropDown(
                              // No Form validator here — error is fully
                              // manual via docDropdownError below, so it
                              // clears reliably the instant a value is picked.
                              validator: (value) => null,
                              contentPadding: EdgeInsets.zero,
                              filled: false,
                              value: docCtrl.selectedMasterMetaDocName.value,
                              buttonStyleData: ButtonStyleData(
                                width: 120.w,
                                height: 44.h,
                                // Zeroed out because the hint already carries
                                // its own EdgeInsets.all(8.h) (see
                                // primary_dropdown.dart) — adding padding here
                                // too would double-inset the hint relative to
                                // the selected value below.
                                padding: EdgeInsets.zero,
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppColors.borderGrey),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              hintText: docCtrl.docMetaList.isEmpty
                                  ? "No document found"
                                  : "Select document",
                              // Fixed, static list (Acknowledgements,
                              // Compensation, Health Record) — names are short
                              // and known ahead of time, so a single-line row
                              // is always enough here.
                              itemHeight: 44.h,
                              selectedItemBuilder: (context) =>
                                  docCtrl.docMetaList.map((item) {
                                    return Align(
                                      alignment: Alignment.centerLeft,
                                      // Mirrors the hint's own EdgeInsets.all(8.h)
                                      // so the selected value lines up with
                                      // where the placeholder text sat.
                                      child: Padding(
                                        padding: EdgeInsets.all(8.h),
                                        child: Text(
                                          item.documentName,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTextStyle.normal12style
                                              .copyWith(
                                            fontWeight: FontWeight.w400,
                                            color: AppColors.defaultTxtGrey,
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                              items: docCtrl.docMetaList.map((item) {
                                return DropdownMenuItem<String>(
                                  value: item.documentName ?? '',
                                  child: Padding(
                                    padding: EdgeInsets.all(8.h),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        item.documentName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTextStyle.normal12style
                                            .copyWith(
                                          fontWeight: FontWeight.w400,
                                          color: AppColors.defaultTxtGrey,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null && value.isNotEmpty) {
                                  for (var a in docCtrl.docMetaList) {
                                    if (a.documentName == value) {
                                      docCtrl.selectedSubDocId.value = 0;
                                      docCtrl.selectedSubDocName.value = '';
                                      docCtrl.docSubList.clear();
                                      docCtrl.selectedMasterMetaDocName.value = value;
                                      docCtrl.selectedMasterMetaDocId.value = a.employeeDocumentTypeMetaDataId ?? 0;
                                      docCtrl.fetchSubDocList(docMetaId:  a.employeeDocumentTypeMetaDataId );
                                    }
                                  }
                                  // ✅ Clear this field's error immediately —
                                  // this is a plain Rx write, not dependent
                                  // on any FormFieldState lookup.
                                  docDropdownError.value = null;
                                }
                              },
                            ),
                            if (docDropdownError.value != null) ...[
                              SizedBox(height: 6.h),
                              Text(
                                docDropdownError.value!,
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
                    SizedBox(height: 15.h),
                    SizedBox(
                      width: double.infinity,
                      child: Obx(() {
                        final bool hasLongSubDocName = docCtrl.docSubList.any(
                                (item) => item.documentName.length > 30);
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            PrimaryDropDown(
                              validator: (value) => null,
                              contentPadding: EdgeInsets.zero,
                              filled: false,
                              value: docCtrl.selectedSubDocName.value,
                              buttonStyleData: ButtonStyleData(
                                width: 120.w,
                                height: 44.h,
                                // Zeroed out because the hint already carries
                                // its own EdgeInsets.all(8.h) (see
                                // primary_dropdown.dart) — adding padding here
                                // too would double-inset the hint relative to
                                // the selected value below.
                                padding: EdgeInsets.zero,
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppColors.borderGrey),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              hintText: docCtrl.docMetaList.isEmpty
                                  ? "No document found"
                                  : (docCtrl.docSubList.isEmpty
                                  ? "No sub document found"
                                  : "Select sub document"),
                              itemHeight: hasLongSubDocName ? 60.h : 44.h,
                              // Same reasoning as the master-document dropdown:
                              // keep the closed button single-line even when
                              // the open menu wraps long sub-document names.
                              selectedItemBuilder: (context) =>
                                  docCtrl.docSubList.map((item) {
                                    return Align(
                                      alignment: Alignment.centerLeft,
                                      // Mirrors the hint's own EdgeInsets.all(8.h)
                                      // so the selected value lines up with
                                      // where the placeholder text sat.
                                      child: Padding(
                                        padding: EdgeInsets.all(8.h),
                                        child: Text(
                                          item.documentName,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTextStyle.normal12style
                                              .copyWith(
                                            fontWeight: FontWeight.w400,
                                            color: AppColors.defaultTxtGrey,
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                              items: docCtrl.docSubList.map((item) {
                                return DropdownMenuItem<String>(
                                  value: item.documentName ?? '',
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 8.h,vertical: 3.h),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        item.documentName,
                                        maxLines: hasLongSubDocName ? 2 : 1,
                                        overflow: TextOverflow.clip,
                                        style: AppTextStyle.normal12style
                                            .copyWith(
                                          fontWeight: FontWeight.w400,
                                          color: AppColors.defaultTxtGrey,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                for (var a in docCtrl.docSubList) {
                                  if (a.documentName == value) {
                                    docCtrl.selectedSubDocName.value = value ?? '';
                                    docCtrl.selectedSubDocId.value = a.employeeDocumentTypeSetupId ?? 0;
                                    docCtrl.isExpDateShown.value = a.expiry_type == "Issuer Expiry" ? true: false;
                                  }
                                }
                                if (value != null && value.isNotEmpty) {
                                  // ✅ Clear this field's error immediately.
                                  subDocDropdownError.value = null;
                                }
                              },
                            ),
                            if (subDocDropdownError.value != null) ...[
                              SizedBox(height: 6.h),
                              Text(
                                subDocDropdownError.value!,
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
                    SizedBox(height: 15.h),
                    // Expiry Date Field
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Expiry date of document",
                        style: AppTextStyle.bold12style.copyWith(
                          color: AppColors.defaultTxtGrey,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),

                    PrimaryTextField(
                      readonly: true,
                      controller: expDateController,
                      hintText: "Enter Expiry date of document",
                      filled: false,
                      filledColor: Colors.white,
                      borderRadius: 8,
                      contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                      hintStyle: AppTextStyle.regular12style.copyWith(
                        fontWeight: FontWeight.w400,
                        color: AppColors.hintGrey,
                      ),
                      onTap: () async{
                        FocusScope.of(Get.context!).unfocus();
                        final String? selectedDate =
                        await Get.dialog(CalenderDatePickDialogWidget());

                        if (selectedDate != null) {
                          expDateController.text = selectedDate;

                          final DateTime datePicked = DateFormat("yyyy-MM-dd").parse(selectedDate);
                          // Build UTC midnight directly from the picked
                          // Y/M/D — parsing gives local midnight, and
                          // .toUtc() on that shifts the calendar day back
                          // by one whenever the device is ahead of UTC.
                          docCtrl.expiryIsoDate.value = DateTime.utc(
                            datePicked.year,
                            datePicked.month,
                            datePicked.day,
                          ).toIso8601String();
                        }
                      },
                      suffixIcon: Padding(
                        padding: EdgeInsets.all(12.w),
                        child: SvgPicture.asset(AppAsset.documentExpiryCalenderSvgIcon),
                      ),
                    ),
                    SizedBox(height: 28.h),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Log Out Button
                        Expanded(
                          child: PrimaryOutlinedButton(
                            width: 100.w,
                            height: 31.h,
                            text: "Cancel",
                            borderWidth: 1.5,
                            radius: 8,
                            textStyle: AppTextStyle.normal12style.copyWith(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryAppColor,
                            ),
                            buttonColor: AppColors.primaryAppColor,
                            onPressed: () {
                              docCtrl.clearAll();
                              docCtrl.docSubList.clear();
                              docCtrl.selectedSubDocName.value = '';
                              docCtrl.selectedSubDocId.value = 0;
                              docDropdownError.value = null;
                              subDocDropdownError.value = null;
                              Get.back();
                            },
                          ),
                        ),
                        customWidth(12.w),
                        // Cancel Button
                        Expanded(
                          child:Obx(() => docCtrl.isDocumentSaveLoading.value ? Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primaryAppColor,
                            ),
                          ): PrimaryButton(
                            onTap: () async{
                              // Manual validation for the two dropdowns.
                              docDropdownError.value =
                              docCtrl.selectedMasterMetaDocName.value.trim().isEmpty
                                  ? 'Document is required'
                                  : null;
                              subDocDropdownError.value =
                              docCtrl.selectedSubDocName.value.trim().isEmpty
                                  ? 'Sub document is required'
                                  : null;

                              final bool isFormValid = _formKey.currentState!.validate();
                              final bool isDropdownValid = docDropdownError.value == null &&
                                  subDocDropdownError.value == null;

                              if (isFormValid && isDropdownValid){
                                // Scanned pages are merged into one PDF; an
                                // uploaded PDF is sent as picked.
                                final bool hasCapturedPages =
                                    docCtrl.capturedPages.isNotEmpty;
                                final File? uploadFile = hasCapturedPages
                                    ? await docCtrl.buildCapturedPagesPdf()
                                    : docCtrl.selectedPdfFile.value;

                                if (uploadFile == null) {
                                  if (docCtrl.fileNameValidation.value.isEmpty) {
                                    docCtrl.fileNameValidation.value =
                                        'Please upload document';
                                  }
                                  return;
                                }

                                var uploadResponse = await docCtrl.postUploadDocumentBase64Data(
                                    docMetaId: docCtrl.selectedMasterMetaDocId.value,
                                    docTypeSetupId: docCtrl.selectedSubDocId.value,
                                    empId: empId,
                                    base64File: uploadFile,
                                    documentName: hasCapturedPages
                                        ? uploadFile.path.split('/').last
                                        : docCtrl.fileName.value,
                                    expiryDate: expDateController.text.isEmpty ? null : docCtrl.expiryIsoDate.value);
                                if(uploadResponse.statusCode == 200 || uploadResponse.statusCode ==201){
                                  Get.back();
                                  docCtrl.clearAll();
                                  docCtrl.fetchDocListDetails(empId: empId, approveOnly: 'no', searchText: 'all');
                                  showSucessDialog( context: context,
                                      message: 'Document uploaded successfully.',
                                      title: 'Successfully');
                                }else{
                                  Get.back();
                                  docCtrl.clearAll();
                                  showDocErrorDialog(context: context,
                                      message: uploadResponse.message,
                                      title: 'Error');
                                }
                              }else{
                                if (docCtrl.fileName.value.isEmpty &&
                                    docCtrl.capturedPages.isEmpty) {
                                  docCtrl.fileNameValidation.value = 'Please upload document';
                                }
                              }
                            },
                            width: 100.w,
                            height: 31.h,
                            padding: EdgeInsets.zero,
                            borderRadius: 8,
                            label: "Save",
                            labelStyle: AppTextStyle.normal12style.copyWith(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          )),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    },
  );
}

/// Width reserved for the "or" separator, shared by the label row and the
/// box row below it so the two columns stay aligned with each other.
final double _orColumnWidth = 40.w;

/// Side of a captured-page thumbnail — two of them plus the gaps fill the
/// dashed frame, matching the width of the upload box beside it.
final double _capturedTileSize = 52.w;

Widget _docSourceLabel(String text) {
  return Text(
    text,
    textAlign: TextAlign.center,
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    style: AppTextStyle.bold12style.copyWith(
      fontSize: 14.sp,
      fontWeight: FontWeight.w600,
      color: AppColors.defaultTxtGrey,
    ),
  );
}

/// Captured pages laid out two to a row inside the same dashed frame, each
/// removable, with a trailing tile for scanning another page.
Widget _capturedPagesGrid({
  required List<CapturedPage> pages,
  required void Function(CapturedPage page) onRemove,
  required VoidCallback onAdd,
}) {
  return DottedBorder(
    padding: EdgeInsets.all(8.w),
    borderType: BorderType.RRect,
    dashPattern: [6, 4],
    color: Color(0xffBEBEBE),
    radius: Radius.circular(8),
    strokeWidth: 1.5,
    child: Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: [
        for (final CapturedPage page in pages)
          _capturedPageTile(page: page, onRemove: () => onRemove(page)),
        _addPageTile(onAdd),
      ],
    ),
  );
}

Widget _capturedPageTile({
  required CapturedPage page,
  required VoidCallback onRemove,
}) {
  return SizedBox(
    height: _capturedTileSize,
    width: _capturedTileSize,
    child: Stack(
      children: [
        Positioned.fill(
          child: Container(
            padding: EdgeInsets.fromLTRB(6.w, 8.h, 12.w, 6.h),
            decoration: BoxDecoration(
              color: Color(0xffF2F2F2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              page.label,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyle.normal10style.copyWith(
                fontSize: 8.sp,
                height: 1.35,
                color: AppColors.defaultTxtGrey,
              ),
            ),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: GestureDetector(
            onTap: onRemove,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: EdgeInsets.all(3.w),
              child: Icon(
                Icons.close,
                size: 11.sp,
                color: AppColors.defaultTxtGrey,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _addPageTile(VoidCallback onAdd) {
  return InkWell(
    onTap: onAdd,
    child: Container(
      height: _capturedTileSize,
      width: _capturedTileSize,
      decoration: BoxDecoration(
        color: Color(0xffF2F2F2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(
        Icons.add,
        size: 22.sp,
        color: AppColors.defaultTxtGrey,
      ),
    ),
  );
}

Widget _docSourceBox({
  required String icon,
  required String actionLabel,
  required VoidCallback onTap,
  bool isSvgIcon = false,
}) {
  return InkWell(
    onTap: onTap,
    child: DottedBorder(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 14.h),
      borderType: BorderType.RRect,
      dashPattern: [6, 4],
      color: Color(0xffBEBEBE),
      radius: Radius.circular(8),
      strokeWidth: 1.5,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 62.h,
              width: 62.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.withValues(alpha: 0.25),
              ),
              child: Center(
                child: isSvgIcon
                    ? SvgPicture.asset(icon, height: 34.h, width: 34.h)
                    : Image.asset(icon, height: 40.h),
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              actionLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyle.normal12style.copyWith(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: Color(0xff008ABD),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../../core/ui/const_sucess_popup.dart';
import '../../../../../services/auth_api_services/auth_services.dart';
import '../../../data/patient_form_data.dart';
import '../repository/form_builder_repository.dart';
import 'package:clinician_app/services/mock/mock_data_service.dart';
final ApiService Api = Get.put(ApiService());
/// get patient form API
Future<PatientByPtIdFormModel> getPatientFormByPatientID(BuildContext context,
    {required int patientFormId}) async {
  var itemData;
  String convertIsoToDayMonthYear(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return '';
    try {
      DateTime dateTime = DateTime.parse(isoDate);
      return DateFormat('dd.MM.yy').format(dateTime);
    } catch (_) {
      return '';
    }
  }
  try {
    // final response = await Api.get(
    //    FormBuilderRepository.getPatientFormByPatientFormID(
    //         patientFormID: patientFormId));  // MOCKED for local UI testing
    final response = mockResponse(MockData.get('forms.patientFormById'));
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = response.data;

      final assignedTo = data['assigned_to'];
      final clinicianData = assignedTo?['clinician'];
      final qaData = assignedTo?['qa'];
      final coderData = assignedTo?['coder'];
      final patientReffreal = data['patient_referral'];

      itemData =  PatientByPtIdFormModel(
        patientFormId: data['patient_form_id'] ?? 0,
        formId: data['form_id'] ?? 0,
        formName: data['formName'] ?? '',
        patientId: data['patient_id'] ?? 0,
        chartId: data['chart_id'] ?? 0,
        episodeId: data['episode_id'] ?? 0,
        status: data['status'] ?? '',
        faceToFace: data['face_to_face'],
        createdAt: data['created_at'] ?? '',
        updatedAt: data['updated_at'] ?? '',
        assignedTo: AssignedTo(
          clinician: clinicianData == null ?
          Clinician(
            staffId:  0,
            name:  '',
            imgurl: '',
            color:  '',
            abbreviation: clinicianData?['abbreviation'] ?? '',
          ):Clinician(
            staffId: clinicianData?['staff_id'] ?? 0,
            name: clinicianData?['name'] ?? '',
            imgurl: clinicianData?['imgurl'] ?? '',
            color: clinicianData?['color'] ?? '',
            abbreviation: clinicianData?['abbreviation'] ?? '',
          ),
          qa: qaData == null ?StaffMember(
            staffId: 0,
            name:  '',
            color:  '',
            abbreviation:  '',
          ) :StaffMember(
            staffId: qaData?['staff_id'] ?? 0,
            name: qaData?['name'] ?? '',
            color: qaData?['color'] ?? '',
            abbreviation: qaData?['abbreviation'] ?? '',
          ),
          coder: coderData == null ?StaffMember(
            staffId:  0,
            name:  '',
            color: '',
            abbreviation:  '',
          ) : StaffMember(
            staffId: coderData?['staff_id'] ?? 0,
            name: coderData?['name'] ?? '',
            color: coderData?['color'] ?? '',
            abbreviation: coderData?['abbreviation'] ?? '',
          ),
        ),
        statusHistory: (data['status_history'] as List? ?? [])
            .map((e) => StatusHistory(
          fromStatus: e?['from_status'] ?? '',
          toStatus: e?['to_status'] ?? '',
          note: e?['note'],
          changedBy: ChangedBy(
            employeeId: e?['changed_by']?['employee_id'] ?? 0,
            name: e?['changed_by']?['name'] ?? '',
          ),
          changedAt: e?['changed_at'] ?? '',
        ))
            .toList(),
        subForms: (data['subForms'] as List? ?? [])
            .map((e) => SubFormList(
          id: e?['id'] ?? 0,
          subFormId: e?['subFormId'] ?? 0,
          subFormName: e?['subFormName'] ?? '',
          isFilled: e['isFilled'] ?? false,
          comment_count: e["comment_count"] ?? 0
        ))
            .toList(),
        referralData: patientReffreal == null ? PatientFormReferralData(
            patientId: 0,
            patientFirstname: '',
            patientLastname: '',
            patientDob: '',
            patientGenderId: 0,
            patientPhone: '',
            patientAddress: '',
            patientImageUrl: '',
            patientChartNo: 0):PatientFormReferralData(
            patientId: patientReffreal['pt_id'] ?? 0,
            patientFirstname: patientReffreal['pt_first_name'] ?? '',
            patientLastname: patientReffreal['pt_last_name'] ?? '',
            patientDob: patientReffreal['pt_date_of_birth']?? '',
            patientGenderId: patientReffreal['genderId'] ?? 0,
            patientPhone: patientReffreal['pt_contact_no'] ?? '',
            patientAddress: patientReffreal['pt_address'] ?? '',
            patientImageUrl: patientReffreal['pt_img_url'] ?? '',
            patientChartNo: patientReffreal['pt_chart_no'] ?? 0),

      );

    } else {
      Get.back();
      showDocErrorDialog(context: Get.context!,
          message: response.data['message'][0] ?? 'Something went wrong',
          title: 'Error');
    }
    return itemData;
  } catch (e) {
    Get.back();
    showDocErrorDialog(context: Get.context!,
        message: 'Something went wrong!',
        title: 'Error');
    return itemData;
  }
}
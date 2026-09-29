

import 'package:flutter/cupertino.dart';
import 'package:clinician_app/pages/oasis_form_builder/constants/enums.dart';
import 'package:clinician_app/pages/oasis_form_builder/forms/evaluation/advance_beneficiary_notice_of_non_coverage/form_data_advance_beneficiary_notice_of_non_coverage.dart';
import 'package:clinician_app/pages/oasis_form_builder/forms/evaluation/care_coordination_note/form_data_care_coordination_note.dart';
import 'package:clinician_app/pages/oasis_form_builder/forms/evaluation/cornell_scale/form_data_cornell_scale.dart';
import 'package:clinician_app/pages/oasis_form_builder/forms/evaluation/employee_incident_report/form_data_employee_incident_report.dart';
import 'package:clinician_app/pages/oasis_form_builder/forms/evaluation/home_health_change_of_care_notice/form_data_home_health_change_of_care_notice.dart';
import 'package:clinician_app/pages/oasis_form_builder/forms/evaluation/medication_profile/form_data_medication_profile.dart';
import 'package:clinician_app/pages/oasis_form_builder/forms/evaluation/notice_of_medicare_non_coverage/form_data_notice_of_medicare_non_coverage.dart';
import 'package:clinician_app/pages/oasis_form_builder/forms/evaluation/home_health_aide_care_plan/form_data_home_health_aide_care_plan.dart';
import 'package:clinician_app/pages/oasis_form_builder/forms/evaluation/nutritional_assessment_and_service_plan/form_data_nutritional_assessment_and_service_plan.dart';
import 'package:clinician_app/pages/oasis_form_builder/forms/evaluation/medical_social_services_evaluation/form_data_medical_social_services_evaluation.dart';
import 'package:clinician_app/pages/oasis_form_builder/forms/evaluation/occupational_therapy_reassesmenrt/form_data_occupational_therapy_reassessment.dart';
import 'package:clinician_app/pages/oasis_form_builder/forms/evaluation/ot_evaluation/form_data_ot_evaluation.dart';
import 'package:clinician_app/pages/oasis_form_builder/forms/evaluation/oxygen_safety_assessment/form_data_oxygen_safety_assessment.dart';
import 'package:clinician_app/pages/oasis_form_builder/forms/evaluation/patient_incident_report/form_data_patient_incident_report.dart';
import 'package:clinician_app/pages/oasis_form_builder/forms/evaluation/physical_therapy_reassessment/form_data_physical_therapy_reassessment.dart';
import 'package:clinician_app/pages/oasis_form_builder/forms/evaluation/physician_order/form_data_physician_order.dart';
import 'package:clinician_app/pages/oasis_form_builder/forms/evaluation/skilled_nursing_evaluation/form_data_skilled_nursing_evaluation.dart';
import 'package:clinician_app/pages/oasis_form_builder/forms/evaluation/speech_therapy_reassessment/form_data_speech_therapy_reassessment.dart';
import 'package:clinician_app/pages/oasis_form_builder/forms/evaluation/st_eval/form_data_st_evaluation.dart';
import 'package:clinician_app/pages/oasis_form_builder/forms/evaluation/supervisory_note/form_data_supervisory_note.dart';
import 'package:clinician_app/pages/oasis_form_builder/forms/oasis_ot_discharge/form_data_ot_discharge.dart';
import 'package:clinician_app/pages/oasis_form_builder/forms/oasis_ot_discharge_non_visit/form_data_ot_discharge_non_visit.dart';
import 'package:clinician_app/pages/oasis_form_builder/forms/oasis_ot_other_follow_up/form_data_ot_other_follow_up.dart';
import 'package:clinician_app/pages/oasis_form_builder/forms/oasis_ot_recert/form_data_ot_recert.dart';
import 'package:clinician_app/pages/oasis_form_builder/forms/oasis_ot_roc_recert/form_data_ot_roc_recert.dart';
import 'package:clinician_app/pages/oasis_form_builder/forms/oasis_ot_resumption_of_care/form_data_ot_resumption_of_care.dart';
import 'package:clinician_app/pages/oasis_form_builder/forms/oasis_ot_start_of_care/form_data_ot_start_of_care.dart';
import 'package:clinician_app/pages/oasis_form_builder/forms/oasis_pt_discharge/form_data_pt_discharge.dart';
import 'package:clinician_app/pages/oasis_form_builder/forms/oasis_pt_discharge_non_visit/form_data_pt_discharge_non_visit.dart';
import 'package:clinician_app/pages/oasis_form_builder/forms/oasis_pt_resumption_of_care/form_data_pt_resumption_of_care.dart';
import 'package:clinician_app/pages/oasis_form_builder/forms/oasis_pt_recert/form_data_pt_recert.dart';
import 'package:clinician_app/pages/oasis_form_builder/forms/oasis_pt_roc_recert/form_data_pt_roc_recert.dart';
import 'package:clinician_app/pages/oasis_form_builder/forms/oasis_pt_start_of_care/form_data_pt_start_of_care.dart';
import 'package:clinician_app/pages/oasis_form_builder/forms/oasis_pt_other_follow_up/form_data_pt_other_follow_up.dart';
import 'package:clinician_app/pages/oasis_form_builder/forms/oasis_rn_discharge/form_data_rn_discharge.dart';
import 'package:clinician_app/pages/oasis_form_builder/forms/oasis_rn_other_follow_up/form_data_other_follow_up.dart';
import 'package:clinician_app/pages/oasis_form_builder/forms/oasis_rn_recert/form_data_rn_recert.dart';
import 'package:clinician_app/pages/oasis_form_builder/forms/oasis_rn_resumption_of_care/form_data_rn_resumption.dart';
import 'package:clinician_app/pages/oasis_form_builder/forms/oasis_rn_roc_recert/form_data_rn_roc_recert.dart';
import 'package:clinician_app/pages/oasis_form_builder/forms/oasis_rn_start_of_care/form_data_start_of_care.dart';
import 'package:clinician_app/pages/oasis_form_builder/forms/oasis_st_discharge/form_data_st_discharge.dart';
import 'package:clinician_app/pages/oasis_form_builder/forms/oasis_st_recert/form_data_st_recert.dart';
import 'package:clinician_app/pages/oasis_form_builder/forms/oasis_st_resumption_of_care/form_data_st_resumption_of_care.dart';
import 'package:clinician_app/pages/oasis_form_builder/forms/oasis_st_roc_recert/form_data_st_roc_recert.dart';
import 'package:clinician_app/pages/oasis_form_builder/forms/oasis_st_start_of_care/form_data_st_start_of_care.dart';
import 'package:clinician_app/pages/oasis_form_builder/forms/oasis_st_other_follow_up/form_data_st_other_follow_up.dart';
import 'package:clinician_app/pages/oasis_form_builder/forms/oasis_st_transfer_death/form_data_st_transfer_death.dart';
import 'package:clinician_app/pages/oasis_form_builder/forms/visit_note/home_health_aide_visit_note/form_data_home_health_aide_visit_note.dart';
import 'package:clinician_app/pages/oasis_form_builder/forms/visit_note/medical_social_services_visit_note/form_data_medical_social_services_visit_note.dart';
import 'package:clinician_app/pages/oasis_form_builder/forms/visit_note/speech_therapy_missed_visit_note/form_data_speech_therapy_missed_visit_note.dart';
import 'package:clinician_app/pages/oasis_form_builder/forms/visit_note/home_health_aide_missed_visit_note/form_data_home_health_aide_missed_visit_note.dart';
import 'package:clinician_app/pages/oasis_form_builder/forms/visit_note/medical_social_services_missed_visit_note/form_data_medical_social_services_missed_visit_note.dart';
import 'package:clinician_app/pages/oasis_form_builder/forms/visit_note/occupational_therapy_discharge_summary_non_visit/form_data_occupational_therapy_discharge_summary_non_visit.dart';
import 'package:clinician_app/pages/oasis_form_builder/forms/visit_note/medical_social_services_discharge_summary_non_visit/form_data_medical_social_services_discharge_summary_non_visit.dart';
import 'package:clinician_app/pages/oasis_form_builder/forms/visit_note/occupational_therapy_discharge_visit_note/form_data_occupational_therapy_discharge_visit_note.dart';
import 'package:clinician_app/pages/oasis_form_builder/forms/visit_note/occupational_therapy_missed_visit_note/form_data_occupational_therapy_missed_visit_note.dart';
import 'package:clinician_app/pages/oasis_form_builder/forms/visit_note/occupational_therapy_visit_note/form_data_occupational_therapy_visit_note.dart';
import 'package:clinician_app/pages/oasis_form_builder/forms/visit_note/physical_therapy_discharge_visit_note/form_data_physical_therapy_discharge_visit_note.dart';
import 'package:clinician_app/pages/oasis_form_builder/forms/visit_note/physical_therapy_visit_note/form_data_physical_therapy_visit_note.dart';
import 'package:clinician_app/pages/oasis_form_builder/forms/visit_note/skilled_nursing_discharge_summary_non_visit/form_data_skilled_nursing_discharge_summary_non_visit.dart';
import 'package:clinician_app/pages/oasis_form_builder/forms/visit_note/physical_therapy_discharge_summary_non_visit/form_data_physical_therapy_discharge_summary_non_visit.dart';
import 'package:clinician_app/pages/oasis_form_builder/forms/visit_note/skilled_nursing_discharge_visit_note/form_data_skilled_nursing_discharge_visit_note.dart';
import 'package:clinician_app/pages/oasis_form_builder/forms/visit_note/skilled_nursing_patient_missed_visit/form_data_skilled_nursing_patient_missed_visit.dart';
import 'package:clinician_app/pages/oasis_form_builder/forms/visit_note/speech_therapy_discharge_summary_non_visit/form_data_speech_therapy_discharge_summary_non_visit.dart';
import 'package:clinician_app/pages/oasis_form_builder/forms/visit_note/speech_therapy_discharge_visit_note/form_data_speech_therapy_discharge_visit_note.dart';
import 'package:clinician_app/pages/oasis_form_builder/forms/visit_note/speech_therapy_visit_note/form_data_speech_therapy_visit_note.dart';
import 'package:clinician_app/pages/oasis_form_builder/model/patient_chart.dart';
import 'package:clinician_app/pages/oasis_form_builder/model/patient_form_model.dart';
import 'package:clinician_app/pages/oasis_form_builder/services/api/repository/form_builder_repository.dart';
import 'package:clinician_app/pages/oasis_form_builder/widgets/dynamic/model/question_data_model.dart';
import 'package:get/get.dart';

import '../../../../../core/constant/app_string.dart';
import '../../../../../model/request/request_data_model.dart';
import '../../../../../services/auth_api_services/auth_services.dart';
import '../../../data/pending_forms_data.dart';
import '../../../forms/evaluation/case_conference/form_data_case_conference.dart';
import '../../../forms/evaluation/infection_identification_report/form_data_infection_identification_report.dart';
import '../../../forms/evaluation/kaiser_notice_of_medicare_non_coverage/form_data_kaiser_notice_of_medicare_non_coverage.dart';
import '../../../forms/evaluation/physical_therapy_evaluation/form_data_physical_therapy_evaluation.dart';
import '../../../forms/evaluation/physician_dme_request_order/form_data_physician_dme_request.dart';
import '../../../forms/oasis_rn_discharge_non_visit/form_data_rn_discharge_non_visit.dart';
import '../../../forms/oasis_st_discharge_non_visit/form_data_st_discharge_non_visit.dart';
import '../../../forms/visit_note/medical_social_services_discharge_visit_note/form_data_medical_social_services_discharge_visit_note.dart';
import '../../../forms/visit_note/physical_therapy_missed_visit_note/form_data_physical_therapy_missed_visit_note.dart';
import '../../../forms/visit_note/skilled_nursing_visit_note/form_data_skilled_nursing_visit_note.dart';
import '../../../model/chart_patient_referral_data_model.dart';
import '../../../model/employee_type.dart';
import '../../../model/question_markup_model.dart';
import '../../../widgets/dynamic/model/option_data_model.dart';
import 'package:clinician_app/services/mock/mock_data_service.dart';

// Other imports
class FormBuilderManager {
  final ApiService _api = Get.put(ApiService());
  List<OptionDataModel> getOptions(List data) {
    List<OptionDataModel> dataSet = [];
    for (var element in data) {
      dataSet.add(OptionDataModel.fromJson(element, AnswerType.none));
    }
    return dataSet;
  }

  Future<Map<String, dynamic>> getPatientFormByPatientFormID(
      BuildContext context,
      {required patientFormId, int? subFormId}) async {
    List<QuestionDataModel> itemsList = [];
    Map<String, dynamic> commentUsers = {};
    try {
      // final response = await _api.get(
      //     FormBuilderRepository.getPatientFormByPatientFormIDWithSub(
      //         patientFormID: patientFormId, subFormID: subFormId!));  // MOCKED for local UI testing
      final response = mockResponse(MockData.get('forms.patientFormQuestions'));
      if (response.statusCode == 200 || response.statusCode == 201) {
        for (var item in response.data['data']["questions"]) {
          try {
            itemsList.add(QuestionDataModel.fromJson(item));
          } catch (e) {
            print(e);
          }
        }
        final rawCommentUsers = response.data['comment_users'];
        if (rawCommentUsers is Map) {
          rawCommentUsers.forEach((key, value) {
            if (value is Map) {
              commentUsers[key.toString()] = Map<String, dynamic>.from(value);
            }
          });
        }
      } else {
        print('Api Error');
      }
      return {"questions": itemsList, "commentUsers": commentUsers};
    } catch (e) {
      print("Error $e");
      return {"questions": itemsList, "commentUsers": commentUsers};
    }
  }

  ///ADD Patient Answers Patch API
  Future<ApiData> addPatientFormAnswer(
    BuildContext context,
    List<Map> answers,
  ) async {
    try {
      // var response = await _api.patchList(
      //    FormBuilderRepository.patientFormAnswer,
      //   answers,
      // );  // MOCKED for local UI testing
      var response = mockResponse(MockData.get('forms.answerSaved'));
      // print(response);
      if (response.statusCode == 200 || response.statusCode == 201) {
        // orgDocumentGet(context);
        return ApiData(
            statusCode: response.statusCode!,
            success: true,
            data: response.data,
            message: response.statusMessage!);
      } else {
        print("Error 1");
        return ApiData(
            statusCode: response.statusCode!,
            success: false,
            message: response.data['message']);
      }
    } catch (e) {
      print("Error $e");
      return ApiData(
          statusCode: 404,
          success: false,
          message: AppString.somethingWentWrong);
    }
  }

  Future<ApiData> patchIsAssistantFormReview({
    required BuildContext context,
    required int visitId,
    required int patientFormId,
  }) async {
    try {
      // var response = await _api.patchNoRequest(
      //   path: FormBuilderRepository.patchIsAssistantForm(visitId: visitId.toString(), formId: patientFormId.toString()),
      // );  // MOCKED for local UI testing
      var response = mockResponse(MockData.get('forms.assistantFormReview'));
      // print(response);
      if (response.statusCode == 200 || response.statusCode == 201) {
        var data = response.data;
        final supervisoryNoteFormID = data["supervisoryNote"]['patient_form_id'] ?? 0;
        // orgDocumentGet(context);
        return ApiData(
            statusCode: response.statusCode!,
            success: true,
            message: response.statusMessage!,
            supervisoryNoteFormID:  supervisoryNoteFormID);
      } else {
        print("Error 1");
        return ApiData(
            statusCode: response.statusCode!,
            success: false,
            message: response.statusMessage!);
      }
    } catch (e) {
      print("Error $e");
      return ApiData(
          statusCode: 505,
          success: false,
          message: AppString.somethingWentWrong);
    }
  }

  Future<ApiData> patchPatientFormRestart(
      BuildContext context,
      int patientFormId,
      ) async {
    try {
      // var response = await _api.patchNoRequest(
      //   path: FormBuilderRepository.patchRestartForm(patientFormId: patientFormId),
      // );  // MOCKED for local UI testing
      var response = mockResponse(MockData.get('forms.restart'));
      // print(response);
      if (response.statusCode == 200 || response.statusCode == 201) {
        // orgDocumentGet(context);
        return ApiData(
            statusCode: response.statusCode!,
            success: true,
            data: response.data,
            message: response.statusMessage!);
      } else {
        print("Error 1");
        return ApiData(
            statusCode: response.statusCode!,
            success: false,
            message: response.data['message']);
      }
    } catch (e) {
      print("Error $e");
      return ApiData(
          statusCode: 404,
          success: false,
          message: AppString.somethingWentWrong);
    }
  }

  /// GET all patient referrels
  Future<Map<String, dynamic>> getAllPatientReferral(
    BuildContext context, {
    required int page,
    required int perPage,
    String? patientName,
  }) async {
    try {
      // var response = await _api.post(
      //    FormBuilderRepository.patientReferralList,
      //  {
      //     "page": page,
      //     "records": perPage,
      //     if (patientName != null && patientName.isNotEmpty)
      //       "search": patientName,
      //   },
      // );  // MOCKED for local UI testing
      var response = mockResponse(MockData.get('forms.patientReferralList'), statusCode: 201, statusMessage: 'Created');
      final List list = response.data['patientReferrals'];
      // print(list.runtimeType);
      if (response.statusCode == 201) {
        return {
          "patients": ChartPatientReferral.fromJsonList(list),
          "nextPageAvailable": page * perPage < response.data['meta']['total'],
        };
      } else {
        print("Error 1");
        return {
          "patients": [],
          "nextPageAvailable": false,
        };
      }
    } catch (e) {
      print("Error $e");
      return {
        "patients": [],
        "nextPageAvailable": false,
      };
    }
  }

  /// Save Patient Form Answer
  Future<bool> savePatientForm(
    BuildContext context, {
    required int patientFormID,
    required Map<String, dynamic> formData,
  }) async {
    try {
      print('Raw seleted form data: $formData');
      // var response = await _api.post(
      //    FormBuilderRepository.getPatientFormByPatientFormID(
      //       patientFormID: patientFormID),
      //    formData,
      // );  // MOCKED for local UI testing
      var response = mockResponse(MockData.get('forms.savePatientForm'), statusCode: 201, statusMessage: 'Created');
      if (response.statusCode == 201) {
        print('Raw seleted form response: ${response.toString()}');
        return true;
      } else {
        print("Error 1");
        return false;
      }
    } catch (e) {
      print("Error $e");
      return false;
    }
  }

  /// Patch
  Future<ApiData> patchPatientForm(
      BuildContext context, {
        required int patientFormID,
       required String formData,
        bool? isFaceToFace,
      }) async {
    try {
      print('Raw seleted form data: $formData');
      // var response = await _api.patch(
      //   FormBuilderRepository.getPatientFormByPatientFormID(
      //       patientFormID: patientFormID),
      //   isFaceToFace == true ? {
      //     "status" : formData,
      //     "face_to_face": isFaceToFace
      //   } : {
      //     "status" : formData
      //   },
      // );  // MOCKED for local UI testing
      var response = mockResponse(MockData.get('forms.patchPatientForm'));
      if (response.statusCode == 201 || response.statusCode == 200) {
        print('Raw seleted form response: ${response.toString()}');
        var data = response.data;
        final nextFormId = data['nextPatientFormId']?? 0;
        final nextFormNameString = data['nextFormName'] ?? "";
        return ApiData(
            statusCode: response.statusCode!,
            success: true,
            message: response.statusMessage!,
            nextPatientFormId: nextFormId,
            nextFormName: nextFormNameString);
      } else {
        print("Error 1");
        return ApiData(
            statusCode: response.statusCode!,
            success: false,
            message: response.statusMessage!);
      }
    } catch (e) {
      print("Error $e");
      return ApiData(
          statusCode: 505,
          success: false,
          message: AppString.somethingWentWrong);
    }
  }

  ///Upload Signatures
  Future<String?> uploadFiles(
    BuildContext context, {
    required formData,
  }) async {
    try {
      // var response = await _api.postWithFormData(
      //   path: FormBuilderRepository.uploadFile,
      //   formData: formData,
      // );  // MOCKED for local UI testing
      var response = mockResponse(MockData.get('forms.uploadFile'), statusCode: 201, statusMessage: 'Created');
      print(response);
      if (response.statusCode == 201) {
        return response.data['url'];
      } else {
        print("Error 1");
        return null;
      }
    } catch (e) {
      print("Error $e");
      return null;
    }
  }

  ///Delete Signatures
  Future<void> deleteFiles(
    BuildContext context, {
    required String url,
  }) async {
    try {
      // var response = await _api.deleteWithData(
      //   path: FormBuilderRepository.deleteFile,
      //   data: {"url": url},
      // );  // MOCKED for local UI testing
      var response = mockResponse(MockData.get('forms.deleteFile'));
      if (response.statusCode == 200) {
        print('Image Deleted');
        //Deleted Succesfully
      } else {
        print("Error 1");
      }
    } catch (e) {
      print("Error $e");
    }
  }

  ///get patient-referral API
  Future<ChartPatientReferral?> getPatientReferral(BuildContext context,
      {required referralID}) async {
    try {
      // final response = await _api.get(
      //         FormBuilderRepository.getPatientReferral(referralID: referralID));  // MOCKED for local UI testing
      final response = mockResponse(MockData.get('forms.patientReferral'));
      if (response.statusCode == 200) {
        // print(response.data);
        return ChartPatientReferral.fromJson(response.data);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// Get All Forms
  Future<List<PatientForm>> getAllFormsData(BuildContext context) async {
    try {
      // final response =
      //     await _api.get( FormBuilderRepository.getAllForms);  // MOCKED for local UI testing
      final response = mockResponse(MockData.get('forms.allForms'));
      if (response.statusCode == 200) {
        return PatientForm.fromJsonList(response.data);
      } else {
        print('Api Error');
        return [];
      }
    } catch (e) {
      print("Error $e");
      return [];
    }
  }


/// Get All Charts of Patient
  Future<List<PatientChart>> getPatientCharts(BuildContext context, {required int patientId}) async {
    try {
      // final response =
      //     await _api.get( FormBuilderRepository.getPatientCharts(patientId: patientId));  // MOCKED for local UI testing
      final response = mockResponse(MockData.get('forms.patientCharts'));
      if (response.statusCode == 200) {
        return PatientChart.listFromJson(response.data);
      } else {
        print('Api Error');
        return [];
      }
    } catch (e) {
      print("Error $e");
      return [];
    }
  }

  /// Get All SubForms
  Future<List<PatientSubForm>> getAllSubFormsData(BuildContext context) async {
    try {
      // final response =
      //     await _api.get( FormBuilderRepository.getAllSubForms);  // MOCKED for local UI testing
      final response = mockResponse(MockData.get('forms.allSubForms'));
      if (response.statusCode == 200) {
        return PatientSubForm.fromJsonList(response.data);
      } else {
        print('Api Error');
        return [];
      }
    } catch (e) {
      print("Error $e");
      return [];
    }
  }

  /// Get All INIT Forms Data
  Future<Map<String, dynamic>> getInitFormData(BuildContext context,
      {required int patientID,
      required int chartID,
      required int episodeID}) async {
    try {
      // final response = await _api.get(
      //    FormBuilderRepository.getPatientFormByPatientID(
      //     patientID: patientID,
      //     chartID: chartID,
      //     episodeID: episodeID,
      //   ),
      // );  // MOCKED for local UI testing
      final response = mockResponse(MockData.get('forms.initFormData'));
      if (response.statusCode == 200) {
        final List<PatientForm> filledForms = [];
        for (int i = 0; i < response.data['filled'].length; i++) {
          final formData = response.data['filled'][i];
          filledForms.add(
            PatientForm.fromJson(
              formData,
            ),
          );
        }
        final List<PatientForm> unfilledForms = [];
        for (int i = 0; i < response.data['unfilled'].length; i++) {
          final formData = response.data['unfilled'][i];
          unfilledForms.add(
            PatientForm.fromJson(
              formData,
            ),
          );
        }
        return {
          "filled": filledForms,
          "unfilled": unfilledForms,
        };
      } else {
        print('Api Error');
        return {};
      }
    } catch (e) {
      print("Error $e");
      return {};
    }
  }

  /// fetch episode dropdown
  Future<List<PatentDataEpisode>> getEpisodeDropdown(BuildContext context,
      {required int patientID,
        }) async {
    List<PatentDataEpisode> itemData = [];
    try {
      // final response = await _api.get(
      //    FormBuilderRepository.getPatientEpisodeDropdown(
      //     patientId: patientID,

      //   ),
      // );  // MOCKED for local UI testing
      final response = mockResponse(MockData.get('forms.episodeDropdown'));
      if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 304) {
        for(var item in response.data){
          itemData.add(PatentDataEpisode(
              ptEpisodeId: item['pt_episodeId'] ?? 0,
              episodeId: item['episode_id'] ?? 0,
              chartId: item['chart_id'] ?? 0,
              label: item['label'] ?? '',
              episodeFrom: item['episodeFrom'] ?? '',
              episodeTo: item['episodeTo'] ?? '',
              pt_id: item['pt_id'] ?? 0));
        }
        return itemData;
      } else {
        print('Api Error');
        return itemData;
      }
    } catch (e) {
      print("Error $e");
      return itemData;
    }
  }

  /// POST Init Form
  Future<PatientForm?> initPatientForm(
    BuildContext context, {
    required int patientID,
    required int chartID,
    required int episodeID,
    required int formID,
  }) async {
    try {
      // var response = await _api.post(
      //   FormBuilderRepository.initPatientForm,
      //    {
      //     "patient_id": patientID,
      //     "formId": formID,
      //     "chart_id": chartID,
      //     "episode_id": episodeID
      //   },
      // );  // MOCKED for local UI testing
      var response = mockResponse(MockData.get('forms.initPatientForm'), statusCode: 201, statusMessage: 'Created');
      // print(list.runtimeType);
      if (response.statusCode == 201) {
        return PatientForm.fromJson(response.data);
      } else {
        print("Error 1");
        return null;
      }
    } catch (e) {
      print("Error $e");
      return null;
    }
  }

  /// GET Question Markup
  Future<QuestionMarkup?> getQuestionMarkupByCode(
    BuildContext context, {
    required String questionCode,
  }) async {
    try {
      // var response = await _api.get(
      //   FormBuilderRepository.getQuestionMarkupByCode(code: questionCode),
      // );  // MOCKED for local UI testing
      var response = mockResponse(MockData.get('forms.questionMarkup'));
      // print(list.runtimeType);
      if (response.statusCode == 200) {
        return QuestionMarkup.fromJson(response.data['data']);
      } else {
        print("Error 1");
        return null;
      }
    } catch (e) {
      print("Error $e");
      return null;
    }
  }

  ///GET Employee Types By Department 1
  Future<List<EmployeeType>> getEmployeeTypesByDepartment1(
    BuildContext context,
  ) async {
    try {
      // var response = await _api.get(
      //   FormBuilderRepository.getEmployeeTypeByDepartment1,
      // );  // MOCKED for local UI testing
      var response = mockResponse(MockData.get('forms.employeeTypes'));
      // print(list.runtimeType);
      if (response.statusCode == 200) {
        return EmployeeType.fromJsonList(response.data);
      } else {
        print("Error 1");
        return [];
      }
    } catch (e) {
      print("Error $e");
      return [];
    }
  }

  /// ==================== FOR LOCAL DEVELOPMENT USE ONLY =====================
  ///
  Future<List<QuestionDataModel>> getDummyDataPatientFormByID(
      BuildContext context,
      {required patientId,
      required formId}) async {
    List<QuestionDataModel> itemsList = [];
    try {
      for (var item in (formMapper[formId]?[patientId]?['questions'] ?? [])) {
        // print(item);
        try {
          itemsList.add(
            QuestionDataModel.fromJson(item),
          );
        } catch (e) {
          print('\x1B[31m[ERROR] Something went wrong!\x1B[0m');
          print(e);
        }
      }
      // print("Response:::::${response}");

      return itemsList;
    } catch (e) {
      print("Errorssss $e");
      return itemsList;
    }
  }

  Future<String> getFormTitle({required patientId, required formId}) async {
    try {
      return formMapper[formId]?[patientId]?['title'] ?? " dd";
    } catch (e) {
      print("Error $e");
      return "";
    }
  }

  Future<String> getFormTemplateName(
      {required patientId, required formId}) async {
    try {
      return formMapper[formId]?[patientId]?['template_name'] ?? " ee";
    } catch (e) {
      print("Error $e");
      return "";
    }
  }

  Future<int> getColumns({required patientId, required formId}) async {
    try {
      return 2;
    } catch (e) {
      print("Error $e");
      return 2;
    }
  }


  /// New start visit needed manager files
  Future<ApiData> patchAssignPhysicianOrderForm(
      BuildContext context, {
        required int patientFormID,
      }) async {
    try {
      // var response = await _api.post(
      //   FormBuilderRepository.patchPhysicianOrder(
      //       patientFormId: patientFormID), {},

      // );  // MOCKED for local UI testing
      var response = mockResponse(MockData.get('forms.assignPhysicianOrder'), statusCode: 201, statusMessage: 'Created');
      if (response.statusCode == 201) {
        return ApiData(
            statusCode: response.statusCode!,
            success: true,
            message: response.statusMessage!);
      } else {
        print("Error 1");
        return ApiData(
            statusCode: response.statusCode!,
            success: false,
            message: response.statusMessage!);
      }
    } catch (e) {
      print("Error $e");
      return ApiData(
          statusCode: 500,
          success: true,
          message: 'Something went wrong');
    }
  }

  Future<ApiData> patchStartVisit({
    required BuildContext context,
    required int visitId,
    required bool onWay,
    String? visitTypeData,
    bool? isLastVisit,
  }) async {
    try {
      // var response = await _api.patch(
      //      "/patient-visits/$visitId",
      //     isLastVisit == true ? {
      //       "onWay": onWay,
      //       "episodeEndType": visitTypeData
      //     }:{
      //       "onWay": onWay,
      //     }
      // );  // MOCKED for local UI testing
      var response = mockResponse(MockData.get('forms.startVisit'));

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("patch start visit response: ${response.data}");
        var data = response.data;
        int ptId = data['pt_id'] ?? 0;
        int ptFormId = data['patient_form_id'] ?? 0;
        bool isVisitTypeSection = data['episodeStatus']['requiresVisitTypeSelection'] ?? false;
        bool isEpisodeEndDecision = data['isSecondLastEpisodeVisit'] ??false;
        String lastVisitAssistant = data['lastVisitPerformedBy'] ?? '';
        List<int> pendingFormsIds = List<int>.from(data['pendingAssistantFormIds'] ?? []);
        print("isSecondLastEpisodeVisit: $isEpisodeEndDecision");
        return ApiData(
          statusCode: response.statusCode!,
          success: true,
          message: response.statusMessage!,
          ptFormId: ptFormId,
          ptId: ptId,
          visitTypeSelection: isVisitTypeSection,
          episodeEndDecision: isEpisodeEndDecision,
          pendingFormsIds: pendingFormsIds,
          lastVisitPerformedBy: lastVisitAssistant,
        );
      } else {
        print("Error Start visit");
        return ApiData(
            statusCode: response.statusCode!,
            success: false,
            message: response.data['message']);
      }
    } catch (e) {
      print("Error $e");
      return ApiData(
          statusCode: 404, success: false, message: AppString.somethingWentWrong);}
  }

  Future<ApiData> uploadVisitPhoto(
      BuildContext context,
      int visitId,
      String base64,
      ) async {
    try {
      // var response = await _api.post(
      //   MarkMissedRepository.uploadVisitPhoto(visitId: visitId),
      //    {
      //     "base64": base64,
      //   },
      // );  // MOCKED for local UI testing
      var response = mockResponse(MockData.get('forms.uploadVisitPhoto'));
      print(response);
      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Visit photo uploaded");
        return ApiData(
          statusCode: response.statusCode!,
          success: true,
          message: response.statusMessage!,
        );
      } else {
        print("Error 1");
        return ApiData(
          statusCode: response.statusCode!,
          success: false,
          message: response.data['message'],
        );
      }
    } catch (e) {
      print("Error $e");
      return ApiData(
        statusCode: 404,
        success: false,
        message: AppString.somethingWentWrong,
      );
    }
  }

  Future<ApiData> markVisitMissed(
      BuildContext context,
      int visitId, {
        required String reason,
        required bool isAttemptedVisit,
        String? photoUrl,
        required List<String> actionsTaken,
        required String notificationDate,
        required String notificationTime,
        required List<String> individualsNotified,
        required List<String> notificationMethods,
      }) async {
    try {
      // var response = await _api.patch(
      //   MarkMissedRepository.markMissed(visitId: visitId),
      //   {
      //     "reason":              reason,
      //     "isAttemptedVisit":    isAttemptedVisit,
      //     "photoUrl":            photoUrl,
      //     "actionsTaken":        actionsTaken,
      //     "notificationDate":    notificationDate,
      //     "notificationTime":    notificationTime,
      //     "individualsNotified": individualsNotified,
      //     "notificationMethods": notificationMethods,
      //   },
      // );  // MOCKED for local UI testing
      var response = mockResponse(MockData.get('forms.markVisitMissed'));
      print(response);
      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Visit marked as missed");
        var data = response.data;
        final missVisitPatientForm = data['patient_form_id'] ?? 0;
        final requiredEpisodEnd = data['requiresEpisodeEndDecision'] ?? false;
        final lastVisitId = data['lastVisitId'] ?? 0;
        final dischardeFormPatientId = data['dischargeFormPatientFormId'] ?? 0;
        final patientDischarged = data['patientDischarged'] ?? false;
        return ApiData(
          statusCode: response.statusCode!,
          success:    true,
          message:    response.statusMessage!,
          missVisitFormID: missVisitPatientForm,
          requiredEpisodEnd: requiredEpisodEnd,
          lastVisitId: lastVisitId,
          dischardeFormPatientId: dischardeFormPatientId,
          patientDischarged: patientDischarged,
        );
      } else {
        print("Error 1");
        return ApiData(
          statusCode: response.statusCode!,
          success:    false,
          message:    response.data['message'],
        );
      }
    } catch (e) {
      print("Error $e");
      return ApiData(
        statusCode: 404,
        success:    false,
        message:    AppString.somethingWentWrong,
      );
    }
  }


  Future<ApiData> patchEpisodeEnd({
    required BuildContext context,
    required int visitId,
    required String episodeEndType
  }) async {
    try {
      // var response = await _api.patch(
      //     MarkMissedRepository.patientVisitEpisodEnd(visitId: visitId),
      //    {
      //       "episodeEndType": episodeEndType,
      //     }
      // );  // MOCKED for local UI testing
      var response = mockResponse(MockData.get('forms.episodeEnd'));
      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Episode changed");

        return ApiData(
          statusCode: response.statusCode!,
          success: true,
          message: response.statusMessage!,
        );
      } else {
        print("Error 1");
        return ApiData(
            statusCode: response.statusCode!,
            success: false,
            message: response.data['message']);
      }
    } catch (e) {
      print("Error $e");
      return ApiData(
          statusCode: 404, success: false, message: AppString.somethingWentWrong);
    }
  }


  Future<ApiData> patchRecertVisit({
    required BuildContext context,
    required int id,
    required String decision,

  }) async {
    try {
      // var response = await _api.patch(
      //   MarkMissedRepository.recertDecisionVisit(visitId: id),
      //  {
      //     "decision": decision,
      //   },
      // );  // MOCKED for local UI testing
      var response = mockResponse(MockData.get('forms.recertDecision'));

      print('decision: $response');
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiData(
          statusCode: response.statusCode!,
          success: true,
          message: response.statusMessage!,
        );
      } else {
        return ApiData(
          statusCode: response.statusCode!,
          success: false,
          message: response.data['message'][0],
        );
      }
    } catch (e) {
      print("Error $e");
      return ApiData(
        statusCode: 404,
        success: false,
        message: AppString.somethingWentWrong,
      );
    }
  }


  Future<List<PendingReviewAssistanceForm>> getEmrPendingReviewForm({
    required BuildContext context,
    required int patientId,
  }) async {
    List<PendingReviewAssistanceForm> itemsData = [];
    try {
      // final response = await _api.get(
      //     MarkMissedRepository.getPatientFormReview(patientId: patientId));  // MOCKED for local UI testing
      final response = mockResponse(MockData.get('forms.pendingReviewForms'));

      if (response.statusCode == 200 || response.statusCode == 201) {
        for (var item in response.data) {
          itemsData.add(PendingReviewAssistanceForm(
            visitId: item['visitId'] ?? 0,
            patientFormId: item['patientFormId'] ?? 0,
            patientId: item['patientId'] ?? 0,
            formId: item['formId'] ?? 0,
            formName: item['formName'] ?? '',
            assistantEmployeeId: item['assistantEmployeeId'] ?? 0,
            assistantName: item['assistantName'] ?? '',
            assistantImage: item['assistantImage'] ?? '',
            assistantEmployeeType: item['assistantEmployeeType'] ?? '',
            assistantEmployeeTypeAbbreviation: item['assistantEmployeeTypeAbbreviation'] ?? '',
          ));
        }

        return itemsData;
      } else {
        debugPrint("patient visit list error: ${response.statusCode}");
      }

      return itemsData;
    } catch (e) {
      debugPrint("get patient visit error: $e");
      return itemsData;
    }
  }

/// =============================== Till Here ================================
}

Map<int, Map> formMapper = {
  // Start Of Care
  1: FormDataStartOfCare.rnSocDrawerItems,
  2: FormDataPTStartOfCare.ptSocDrawerItems,
  3: FormDataOTStartOfCare.otSocDrawerItems,
  4: FormDataSTStartOfCare.stSocDrawerItems,
  5: FormDataSTTransferDeath.stTransferDeathDrawerItems,
  // ROC
  6: FormDataRnResumption.rnRocDrawerItems,
  7: FormDataPTResumptionOfCare.ptRocDrawerItems,
  8: FormDataOtResumptionOfCare.otROCDrawerItems,
  9: FormDataStResumptionOfCare.stROCDrawerItems,
  // ROC RECERT
  10: FormDataRnRocRecert.rnRocRecertDrawerItems,
  11: FormDataPTRocRecert.ptRocRecertDrawerItems,
  12: FormDataOTRocRecert.otRocRecertDrawerItems,
  13: FormDataSTRocRecert.stRocRecertDrawerItems,
  // DISCHARGE NON VISIT
  14: FormDataRnDischargeNonVisit.rnDischargeNonVisitDrawerItems,
  15: FormDataPtDischargeNonVisit.ptDischargeNonVisitDrawerItems,
  16: FormDataOTDischargeNonVisit.otDischargeNonVisitDrawerItems,
  17: FormDataStDischargeNonVisit.stDischargeNonVisitDrawerItems,
  18: FormDataSkilledNursingDischargeSummaryNonVisit
      .skilledNursingDischargeSummaryNonVisitDrawerItems,
  19: FormDataPhysicalTherapyDischargeSummaryNonVisit.drawerItems,
  20: FormDataOccupationalTherapyDischargeSummaryNonVisit.drawerItems,
  21: FormDataSpeechTherapyDischargeSummaryNonVisit
      .speechTherapyDischargeSummaryNonVisitDrawerItems,
  22: FormDataMedicalSocialServicesDischargeSummaryNonVisit
      .medicalSocialServicesDischargeSummaryNonVisitDrawerItems,
  23: FormDataHomeHealthAideCarePlan.drawerItems,
  24: FormDataSkilledNursingPatientMissedVisit.drawerItems,
  25: FormDataPhysicalTherapyMissedVisitNote.drawerItems,
  26: FormDataOccupationalTherapyMissedVisitNote.drawerItems,
  27: FormDataSpeechTherapyMissedVisitNote.drawerItems,
  28: FormDataMedicalSocialServicesMissedVisitNote.drawerItems,
  29: FormDataHomeHealthSideMissedVisitNote.drawerItems,
  30: FormDataSkilledNursingEvaluation.drawerItems,
  31: FormDataPhysicalTherapyEvaluation.ptEvalFormDrawerItems,
  32: FormDataOtEvaluation.drawerItems,
  33: FormDataStEvaluation.drawerItems,

  34: FormDataHomeHealthAideVisitNote.drawerItems,
  35: FormDataCareCoordinationNote.drawerItems,
  36: FormDataSkilledNursingVisitNote.drawerItems,
  37: FormDataPhysicalTherapyVisitNote.drawerItems,
  38: FormDataOccupationalTherapyVisitNote.drawerItems,
  39: FormDataSpeechTherapyVisitNote.drawerItems,
  40: FormDataSpeechTherapyReassessment.drawerItems,
  41: FormDataPhysicalTherapyReassessment.drawerItems,
  42: FormDataOccupationalTherapyReassessment.drawerItems,
  43: FormDataSkilledNursingDischargeVisitNote.drawerItems,
  44: FormDataPhysicalTherapyDischargeVisitNote.drawerItems,
  45: FormDataOccupationalTherapyDischargeVisitNote.drawerItems,
  46: FormDataSpeechTherapyDischargeVisitNote.drawerItems,
  // RECERT
  47: FormDataRnRecert.rnRecertDrawerItems,
  48: FormDataPTRecert.ptRecertDrawerItems,
  49: FormDataOTRecert.otRecertDrawerItems,
  50: FormDataSTRecert.stRecertDrawerItems,
  // OTHER FOLLOW UP
  51: FormDataOtherFollowUp.rnFollowUpDrawerItems,
  52: FormDataPTOtherFollowUp.ptFollowUpDrawerItems,
  53: FormDataOTOtherFollowUp.otFollowUpDrawerItems,
  54: FormDataSTOtherFollowUp.stFollowUpDrawerItems,
  // DISCHARGE
  55: FormDataRnDischarge.rnDischargeDrawerItems,
  56: FormDataPtDischarge.ptDischargeDrawerItems,
  57: FormDataOtDischarge.otDischargeDrawerItems,
  58: FormDataStDischarge.stDischargeDrawerItems,

  59: FormDataNoticeOfMedicareNonCoverage.drawerItems,
  60: FormDataHomeHealthChangeOfCareNotice.drawerItems,
  61: FormDataKaiserNotificationOfMedicareNonCoverage.drawerItems,
  62: FormDataAdvanceBeneficiaryNoticeOfNonCoverage.drawerItems,
  63: FormDataCornellScale.drawerItems,
  64: FormDataOxygenSafetyAssessment.drawerItems,
  65: FormDataMedicalSocialServicesVisitNote.drawerItems,
  66: FormDataInfectionIdentificationReport.drawerItems,
  67: FormDataMedicalSocialServicesDischargeVisitNote.drawerItems,
  68: FormDataPatientIncidentReport.drawerItems,
  69: FormDataEmployeeIncidentReport.drawerItems,
  70: FormDataPhysicianDMERequest.drawerItems,
  71: FormDataMedicalSocialServicesEvaluation.drawerItems,
  72: FormDataCaseConference.drawerItems,
  73: FormDataPhysicianOrder.drawerItems,
  74: FormDataMedicationProfile.drawerItems,
  75: FormDataNutritionalAssessmentAndServicePlan.drawerItems,
  76: FormDataSupervisoryNote.drawerItems,
};


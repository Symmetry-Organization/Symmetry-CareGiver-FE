import 'dart:convert';
import 'dart:io';

import 'package:clinician_app/controller/repository/profile_repo.dart';
import 'package:clinician_app/model/profile/edit_employee_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../core/constant/app_string.dart';
import '../model/profile/clinitina_data_model.dart';
import '../model/profile/patient_visitsnote_model.dart';
import '../model/profile/visit_details_model.dart';
import '../model/request/patient_schedule_model.dart';
import '../model/request/request_data_model.dart';
import '../services/auth_api_services/auth_services.dart';
import '../services/token_manager/token_manager_service.dart';
import 'package:clinician_app/services/mock/mock_data_service.dart';

class ProfileController extends GetxController{
  final ApiService _api = Get.put(ApiService());
  final selectedIndex = (-1).obs;
  final isClinitianloading = false.obs;
  final isLoading = false.obs;
  final isEmployeeLoading = false.obs;
  final isEmployeedetailsLoading = false.obs;
  final isEmployeeSaveLoading = false.obs;
  final isVisitUpdateLoding = false.obs;
  final isAssistanceLoading = false.obs;
  final isAssistantAssignLoading = false.obs;
  final error = ''.obs;
  final employeeId = 0.obs;
  final ImagePicker _picker = ImagePicker();
  final employeeAssistantTypeModel = <EmployeeAssistantTypeModel>[].obs;
  final selectedDataId = 0.obs;
  final selectedDataName = ''.obs;
  final emailController = TextEditingController().obs;

  final patientVisitNoteData = PatientVisitsNoteModel(
      employeeId: 0,
      date: '', items: []).obs;
  final clinitinaLoginDataModel = ClinitinaLoginDataModel(
      clinicianFullName: '',
      imageUrl: '',
      employeeTypeId: 0,
      abbreviation: '',
      color: "",
      employeeType: '', age: 0, gender: ''
      ).obs;
  final Rxn<VisitDetailModel> visitDetailModel = Rxn<VisitDetailModel>();
  final employeeIdByEmail = EmployeeIdByEmail(employeeId: 0).obs;


  final Rx<File?> selectedImage = Rx<File?>(null);
  final RxString imageBase64 = ''.obs;

  final firstNameController = TextEditingController().obs;
  final lastNameController  = TextEditingController().obs;
  final phoneController     = TextEditingController().obs;
  final emailAssistenseController  = TextEditingController().obs;
  final RxString employeeImage = ''.obs;
  // @override
  // void onInit() {
  //   super.onInit();
  //   fetchRecordType();
  // }



  static const int maxBytes = 20 * 1024 * 1024; // 20MB
  RxInt contentTypeInx = 0.obs;
  Rx<DateTime> currentDate = DateTime.now().obs;
  final calController = CalendarController().obs;

  String get formattedDate =>
      DateFormat('yyyy-MM-dd').format(currentDate.value);
  String get formattedDateReadable =>
      DateFormat('MMMM d, yyyy').format(currentDate.value);

  void changeDate(int day) {
    currentDate.value = currentDate.value.add(Duration(days: day));
    if (contentTypeInx.value == 1) {
      calController.value.displayDate = currentDate.value;
    }
  }
  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      // optional: you can also limit dimensions:
      // maxWidth: 2000,
      // maxHeight: 2000,
    );

    if (image == null) return;

    // ✅ ensure it's an image (no pdf)
    final ext = image.name.split('.').last.toLowerCase();
    const allowed = ['jpg', 'jpeg', 'png', 'webp', 'heic'];
    if (!allowed.contains(ext)) {
      Get.snackbar('Invalid file', 'Please select an image file only.');
      return;
    }

    // ✅ size check (use XFile length, fast)
    final int fileSize = await image.length();
    if (fileSize > maxBytes) {
      Get.snackbar('File too large', 'Please select an image under 20MB.');
      return;
    }

    final file = File(image.path);
    selectedImage.value = file;

    // ✅ Convert to Base64
    final bytes = await file.readAsBytes();
    imageBase64.value = base64Encode(bytes);
  }
  Future<void> fetchRecordType() async {
    selectedImage.value = null;
    employeeIdByEmail.value = await getEmployeeIdMaster();
    print('Login Employee ID: $employeeIdByEmail.value');
    employeeId.value = employeeIdByEmail.value.employeeId;
    final data = await getEmployeePrefillMaster(empId:employeeIdByEmail.value.employeeId);

    // if (recordTypes.isNotEmpty) {
    //   selectedRecordTypeId.value = recordTypes.first.recordId; // int
    //   selectedRecordName.value = recordTypes.first.recordName ?? '';
    // } else {
    //   selectedRecordTypeId.value = 0;
    //   selectedRecordName.value = '';
    // }
  }
  void clearEmpId(){
    employeeIdByEmail.value = EmployeeIdByEmail(employeeId: 0);
    employeeId.value = 0;
  }
  Future<void> fetchPatientNoteRecord({required int empId, required String date}) async {
    print('Selected date ${date}');
     patientVisitNoteData.value = await getPatientVisitesNote(empId: empId, date: date);
  }
  Future<void> fetchVisitDetails({required int visitId}) async {
    visitDetailModel.value = await getVisitDetailsData(visitId: visitId);
  }
  Future<void> fetchClinitionLoginDetails() async {
    clinitinaLoginDataModel.value = await getLoginClinitianData();
  }
  Future<void> fetchAssistanceDropdown({required int clinicianEmployeeTypeId}) async {
    employeeAssistantTypeModel.value = await getAssistanceVisit(clinicianEmployeeTypeId: clinicianEmployeeTypeId);
  }


  /// Edit Profile Employee ID fetch method
  // Future<int> getEmployeeIdMaster() async {
  //   var dataId = 0;
  //   final companyId = await TokenManager.getCompanyId();
  //   final email = await TokenManager.getEmail();
  //   try {
  //     isLoading.value = true;
  //     error.value = '';
  //
  //
  //     final res = await _api.get(ProfileRepository.getEmpIdByEmail(companyId: companyId, email: email));
  //     if (res.statusCode == 200 || res.statusCode == 201) {
  //         dataId = res.data?? 0;
  //       return dataId;
  //     } else {
  //       error.value = "failed to load data";
  //     }
  //   } catch (e) {
  //     error.value = e.toString();
  //   } finally {
  //     isLoading.value = false;
  //   }
  //
  //   // ✅ return ONLY here
  //   return dataId;
  // }

  Future<ClinitinaLoginDataModel> getLoginClinitianData() async {
    // List<OfferLetterData> itemsList = [];
    var itemsList = ClinitinaLoginDataModel(
        clinicianFullName: '',
        imageUrl: '',
        employeeTypeId: 0,
        abbreviation: '',
        color: '',
        employeeType: '',
        age: 0,
        gender: '');
    final companyId = await TokenManager.getCompanyId();
    final email = await TokenManager.getEmail();
    try {
      isClinitianloading.value = true;
      error.value = '';
      // final response =  await _api.get(ProfileRepository.getClinitianData());  // MOCKED for local UI testing
      final response = mockResponse(MockData.get('profile.clinicianData'));
      if (response.statusCode == 200 || response.statusCode == 201) {
        itemsList = ClinitinaLoginDataModel(
            clinicianFullName: response.data['clinicianFullName'] ?? '',
            imageUrl: response.data['imageUrl'] ?? '',
            employeeTypeId: response.data['employeeTypeId'] ?? 0,
            abbreviation: response.data['abbreviation'] ?? '',
            color: response.data['color'] ?? '',
            employeeType: response.data['employeeType'] ?? '',
            age: response.data['age'] ?? 0,
            gender: response.data['gender'] ?? '');
      } else {
        print('Api Error');
        error.value = "failed to load data";
      }
      print("Response:::::${response}");
      return itemsList;
    } catch (e) {
      error.value = e.toString();
      isClinitianloading.value = false;
      print("Error $e");
      return itemsList;
    }
  }

  Future<EmployeeIdByEmail> getEmployeeIdMaster() async {
    // List<OfferLetterData> itemsList = [];
    var itemsList = EmployeeIdByEmail(employeeId: 0);
    final companyId = await TokenManager.getCompanyId();
    final email = await TokenManager.getEmail();
    try {
      isLoading.value = true;
      error.value = '';
      // final response =  await _api.get(ProfileRepository.getEmpIdByEmail(companyId: companyId, email: email));  // MOCKED for local UI testing
      final response = mockResponse(MockData.get('profile.employeeIdByEmail'));
      if (response.statusCode == 200 || response.statusCode == 201) {
        itemsList = EmployeeIdByEmail(employeeId: int.parse(response.data));
      } else {
        print('Api Error');
        error.value = "failed to load data";
      }
      print("Response:::::${response}");
      return itemsList;
    } catch (e) {
      error.value = e.toString();
      isLoading.value = false;
      print("Error $e");
      return itemsList;
    }
  }
  /// Edit Profile
  Future<ApiData> patchEmployeeDataData({
    required int empId,
    required String employeeFirstName,
    required String employeeLastName,
    required String employeePhone,
    required String employeeEmail,
    required String employeeaddress,
  }) async {
    // Shared helper — add once at the top of the class (or in a utils file)
    String extractBackendMessage(dynamic data, String? fallback) {
      if (data is Map<String, dynamic> && data['message'] != null) {
        return data['message'].toString();
      } else if (data is String && data.isNotEmpty) {
        return data;
      }
      return fallback ?? AppString.somethingWentWrong;
    }
    try {
      isEmployeeSaveLoading.value = true;
      error.value = '';

      final userId = await TokenManager.getUserId();
      final companyId = await TokenManager.getCompanyId();

      // final res = await _api.patch(
      //   ProfileRepository.patchEmployeeData(empId: empId),
      //   {
      //     "employeeId": empId,
      //     "userId": userId,
      //     "firstName": employeeFirstName,
      //     "lastName": employeeLastName,
      //     "primaryPhoneNbr": employeePhone,
      //     "personalEmail": employeeEmail,
      //     "companyId": companyId,
      //   },
      // );  // MOCKED for local UI testing
      final res = mockResponse(MockData.get('profile.patchEmployee'));

      if (res.statusCode == 200 || res.statusCode == 201) {
        final backendMessage = extractBackendMessage(res.data, res.statusMessage);
        return ApiData(
          success: true,
          message: backendMessage,
          statusCode: res.statusCode!,
        );
      } else {
        final backendMessage = extractBackendMessage(res.data, res.statusMessage);
        error.value = backendMessage;
        return ApiData(
          success: false,
          message: backendMessage,
          statusCode: res.statusCode!,
        );
      }
    } on DioException catch (e) {
      final backendMessage = extractBackendMessage(e.response?.data, null);
      error.value = backendMessage;
      return ApiData(
        success: false,
        message: backendMessage,
        statusCode: e.response?.statusCode ?? 404,
      );
    } catch (e) {
      error.value = e.toString();
      return ApiData(
        success: false,
        message: AppString.somethingWentWrong,
        statusCode: 404,
      );
    } finally {
      isEmployeeSaveLoading.value = false;
    }
  }

  /// Attach employee imageBase64
  Future<ApiData> attachEmployeIamge({
    required int empId,
  }) async {
    try {
      isEmployeeSaveLoading.value = true;
      error.value = '';
      // final res = await _api.post(ProfileRepository.attachEmployeeImageData(empId: empId), {
      //   "base64" : imageBase64.value,
      // });  // MOCKED for local UI testing
      final res = mockResponse(MockData.get('profile.attachImage'));

      if (res.statusCode == 200 || res.statusCode == 201) {
        // final data = res.data as Map<String, dynamic>;
        return ApiData(
            success: true,
            message: res.statusMessage!,
            statusCode: res.statusCode!
        );
      }else{
        error.value = res.statusMessage!;
        return ApiData(
            success: false,
            message: res.statusMessage!,
            statusCode: res.statusCode!
        );
      }
    } catch (e) {
      error.value = e.toString();
      return ApiData(
          success: false,
          message:AppString.somethingWentWrong,
          statusCode: 404
      );
    } finally {
      isEmployeeSaveLoading.value = false;
    }
  }


  Future<EmployeePrefill> getEmployeePrefillMaster(
      {required int empId}
      ) async {
    var itemData = EmployeePrefill(
        employeeId: 0,
        employeeFirstName: '',
        employeeLastName: '',
        employeeEmail: '',
        employeePhone: '',
        employeeAddress: '',
        employeeImage: '');
    try {
      isEmployeeLoading.value = true;
      error.value = '';

      // final res = await _api.get(ProfileRepository.patchEmployeeData(empId: empId));  // MOCKED for local UI testing
      final res = mockResponse(MockData.get('profile.employeePrefill'));
      if (res.statusCode == 200 || res.statusCode == 201) {
          itemData = EmployeePrefill(
              employeeId: res.data['employeeId'] ?? 0,
              employeeFirstName: res.data['firstName'] ?? '',
              employeeLastName: res.data['lastName'] ?? '',
              employeeEmail:  res.data['personalEmail'] ?? '',
              employeePhone: res.data['primaryPhoneNbr'] ?? '',
              employeeAddress: res.data['finalAddress'] ?? '',
              employeeImage: res.data['imgurl'] ?? ''
              );
          firstNameController.value.text = itemData.employeeFirstName ?? '';
          lastNameController.value.text =
              itemData.employeeLastName ?? '';

          emailController.value.text =
              itemData.employeeEmail ?? '';

          phoneController.value.text =
              itemData.employeePhone ?? '';

          employeeImage.value = itemData.employeeImage;

      } else {
        error.value = "failed to load emp data";
      }
    } catch (e) {
      error.value = e.toString();
    } finally {
      isEmployeeLoading.value = false;
    }

    // ✅ return ONLY here
    return itemData;
  }

  Future<PatientVisitsNoteModel> getPatientVisitesNote(
      {required int empId,
      required String date}
      ) async {
    var itemData = PatientVisitsNoteModel(
        employeeId: empId, date: date, items: const []);
    String formatTimeToAMPM(String? dateTimeString) {
      if (dateTimeString == null || dateTimeString.isEmpty) return '';
      try {
        final DateTime dateTime = DateTime.parse(dateTimeString).toLocal();
        return DateFormat('h.mm a').format(dateTime);
      } catch (e) {
        return '';
      }
    }
    String toShortForm(String? name) {
      if (name == null || name.trim().isEmpty) return '';
      return name
          .trim()
          .split(RegExp(r'\s+'))
          .where((word) => word.isNotEmpty)
          .map((word) => word[0].toUpperCase())
          .join();
    }

    String getDisplayName(String? name) {
      if (name == null || name.trim().isEmpty) return '';

      final words = name
          .trim()
          .split(RegExp(r'\s+'))
          .where((word) => word.isNotEmpty)
          .toList();

      if (words.length == 1) {
        return words.first;          // e.g. "SOC" -> "SOC"
      }

      return toShortForm(name);      // e.g. "Physical Therapy Notes" -> "PTN"
    }
    try {
      isEmployeeLoading.value = true;
      error.value = '';
      // final res = await _api.get(ProfileRepository.getPatientVisitsNote(empId: empId, date: date));  // MOCKED for local UI testing
      final res = mockResponse(MockData.get('profile.patientVisitsNote'));
      if (res.statusCode == 200 || res.statusCode == 201) {
        List<PatientVisitItems> patientItems = [];
        if (res.data["items"] != null) {
          for (var p in res.data["items"]) {
            final primaryDiagnosis = p["primaryDiagnosis"] ?? {};
            final visitType = p["visitType"] ?? {};
            patientItems.add(
              PatientVisitItems(
                  visitId: p['visitId'] ?? 0,
                  employeeId: p['employeeId'] ?? 0,
                  employeeTypeId:  p["employeeTypeId"] ?? 0,
                  pt_id: p['pt_id'] ?? 0,
                  patientName: p['patientName'] ?? '',
                  imageUrl: p['imageUrl'] ?? '',
                  primaryDiagnosis: PrimaryDiagnosis(
                      id: primaryDiagnosis['id'] ?? 0,
                      name: primaryDiagnosis['name'] ?? '',
                      code: primaryDiagnosis['code'] ?? ''
                  ),
                  visitType: VisitType(
                      id: visitType['id'] ?? 0,
                      name: visitType['name'] != null ? getDisplayName(visitType['name']): '',
                  ),
                  visiteDateTimeFrom: p['visiteDateTimeFrom'] != null ? formatTimeToAMPM(p['visiteDateTimeFrom']) : '',
                  visitDateTimeTo: p['visitDateTimeTo'] != null ? formatTimeToAMPM(p['visitDateTimeTo']) : '',
                  isVisitCompleted: p['isVisitCompleted'] ?? false,
                  isVisitMissed: p['isVisitMissed'] ?? false,
                  isVisitAccepted: p['isVisitAccepted'] ?? false,
                  isSecondLastEpisodeVisit: p["isSecondLastEpisodeVisit"] ?? false,
                  visitCharge: double.parse(
                    (((p['visit_charge'] as num?)?.toDouble() ?? 0.0)
                        .toStringAsFixed(2)),
                  ),

              ),
            );
          }
        }
        itemData = PatientVisitsNoteModel(
          employeeId: res.data['employeeId'] ?? 0,
          date: res.data['date'] ?? '',
          items: patientItems,
        );
      } else {
        error.value = "failed to load emp data";
      }
    } catch (e) {
      error.value = e.toString();
    } finally {
      isEmployeeLoading.value = false;
    }
    // ✅ return ONLY here
    return itemData;
  }


  Future<VisitDetailModel> getVisitDetailsData(
      {required int visitId}
      ) async {
    var itemData = VisitDetailModel(
      visitHeader: VisitHeader(
        visitId: visitId,
        visitTypeId: 0,
        visitTypeName: '',
        timeRange: '',
      ),
      patient: Patient(
        name: '',
        imageUrl: '',
        primaryDiagnosis: '',
        summary: '',
        address: '',
      ),
      planOfCare: const [],
      visitInstructions: const [],
      otherClinicians: const [],
      weeks: const [],
      isAssistantUser: false,
    );
    String formatTimeToAMPM(String? dateTimeString) {
      if (dateTimeString == null || dateTimeString.isEmpty) return '';

      try {
        final DateTime dateTime = DateTime.parse(dateTimeString).toLocal();
        return DateFormat('h.mm a').format(dateTime).replaceAll(' ', '');
      } catch (e) {
        return '';
      }
    }
    try {
      isEmployeedetailsLoading.value = true;
      error.value = '';
      // final res = await _api.get(ProfileRepository.getVisitDetails(visitId: visitId));  // MOCKED for local UI testing
      final res = mockResponse(MockData.get('profile.visitDetails'));


      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = res.data;

        final header = data['visitHeader'];
        final patient = data['patient'];

        itemData = VisitDetailModel(
          visitHeader: VisitHeader(
            visitId: header['visitId'] ?? 0,
            visitTypeId: header['visitTypeId'] ?? 0,
            visitTypeName: header['visitTypeName'] ?? '',
            timeRange: header['timeRange'] ?? '',
          ),
          isAssistantUser: data['isAssistantUser'] ?? false,
          patient: Patient(
            name: patient['name'] ?? '',
            imageUrl: patient['imageUrl'] ?? '',
            primaryDiagnosis: patient['primaryDiagnosis'] ?? '',
            summary: patient['summary'] ?? '',
            address: patient['address'] ?? '',
          ),
          planOfCare: (data['planOfCare'] as List? ?? [])
              .map(
                (e) => PlanOfCare(
                  color: e?['color']??'',
              employeeTypeId: e?['employeeTypeId'] ?? 0,
              abbreviation: e?['abbreviation'] ?? '',
            ),
          )
              .toList(),
          visitInstructions:
          List.generate((data['visitInstructions'] as List? ?? []).length,
                  (_) => VisitInstruction()),
          otherClinicians:(data['otherClinicians'] as List? ?? [])
              .map(
                (o) => OtherClinician(
                  userId: o['userId'] ?? 0,
                    employeeTypeColor: o['employeeTypeColor'] ?? '',
                    employeeId: o['employeeId'] ?? 0,
                    name: o['name'] ?? '',
                    employeeTypeAbbreviation: o['employeeTypeAbbreviation'] ?? '',
                    phone: o['phone'] ?? '',
                    imageUrl: o['imageUrl'] ?? ''),
          )
              .toList(),
          weeks: (data['weeks'] as List? ?? [])
              .map(
                (w) => Week(
              weekNo: w?['weekNo'] ?? 0,
              socLabel: w?['socLabel'] ?? '',
              items: (w?['items'] as List? ?? [])
                  .map(
                    (i) => WeekItem(
                  visitId: i?['visitId'] ?? 0,
                  date: i?['date'] ?? '',
                  employeeTypeAbbreviation:
                  i?['employeeTypeAbbreviation'] ?? '',
                  timeRange: i?['timeRange'] ?? '',
                  isCompleted: i?['isCompleted'] ?? false,
                ),
              )
                  .toList(),
            ),
          )
              .toList(),
        );
      }
      else {
        error.value = "failed to load emp data";
      }
    } catch (e) {
      error.value = e.toString();
    } finally {
      isEmployeedetailsLoading.value = false;
    }
    // ✅ return ONLY here
    return itemData;
  }

  /// Attach employee imageBase64
  Future<ApiData> postVisitUpdate({
    required int visitId,
    required String rejectedReason,
    required bool isVisitAccepted,
  }) async {
    try {
      isVisitUpdateLoding.value = true;
      error.value = '';
      // final res = await _api.post(ProfileRepository.postVisitAceptReject(),
      //     isVisitAccepted ? {
      //       "visitId": visitId,
      //       "isVisitAccepted": isVisitAccepted
      //     } : {
      //       "visitId": visitId,
      //       "rejectedReason": rejectedReason,
      //       "isVisitAccepted": isVisitAccepted
      //     }
      // );  // MOCKED for local UI testing
      final res = mockResponse(MockData.get('profile.visitAcceptReject'));

      if (res.statusCode == 200 || res.statusCode == 201) {
        // final data = res.data as Map<String, dynamic>;
        return ApiData(
            success: true,
            message: res.statusMessage!,
            statusCode: res.statusCode!
        );
      }else{
        error.value = res.statusMessage!;
        return ApiData(
            success: false,
            message: res.statusMessage!,
            statusCode: res.statusCode!
        );
      }
    } catch (e) {
      error.value = e.toString();
      return ApiData(
          success: false,
          message:AppString.somethingWentWrong,
          statusCode: 404
      );
    } finally {
      isVisitUpdateLoding.value = false;
    }
  }

  /// Assistance

  Future<List<EmployeeAssistantTypeModel>> getAssistanceVisit({required int clinicianEmployeeTypeId}) async {
    List<EmployeeAssistantTypeModel> itemData = [];
    String formatTimeToAMPM(String? dateTimeString) {
      if (dateTimeString == null || dateTimeString.isEmpty) return '';

      try {
        final DateTime dateTime = DateTime.parse(dateTimeString).toLocal();
        return DateFormat('h.mm a').format(dateTime).replaceAll(' ', '');
      } catch (e) {
        return '';
      }
    }
    try {
      isAssistanceLoading.value = true;
      error.value = '';

      // final res = await _api.get(
      //   ProfileRepository.getAssistanceDropdown(clinicianEmployeeTypeId: clinicianEmployeeTypeId),
      // );  // MOCKED for local UI testing
      final res = mockResponse(MockData.get('profile.assistanceDropdown'));

      if(res.statusCode == 200 || res.statusCode == 201) {
        final data = res.data;
        for(var item in res.data){
          final List<AssistantModel> assistants = [];

          if (item['assistants'] != null) {
            for (var a in item['assistants']) {
              assistants.add(
                AssistantModel(
                    employeeId: a['employeeId'] ?? 0,
                    userId: a['userId'] ?? 0,
                    userName:  a['userName'] ?? '',
                    personalEmail: a["personalEmail"] ?? ''

                ),
              );
            }
          }
          itemData.add(EmployeeAssistantTypeModel(
              employeeTypeId: item['employeeTypeId'] ?? 0,
              employeeType: item['employeeType'] ?? '',
              color: item['color'] ?? '',
              abbreviation: item['abbreviation'] ?? '',
              departmentId: item['departmentId'] ?? 0,
              isAssistant: item['isAssistant'] ?? false,
              assistantMasterId: item['assistantMasterId'] ?? 0,
              assistants: assistants));
        }

      } else {
        error.value = "failed to load data";
      }
    } catch (e) {
      error.value = e.toString();
      debugPrint('error assistance details: $e');
    } finally {
      isAssistanceLoading.value = false;
    }

    return itemData;
  }
  Future<ApiData> PostAssignAssistance({
    required int visitId,
   required int EmployeeId
  }) async {
    try {
      isAssistantAssignLoading.value = true;
      error.value = '';
      // final res = await _api.post(ProfileRepository.postAssignAssistant, {
      //   "visitId": visitId,
      //   "employeeId": EmployeeId
      // });  // MOCKED for local UI testing
      final res = mockResponse(MockData.get('profile.assignAssistant'));

      if (res.statusCode == 200 || res.statusCode == 201) {
        // final data = res.data as Map<String, dynamic>;
        return ApiData(
            success: true,
            message: res.statusMessage!,
            statusCode: res.statusCode!
        );
      }else{
        error.value = res.statusMessage!;
        return ApiData(
            success: false,
            message: res.statusMessage!,
            statusCode: res.statusCode!
        );
      }
    } catch (e) {
      error.value = e.toString();
      return ApiData(
          success: false,
          message:AppString.somethingWentWrong,
          statusCode: 404
      );
    } finally {
      isAssistantAssignLoading.value = false;
    }
  }
}
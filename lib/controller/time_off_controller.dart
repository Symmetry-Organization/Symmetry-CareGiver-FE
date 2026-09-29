import 'package:clinician_app/controller/repository/profile_repo.dart';
import 'package:clinician_app/model/profile/time_off_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../core/constant/app_string.dart';
import '../model/request/request_data_model.dart';
import '../services/auth_api_services/auth_services.dart';
import 'package:clinician_app/services/mock/mock_data_service.dart';

class TimeController extends GetxController {
  final ApiService _api = Get.put(ApiService());
  final isLoading = false.obs;
  final isTimeOffSaveLoading = false.obs;
  final error = ''.obs;
  final timeOfftype = <TimeOffType>[].obs;
  final leaveTypeRecord = <LeaveType>[].obs;
  RxInt homeIndex = 0.obs;
  RxString timeOfType = ''.obs;
  RxInt timeOfTypeId = 0.obs;
  RxString leaveType = ''.obs;
  RxInt leaveTypeId = 0.obs;
  RxBool halfDayaLeave = false.obs;
  RxString recordType = ''.obs;
  RxString zoneType = ''.obs;
  final timeOffHistory = TimeOffHistory(timeOffData: []).obs;

  @override
  void onInit() {
    super.onInit();
    fetchDropdownMaster();

  }
  /// Methods
  Future<void> fetchDropdownMaster() async {
    final list = await getTimeOffTypeData();
    final leaveList = await getLeaveTypeData();
    timeOfftype.assignAll(list);
    leaveTypeRecord.assignAll(leaveList);
  }
  Future<void> fetchEmpHistoryTimeOff({required int employeeId}) async {
     timeOffHistory.value = await getTimeOffEmpDataHistory(empId: employeeId);
  }




  /// Api's call

  Future<List<TimeOffType>> getTimeOffTypeData() async {
    List<TimeOffType> itemData = [];
    try {
      isLoading.value = true;
      error.value = '';

      // final res = await _api.get(ProfileRepository.getTimeOffTypes());  // MOCKED for local UI testing
      final res = mockResponse(MockData.get('timeOff.types'));

      if (res.statusCode == 200 || res.statusCode == 201) {
        for (var i in res.data) {
          itemData.add(
            TimeOffType(
              id: i['id'] ?? 0,
              name: i['name'] ?? '',
            ),
          );
        }
      } else {
        error.value = "failed to load data";
      }
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }

    // ✅ return ONLY here
    return itemData;
  }
  Future<List<LeaveType>> getLeaveTypeData() async {
    List<LeaveType> itemData = [];
    try {
      isLoading.value = true;
      error.value = '';

      // final res = await _api.get(ProfileRepository.getLeaveType());  // MOCKED for local UI testing
      final res = mockResponse(MockData.get('timeOff.leaveTypes'));

      if (res.statusCode == 200 || res.statusCode == 201) {
        for (var i in res.data) {
          itemData.add(
            LeaveType(
              id: i['id'] ?? 0,
              name: i['name'] ?? '',
            ),
          );
        }
      } else {
        error.value = "failed to load data";
      }
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }

    // ✅ return ONLY here
    return itemData;
  }

  Future<ApiData> postTimeOffData({
    required int empId,
    required int timeOffTypeId,
    required int leaveTypeId,
    required String leaveType,
    required String startDate,
    required String endDate,
    required String reason,
    required bool firstHalf,
  }) async {
    try {
      isTimeOffSaveLoading.value = true;
      error.value = '';

      // final res = await _api.post(
      //   ProfileRepository.postAddTimeOffRequest(),
      //   leaveType == 'One day'
      //       ? {
      //     "employeeId": empId,
      //     "timeOffTypeId": timeOffTypeId,
      //     "leaveTypeId": leaveTypeId,
      //     "startDate": startDate,
      //     "reason": reason,
      //   }
      //       : leaveType == "Multi days"
      //       ? {
      //     "employeeId": empId,
      //     "timeOffTypeId": timeOffTypeId,
      //     "leaveTypeId": leaveTypeId,
      //     "startDate": startDate,
      //     "endDate": endDate,
      //     "reason": reason,
      //   }
      //       : {
      //     "employeeId": empId,
      //     "timeOffTypeId": timeOffTypeId,
      //     "leaveTypeId": leaveTypeId,
      //     "reason": reason,
      //     "firstHalf": firstHalf,
      //   },
      // );  // MOCKED for local UI testing
      final res = mockResponse(MockData.get('timeOff.addRequest'));

      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = res.data as Map<String, dynamic>?;
        final backendMessage = data?['message']?.toString() ??
            res.statusMessage ??
            AppString.somethingWentWrong;

        return ApiData(
          success: true,
          message: backendMessage,
          statusCode: res.statusCode!,
        );
      } else {
        final data = res.data as Map<String, dynamic>?;
        final backendMessage = data?['message']?.toString() ??
            res.statusMessage ??
            AppString.somethingWentWrong;

        error.value = backendMessage;
        return ApiData(
          success: false,
          message: backendMessage,
          statusCode: res.statusCode!,
        );
      }
    } on DioException catch (e) {
      final data = e.response?.data;
      String backendMessage;

      if (data is Map<String, dynamic> && data['message'] != null) {
        backendMessage = data['message'].toString();
      } else if (data is String && data.isNotEmpty) {
        backendMessage = data;
      } else {
        backendMessage = AppString.somethingWentWrong;
      }

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
      isTimeOffSaveLoading.value = false;
    }
  }

  Future<TimeOffHistory> getTimeOffEmpDataHistory({
    required int empId
  }) async {
    List<TimeOffData> itemData = [];
    String formatIOSDate(String iosDate) {
      if (iosDate.isEmpty) return '';

      DateTime dateTime = DateTime.parse(iosDate);

      return DateFormat('yyyy/MM/dd/h.mm a')
          .format(dateTime);
    }
    try {
      isLoading.value = true;
      error.value = '';

      // final res = await _api.get(ProfileRepository.getTimeOffHistory(empId: empId));  // MOCKED for local UI testing
      final res = mockResponse(MockData.get('timeOff.history'));

      if (res.statusCode == 200 || res.statusCode == 201) {
        for (var i in res.data['history']) {
          itemData.add(
            TimeOffData(
              timeOffRequestId: i['timeOffRequestId'] ?? 0,
              employeeId: i['employeeId'] ?? 0,
              employeeName: i['employeeName'] ?? '',
              timeOffTypeId: i['timeOffTypeId'] ?? 0,
              timeOffTypeName: i['timeOffTypeName'] ?? '',
              startDate: i['startDate'] != null ? formatIOSDate(i['startDate']) : '',
              endDate: i['endDate'] != null ? formatIOSDate(i['endDate']) : '',
              reason: i['reason'] ?? '',
              status: i['status'] ?? '',
              createdAt: i['createdAt'] != null ? formatIOSDate(i['createdAt']) : '',
            ),
          );
        }
        return TimeOffHistory(timeOffData: itemData);
      } else {
        error.value = "failed to load data";
      }
    } catch (e) {
      error.value = e.toString();
      debugPrint('error time off history: $e');
    } finally {
      isLoading.value = false;
    }

    // ✅ return ONLY here
    return TimeOffHistory(timeOffData: itemData);
  }
}

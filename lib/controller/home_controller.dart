import 'dart:async';
import 'dart:convert';

import 'package:clinician_app/controller/repository/request_repo.dart';
import 'package:clinician_app/core/constant/list_content.dart';
import 'package:clinician_app/model/request/request_data_model.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../model/request/patient_schedule_model.dart';
import '../model/request/requestList_model.dart';
import '../services/auth_api_services/auth_services.dart';
import 'package:clinician_app/services/mock/mock_data_service.dart';

class HomeController extends GetxController {
  final ApiService _api = Get.put(ApiService());

  final isRequestLoading = false.obs;
  final isScheduleLoading = false.obs;
  final error = ''.obs;

  final todayVisitsModel = TodayVisitsModel(todaysDate: '', visits: []).obs;

  final patientScheduleModel = PatientScheduleModel(
    imageUrl: '',
    patientName: '',
    diagnosisName: '',
    zoneName: '',
    inZone: false,
    visitTypeName: '',
    address: '',
    visitCharge: 0.0,
    weeks: [],
  ).obs;

  RxInt homeIndex = 0.obs;
  RxString statusVal = 'Pending'.obs;

  RxBool isLiveView = false.obs;
  RxList<RequestDataModel> requestList = <RequestDataModel>[].obs;

  RxList<RequestDataModel> get selectedReqTypeList => requestList
      .where(
        (val) =>
    val.status?.toLowerCase().contains(statusVal.value.toLowerCase()) ??
        false,
  )
      .toList()
      .obs;

  // ✅ first time loader control (UI should use this)
  final RxBool showFirstLoader = true.obs;

  // ✅ optional thin refresh indicator (not blocking UI)
  final RxBool isSilentRefreshing = false.obs;

  // ✅ store latest params for search/filter/refresh
  int _lastClinicianId = 0;
  String _lastVisitStatus = 'pending';
  String _lastPatientName = 'all';

  // ✅ debounce + overlap protection
  Timer? _debounceTimer;
  bool _isFetching = false;

  @override
  void onInit() {
    super.onInit();

    requestList.value = List.from(ListContent.requestDataList);
    requestList.refresh();

    ever(todayVisitsModel, (v) {
      // ignore: avoid_print
      print("✅ todayVisitsModel updated. total visits: ${v.visits.length}");
    });
  }

  void clearAllData() {
    todayVisitsModel.value = TodayVisitsModel(todaysDate: '', visits: []);
    patientScheduleModel.value = PatientScheduleModel(
      imageUrl: '',
      patientName: '',
      diagnosisName: '',
      zoneName: '',
      inZone: false,
      visitTypeName: '',
      address: '',
      visitCharge: 0.0,
      weeks: [],
    );
    showFirstLoader.value = true;
  }

  /// ✅ debounce search (call this from UI onChanged)
  void debounceSearch({
    required String patientName,
    Duration delay = const Duration(milliseconds: 500),
  }) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(delay, () async {
      await fetchListAllDetails(
        clinicianId: _lastClinicianId,
        visitStatus: _lastVisitStatus,
        patientName: patientName.trim().isEmpty ? 'all' : patientName.trim(),
        isPollingCall: false,
      );
    });
  }

  /// ✅ re-fetch the request list using whatever clinician/filter/search
  /// params were used last — call this after accept/reject, or when
  /// returning to the request list screen.
  Future<void> refreshRequestList() async {
    await fetchListAllDetails(
      clinicianId: _lastClinicianId,
      visitStatus: _lastVisitStatus,
      patientName: _lastPatientName,
      isPollingCall: false,
    );
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    super.onClose();
  }

  /// ---------------- FETCH METHODS ----------------

  Future<void> fetchListAllDetails({
    required int clinicianId,
    required String visitStatus,
    required String patientName,

    /// if true -> this is background refresh (no first loader)
    bool isPollingCall = false,
  }) async {
    // ✅ guard: never call API with an invalid clinician id
    if (clinicianId == 0) {
      print('⚠️ fetchListAllDetails skipped: clinicianId is 0');
      return;
    }

    // ✅ status always lowercase so polling/refresh can't mismatch
    final normalizedStatus = visitStatus.toLowerCase();

    // store latest params for polling/search/filter
    _lastClinicianId = clinicianId;
    _lastVisitStatus = normalizedStatus;
    _lastPatientName = patientName.trim().isEmpty ? 'all' : patientName.trim();

    // avoid overlapping calls (very important for polling)
    if (_isFetching) return;
    _isFetching = true;

    try {
      // show small indicator only for polling refresh
      if (isPollingCall && !showFirstLoader.value) {
        isSilentRefreshing.value = true;
      }

      final result = await getRequestListData(
        clinicianId: clinicianId,
        visitStatus: normalizedStatus,
        patientName: _lastPatientName,
      );

      // ✅ on a SILENT poll, don't wipe existing data if the call errored
      if (isPollingCall && error.value.isNotEmpty && result.visits.isEmpty) {
        print('⚠️ polling call failed, keeping existing data');
      } else {
        todayVisitsModel.value = result;
      }

      // After first successful load, disable first loader forever
      if (showFirstLoader.value) {
        showFirstLoader.value = false;
      }
    } finally {
      isSilentRefreshing.value = false;
      _isFetching = false;
    }
  }

  Future<void> fetchPatientScheduleData({required int visitId}) async {
    patientScheduleModel.value = await getVisitScheduleData(visitId: visitId);
  }

  /// ---------------- API METHODS ----------------

  Future<TodayVisitsModel> getRequestListData({
    required int clinicianId,
    required String visitStatus,
    required String patientName,
  }) async {
    TodayVisitsModel? itemData;

    // ---------- type-safe helpers ----------
    String asString(dynamic v, [String def = '']) {
      if (v == null) return def;
      return v.toString();
    }

    int asInt(dynamic v, [int def = 0]) {
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v) ?? def;
      return def;
    }

    double asDouble(dynamic v, [double def = 0.0]) {
      if (v is double) return v;
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? def;
      return def;
    }

    String formatIOSDate(dynamic iosDate) {
      final s = asString(iosDate);
      if (s.isEmpty) return '';
      try {
        final DateTime dateTime = DateTime.parse(s);
        return DateFormat('dd MMM yyyy').format(dateTime).toLowerCase();
      } catch (_) {
        return s; // show raw value instead of crashing
      }
    }

    String formatTimeToAMPM(String? dateTimeString) {
      if (dateTimeString == null || dateTimeString.isEmpty) return '';
      try {
        final DateTime dateTime = DateTime.parse(dateTimeString).toLocal();
        return DateFormat('h.mm a').format(dateTime);
      } catch (e) {
        return '';
      }
    }
    // ----------------------------------------

    try {
      isRequestLoading.value = true;
      error.value = '';

      // final res = await _api.get(
      //   RequestTabRepo.getRequestAllData(
      //     clinicianId: clinicianId,
      //     visitStatus: visitStatus,
      //     patientName: patientName,
      //   ),
      // );  // MOCKED for local UI testing
      final res = mockResponse(MockData.get('request.todayVisits'));

      if (res.statusCode == 200 || res.statusCode == 201) {
        // ✅ handle response arriving as a raw String
        final dynamic body =
        res.data is String ? jsonDecode(res.data as String) : res.data;

        final visitsRaw = (body['visits'] as List?) ?? [];
        print('✅ raw visits count: ${visitsRaw.length}');

        final List<PatientVisitModel> allVisits = [];

        for (final v in visitsRaw) {
          try {
            final List<VisitDetailsModel> visitDetails = [];
            final visitListRaw = (v['visitList'] as List?) ?? [];

            for (final x in visitListRaw) {
              visitDetails.add(
                VisitDetailsModel(
                  visitId: asInt(x['visitId']),
                  visitDateFrom: formatIOSDate(x['visitDateFrom']),
                  visitDateTo: formatIOSDate(x['visitDateTo']),
                  employeeTypeId: asInt(x['employeeTypeId']),
                  employeeTypeAbbreviation:
                  asString(x['employeeTypeAbbreviation']),
                  employeeTypeColor: asString(x['employeeTypeColor']),
                  visitStartTime: formatTimeToAMPM(x['visitDateFrom']),
                  visitEndTime: formatTimeToAMPM(x['visitDateTo']),
                ),
              );
            }

            allVisits.add(
              PatientVisitModel(
                visitId: asInt(v['visitId']),
                visitDateTime: formatIOSDate(v['visitDateTime']),
                visitStatus: asString(v['visitStatus']),
                visitTime: formatTimeToAMPM(v['visitDateTime']),
                ptId: asInt(v['pt_id']),
                patientName: asString(v['patientName']),
                patientImage: asString(v['patientImage']),
                patientGenderId: asInt(v['patientGenderId']),
                genderName: asString(v['genderName']),
                patientAge: asInt(v['patientAge']),
                primaryDiagnosisId: asInt(v['primaryDiagnosisId']),
                primaryDiagnosisName:
                asString(v['primaryDiagnosisName'], '--'),
                // ✅ inZone may come as bool OR String from the API
                inZone: asString(v['inZone']),
                warning: asString(v['warning'] ?? ''),
                zoneId: asInt(v['zoneId']),
                zoneName: asString(v['zoneName'], '--'),
                patientAddress: asString(v['patientAddress'], '--'),
                visitNote: asString(v['visit_note']),
                // ✅ int from JSON no longer crashes a double field
                distance: asDouble(v['distance']),
                visitCharge: double.parse(
                  asDouble(v['visit_charge']).toStringAsFixed(2),
                ),
                visitList: visitDetails,
              ),
            );
          } catch (rowError) {
            // ✅ skip the one bad row, keep the rest
            print('⚠️ skipped one visit row: $rowError');
          }
        }

        itemData = TodayVisitsModel(
          todaysDate: asString(body['todaysDate']),
          visits: allVisits,
        );
        print('✅ parsed visits count: ${allVisits.length}');
        return itemData;
      } else {
        error.value = "Failed to list data";
      }
    } catch (e, st) {
      // ✅ print the REAL error so parsing failures are never silent
      print('❌ getRequestListData ERROR: $e');
      print(st);
      error.value = e.toString();
    } finally {
      isRequestLoading.value = false;
    }

    return itemData ?? TodayVisitsModel(todaysDate: '', visits: []);
  }

  Future<PatientScheduleModel> getVisitScheduleData({
    required int visitId,
  }) async {
    PatientScheduleModel? itemData;

    try {
      isScheduleLoading.value = true;
      error.value = '';

      // final res =
      // await _api.get(RequestTabRepo.getRequestSchedule(visitId: visitId));  // MOCKED for local UI testing
      final res = mockResponse(MockData.get('request.visitSchedule'));

      if (res.statusCode == 200 || res.statusCode == 201) {
        final dynamic data =
        res.data is String ? jsonDecode(res.data as String) : res.data;

        final List<WeekSchedule> weeksList = [];
        final weeksRaw = (data['weeks'] as List?) ?? [];

        for (final w in weeksRaw) {
          final List<VisitScheduleItem> visitList = [];
          final visitsRaw = (w['visits'] as List?) ?? [];

          for (final v in visitsRaw) {
            visitList.add(
              VisitScheduleItem(
                visitId: v['visitId'] ?? 0,
                visitName: v['visitName'] ?? '',
                visitDate: v['visitDate'] ?? '',
                visitTimeFrom: v['visitTimeFrom'] ?? '',
                visitTimeTo: v['visitTimeTo'] ?? '',
                employeeTypeId: v['employeeTypeId'] ?? 0,
                employeeTypeAbbreviation: v['employeeTypeAbbreviation'] ?? '',
                employeeTypeColor: v['employeeTypeColor'] ?? '',
                remainingVisitsCount: v['remainingVisitsCount'] ?? 0,
                episodeTriggerType: v['episodeTriggerType'] ?? '',
                daysToEpisodeEnd: v['daysToEpisodeEnd'] ?? 0,
                lastVisitPerformedBy: v['lastVisitPerformedBy'] ?? '',
                pendingAssistantFormIds: List<int>.from(v['pendingAssistantFormIds'] ?? []),
                lastVisitIds: List<int>.from(v['lastVisitIds'] ?? []),
                isAttemptedVisit: v['isAttemptedVisit'] ?? false,
                isSecondLastEpisodeVisit: v['isSecondLastEpisodeVisit'] ?? false,
                employeeId: v['employeeId'] ?? 0,
                visitType: v['visitType'] ?? 0,
                isVisitCompleted: v['isVisitCompleted'] ?? false,
                isVisitMissed: v['isVisitMissed'] ?? false,
                onWay: v['onWay'] ?? false,
                recordTypeId: v['recordTypeId'] ?? 0,
                isRescheduled: v['isRescheduled'] ?? false,
                rescheduledAt: v['rescheduledAt'] ?? '',
                rescheduleReasonId: v['rescheduleReasonId'] ?? 0,
                visitPhotoUrl: v['visitPhotoUrl'] ?? '',
              ),
            );
          }

          weeksList.add(
            WeekSchedule(
              week: w['week'] ?? 0,
              patientId: w['patientId'] ?? 0,
              chartId: w['chartNo'] ?? 0,
              visits: visitList,
            ),
          );
        }

        itemData = PatientScheduleModel(
          imageUrl: data['imageUrl'] ?? '',
          patientName: data['patientName'] ?? '',
          diagnosisName: data['diagnosisName'] ?? '',
          zoneName: data['zoneName'] ?? '',
          inZone: data['inZone'] ?? false,
          visitTypeName: data['visitTypeName'] ?? '',
          address: data['address'] ?? '',
          visitCharge: (data['visitCharge'] ?? 0).toDouble(),
          weeks: weeksList,
        );
      } else {
        error.value = "Failed to list data";
      }
    } catch (e, st) {
      print('❌ getVisitScheduleData ERROR: $e');
      print(st);
      error.value = e.toString();
    } finally {
      isScheduleLoading.value = false;
    }

    return itemData ??
        PatientScheduleModel(
          imageUrl: '',
          patientName: '',
          diagnosisName: '',
          zoneName: '',
          inZone: false,
          visitTypeName: '',
          address: '',
          visitCharge: 0.0,
          weeks: [],
        );
  }
}
import 'package:clinician_app/controller/repository/calender_repo.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../model/calender/calender_model.dart';
import '../model/calender/list_model.dart';
import '../pages/calender_section/calender_screen.dart';
import '../services/auth_api_services/auth_services.dart';
import 'package:clinician_app/services/mock/mock_data_service.dart';

/// Status values accepted by the calendar list endpoint.
abstract final class CalendarStatusFilter {
  static const String pending = 'pending';
  static const String accepted = 'accepted';
  static const String rejected = 'rejected';
  static const String completed = 'completed';

  static const List<String> all = [pending, accepted, rejected, completed];
}

class CalenderListController extends GetxController {
  final ApiService _api = Get.put(ApiService());

  final isListLoading = false.obs;
  final error = ''.obs;

  final calenderListModel = CalenderListModel(visits: []).obs;
  final RxList<VisitModelData> visitList = <VisitModelData>[].obs;
  final RxList<Appointment> calendarAppointments = <Appointment>[].obs;

  RxInt contentTypeInx = 0.obs;

  /// Filter sheet state. Zone is applied client-side over the loaded list;
  /// status is sent to the API on the next refresh.
  final Rxn<bool> zoneFilterInZone = Rxn<bool>();
  final RxString statusFilter = CalendarStatusFilter.pending.obs;

  /// Loaded visits narrowed by the zone filter (null = all).
  List<VisitsListData> get filteredListVisits {
    final visits = calenderListModel.value.visits;
    final inZone = zoneFilterInZone.value;
    if (inZone == null) return visits;
    return visits.where((v) => v.inZone == inZone).toList();
  }
  Rx<DateTime> currentDate = DateTime.now().obs;
  final calController = CalendarController().obs;

  // ============================
  // ✅ overlap/rate protection (no periodic polling anymore)
  // ============================
  bool _pollInProgress = false;

  /// A load asked for while another one was in flight. Only the latest one is
  /// kept — stepping through dates quickly must end on the date now selected.
  ({String status, String empIds, bool showLoader})? _queuedPoll;

  // ✅ show loader only first time
  bool _hasLoadedOnce = false;

  String get formattedDate => DateFormat('yyyy-MM-dd').format(currentDate.value);

  String get formattedDateReadable =>
      DateFormat('MMMM d, yyyy').format(currentDate.value);

  void changeDate(int day) {
    // Day arithmetic on the calendar fields, not on a Duration: adding 24 h
    // across a DST boundary can land back on the same date.
    final DateTime current = currentDate.value;
    currentDate.value = DateTime(current.year, current.month, current.day + day);
    if (contentTypeInx.value == 1) {
      calController.value.displayDate = currentDate.value;
    }
  }

  // ============================
  // ✅ Public APIs for screen
  // ============================

  /// One-time initial load (shows the full loader).
  void loadInitial({
    required String status,
    required String empIds,
  }) {
    _pollOnce(status: status, empIds: empIds, showLoader: true);
  }

  void refreshNow({
    required String status,
    required String empIds,
  }) {
    // ✅ date change/manual refresh should NOT show full loader
    _pollOnce(status: status, empIds: empIds, showLoader: false);
  }

  Future<void> _pollOnce({
    required String status,
    required String empIds,
    required bool showLoader,
  }) async {
    if (_pollInProgress) {
      _queuedPoll = (status: status, empIds: empIds, showLoader: showLoader);
      return;
    }

    _pollInProgress = true;
    final date = formattedDate;

    // ✅ show loader only when:
    // - caller says showLoader = true
    // - AND we haven't loaded once yet
    final shouldShowLoader = showLoader && !_hasLoadedOnce;

    if (shouldShowLoader) {
      isListLoading.value = true;
    }

    try {
      await Future.wait([
        fetchCalenderListDetails(
          status: status,
          date: date,
          showLoader: shouldShowLoader,
        ),
        fetchCalenderDetails(
          dateFrom: date,
          dateTo: date,
          empIds: empIds,
          showLoader: shouldShowLoader,
        ),
      ]);

      // ✅ after first successful poll
      _hasLoadedOnce = true;
    } catch (e) {
      error.value = e.toString();
    } finally {
      if (shouldShowLoader) {
        isListLoading.value = false;
      }
      _pollInProgress = false;
    }

    final queued = _queuedPoll;
    if (queued != null) {
      _queuedPoll = null;
      await _pollOnce(
        status: queued.status,
        empIds: queued.empIds,
        showLoader: queued.showLoader,
      );
    }
  }

  // ============================
  // Your existing methods (minimal signature change only)
  // ============================

  Future<void> fetchCalenderListDetails({
    required String status,
    required String date,
    required bool showLoader,
  }) async {
    // ✅ do not toggle loading here anymore (handled by _pollOnce)
    calenderListModel.value = await getCalenderListData(
      status: status,
      date: date,
      showLoader: showLoader,
    );
  }

  Future<void> fetchCalenderDetails({
    required String dateFrom,
    required String dateTo,
    required String empIds,
    required bool showLoader,
  }) async {
    final parsedVisitList = await getCalenderData(
      dateFrom: dateFrom,
      dateTo: dateTo,
      empIds: empIds,
      showLoader: showLoader,
    );

    visitList.assignAll(parsedVisitList);
    // ignore: avoid_print
    print('Visit data $parsedVisitList');
    calendarAppointments.assignAll(getAppointments(dataList: visitList));
  }

  Future<CalenderListModel> getCalenderListData({
    required String status,
    required String date,
    required bool showLoader,
  }) async {
    CalenderListModel? itemData;

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
      if (showLoader) {
        isListLoading.value = true;
      }
      error.value = '';

      // final res = await _api.get(
      //   CalenderRepository.getListCalender(
      //     status: status,
      //     date: date,
      //   ),
      // );  // MOCKED for local UI testing
      final res = mockResponse(MockData.get('calendar.visitList'));

      if (res.statusCode == 200 || res.statusCode == 201) {
        List<VisitsListData> visitDataList = [];

        if (res.data["visits"] != null) {
          for (var v in res.data["visits"]) {
            visitDataList.add(
              VisitsListData(
                visitId: v['visitId'] ?? 0,
                employeeTypeId: v['employeeTypeId'] ?? 0,
                patientName: v['patientName'] ?? '',
                patientImgUrl: v['patientImgUrl'] ?? '',
                address: v['address'] ?? '--',
                 visitType: v['visitTypeName'] != null ? getDisplayName(v['visitTypeName']) : '',
                primaryDiagnosis: v['primaryDiagnosis'] ?? '',
                timeFrom:
                v['timeFrom'] != null ? formatTimeToAMPM(v['timeFrom']) : '',
                timeTo:
                v['timeTo'] != null ? formatTimeToAMPM(v['timeTo']) : '',
                inZone: v['inZone'] ?? false,
                distance: v['distance'] ?? 0.0,
                isSecondLastEpisodeVisit: v["isSecondLastEpisodeVisit"] ?? false,
                visitCharge: double.parse(
                  (((v['visit_charge'] as num?)?.toDouble() ?? 0.0)
                      .toStringAsFixed(2)),
                ),
              ),
            );
          }
        }

        itemData = CalenderListModel(visits: visitDataList);
        // ignore: avoid_print
        print("calendar data ${itemData.visits.length}");
      } else {
        error.value = "Failed to list data";
      }
    } catch (e) {
      error.value = e.toString();
    } finally {
      if (showLoader) {
        isListLoading.value = false;
      }
    }

    return itemData ?? CalenderListModel(visits: []);
  }

  Future<List<VisitModelData>> getCalenderData({
    required String dateFrom,
    required String dateTo,
    required String empIds,
    required bool showLoader,
  }) async {
    List<VisitModelData> visitList = [];

    try {
      if (showLoader) {
        isListLoading.value = true;
      }
      error.value = '';

      // final res = await _api.get(
      //   CalenderRepository.getCalenderData(
      //     dateFrom: dateFrom,
      //     dateTo: dateTo,
      //     empIds: empIds,
      //   ),
      // );  // MOCKED for local UI testing
      final res = mockResponse(MockData.get('calendar.calendarData'));

      if (res.statusCode == 200 || res.statusCode == 201) {
        // ignore: avoid_print
        print("calendar raw data ${res.data}");

        for (final item in res.data) {
          final patientMap = item['patient'] ?? {};
          final Map<String, dynamic> employeeMap = item['employee'] ?? {};
          final Map<String, dynamic> employeeTypeMap =
              item['employeeType'] ?? {};

          visitList.add(
            VisitModelData(
              visitId: item['visitId'] ?? 0,
              ptId: item['pt_id'] ?? 0,
              employeeTypeId: item['employeeTypeId'] ?? 0,
              employeeId: item['employeeId'] ?? 0,
              visitType: item['visitType'] ?? 0,
              visiteDateTimeFrom: item['visiteDateTimeFrom'] ?? '',
              visitDateTimeTo: item['visitDateTimeTo'] ?? '',
              isVisitCompleted: item['isVisitCompleted'] ?? false,
              isVisitMissed: item['isVisitMissed'] ?? false,
              onWay: item['onWay'] ?? false,
              recordTypeId: item['recordTypeId'] ?? 0,
              inZone: item['inZone'] ?? false,

              patient: Patient(
                ptId: patientMap['pt_id'] ?? 0,
                ptFirstName: patientMap['pt_first_name'] ?? '',
                ptLastName: patientMap['pt_last_name'] ?? '',
                ptContactNo: patientMap['pt_contact_no'] ?? '',
                ptZipCode: patientMap['pt_zip_code'] ?? '',
                ptChartNo: patientMap['pt_chart_no'] ?? 0,
                ptSummary: patientMap['pt_summary'] ?? '',
                ptRefferalDate: patientMap['pt_refferal_date'] ?? '',
                fkSrvId: patientMap['fk_srv_id'] ?? 0,
                fkPtPrimaryDiagnosis: patientMap['fk_pt_primary_diagnosis'] ?? 0,
                fkPtSecondaryDiagnosis:
                patientMap['fk_pt_secondary_diagnosis'] ?? [],
                fkPtRefferalSource:
                patientMap['fk_pt_refferal_source'] ?? 0,
                fkPtPcp: patientMap['fk_pt_pcp'] ?? 0,
                fkPtMarketer: patientMap['fk_pt_marketer'] ?? 0,
                fkPtDiscplines:
                (patientMap['fk_pt_discplines'] ?? []).cast<int>(),
                ptCoverageArea: patientMap['pt_coverage_area'] ?? 0,
                isIntake: patientMap['is_intake'] ?? false,
                intakeTime: patientMap['intake_time'] ?? '',
                isArchieved: patientMap['is_archieved'] ?? false,
                archievedTime: patientMap['archieved_time'] ?? '',
                createdAt: patientMap['created_at'] ?? '',
                ptDateOfBirth: patientMap['pt_date_of_birth'] ?? '',
                ptImgUrl: patientMap['pt_img_url'] ?? '',
                fkEmpIdArchived: patientMap['fk_emp_id_archived'] ?? 0,
                fkRptiId: patientMap['fk_rpti_id'] ?? 0,
                isSelfPay: patientMap['is_selfPay'] ?? false,
                documentName: patientMap['document_name'] ?? '',
                moveToScheduler: patientMap['moveToScheduler'] ?? false,
                moveToSchedulerDatetime:
                patientMap['moveToSchedulerDatetime'] ?? '',
                admitDateTime: patientMap['admitDateTime'] ?? '',
                isNonAdmit: patientMap['is_non_admit'] ?? false,
                ptMrn: patientMap['pt_MRN'] ?? 0,
                ptSocDate: patientMap['pt_SOC_date'] ?? '',
                ptSocStatus: patientMap['pt_SOC_status'] ?? false,
                potentialDischargeDate:
                patientMap['potential_discharge_date'] ?? '',
                ptAddress: patientMap['pt_address'] ?? '',
                ptMedicalNote: patientMap['pt_medical_note'] ?? '',
                isDemographicFilled:
                patientMap['is_demographic_filled'] ?? false,
                isDocumentationUpload:
                patientMap['is_documentation_upload'] ?? false,
                isInitialContactFilled:
                patientMap['is_initialContact_filled'] ?? false,
                isOrdersFilled: patientMap['is_orders_filled'] ?? false,
                isPhysicianFilled:
                patientMap['is_physician_filled'] ?? false,
                isPrimaryInsuranceFilled:
                patientMap['is_primaryInsurance_filled'] ?? false,
                companyId: patientMap['companyId'] ?? 0,
                genderId: patientMap['genderId'] ?? 0,
                potentialDuplicate: patientMap['potential_duplicate'] ?? false,
                fkPtPrimaryDiagnosisName:
                patientMap['fk_pt_primary_diagnosis_name'] ?? '',
              ),

              employee: Employee(
                employeeId: employeeMap['employeeId'] ?? 0,
                code: employeeMap['code'] ?? '',
                firstName: employeeMap['firstName'] ?? '',
                lastName: employeeMap['lastName'] ?? '',
                expertise: employeeMap['expertise'] ?? '',
                gender: employeeMap['gender'] ?? '',
                imgurl: employeeMap['imgurl'] ?? '',
                regOfficId: employeeMap['regOfficId'] ?? '',
                onboardingStatus: employeeMap['onboardingStatus'] ?? '',
                userId: employeeMap['userId'] ?? 0,
                ssnNbr: employeeMap['SSNNbr'] ?? '',
                address: employeeMap['address'] ?? '',
                cityId: employeeMap['cityId'] ?? 0,
                dateOfBirth: employeeMap['dateOfBirth'] ?? '',
                departmentId: employeeMap['departmentId'] ?? 0,
                emergencyContact: employeeMap['emergencyContact'] ?? '',
                employeeTypeId: employeeMap['employeeTypeId'] ?? 0,
                employment: employeeMap['employment'] ?? '',
                personalEmail: employeeMap['personalEmail'] ?? '',
                primaryPhoneNbr: employeeMap['primaryPhoneNbr'] ?? '',
                secondryPhoneNbr: employeeMap['secondryPhoneNbr'] ?? '',
                service: employeeMap['service'] ?? '',
                status: employeeMap['status'] ?? '',
                workEmail: employeeMap['workEmail'] ?? '',
                workPhoneNbr: employeeMap['workPhoneNbr'] ?? '',
                companyId: employeeMap['companyId'] ?? 0,
                createdAt: employeeMap['createdAt'] ?? '',
                resumeurl: employeeMap['resumeurl'] ?? '',
                covreage: employeeMap['covreage'] ?? '',
                approved: employeeMap['approved'],
                terminationFlag: employeeMap['terminationFlag'],
                zoneId: employeeMap['zoneId'] ?? 0,
                countryId: employeeMap['countryId'] ?? 0,
                checkDate: employeeMap['checkDate'] ?? '',
                dateofResignation: employeeMap['dateofResignation'] ?? '',
                dateofTermination: employeeMap['dateofTermination'] ?? '',
                finalAddress: employeeMap['finalAddress'] ?? '',
                finalPayCheck: employeeMap['finalPayCheck'] ?? 0,
                grossPay: employeeMap['grossPay'] ?? 0,
                materials: employeeMap['materials'] ?? '',
                methods: employeeMap['methods'] ?? '',
                netPay: employeeMap['netPay'] ?? 0,
                reason: employeeMap['reason'] ?? '',
                rehirable: employeeMap['rehirable'] ?? '',
                type: employeeMap['type'] ?? '',
                dateofHire: employeeMap['dateofHire'] ?? '',
                position: employeeMap['position'] ?? '',
                driverLicenceNbr: employeeMap['driverLicenceNbr'] ?? '',
                race: employeeMap['race'] ?? '',
                rating: employeeMap['rating'] ?? '',
                signatureURL: employeeMap['signatureURL'] ?? '',
                countyId: employeeMap['countyId'] ?? 0,
                active: employeeMap['active'] ?? false,
                summary: employeeMap['summary'],
              ),

              employeeType: EmployeeType(
                employeeTypeId: employeeTypeMap['employeeTypeId'] ?? 0,
                employeeType: employeeTypeMap['employeeType'] ?? '',
                color: employeeTypeMap['color'] ?? '',
                abbreviation: employeeTypeMap['abbreviation'] ?? '',
                departmentId: employeeTypeMap['DepartmentId'] ?? 0,
                isAssistant: employeeTypeMap['is_assistant'] ?? false,
                assistantMasterId: employeeTypeMap['assistant_master_id'] ?? 0,
              ),
            ),
          );
        }
      } else {
        error.value = "Failed to list data";
      }
    } catch (e) {
      error.value = e.toString();
      return [];
    } finally {
      if (showLoader) {
        isListLoading.value = false;
      }
    }

    return visitList;
  }
}

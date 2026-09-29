// Verifies assets/mock/mock_data.json against the real controller parsing.
//
// Because every API call now reads from MockData instead of the network, the
// controller methods can be driven directly in a unit test — whatever the UI
// would show is exactly what these assertions see.
import 'dart:io';

import 'package:clinician_app/controller/calender_controller.dart';
import 'package:clinician_app/controller/chat_controller.dart';
import 'package:clinician_app/controller/earnings_controller.dart';
import 'package:clinician_app/controller/home_controller.dart';
import 'package:clinician_app/controller/live_map_controller.dart';
import 'package:clinician_app/controller/notification_controller.dart';
import 'package:clinician_app/controller/profile_controller.dart';
import 'package:clinician_app/controller/time_off_controller.dart';
import 'package:clinician_app/controller/timesheet_controller.dart';
import 'package:clinician_app/controller/update_documents_controller.dart';
import 'package:clinician_app/services/mock/mock_data_service.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();

    // GetStorage (used by TokenManager) asks path_provider for a directory,
    // which has no implementation under `flutter test` — point it at a temp dir.
    final tempDir = Directory.systemTemp
        .createTempSync('mock_data_test')
        .path;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (call) async => tempDir,
    );

    await GetStorage.init();
    await MockData.load();

    // TimeSheetController resolves ProfileController from GetX in its field
    // initialisers, so it has to be registered before that class is built.
    Get.put(ProfileController());
  });

  test('mock data asset loads', () {
    expect(MockData.isLoaded, isTrue);
    expect(MockData.get('auth.signIn'), isA<Map>());
  });

  test('a missing path degrades to the fallback instead of throwing', () {
    expect(MockData.get('nope.not.here'), isNull);
    expect(MockData.get('nope.not.here', fallback: const []), isEmpty);
  });

  test('get() hands back a copy, so a mutating screen cannot poison the store',
      () {
    final first = MockData.get('chat.list') as List;
    final originalLength = first.length;
    first.clear();
    expect((MockData.get('chat.list') as List).length, originalLength);
  });

  test('login returns a Clinical / Completed user (HomeScreen requires it)', () {
    final user = MockData.getMap('auth.signIn')['user'] as Map;
    expect(user['role'], 'Clinical');
    expect(user['status'], 'Completed');
  });

  test('profile: clinician, prefill, visit notes and visit details parse', () async {
    final c = ProfileController();

    final clinician = await c.getLoginClinitianData();
    expect(clinician.clinicianFullName, isNotEmpty);
    expect(clinician.abbreviation, isNotEmpty);

    final empId = await c.getEmployeeIdMaster();
    expect(empId.employeeId, greaterThan(0));

    final prefill = await c.getEmployeePrefillMaster(empId: empId.employeeId);
    expect(prefill.employeeFirstName, isNotEmpty);
    expect(prefill.employeeEmail, contains('@'));

    final notes =
        await c.getPatientVisitesNote(empId: empId.employeeId, date: '2026-09-17');
    expect(notes.items, isNotEmpty);
    expect(notes.items.first.patientName, isNotEmpty);
    expect(notes.items.first.primaryDiagnosis.name, isNotEmpty);
    // times are reformatted to h.mm a by the controller
    expect(notes.items.first.visiteDateTimeFrom, isNotEmpty);

    final details = await c.getVisitDetailsData(visitId: 51001);
    expect(details.patient.name, isNotEmpty);
    expect(details.planOfCare, isNotEmpty);
    expect(details.otherClinicians, isNotEmpty);
    expect(details.weeks, isNotEmpty);
    expect(details.weeks.first.items, isNotEmpty);

    final assistants = await c.getAssistanceVisit(clinicianEmployeeTypeId: 3);
    expect(assistants, isNotEmpty);
    expect(assistants.first.assistants, isNotEmpty);
  });

  test('home: today visits and visit schedule parse', () async {
    final c = HomeController();

    final today = await c.getRequestListData(
      clinicianId: 4201,
      visitStatus: 'all',
      patientName: '',
    );
    expect(today.visits, isNotEmpty);
    expect(today.visits.first.patientName, isNotEmpty);
    expect(today.visits.first.visitList, isNotEmpty);
    expect(today.visits.first.visitCharge, greaterThan(0));

    final schedule = await c.getVisitScheduleData(visitId: 51001);
    expect(schedule.patientName, isNotEmpty);
    expect(schedule.weeks, isNotEmpty);
    expect(schedule.weeks.first.visits, isNotEmpty);
  });

  test('calendar: list and calendar payloads parse', () async {
    final c = CalenderListController();

    final list = await c.getCalenderListData(
      status: 'accepted',
      date: '2026-09-17',
      showLoader: false,
    );
    expect(list.visits, isNotEmpty);
    expect(list.visits.first.patientName, isNotEmpty);

    final data = await c.getCalenderData(
      dateFrom: '2026-09-15',
      dateTo: '2026-09-21',
      empIds: '4201',
      showLoader: false,
    );
    expect(data, isNotEmpty);
    expect(data.first.patient.ptFirstName, isNotEmpty);
    expect(data.first.employee.firstName, isNotEmpty);
    expect(data.first.employeeType.abbreviation, isNotEmpty);
  });

  test('live map: dashboard, details, list, totals and route parse', () async {
    final c = LiveMapController();

    final dash = await c.getLiveMapDashboardData();
    expect(dash.clinician.name, isNotEmpty);
    expect(dash.activePatients, isNotEmpty);

    final details = await c.getVisitDetailsDashboardData(visitId: 51001);
    expect(details.patient.name, isNotEmpty);
    expect(details.planOfCare, isNotEmpty);

    final visits = await c.getMapListVisit();
    expect(visits.visits, isNotEmpty);

    final totals = await c.getVisitData(clinicianId: 4201);
    expect(totals.visitExpected, greaterThan(0));

    final route = await c.getViewRouteData(clinitianId: 4201, patientId: 3101);
    expect(route.sourceLatitude, isNot(0.0));
    expect(route.destinyLongitude, isNot(0.0));
  });

  test('notifications parse, including the unread flag', () async {
    final list = await NotificationController().getNotificationDataById();
    expect(list, isNotEmpty);
    expect(list.first.title, isNotEmpty);
    expect(list.any((n) => n.isRead == false), isTrue);
  });

  test('timesheet: dropdowns, patients and entries parse', () async {
    final c = TimeSheetController();

    expect(await c.getRecordType(), isNotEmpty);

    final masters = await c.getAllVisitMaster();
    expect(masters, isNotEmpty);
    expect(masters.first.eligibleClinicians, isNotEmpty);

    expect(await c.getAllPatientMaster(search: ''), isNotEmpty);

    final rows = await c.getTimeSheetAllData(
      recordType: 'all',
      chooseDate: '2026-09-17',
      search: '',
      clinicianId: 4201,
    );
    expect(rows, isNotEmpty);
    expect(rows.first.patientName, isNotEmpty);
    expect(rows.first.visitRate, greaterThan(0));
  });

  test('time off: types, leave types and history parse', () async {
    final c = TimeController();
    expect(await c.getTimeOffTypeData(), isNotEmpty);
    expect(await c.getLeaveTypeData(), isNotEmpty);

    final history = await c.getTimeOffEmpDataHistory(empId: 4201);
    expect(history.timeOffData, isNotEmpty);
    expect(history.timeOffData.first.timeOffTypeName, isNotEmpty);
    expect(
      history.timeOffData.map((e) => e.status),
      containsAll(<String>['Approved', 'Pending']),
    );
  });

  test('earnings: summary, today list and totals parse', () async {
    final c = EarningsController();

    final summary = await c.getMyTotalEarningData();
    expect(summary.total, greaterThan(0));

    final todays = await c.getMyTotalEarningTodayData();
    expect(todays, isNotEmpty);
    expect(todays.first.patientName, isNotEmpty);

    final all = await c.getMyAllEarningData(clinitianId: 4201);
    expect(all.total, greaterThan(0));
    expect(all.clinicianId, greaterThan(0));
  });

  test('documents: grouped list, sub-types and prefill parse', () async {
    final c = UpdateDocumentsController();

    final docs = await c.getDocumentListData(
      empId: 4201,
      approveOnly: 'false',
      searchText: '',
    );
    expect(docs.document, isNotEmpty);
    expect(docs.document.first.docList, isNotEmpty);
    expect(docs.document.first.docList.first.documentName, isNotEmpty);

    expect(await c.getSubDocumentListDropdown(docMetaId: 1), isNotEmpty);

    final prefill = await c.fetchPrefillDocument(employeeDocumentId: 91001);
    expect(prefill, isNotNull);
    expect(prefill!.documentName, isNotEmpty);
  });

  test('chat: list, group chat, employee chat, group info and emp detail parse',
      () async {
    final c = ChatDataController();

    final list = await c.getChatListData(
        clinicianId: 4201, showLoader: false, searchFilter: '');
    expect(list, isNotEmpty);
    expect(list.any((e) => e.isGroup), isTrue,
        reason: 'a group thread should be present');
    expect(list.any((e) => !e.isGroup), isTrue,
        reason: 'a 1:1 thread should be present');
    final group = list.firstWhere((e) => e.isGroup);
    expect(group.groupName, isNotEmpty);
    expect(group.groupMembers, isNotNull);
    expect(group.groupMembers!, isNotEmpty);

    // groupInfo.pt_group_id and created_at are read without a null guard and
    // created_at goes through DateTime.parse — a bad shape would throw here.
    final groupChat =
        await c.getPatientChats(ptGroupId: 7701, pageNbr: 1, NbrofRow: 50);
    expect(groupChat, isNotNull);
    expect(groupChat!.groupInfo.groupName, isNotEmpty);
    expect(groupChat.participants, isNotEmpty);
    expect(groupChat.messages, isNotEmpty);
    expect(groupChat.pagination.totalMessages, greaterThan(0));
    // one message carries attachments, which are parsed out of a JSON list
    expect(
      groupChat.messages.any((m) => m.attachedMultimediaUrls.isNotEmpty),
      isTrue,
    );

    final empChat = await c.chatClinicalGroupCommunication(4310, 1, 50);
    expect(empChat, isNotNull);
    expect(empChat!.empInfoData.fullName, isNotEmpty);
    expect(empChat.messages, isNotEmpty);
    expect(empChat.messages.any((m) => m.isMine), isTrue);

    final info = await c.getAllPatientsGroupInfo(7701);
    expect(info, isNotNull);
    expect(info!.allParticipants, isNotEmpty);
    expect(info.patientInfo.ptUserName, isNotEmpty);
    expect(info.mediaLinksAndDocs, isNotEmpty);

    final emp = await c.getEmpDetailCommunication(4310);
    expect(emp.firstName, isNotEmpty);
    expect(emp.employeeTypeAbbreviation, isNotEmpty);
    expect(emp.media, isNotEmpty);
  });
}

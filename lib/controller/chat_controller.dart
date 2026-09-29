// ===========================
// chat_data_controller.dart
// ===========================

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:clinician_app/controller/repository/chat_repo.dart';
import 'package:clinician_app/services/token_manager/token_manager_service.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../core/common/base64_conversation.dart';
import '../core/constant/app_string.dart';
import '../model/chatScreen/chatList_model.dart';
import '../model/chatScreen/empChat_model.dart';
import '../model/chatScreen/emp_info_model.dart';
import '../model/chatScreen/groupChat_model.dart';
import '../model/chatScreen/group_info_model.dart';
import '../model/request/request_data_model.dart';
import '../services/auth_api_services/auth_services.dart';
import '../services/mock/mock_data_service.dart';

class ChatDataController extends GetxController {
  final ApiService _api = Get.put(ApiService());

  // ===================== CHAT LIST =====================
  final isLoadingChatList = false.obs;
  final isChatSendLoading = false.obs;
  final error = ''.obs;
  final chatListItem = <ChatListItem>[].obs;
  final userId = 0.obs;

  bool _isFirstLoad = true;
  final searchText = ''.obs;
  Timer? _searchDebounce;

  void loadInitial({required int clinicianId}) {
    fetchChatListAllData(
      clinicianId: clinicianId,
      showLoader: true,
      searchTextFilter: searchText.value,
    );
  }

  void refreshNow({required int clinicianId}) {
    fetchChatListAllData(
      clinicianId: clinicianId,
      showLoader: false,
      searchTextFilter: searchText.value,
    );
  }

  void debounceSearch({required int clinicianId, required String search}) {
    searchText.value = search.trim().isEmpty ? '' : search.trim();

    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      fetchChatListAllData(
        clinicianId: clinicianId,
        showLoader: false,
        searchTextFilter: searchText.value,
      );
    });
  }

  Future<void> fetchChatListAllData({
    required int clinicianId,
    required bool showLoader,
    required String searchTextFilter,
  }) async {
    userId.value = await TokenManager.getUserId();
    final data = await getChatListData(
      clinicianId: clinicianId,
      showLoader: showLoader,
      searchFilter: searchTextFilter
    );
    chatListItem.assignAll(data);
  }

  Future<List<ChatListItem>> getChatListData({
    required int clinicianId,
    required bool showLoader,
    required String searchFilter
  }) async {
    List<ChatListItem> itemData = [];

    DateTime? parseDateTime(dynamic value) {
      if (value == null) return null;
      final String s = value.toString().trim();
      if (s.isEmpty) return null;
      return DateTime.tryParse(s);
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

    try {
      if (showLoader && _isFirstLoad) {
        isLoadingChatList.value = true;
      }

      error.value = '';

      // final res = await _api.getWithQueryParam(
      //  path: ChatRepository.getChatList(clinicianId: clinicianId),
      //   queryParameters: {
      //    "search":searchFilter
      //   }
      // ); // MOCKED for local UI testing
      final res = mockResponse(MockData.get('chat.list'));

      if (res.statusCode == 200 || res.statusCode == 201) {
        for (var items in res.data) {
          final DateTime? dt = parseDateTime(items['lastMessageTimestamp']);

          itemData.add(
            ChatListItem(
              isGroup: items['is_group'] ?? false,
              unseenMessageCount: items['unseenMessageCount'] ?? 0,
              lastMessageText: items['lastMessageText'] ?? '',
              lastMessageTimestamp: items['lastMessageTimestamp'] != null ? formatTimeToAMPM(items['lastMessageTimestamp']) : '',

              partnerEmpId: items['partner_emp_id'] ?? 0,
              userId: items['userId'] ?? 0,
              firstName: items['firstName'] ?? '',
              lastName: items['lastName'] ?? '',
              imgUrl: items['imgurl'] ?? '',

              ptGroupId: items['pt_group_id']??0,
              groupName: items['group_name'] ?? '',
              groupDescription: items['group_description'] ?? '',
              groupProfileUrl: items['group_profile_url'] ?? '',
              isActive: items['is_active'] ?? false,

              groupMembers: items['groupMembers'] != null
                  ? (items['groupMembers'] as List)
                  .map(
                    (m) => GroupMember(
                  memberId: m['memberId'] ?? 0,
                  firstName: m['firstName'] ?? '',
                  lastName: m['lastName'] ?? '',
                  imgUrl: m['imgurl'] ?? '',
                  userId: m['userId'] ?? 0,
                ),
              )
                  .toList()
                  : null,
            ),
          );
        }

        _isFirstLoad = false;
      } else {
        error.value = "failed to load data";
      }
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoadingChatList.value = false;
    }

    return itemData;
  }

  // ===================== HELPERS =====================
  List<String> parseAttachments(dynamic value) {
    if (value == null) return [];

    if (value is List) {
      return value.map((e) => e.toString().trim()).toList();
    }

    if (value is String && value.trim().startsWith('[')) {
      try {
        final decoded = jsonDecode(value);
        if (decoded is List) {
          return decoded.map((e) => e.toString().trim()).toList();
        }
      } catch (_) {}
    }

    if (value is String) {
      if (value.trim().isEmpty) return [];
      return [value.trim()];
    }

    return [];
  }

  List<String> parseAttachedMultimediaUrl(dynamic raw) {
    if (raw == null) return const [];

    if (raw is List) {
      return raw.map((e) => e.toString()).toList();
    }

    if (raw is String) {
      final trimmed = raw.trim();
      if (trimmed.isEmpty) return const [];

      try {
        final decoded = json.decode(trimmed);

        if (decoded is List) {
          return decoded.map((e) => e.toString()).toList();
        }

        if (decoded is String) {
          return [decoded];
        }
      } catch (_) {
        return trimmed
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
    }

    return const [];
  }

  // ===================== GROUP CHAT API =====================
  Future<PatientGroupChatData?> getPatientChats({
    required int ptGroupId,
    required int pageNbr,
    required int NbrofRow,
  }) async {
    try {
      // final response = await _api.get(
      //   ChatRepository.getChatsScreenList(
      //     ptGroupId: ptGroupId,
      //     pageNbr: pageNbr,
      //     NbrofRow: NbrofRow,
      //   ),
      // ); // MOCKED for local UI testing
      final response = mockResponse(MockData.get('chat.patientChats'));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;

        final groupInfo = GroupInfo(
          ptGroupId: data['groupInfo']['pt_group_id'],
          groupName: data['groupInfo']['group_name'] ?? '',
          groupDescription: data['groupInfo']['group_description'] ?? '',
          groupProfileUrl: data['groupInfo']['group_profile_url'] ?? '',
          isActive: data['groupInfo']['is_active'] ?? false,
          createdAt: DateTime.parse(data['groupInfo']['created_at']),
        );

        final participants = <Participant>[];
        if (data['participants'] != null) {
          for (var p in data['participants']) {
            participants.add(
              Participant(
                participantId: p['participantId'],
                participantType: p['participantType'] ?? '',
                firstName: p['firstName'] ?? '',
                lastName: p['lastName'] ?? '',
                fullName: p['fullName'] ?? '',
                imgurl: p['imgurl'] ?? '',
                email: p['email'] ?? '',
                userId: p['userId'],
                isOnline: p['isOnline'] ?? false,
                lastOnline:
                p['lastOnline'] != null ? DateTime.parse(p['lastOnline']) : null,
                willReceiveSms: p['willReceiveSms'] ?? false,
                employeeTypeAbbreviation: p['employeeTypeAbbreviation'],
                employeeTypeColor: p['employeeTypeColor'],
                employeeTypeId: p['employeeTypeId'],
                employeeTypeName: p['employeeTypeName'],
              ),
            );
          }
        }

        List<Message> messages = [];
        if (data["messages"] != null) {
          for (var m in data["messages"]) {
            final sender = m["sender"] ?? {};

            List<String> attachments = parseAttachments(m["attached_multimedia_url"]);
            // Backend can send voice_note_url either as a plain URL string or
            // as a JSON array (same shape as attached_multimedia_url) — parse
            // it the same way instead of passing the raw field through, or
            // media_kit gets a literal "[\"url\"]" string and fails to open it.
            List<String> voiceNote = parseAttachments(m['voice_note_url']);

            messages.add(
              Message(
                ptUserId: m["pt_user_id"] ?? 0,
                ptEmpUserId: m["pt_user_emp_id"] ?? 0,
                ptChatId: m["pt_chat_id"] ?? 0,
                textContent: m["text_content"] ?? "",
                dateCreated: m["date_created"] ?? "",
                dateModified: m["date_modified"],
                unsend: m["unsend"] ?? false,
                seenByPatient: m["seen_by_patient"] ?? false,
                seenByClinicians: List<int>.from(m["seen_by_clinicians"] ?? []),
                attachedMultimediaUrls: attachments,
                stickerMultimediaUrl: m["sticker_multimedia_url"] ?? "",
                voiceNoteUrl: voiceNote.isNotEmpty ? voiceNote.first : '',
                sentAsSms: m["sent_as_sms"] ?? false,
                sender: Sender(
                  userId: sender["userId"] ?? 0,
                  senderId: sender["senderId"] ?? 0,
                  senderType: sender["senderType"] ?? "",
                  firstName: sender["firstName"] ?? "",
                  lastName: sender["lastName"] ?? "",
                  imgUrl: sender["imgurl"] ?? "",
                ),
              ),
            );
          }
        }

        final pagination = Pagination(
          currentPage: data['pagination']['currentPage'] ?? 1,
          totalPages: data['pagination']['totalPages'] ?? 1,
          totalMessages: data['pagination']['totalMessages'] ?? 0,
          hasNextPage: data['pagination']['hasNextPage'] ?? false,
          hasPreviousPage: data['pagination']['hasPreviousPage'] ?? false,
        );

        return PatientGroupChatData(
          groupInfo: groupInfo,
          participants: participants,
          messages: messages,
          pagination: pagination,
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ===================== EMP CHAT API =====================
  Future<ChatDepartmentGroupCommunicationData?> chatClinicalGroupCommunication(
      final int otherEmpId,
      final int pageNo,
      final int rowNo,
      ) async {
    try {
      // final response = await _api.get(
      //   ChatRepository.getAllEmployeeChat(
      //     pageNo: pageNo,
      //     rows: rowNo,
      //     otherEmpid: otherEmpId,
      //   ),
      // ); // MOCKED for local UI testing
      final response = mockResponse(MockData.get('chat.employeeGroupCommunication'));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;

        final empInfo = data["employee_info"] ?? {};
        final empInfoData = EmployeeClinicalInfoData(
          employeeId: empInfo['employeeId'] ?? 0,
          userId: empInfo['user_id'] ?? 0,
          fullName: empInfo['fullName'] ?? '',
          imageUrl: empInfo['imgurl'] ?? '',
          isOnline: empInfo['isOnline'] ?? false,
        );

        List<ParticipantData> participants = [];
        if (data["participants"] != null) {
          for (var p in data["participants"]) {
            participants.add(
              ParticipantData(
                fullName: p["fullName"] ?? "",
                imgUrl: p["imgurl"] ?? "",
                email: p["email"] ?? "",
                isOnline: p["isOnline"] ?? false,
                willReceiveSms: p["willReceiveSms"] ?? false,
                departmentId: p['departmentId'] ?? 0,
                departmentName: p['departmentName'] ?? '',
                role: p['role'] ?? '',
                employeeId: p['employeeId'] ?? 0,
                userId: p['user_id'] ?? 0,
                position: p['position'] ?? '',
              ),
            );
          }
        }

        List<EmpMessage> messages = [];
        if (data["messages"] != null) {
          for (var m in data["messages"]) {
            final sender = m["sender"] ?? {};
            // Same fix as the group chat parser above: voice_note_url can
            // arrive as a JSON array, so use the parsed URL, not the raw field.
            List<String> voiceNoteUrls = parseAttachedMultimediaUrl(m['voice_note_url']);

            messages.add(
              EmpMessage(
                voiceNoteUrl: voiceNoteUrls.isNotEmpty ? voiceNoteUrls.first : '',
                textContent: m["text_content"] ?? "",
                dateCreated: m["date_created"] ?? "",
                dateModified: m["date_modified"],
                unsend: m["unsend"] ?? false,
                seenByEmployees:
                List<int>.from(m["seen_by_employees"] ?? const <int>[]),
                attachedMultimediaUrl:
                parseAttachedMultimediaUrl(m["attached_multimedia_url"]),
                stickerMultimediaUrl: m["sticker_multimedia_url"] ?? "",
                sender: EmpSender(
                  senderId: sender["senderId"] ?? 0,
                  senderType: sender["senderType"] ?? "",
                  firstName: sender["firstName"] ?? "",
                  lastName: sender["lastName"] ?? "",
                  imgUrl: sender["imgurl"] ?? "",
                ),
                sendAsSms: m["sent_as_sms"] ?? false,
                isMine: m["isMine"] ?? false,
                empChatId: m["emp_chat_id"] ?? 0,
                senderEmpId: m["sender_emp_id"] ?? 0,
                receiverEmpId: m["receiver_emp_id"] ?? 0,
              ),
            );
          }
        }

        final paginationData = data["pagination"] ?? {};
        final pagination = EmpPagination(
          currentPage: paginationData["currentPage"] ?? 1,
          totalPages: paginationData["totalPages"] ?? 1,
          totalMessages: paginationData["totalMessages"] ?? 0,
          hasNextPage: paginationData["hasNextPage"] ?? false,
          hasPreviousPage: paginationData["hasPreviousPage"] ?? false,
        );

        return ChatDepartmentGroupCommunicationData(
          participants: participants,
          messages: messages,
          pagination: pagination,
          empInfoData: empInfoData,
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ===================== CHAT SCREEN (POLLING) =====================
  final isLoadingChatScreen = false.obs;
  final chatScreenError = ''.obs;

  final Rxn<PatientGroupChatData> groupChatData = Rxn<PatientGroupChatData>();
  final Rxn<ChatDepartmentGroupCommunicationData> empChatData =
  Rxn<ChatDepartmentGroupCommunicationData>();

  Timer? _chatScreenTimer;
  bool _chatScreenFirstLoad = true;

  void startChatScreenListening({
    required bool isGroup,
    int? ptGroupId,
    int? otherEmpId,
    int pageNo = 1,
    int rows = 50,
  }) {
    stopChatScreenListening();

    _loadChatScreenOnce(
      isGroup: isGroup,
      ptGroupId: ptGroupId,
      otherEmpId: otherEmpId,
      pageNo: pageNo,
      rows: rows,
      showLoader: true,
    );

    _chatScreenTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      await _loadChatScreenOnce(
        isGroup: isGroup,
        ptGroupId: ptGroupId,
        otherEmpId: otherEmpId,
        pageNo: pageNo,
        rows: rows,
        showLoader: false,
      );
    });
  }

  void stopChatScreenListening() {
    _chatScreenTimer?.cancel();
    _chatScreenTimer = null;
  }

  Future<void> _loadChatScreenOnce({
    required bool isGroup,
    required bool showLoader,
    int? ptGroupId,
    int? otherEmpId,
    required int pageNo,
    required int rows,
  }) async {
    try {
      if (showLoader) {
        isLoadingChatScreen.value = true;
      }
      chatScreenError.value = '';

      if (isGroup) {
        if (ptGroupId == null) {
          chatScreenError.value = "ptGroupId is required for group chat";
          return;
        }

        final data = await getPatientChats(
          ptGroupId: ptGroupId,
          pageNbr: pageNo,
          NbrofRow: rows,
        );

        if (data != null) groupChatData.value = data;
      } else {
        if (otherEmpId == null) {
          chatScreenError.value = "otherEmpId is required for employee chat";
          return;
        }

        final data = await chatClinicalGroupCommunication(
          otherEmpId,
          pageNo,
          rows,
        );

        if (data != null) empChatData.value = data;
      }

      _chatScreenFirstLoad = false;
    } catch (e) {
      chatScreenError.value = e.toString();
    } finally {
      isLoadingChatScreen.value = false;
    }
  }

  Future<ApiData> postSendChatData({
    required int ptGroupId,
    required String textContent,
    required bool restrictPatientFromView,
    required bool sentAsSms,
    required int receiverEmpId,
    required String empTextContent,
    required bool isGroup,
  }) async {
    try {
      isChatSendLoading.value = true;
      error.value = '';

      // final res = await _api.post(ChatRepository.postSendChat(isGroup: isGroup),
      //     isGroup ?
      //     {
      //       "pt_group_id": ptGroupId,
      //       "text_content": textContent,
      //       "restrict_patient_from_view": restrictPatientFromView,
      //       "sent_as_sms": sentAsSms,
      //       // "voice_note_url": null
      //     } : {
      //       "receiver_emp_id": receiverEmpId,
      //       "text_content": empTextContent,
      //     }); // MOCKED for local UI testing
      final res = mockResponse(MockData.get('chat.sendMessage'));

      if (res.statusCode == 200 || res.statusCode == 201) {
        // final data = res.data as Map<String, dynamic>;
        var uploadResponse = res.data;
        int ChatId = isGroup ?uploadResponse['pt_chat_id']:uploadResponse['emp_chat_id'];
        return ApiData(
            success: true,
            message: res.statusMessage!,
            statusCode: res.statusCode!,
            chatId: ChatId
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
      isChatSendLoading.value = false;
    }
  }

  Future<ApiData> postSendAttachmentUrl({
    required int chatId,
    required File base64File,
    required String documentName,
    required bool isGroup,
  }) async {
    try {
      isChatSendLoading.value = true;
      error.value = '';
      final String base64 = await FileUtils.fileToBase64(base64File!);
      // final res = await _api.post(ChatRepository.postAttachMedia(isGroup: isGroup, chatId: chatId),
      //     {
      //     "base64": base64,
      //     "fileName": documentName,
      //     }
      //                 ); // MOCKED for local UI testing
      final res = mockResponse(MockData.get('chat.sendAttachment'));

      if (res.statusCode == 200 || res.statusCode == 201) {
        // final data = res.data as Map<String, dynamic>;
        // var uploadResponse = res.data;
        // int ChatId = isGroup ?uploadResponse['pt_chat_id']:uploadResponse['emp_chat_id'];
        return ApiData(
            success: true,
            message: res.statusMessage!,
            statusCode: res.statusCode!,
            // chatId: ChatId
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
      isChatSendLoading.value = false;
    }
  }

  Future<ApiData> postSendVoiceNoteAttachmentUrl({
    required int chatId,
    required File base64File,
    required String documentName,
    required bool isGroup,
    required int duration,
  }) async {
    try {
      isChatSendLoading.value = true;
      error.value = '';
      final String base64 = await FileUtils.fileToBase64(base64File!);
      // final res = await _api.post(ChatRepository.postAttachVoiceNoteMedia(isGroup: isGroup, chatId: chatId),
      //     {
      //       "base64": base64,
      //       "duration": duration,
      //       "filename": documentName
      //     }
      // ); // MOCKED for local UI testing
      final res = mockResponse(MockData.get('chat.sendVoiceNote'));

      if (res.statusCode == 200 || res.statusCode == 201) {
        // final data = res.data as Map<String, dynamic>;
        // var uploadResponse = res.data;
        // int ChatId = isGroup ?uploadResponse['pt_chat_id']:uploadResponse['emp_chat_id'];
        return ApiData(
          success: true,
          message: res.statusMessage!,
          statusCode: res.statusCode!,
          // chatId: ChatId
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
      isChatSendLoading.value = false;
    }
  }

  Future<PatientsGroupInfoData?> getAllPatientsGroupInfo(
      final int id) async {
    try {
      // final response = await _api.get(
      //   ChatRepository.getGroupInfoPatientsChats(id: id),
      // ); // MOCKED for local UI testing
      final response = mockResponse(MockData.get('chat.groupInfo'));

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Patients Group Info API Response: ${response.data}");

        final data = response.data;

        List<ParticipantGroup> participants = [];
        if (data["allParticipants"] != null) {
          for (var p in data["allParticipants"]) {
            participants.add(
              ParticipantGroup(
                participantId: p["participantId"] ?? 0,
                participantType: p["participantType"] ?? "",
                firstName: p["firstName"] ?? "",
                lastName: p["lastName"] ?? "",
                fullName: p["fullName"] ?? "",
                imgUrl: p["imgurl"] ?? "",
                email: p["email"] ?? "",
                address: p["address"],
                treatment: p["treatment"],
                lastOnline: p["lastOnline"],
              ),
            );
          }
        }

        final patientInfo = PatientGroupInfo(
          ptUserId: data["patientInfo"]["pt_user_id"] ?? 0,
          ptUserName: data["patientInfo"]["pt_user_name"] ?? "",
          ptUserEmail: data["patientInfo"]["pt_user_email"] ?? "",
          ptUserProfileUrl: data["patientInfo"]["pt_user_profile_url"] ?? "",
          ptUserAddress: data["patientInfo"]["pt_user_address"] ?? "",
          ptUserTreatment: data["patientInfo"]["pt_user_treatment"] ?? "",
          ptUserLastOnline: data["patientInfo"]["pt_user_last_online"] ?? "",
        );
        List<MediaLinksData> mediaData = [];
        if (data["mediaLinksAndDocs"] != null) {
          for (var p in data["mediaLinksAndDocs"]) {
            mediaData.add(
              MediaLinksData(
                  mediaID: p['mediaId'] ?? '',
                  mediaType: p['mediaType'] ?? '',
                  mediaUrl: p['mediaUrl'] ?? '',
                  description: p['description'] ?? '',
                  datecreated: p['dateCreated'] ?? ''

              ),
            );
          }
        }

        final groupInfo = PatientsGroupInfoData(
          ptGroupId: data["pt_group_id"] ?? 0,
          groupName: data["group_name"] ?? "",
          groupDescription: data["group_description"] ?? "",
          groupProfileUrl: data["group_profile_url"] ?? "",
          isActive: data["is_active"] ?? false,
          createdAt: data["created_at"] ?? "",
          totalMessages: data["totalMessages"] ?? 0,
          unseenMessageCount: data["unseenMessageCount"] ?? 0,
          allParticipants: participants,
          mediaLinksAndDocs: mediaData,
          patientInfo: patientInfo,
        );
        return groupInfo;
      } else {
        print("Patients Group Info API Error: ${response.statusMessage}");
        return null;
      }
    } catch (e) {
      print("Patients Group Info API Exception: $e");
      return null;
    }
  }

  Future<EmpDetailsDataClass> getEmpDetailCommunication(
      final int empId) async
  {
    var empDetails;
    try {
      // final response = await _api.get(
      //   ChatRepository.getEmployeeDetailsCom(empId: empId),
      // ); // MOCKED for local UI testing
      final response = mockResponse(MockData.get('chat.empDetail'));

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Employee Details API Response: ${response.data}");


        List<String> mediaUrl = [];
        if (response.data["media"] != null) {
          for (var m in response.data["media"]) {
            mediaUrl.add(
                m
            );
          }
        }
        // assuming the response.data is a List (as in your provided JSON)
        empDetails =
            EmpDetailsDataClass(
              firstName: response.data['firstName'] ?? '',
              lastName: response.data['lastName'] ?? '',
              employeeId: response.data['employeeId'] ?? 0,
              userId: response.data['userId'] ?? 0,
              profileUrl: response.data['profileUrl'] ?? '',
              departmentId: response.data['departmentId'] ?? 0,
              employeeTypeId: response.data['employeeTypeId'] ?? 0,
              employeeTypeAbbreviation: response.data['employeeTypeAbbreviation'] ?? '',
              employeeTypeColor: response.data['employeeTypeColor'] ?? '',
              media: mediaUrl,
            );
        return empDetails;
      } else {
        print("Employee Group API Error: ${response.statusMessage}");
        return empDetails;
      }
    } catch (e) {
      print("Employee Group API Exception: $e");
      return empDetails;
    }
  }
  Future<ApiData> deleteEmployeeChat(
     {
        required int otherEmpId,

      }) async {
    try {
      // var response = await _api.delete(
      //   ChatRepository.deleteEmpChat(otherEmpId: otherEmpId),
      // ); // MOCKED for local UI testing
      var response = mockResponse(MockData.get('chat.deleteEmployeeChat'));

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Emp Chat clear Successfully");
        return ApiData(
          statusCode: response.statusCode!,
          success: true,
          message: response.statusMessage ?? "Success",
          data: response.data,
        );
      } else {
        print("Error 1");
        return ApiData(
          statusCode: response.statusCode!,
          success: false,
          message: response.data['message'] ?? "Error occurred",
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

  Future<ApiData> clearPatientGropChatPatch(
      {
        required int id,
      }) async {
    try {
      // var response = await _api.delete(
      //   ChatRepository.patchClearPatientGroupChat(id: id),
      // ); // MOCKED for local UI testing
      var response = mockResponse(MockData.get('chat.clearPatientGroupChat'));

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Group Chat clear Successfully");
        return ApiData(
          statusCode: response.statusCode!,
          success: true,
          message: response.statusMessage ?? "Success",
          data: response.data,
        );
      } else {
        print("Error 1");
        return ApiData(
          statusCode: response.statusCode!,
          success: false,
          message: response.data['message'] ?? "Error occurred",
        );
      }
    } catch (e) {
      print("Error $e");
      return ApiData(
        statusCode: 404,
        success: false,
        message: "Something Went Wrong",
      );
    }
  }

  Future<ApiData> patchexitPatientGrop(
      {
        required int patientId,

      }) async {
    try {
      // var response = await _api.delete(
      //   ChatRepository.patchExitPatientGrp(id: patientId),
      // );  // MOCKED for local UI testing
      var response = mockResponse(MockData.get('chat.exitPatientGroup'));
      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Group Exit Successfully");
        return ApiData(
          statusCode: response.statusCode!,
          success: true,
          message: response.statusMessage ?? "Success",
          //data: response.data,
        );
      } else {
        print("Error 1");
        return ApiData(
          statusCode: response.statusCode!,
          success: false,
          message: response.data['message'] ?? "Error occurred",
        );
      }
    } catch (e) {
      print("Error $e");
      return ApiData(
        statusCode: 404,
        success: false,
        message: "Something Went Wrong",
      );
    }
  }
  Future<DownloadFileData?> getEmployeeDocumentByFileName(
      {
        required String apiPath,
        required String fileUrl,
      }
      ) async {
    try {
      // Signed URLs (e.g. "...photo.jpg?token=...") carry query params —
      // split on '/' alone would leave "photo.jpg?token=..." as the
      // filename, breaking both the API path and the saved file's extension.
      final uri = Uri.tryParse(fileUrl);
      final fileName = (uri != null && uri.pathSegments.isNotEmpty)
          ? uri.pathSegments.last
          : fileUrl.split('/').last;
      // final response = await _api.getBytes(
      //   path: "$apiPath/$fileName",
      // );  // MOCKED for local UI testing — no real file behind a mock URL
      final response = mockBytesResponse();
      if (response.statusCode == 200 || response.statusCode == 201) {
        return DownloadFileData(
          fileName: fileName,
          bytes: response.data,
        );
      } else {
        print('Api Error');
        return null;
      }
    } on DioException catch (e) {
      print("Error ${e.response?.data['message'] ?? e.message}");
      return null;
    } catch (e) {
      print("Error $e");
      return null;
    }
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    stopChatScreenListening();
    super.onClose();
  }
  
  
}

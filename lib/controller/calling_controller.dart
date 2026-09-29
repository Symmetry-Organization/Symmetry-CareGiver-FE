import 'dart:io';

import 'package:clinician_app/controller/repository/calling_repo.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

import '../core/constant/api_app_constant.dart';
import '../core/constant/app_string.dart';
import '../model/request/request_data_model.dart';
import '../pages/video_calling/callingconst_screen.dart';
import '../services/auth_api_services/auth_services.dart';
import '../services/token_manager/token_manager_service.dart';
import 'package:clinician_app/services/mock/mock_data_service.dart';

class CallingController extends GetxController{
  final ApiService _api = Get.put(ApiService());
  String fcmToken = '';
  Future<void> initFCM({required String deviceName}) async {
    final userId = await TokenManager.getUserId();

    // 1️⃣ ASK PERMISSION (iOS + Android 13+)
    NotificationSettings settings =
    await FirebaseMessaging.instance.requestPermission();

    print("🔔 Notification permission: ${settings.authorizationStatus}");

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      print("🚫 Notifications denied — skipping FCM registration");
      return;
    }

    // 2️⃣ iOS: FCM needs the APNS token first. On the simulator (or without
    // the Push Notifications entitlement) it never arrives — skip gracefully
    // instead of crashing.
    if (Platform.isIOS) {
      String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();

      // Give it a moment — the APNS token can arrive slightly after launch.
      if (apnsToken == null) {
        await Future.delayed(const Duration(seconds: 2));
        apnsToken = await FirebaseMessaging.instance.getAPNSToken();
      }

      if (apnsToken == null) {
        print("⚠️ APNS token unavailable (simulator or missing push "
            "entitlement) — skipping FCM token fetch");
        return;
      }
    }

    // 3️⃣ Get FCM token
    final token = await FirebaseMessaging.instance.getToken();

    if (token == null) {
      print("⚠️ FCM token is null — skipping device registration");
      return;
    }

    print("🌐 Mobile FCM Token: $token");
    fcmToken = token;

    // 4️⃣ Register device with correct platform type
    final deviceType = Platform.isIOS ? "IOS" : "ANDROID";

    var response = await addRegisterDevice(
      userId: userId,
      fcmToken: fcmToken,
      deviceType: deviceType,
      deviceName: deviceName, // was hardcoded "MOBILE DEVICE"
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      TokenManager.setFcmToken(fcmToken: fcmToken);
      print('Device data ${response.data}');
    } else {
      print('Device error ${response.message}');
    }

    // 5️⃣ Foreground / tap listeners (uncomment when ready)
    // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //   print("📩 Foreground message: ${message.data}");
    // });
    //
    // FirebaseMessaging.onMessageOpenedApp.listen((message) {
    //   print("📲 Opened app from notification");
    // });
  }

  Future<ApiData> addRegisterDevice({
    required int userId,
    required String fcmToken,
    required String deviceType,
    required String deviceName

  }) async {
    try {
      // var response = await _api.post(
      //   CallingRepo.postRegisterDevice(),
      //  {
      //     "userId": userId,
      //     "fcmToken": fcmToken,
      //     "deviceType": deviceType,
      //     "deviceName": deviceName
      //   },
      // );  // MOCKED for local UI testing
      var response = mockResponse(MockData.get('calling.registerDevice'));

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Device register Successfully");
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

  Future<ApiData> addCallInitiate(
      BuildContext context, {
        required List<int> participantUserIds,
        required String callType,
        required bool isVideo

      }) async {
    try {
      print('Calling UseId $participantUserIds');
      final companyId = await TokenManager.getCompanyId();
      // var response = await _api.post(
      //    CallingRepo.postCallInitiate(),
      //   {
      //     "participantUserIds": participantUserIds,
      //     "callType": callType,
      //     "companyId": companyId,
      //     "isVideo": isVideo,                  // Optional, defaults to true if not provided
      //   },

      // );  // MOCKED for local UI testing
      var response = mockResponse(MockData.get('calling.initiate'));

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Call initiate Successfully");
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

  Future<void> handleCallAccepted(Map payload,GlobalKey<NavigatorState>? navigatorKey,String isVideo) async {
    debugPrint('✅ Accept clicked, payload: $payload');
    final userId = await TokenManager.getUserId();
    final accessToken = await TokenManager.getAccessToken();
    try {
      // Extract what SW sent us
      final callIdRaw = payload['callId'];
      // final userIdRaw = payload['userId'];

      final int? callId = callIdRaw != null ? int.tryParse(callIdRaw.toString()) : null;
      // final int? userId = userIdRaw != null ? int.tryParse(userIdRaw.toString()) : null;
      print('${payload['callId']} ${userId} :::::::IOIOIOI');
      if (callId == null || userId == null) {
        debugPrint('Invalid callId/userId in payload: $payload');
        return;
      }

      // 1️⃣ Call your backend from Flutter
      // final uri = Uri.parse('${ApiAppConstant.domain}calls/join');
      // final response = await http.post(
      //   uri,
      //   headers: {'Content-Type': 'application/json','Authorization': 'Bearer $accessToken'},
      //   body: jsonEncode({
      //     'callId': callId,
      //     'userId': userId,
      //   }),
      // );  // MOCKED for local UI testing
      final response = mockHttpResponse(MockData.get('calling.join'));

      if (response.statusCode != 200 || response.statusCode != 201) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        debugPrint('calls/join response: $json');
        final channelName = json['channelName'] as String? ?? 'Test';
        final token = json['token'] as String? ?? '';
        final status = json['status'] as String?;
        final isVideoCall = json['isVideo'] as bool?;
        final groupName = json['groupName'] as String?;
        final groupImage = json['groupImage'] as String?;
        final callerName = json['contactName'] as String?;
        final userImage = json['contactImage'] as String?;
        final int? respCallId = json['callId'] is int
            ? json['callId'] as int
            : int.tryParse(json['callId']?.toString() ?? '');

        // 2️⃣ Navigate to your Agora screen
        if (Get.isDialogOpen == true) {
          Get.back(); // close dialog
        }

        Get.to(() => VideoCallAgoraScreen(
          userName: callerName,
          isVideoOn: isVideoCall == true,
          isAudioOn: true,
          channelName: channelName,
          token: token,
          callId: respCallId,
          groupImage: groupImage,
          groupName: groupName,
          userImage: isVideoCall == true ? '' : userImage,
          receiverImages: (json['receiverImages'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
          receiverNames: (json['receiverNames'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
          receiverIds: (json['receiverUserId'] as List<dynamic>?)?.map((e) => int.tryParse(e.toString()) ?? 0).toList() ?? [],
        ));

      }



      // Expected response:
      // {
      //   "callId": 29,
      //   "channelName": "call_...",
      //   "token": "006...",
      //   "appId": "a7cde...",
      //   "status": "ONGOING"
      // }


    } catch (e, st) {
      debugPrint('Error in _handleCallAccepted: $e\n$st');
    }
  }

  Future<void> handleCallRejected(Map payload) async {
    // Optional: call /calls/reject, update UI, etc.
    final userId = await TokenManager.getUserId();
    final accessToken = await TokenManager.getAccessToken();
    try{
      final callIdRaw = payload['callId'];
      // final userIdRaw = payload['userId'];

      final int? callId = callIdRaw != null ? int.tryParse(callIdRaw.toString()) : null;
      // final uri = Uri.parse('${ApiAppConstant.domain}calls/end');
      // final response = await http.post(
      //   uri,
      //   headers: {'Content-Type': 'application/json','Authorization': 'Bearer $accessToken'},
      //   body: jsonEncode({
      //     "callId": callId,
      //     "userId": userId,
      //     "status": "LEFT"
      //   }),
      // );  // MOCKED for local UI testing
      final response = mockHttpResponse(MockData.get('calling.end'));
    }catch(e){

    }
  }

  Future<void> handleCallDecline(Map payload) async {
    // Optional: call /calls/reject, update UI, etc.
    final userId = await TokenManager.getUserId();
    final accessToken = await TokenManager.getAccessToken();
    try{
      final callIdRaw = payload['callId'];
      // final userIdRaw = payload['userId'];

      final int? callId = callIdRaw != null ? int.tryParse(callIdRaw.toString()) : null;
      // final uri = Uri.parse('${ApiAppConstant.domain}calls/decline');
      // final response = await http.post(
      //   uri,
      //   headers: {'Content-Type': 'application/json','Authorization': 'Bearer $accessToken'},
      //   body: jsonEncode({
      //     "callId": callId,
      //     "userId": userId,
      //     //"status": "LEFT"
      //   }),
      // );  // MOCKED for local UI testing
      final response = mockHttpResponse(MockData.get('calling.decline'));
      if(response.statusCode == 201 || response.statusCode == 200){
        print('Call decline');
      }else{
        print('Call decline error');
      }
    }catch(e){

    }
  }


// Future<CallHistoryResponseLog> getEmpDetailCommunication({
//   required BuildContext context,
//   required final String pageNr,
//   required final String pageSize,
//   required final String filterType}) async
// {
//   var callDetails;
//   String convertIsoToCustomFormat(String? isoDate) {
//     if (isoDate == null || isoDate.isEmpty) return '';
//     try {
//       DateTime dateTime = DateTime.parse(isoDate);
//       return DateFormat('d MMM, hh:mma').format(dateTime);
//     } catch (_) {
//       return '';
//     }
//   }
//
//   try {
//     final response = await Api(context).get(
//       path: CallingRepo.getCallsLog(pageNr: pageNr, pageSize: pageSize, filterType: filterType),
//     );
//
//     if (response.statusCode == 200 || response.statusCode == 201) {
//       print("Call History API Response: ${response.data}");
//
//       List<CallHistory> callLog = [];
//       if (response.data["data"] != null) {
//         for (var m in response.data["data"]) {
//           callLog.add(
//               CallHistory(
//                   isVideo:  m["isVideo"] ?? false,
//                   callId: m['callId'] ?? 0,
//                   callType: m['callType'] ?? '',
//                   callDirection:  m['callDirection'] ??'',
//                   status:  m['status'] ??'',
//                   participantStatus:  m['participantStatus'] ??'',
//                   startTime:  m['startTime'] != null ? convertIsoToCustomFormat(m['startTime']) : '',
//                   duration: m['duration'] ?? 0,
//                   contactName:  m['contactName'] ??'',
//                   contactEmail:  m['contactEmail'] ??'',
//                   contactUserId:m['contactUserId'] != null
//                       ? List<int>.from(m['contactUserId'])
//                       : [],
//                   participantCount: m['participantCount']  ?? 0,
//                   timeAgo:  m['timeAgo'] ??'',
//                   phoneNo : m['phoneNo'] ?? '',
//                   contactImage: m['contactImage'] ?? '')
//           );
//         }
//       }
//       // assuming the response.data is a List (as in your provided JSON)
//       callDetails =
//           CallHistoryResponseLog(
//             data: callLog,
//             pageNbr: response.data["pageNbr"],
//             pageSize: response.data["pageSize"],
//             totalRecords: response.data["totalRecords"],
//             totalPages: response.data["totalPages"],
//             hasNextPage: response.data["hasNextPage"],
//             hasPreviousPage: response.data["hasPreviousPage"],
//           );
//       return callDetails;
//     } else {
//       print("Call details API Error: ${response.statusMessage}");
//       return callDetails;
//     }
//   } catch (e) {
//     print("Call details  API Exception: $e");
//     return callDetails;
//   }
// }

  Future<ApiData> unRegisterDevice({
    required BuildContext context,
    required String fcmToken,
  }) async {
    try {
      // var response = await _api.post(
      //   CallingRepo.postUnRegisterDevice(),
      //  {
      //     "fcmToken": fcmToken,
      //   },
      // );  // MOCKED for local UI testing
      var response = mockResponse(MockData.get('calling.unregisterDevice'));

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Device unregister Successfully");
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

  Future<ApiData> addParticipentInitiate(
      BuildContext context, {
        required List<int> participantUserIds,
        required int callId,
        required int inviterId

      }) async {
    try {
      print('Calling UseId $participantUserIds');
      final companyId = await TokenManager.getCompanyId();
      // var response = await _api.post(
      //   CallingRepo.postAddParticipent(),
      //   {
      //     "callId": callId,
      //     "inviterId": inviterId,
      //     "participantUserIds": participantUserIds
      //   },

      // );  // MOCKED for local UI testing
      var response = mockResponse(MockData.get('calling.addParticipant'));

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Add Participent Successfully");
        return ApiData(
          statusCode: response.statusCode!,
          success: true,
          message: response.statusMessage ?? "Success",
          data: response.data,
        );
      } else {
        print("Add Participent Error ");
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
}



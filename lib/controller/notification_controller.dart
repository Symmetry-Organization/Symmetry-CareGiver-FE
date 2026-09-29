import 'package:clinician_app/controller/repository/notification_repo.dart';
import 'package:clinician_app/model/notification/notification_model.dart';
import 'package:clinician_app/services/token_manager/token_manager_service.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../core/constant/app_string.dart';
import '../model/request/request_data_model.dart';
import '../services/auth_api_services/auth_services.dart';
import 'package:clinician_app/services/mock/mock_data_service.dart';

class NotificationController extends GetxController {
  final ApiService _api = Get.put(ApiService());
  final isNotificationList = false.obs;
  final error = ''.obs;
  final notificationModelData = <NotificationModelData>[].obs;

  // ✅ Unread notification state for bell dot
  final hasNewNotification = false.obs;

  Future<void> fetchNotificationListData() async {
    notificationModelData.value = await getNotificationDataById();

    // ✅ Check if any notification is unread -> show dot on bell
    hasNewNotification.value =
        notificationModelData.any((n) => n.isRead == false);

    debugPrint(
        "🔔 After fetch: hasNewNotification=${hasNewNotification.value}, "
            "total=${notificationModelData.length}, "
            "unread=${notificationModelData.where((n) => !n.isRead).length}");
  }

  Future<List<NotificationModelData>> getNotificationDataById() async {
    List<NotificationModelData> itemData = [];
    String timeAgo(String dateTimeString) {
      try {
        final dateTime = DateTime.parse(dateTimeString).toLocal();
        final now = DateTime.now();

        final diff = now.difference(dateTime);

        if (diff.inSeconds < 60) return "Just now";
        if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
        if (diff.inHours < 24) return "${diff.inHours}h ago";
        if (diff.inDays < 7) return "${diff.inDays}d ago";

        final weeks = (diff.inDays / 7).floor();
        if (weeks < 4) return "${weeks}w ago";

        final months = (diff.inDays / 30).floor();
        if (months < 12) return "${months}mo ago";

        final years = (diff.inDays / 365).floor();
        return "${years}y ago";
      } catch (e) {
        // fallback if date parsing fails
        return dateTimeString;
      }
    }

    try {
      isNotificationList.value = true;
      error.value = '';
      final userId = await TokenManager.getUserId();
      // final res = await _api.get(
      //     NotificationRepository.getNotificationList(userId: userId)
      // );  // MOCKED for local UI testing
      final res = mockResponse(MockData.get('notifications.list'));

      if (res.statusCode == 200 || res.statusCode == 201) {
        for (var item in res.data) {
          // 🔍 DEBUG: what does the server actually send?
          debugPrint(
              "🔍 SERVER DATA: notifyId=${item['notificationId']} "
                  "type=${item['type']} isRead=${item['isRead']}");

          itemData.add(NotificationModelData(
              notifyId: item['notificationId'] ?? 0,
              userId: item['userId'] ?? 0,
              type: item['type'] ?? '',
              title: item['title'] ?? '',
              body: item['body'] ?? '',
              // data: item['data'] ?? '',
              isRead: item['isRead'] ?? false,
              callId: item['callId'] ?? 0,
              createdAt: item['createdAt'] != null ? timeAgo(item['createdAt']) : '',
              createdAtIso: item['createdAt'] ?? '',
              updatedAt: item['updatedAt'] ?? ''));
        }
      } else {
        error.value = "Failed to list data";
      }
    } catch (e) {
      error.value = e.toString();
    } finally {
      isNotificationList.value = false;
    }

    // ✅ guaranteed return
    return itemData;
  }

  // ---------------- ACTIONS (API + LOCAL STATE) ----------------

  // ✅ Mark single notification as read (tap on tile)
  Future<void> markAsRead(int notifyId) async {
    debugPrint("👆 markAsRead called for notifyId=$notifyId"); // 🔍 DEBUG

    final index =
    notificationModelData.indexWhere((n) => n.notifyId == notifyId);
    if (index == -1 || notificationModelData[index].isRead == true) return;

    // Optimistic local update (instant UI feedback)
    notificationModelData[index].isRead = true;
    notificationModelData.refresh();
    hasNewNotification.value =
        notificationModelData.any((n) => n.isRead == false);

    // API call
    final res = await notificationReadPatch(notificationId: notifyId);
    if (!res.success) {
      // Revert on failure
      notificationModelData[index].isRead = false;
      notificationModelData.refresh();
      hasNewNotification.value = true;
    }
  }

  // ✅ Mark all as read ("Mark all read" button)
  Future<void> markAllAsRead() async {
    debugPrint("👆 markAllAsRead CALLED — stack trace:"); // 🔍 DEBUG
    debugPrint(StackTrace.current.toString()); // 🔍 shows WHO called this

    final res = await notificationReadAllPatch();
    if (res.success) {
      for (var n in notificationModelData) {
        n.isRead = true;
      }
      notificationModelData.refresh();
      hasNewNotification.value = false;
    } else {
      Get.snackbar("Error", res.message);
    }
  }

  // ✅ Delete notification (swipe to delete) — returns true if deleted
  Future<bool> removeNotification(int notifyId) async {
    final res = await deleteNotification(notificationId: notifyId);
    if (res.success) {
      notificationModelData.removeWhere((n) => n.notifyId == notifyId);
      hasNewNotification.value =
          notificationModelData.any((n) => n.isRead == false);
      return true;
    } else {
      Get.snackbar("Error", res.message);
      // Refresh list to restore the dismissed item in UI
      fetchNotificationListData();
      return false;
    }
  }

  // ---------------- API MANAGERS ----------------

  Future<ApiData> notificationReadPatch({
    required int notificationId,
  }) async {
    try {
      // var response = await _api.patch(
      //     NotificationRepository.patchNotification(notifyId: notificationId), {}
      // );  // MOCKED for local UI testing
      var response = mockResponse(MockData.get('notifications.markRead'));

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Notification read successfully");
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

  Future<ApiData> notificationReadAllPatch() async {
    try {
      final userId = await TokenManager.getUserId();
      // var response = await _api.patch(
      //     NotificationRepository.patchMarkAllRead(userId: userId), {}
      // );  // MOCKED for local UI testing
      var response = mockResponse(MockData.get('notifications.markAllRead'));

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Notification All read successfully");
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

  Future<ApiData> deleteNotification({
    required int notificationId,
  }) async {
    try {
      // var response = await _api.delete(
      //   NotificationRepository.deleteNotification(notifyId: notificationId),
      // );  // MOCKED for local UI testing
      var response = mockResponse(MockData.get('notifications.delete'));

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Notification delete read successfully");
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
}
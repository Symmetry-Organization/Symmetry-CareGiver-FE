import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


class CallNotificationService {
  static final FlutterLocalNotificationsPlugin _fln = FlutterLocalNotificationsPlugin();

  static const String _channelId = 'incoming_call_channel';
  static const int _notifId = 9001;

  static const String actionAccept = 'CALL_ACCEPT';
  static const String actionReject = 'CALL_REJECT';

  static Future<void> init({
    required GlobalKey<NavigatorState> navigatorKey,
  }) async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);

    await _fln.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse r) async {
        // Runs when app is in foreground/background and user taps action.
        await _handleAction(r, navigatorKey);
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      _channelId,
      'Incoming Calls',
      description: 'Incoming call notifications',
      importance: Importance.max,
    );

    final androidPlugin =
    _fln.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(channel);
  }

  static Future<void> showIncomingCall({
    required String callId,
    required String callerName,
    String? profileUrl, // (optional, not used by default here)
    String isVideo = "false",
  }) async {
    final payload = jsonEncode({
      'type': 'CALL_INCOMING',
      'callId': callId,
      'callerName': callerName,
      'profileUrl': profileUrl ?? '',
      'isVideo': isVideo,
    });

    final androidDetails = AndroidNotificationDetails(
      _channelId,
      'Incoming Calls',
      channelDescription: 'Incoming call notifications',
      importance: Importance.max,
      priority: Priority.high,
      category: AndroidNotificationCategory.call,
      fullScreenIntent: true, // makes it “call-like”
      ongoing: true,
      autoCancel: false,
      timeoutAfter: 30000,
      sound: RawResourceAndroidNotificationSound('incommingCall.mp3'),// auto dismiss after 30s (optional)

      actions: <AndroidNotificationAction>[
        const AndroidNotificationAction(
          actionReject,
          'Reject',
          showsUserInterface: true, // brings app to front
          cancelNotification: true,
        ),
        const AndroidNotificationAction(
          actionAccept,
          'Accept',
          showsUserInterface: true, // brings app to front
          cancelNotification: true,
        ),
      ],
    );

    await _fln.show(
      id: _notifId,
      title: 'Incoming call',
      body: callerName,
      notificationDetails: NotificationDetails(android: androidDetails),
      payload: payload,
    );
  }

  static Future<void> dismiss() async => _fln.cancel(id: _notifId);

  static Future<void> _handleAction(
      NotificationResponse response,
      GlobalKey<NavigatorState> navigatorKey,
      ) async {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) return;

    final data = jsonDecode(payload) as Map<String, dynamic>;
    final callId = (data['callId'] ?? '').toString();
    final isVideo = (data['isVideo'] ?? 'false').toString();

    await dismiss();

    // if (response.actionId == actionAccept) {
    //   await handleCallAccepted({"callId": callId}, navigatorKey, isVideo);
    // } else if (response.actionId == actionReject) {
    //   await handleCallRejected({"callId": callId});
    // } else {
    //   // User tapped notification body (not action)
    //   // If you want, you can navigate to your call screen here.
    // }
  }
}

/// Required by flutter_local_notifications for background action callback
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) {
  // Keep empty OR log.
  // Note: Calling network/API here is possible but requires careful isolate setup.
}

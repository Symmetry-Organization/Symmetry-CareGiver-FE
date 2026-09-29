import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class ChatNotificationService {
  static const String channelId   = 'chat_messages_channel';
  static const String channelName = 'Chat Messages';
  static const String channelDesc = 'Incoming chat message notifications';

  /// Call once in main() — creates the channel and wires up the tap callback.
  static Future<void> init({
    void Function(Map<String, dynamic> data)? onNotificationTap,
  }) async {
    final fln = FlutterLocalNotificationsPlugin();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await fln.initialize(
      settings: const InitializationSettings(
        android: androidInit,
        iOS: iosInit,
      ),
      onDidReceiveNotificationResponse: (response) {
        if (onNotificationTap == null) return;
        final payload = response.payload;
        if (payload == null || payload.isEmpty) return;
        try {
          onNotificationTap(jsonDecode(payload) as Map<String, dynamic>);
        } catch (_) {}
      },
      onDidReceiveBackgroundNotificationResponse: _onBackgroundTap,
    );

    await _ensureChannel(fln);
  }

  /// Request iOS notification permissions manually (optional).
  /// Useful if you set request*Permission to false in init() and want
  /// to ask the user at a better moment in your app flow.
  static Future<bool> requestIOSPermissions() async {
    if (!Platform.isIOS) return true;
    final fln = FlutterLocalNotificationsPlugin();
    final granted = await fln
        .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    return granted ?? false;
  }

  /// Show a WhatsApp-style heads-up notification with optional sender image
  /// on Android; standard alert notification on iOS.
  /// Safe to call from both the main isolate and the background isolate.
  static Future<void> show({
    required int id,
    required String title,          // sender name
    required String body,           // message text
    String? senderImageUrl,         // sender profile picture URL
    Map<String, dynamic>? payloadData,
  }) async {
    final fln = FlutterLocalNotificationsPlugin();

    // Background isolate must re-init independently.
    // Permission flags are false here so show() never triggers the
    // iOS permission dialog — that's init()'s job.
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await fln.initialize(
      settings: const InitializationSettings(
        android: androidInit,
        iOS: iosInit,
      ),
    );

    await _ensureChannel(fln);

    // Download sender image bytes (works in background isolate — dart:io only).
    // Only used by Android's messaging style; skip the download on iOS.
    final Uint8List? imageBytes =
    Platform.isAndroid ? await _downloadImage(senderImageUrl) : null;

    // ---------- Android: WhatsApp-style messaging layout ----------
    final sender = Person(
      name: title,
      important: true,
      icon: imageBytes != null ? ByteArrayAndroidIcon(imageBytes) : null,
    );

    final messagingStyle = MessagingStyleInformation(
      sender,
      groupConversation: false,
      messages: [
        Message(body, DateTime.now(), sender),
      ],
    );

    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDesc,
      importance: Importance.max,
      priority: Priority.max,
      category: AndroidNotificationCategory.message,
      styleInformation: messagingStyle,
      largeIcon: imageBytes != null ? ByteArrayAndroidBitmap(imageBytes) : null,
      enableVibration: true,
      playSound: true,
      fullScreenIntent: false,
      autoCancel: true,
    );

    // ---------- iOS: standard alert notification ----------
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      threadIdentifier: channelId, // groups chat notifications together
    );

    await fln.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      ),
      payload: payloadData != null ? jsonEncode(payloadData) : null,
    );
  }

  /// Android-only: create the notification channel.
  /// On iOS resolvePlatformSpecificImplementation returns null → no-op.
  static Future<void> _ensureChannel(FlutterLocalNotificationsPlugin fln) async {
    const channel = AndroidNotificationChannel(
      channelId,
      channelName,
      description: channelDesc,
      importance: Importance.max,
      enableVibration: true,
      playSound: true,
    );

    final androidPlugin = fln.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(channel);
  }

  /// Downloads an image from a URL and returns raw bytes.
  /// Uses only dart:io so it works inside the background isolate.
  static Future<Uint8List?> _downloadImage(String? url) async {
    if (url == null || url.trim().isEmpty) return null;
    try {
      final client = HttpClient();
      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close();
      if (response.statusCode != 200) {
        client.close();
        return null;
      }
      final chunks = <int>[];
      await for (final chunk in response) {
        chunks.addAll(chunk);
      }
      client.close();
      return Uint8List.fromList(chunks);
    } catch (_) {
      return null;
    }
  }
}

@pragma('vm:entry-point')
void _onBackgroundTap(NotificationResponse response) {
  // Navigation on tap is handled in main() via onDidReceiveNotificationResponse.
}
import 'package:clinician_app/controller/calling_controller.dart';
import 'package:clinician_app/controller/notification_controller.dart';
import 'package:clinician_app/core/constant/constant_import.dart';
import 'package:clinician_app/pages/auth/splash_screen.dart';
import 'package:clinician_app/pages/oasis_form_builder/provider/form_builder_provider.dart';
import 'package:clinician_app/pages/video_calling/call_background_noti.dart';
import 'package:clinician_app/pages/video_calling/call_ring.dart';
import 'package:clinician_app/pages/video_calling/calling_notification.dart';
import 'package:clinician_app/pages/video_calling/message_notification.dart';
import 'package:clinician_app/services/chat_notification_service.dart';
import 'package:clinician_app/services/mock/mock_data_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:media_kit/media_kit.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ScreenUtil.ensureScreenSize();
  await GetStorage.init();

  // All API calls are commented out for local UI testing — the app reads its
  // data from assets/mock/mock_data.json instead. Load it before the first
  // frame so MockData.get() can stay synchronous at the call sites.
  await MockData.load();

  // if (Firebase.apps.isEmpty) {
  //WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,);
  } on FirebaseException catch (e) {
    if (e.code != 'duplicate-app') rethrow;
  }

  // Request notification permission (Android 13+ requires this at runtime)
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  // Create the chat notification channel on the device
  await ChatNotificationService.init();

  setupForegroundCallListener();
  setupBackgroundCallListener();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  MediaKit.ensureInitialized();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => FormBuilderProvider()),

    ],
      child:  ClinicalApp()));
}
bool _manuallyRejected = false;

/// If you still need navigatorKey for overlay toast usage, keep it.
/// But dialogs/navigation will be handled by GetX.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final callController = Get.put(CallingController());

/// Lets any page mixin RouteAware and reload itself whenever it becomes
/// visible again (e.g. after popping a screen pushed on top of it).
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

// ✅ Helper: update bell dot + refresh notification list (safe if controller not created yet)
void _notifyNewNotification({bool refreshList = true}) {
  if (Get.isRegistered<NotificationController>()) {
    final notificationController = Get.find<NotificationController>();
    notificationController.hasNewNotification.value = true;
    if (refreshList) {
      notificationController.fetchNotificationListData();
    }
  }
}

void setupForegroundCallListener() {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    final data = message.data;
    // print("📲 Received foreground notification: ${message.data}");
    debugPrint("Message: $data");

    // =========================
    // HANDLE CALL INCOMING
    // =========================
    if (data['type'] == 'CALL_INCOMING') {
      final callerName = (data['callerName'] ?? 'Unknown').toString();
      final callId = (data['callId'] ?? '').toString();
      final userProfile = (data['contactImage'] ?? '').toString();
      final userName = (data['contactName'] ?? '').toString();
      final isVideo = (data['isVideo'] ?? 'false').toString();

      // ✅ Show bell dot immediately (call appears in notification list)
      _notifyNewNotification(refreshList: false);

      // 🔔 START RINGTONE (Android)
      AndroidCallRingtone.start();

      // ✅ GetX dialog (no BuildContext needed)
      await Get.dialog(
        AndroidIncomingCallOverlay(
          userImage: userProfile,
          callerName: callerName,

          onAccept: () {
            // 🔕 STOP RINGTONE
            AndroidCallRingtone.stop();

            // ✅ close dialog safely
            if (Get.isDialogOpen == true) {
              Get.back();
            }

            // ✅ do async work after closing
            () async {
              await callController.handleCallAccepted(
                {"callId": callId},
                navigatorKey,
                isVideo,
              );
            }();
          },

          onReject: () {
            _manuallyRejected = true;

            // 🔕 STOP RINGTONE
            AndroidCallRingtone.stop();

            // ✅ close dialog safely
            if (Get.isDialogOpen == true) {
              Get.back();
            }

            () async {
              await callController.handleCallDecline({"callId": callId});
            }();
          },
        ),
        barrierDismissible: false,
      ).whenComplete(() {
        // 🔕 SAFETY
        AndroidCallRingtone.stop();
      });
    }

    // =========================
    // HANDLE CALL CUT / MISSED
    // =========================
    else if (data['type'] == 'CALL_MISSED' ||
        data['type'] == 'CALL_ENDED' ||
        data['type'] == 'CALL_DECLINED') {
      // 🔕 STOP RINGTONE
      AndroidCallRingtone.stop();

      // ✅ Missed/ended call becomes a notification → show dot + refresh list
      _notifyNewNotification();

      // Only auto close when NOT manually rejected
      if (!_manuallyRejected) {
        if (Get.isDialogOpen == true) {
          Get.back();
        }else{
          Get.back();
        }
      }

      _manuallyRejected = false; // reset
      debugPrint("Call ended UI closed.");
    }

    // =========================
    // OTHER NOTIFICATION TYPE
    // =========================
    else {
      // print("📲 Received foreground notification: ${message.data}");
      final title = message.notification?.title ?? 'New message';
      final body = message.notification?.body ?? 'You have a new notification';

      // ✅ Show bell dot immediately + refresh notification list
      _notifyNewNotification();

      showTeamsMessageToastTop(
        title: title,
        message: body,
        onOpen: () {
          // Example:
          // Get.to(() => const ChatsScreen());
        },
        navigatorKey: navigatorKey,
      );
    }
  });
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final data = message.data;
  final type = (data['type'] ?? '').toString();

  // Incoming call → full-screen call notification
  if (type == 'CALL_INCOMING') {
    await CallNotificationService.showIncomingCall(
      callId: (data['callId'] ?? '').toString(),
      callerName: (data['callerName'] ?? 'Unknown').toString(),
      profileUrl: (data['contactImage'] ?? '').toString(),
      isVideo: (data['isVideo'] ?? 'false').toString(),
    );
    return;
  }

  // Call lifecycle events — nothing to show
  if (type == 'CALL_MISSED' || type == 'CALL_ENDED' || type == 'CALL_DECLINED') {
    return;
  }

  // Chat / all other notifications — show heads-up notification
  final title = message.notification?.title ??
      (data['title'] as String?)?.trim() ?? '';
  final body = message.notification?.body ??
      (data['body'] as String?)?.trim() ?? '';

  if (title.isEmpty && body.isEmpty) return;

  await ChatNotificationService.show(
    id: message.hashCode,
    title: title.isEmpty ? 'New Message' : title,
    body: body,
    senderImageUrl: (data['senderImage'] ?? data['imageUrl'] ?? data['contactImage'] ?? '').toString(),
    payloadData: data,
  );
}

void setupBackgroundCallListener() {
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
    debugPrint("📲 Opened from notification (background): ${message.data}");

    final data = message.data;

    // ✅ App opened from a notification → refresh list so dot/list is current
    if (Get.isRegistered<NotificationController>()) {
      Get.find<NotificationController>().fetchNotificationListData();
    }

    // Only handle call notifications
    if (data['type'] != 'CALL_INCOMING') return;

    final String callerName = (data['callerName'] ?? 'Unknown').toString();
    final String callId = (data['callId'] ?? '').toString();
    final String isVideo = (data['isVideo'] ?? 'false').toString();

    // ✅ GetX dialog for background open
    Get.dialog(
      AndroidIncomingCallOverlay(
        callerName: callerName,
        onAccept: () async {
          if (Get.isDialogOpen == true) Get.back();
          await callController.handleCallAccepted({"callId": callId}, navigatorKey, isVideo);
        },
        onReject: () async {
          _manuallyRejected = true;
          if (Get.isDialogOpen == true) Get.back();
          await callController.handleCallRejected({"callId": callId});
        },
      ),
      barrierDismissible: false,
    );
  });
}

void showTeamsMessageToastTop({
  required GlobalKey<NavigatorState> navigatorKey,
  required String title,
  required String message,
  VoidCallback? onOpen,
  Duration duration = const Duration(seconds: 5),
}) {
  final overlayState = navigatorKey.currentState?.overlay;
  if (overlayState == null) return;

  late OverlayEntry entry;

  entry = OverlayEntry(
    builder: (context) {
      return TopToastEntry(
        title: title,
        message: message,
        duration: duration,
        onOpen: () {
          if (entry.mounted) entry.remove();
          onOpen?.call();
        },
        onDismiss: () {
          if (entry.mounted) entry.remove();
        },
      );
    },
  );

  overlayState.insert(entry);
}

class ClinicalApp extends StatelessWidget {
  const ClinicalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(375, 812),
      enableScaleText: () => true,
      minTextAdapt: true,
      useInheritedMediaQuery: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: 'Clinician App',
          navigatorKey: navigatorKey,
          navigatorObservers: [routeObserver],
          defaultTransition: Transition.cupertino,
          transitionDuration: const Duration(milliseconds: 300),
          popGesture: true,
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primaryAppColor,
            ),
            fontFamily: AppTextStyle.fontFamily,
          ),
          home: SplashScreen(),
        );
      },
    );
  }
}
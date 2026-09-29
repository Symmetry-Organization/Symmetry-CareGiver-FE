import 'package:clinician_app/core/constant/constant_import.dart';
import 'package:clinician_app/core/ui/common_appbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../model/notification/notification_model.dart';

import '../../controller/notification_controller.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final NotificationController notificationController =
  Get.put(NotificationController());

  @override
  void initState() {
    super.initState();
    notificationController.fetchNotificationListData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            CommonAppbar(
              label: "Notifications",
              padding: EdgeInsets.only(
                left: 20.w,
                right: 20.w,
                top: 15.h,
                bottom: 8.h,
              ),
            ),
            Divider(),
            Expanded(
              child: Obx(() {
                // ✅ Loading
                if (notificationController.isNotificationList.value) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryAppColor,
                    ),
                  );
                }

                // ✅ Error
                if (notificationController.error.value.isNotEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Server error occurred. Please try again later.",
                            textAlign: TextAlign.center,
                            style: AppTextStyle.regular12style.copyWith(
                              color: AppColors.defaultTxtGrey,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          TextButton(
                            onPressed: () {
                              notificationController
                                  .fetchNotificationListData();
                            },
                            child: const Text("Retry"),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // ✅ Empty State
                if (notificationController.notificationModelData.isEmpty) {
                  return Center(
                    child: Text(
                      "No notifications found!",
                      style: AppTextStyle.regular12style.copyWith(
                        color: AppColors.defaultTxtGrey,
                      ),
                    ),
                  );
                }

                // ✅ Render list directly from model (so isRead updates reflect)
                final rows = _groupByDay(notificationController.notificationModelData);
                return ListView.builder(
                  itemCount: rows.length,
                  padding: EdgeInsets.only(bottom: 20.h),
                  itemBuilder: (context, index) {
                    final row = rows[index];
                    if (row.header != null) {
                      return _SectionHeader(label: row.header!);
                    }
                    final i = row.item!;
                    return Dismissible(
                      key: ValueKey(i.notifyId),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.only(right: 20.w),
                        color: Colors.red.shade50,
                        child: Icon(Icons.delete_outline,
                            color: Colors.red, size: 22),
                      ),
                      // ✅ Only remove row if delete API succeeds
                      confirmDismiss: (_) async {
                        final deleted = await notificationController
                            .removeNotification(i.notifyId);
                        if (deleted && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Row(
                                children: [
                                  Expanded(
                                    child: Text("Notification deleted"),
                                  ),
                                ],
                              ),
                              backgroundColor: AppColors.redBackGColor,
                              behavior: SnackBarBehavior.floating,
                              margin: const EdgeInsets.all(12),
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        }
                        return deleted;
                      },
                      child: NotificationTile(
                        NotificationItem.fromModel(i),
                        // ✅ Tap to mark as read
                        onTap: () =>
                            notificationController.markAsRead(i.notifyId),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- UI CLASSES ----------------

/// Flattened list row: a "Today / Yesterday / date" header or an item.
class _NotificationRow {
  const _NotificationRow.header(this.header) : item = null;
  const _NotificationRow.item(this.item) : header = null;

  final String? header;
  final NotificationModelData? item;
}

List<_NotificationRow> _groupByDay(List<NotificationModelData> items) {
  final rows = <_NotificationRow>[];
  String? last;
  for (final item in items) {
    final label = _dayLabel(item.createdAtIso);
    if (label != last) {
      last = label;
      rows.add(_NotificationRow.header(label));
    }
    rows.add(_NotificationRow.item(item));
  }
  return rows;
}

String _dayLabel(String iso) {
  final date = DateTime.tryParse(iso)?.toLocal();
  if (date == null) return 'Earlier';
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(date.year, date.month, date.day);
  if (day == today) return 'Today';
  if (day == today.subtract(const Duration(days: 1))) return 'Yesterday';
  return DateFormat('d MMMM yyyy').format(day);
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 8.h),
      child: Text(
        label,
        style: AppTextStyle.regular12style.copyWith(
          fontWeight: FontWeight.w400,
          color: AppColors.defaultTxtGrey,
        ),
      ),
    );
  }
}

/// Icon + tint per notification type (Figma coloured discs).
class _NotificationLook {
  const _NotificationLook(this.icon, this.color);

  final IconData icon;
  final Color color;

  static _NotificationLook of(String type, {required bool isCall}) {
    if (isCall) return const _NotificationLook(Icons.call_rounded, Color(0xffF4675B));
    switch (type.toUpperCase()) {
      case 'VISIT_ASSIGNED':
      case 'VISIT_COMPLETED':
        return const _NotificationLook(Icons.check_rounded, Color(0xff1FB58F));
      case 'VISIT_PENDING':
        return const _NotificationLook(Icons.hourglass_bottom_rounded, Color(0xff2B6CB0));
      case 'VISIT_MISSED':
        return const _NotificationLook(Icons.event_busy_rounded, Color(0xffE53935));
      case 'VISIT_RESCHEDULED':
        return const _NotificationLook(Icons.event_note_rounded, Color(0xff9EC9E2));
      case 'ROUTE_UPDATED':
        return const _NotificationLook(Icons.traffic_rounded, Color(0xff4A4A4A));
      case 'EARNING':
        return const _NotificationLook(Icons.attach_money_rounded, Color(0xffF5B740));
      case 'CERTIFICATE':
      case 'CERTIFICATE_EXPIRED':
        return const _NotificationLook(Icons.badge_rounded, Color(0xff9B6BF2));
      case 'CHAT_MESSAGE':
        return const _NotificationLook(Icons.chat_bubble_rounded, Color(0xff65BCE8));
      case 'TIME_OFF':
        return const _NotificationLook(Icons.beach_access_rounded, Color(0xff1FB58F));
      case 'SCHEDULE_UPDATE':
        return const _NotificationLook(Icons.schedule_rounded, Color(0xffF4675B));
    }
    return const _NotificationLook(Icons.notifications_rounded, Color(0xff65BCE8));
  }
}

class NotificationItem {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String time;
  final String? buttonText;
  final bool isRead;

  NotificationItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.time,
    this.buttonText,
    this.isRead = false,
  });

  factory NotificationItem.fromModel(NotificationModelData m) {
    final look = _NotificationLook.of(m.type, isCall: m.callId != 0);
    return NotificationItem(
      icon: look.icon,
      color: look.color,
      title: m.title,
      subtitle: m.body,
      time: m.createdAt,
      isRead: m.isRead,
    );
  }
}

/// Figma notification row: 40 × 40 coloured disc, semi-bold title, body,
/// light time label on the right and an optional action chip.
class NotificationTile extends StatelessWidget {
  final NotificationItem item;
  final VoidCallback? onTap;
  const NotificationTile(this.item, {this.onTap, super.key});

  static const double _iconDisc = 40;
  static const double _iconSize = 20;
  static const double _lineHeight = 1.5;
  static const double _titleSize = 14;
  static const double _subtitleSize = 10;
  static const double _timeSize = 9;
  static const double _buttonHeight = 25;
  static const double _buttonRadius = 3;
  static const Color _subtitleColor = Color(0xff515151);
  static const Color _buttonBg = Color(0x3365BCE8); // #65BCE833
  static const Color _buttonText = Color(0xff65BCE8);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        // ✅ subtle highlight for unread notifications
        color: item.isRead
            ? Colors.white
            : AppColors.primaryAppColor.withValues(alpha: 0.05),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: _iconDisc.w,
              height: _iconDisc.w,
              decoration: BoxDecoration(
                color: item.color,
                shape: BoxShape.circle,
              ),
              child: Icon(item.icon, color: Colors.white, size: _iconSize.w),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: AppTextStyle.bold14style.copyWith(
                      fontSize: _titleSize.sp,
                      fontWeight: FontWeight.w600,
                      height: _lineHeight,
                      color: AppColors.defaultTxtGrey,
                    ),
                  ),
                  Text(
                    item.subtitle,
                    style: AppTextStyle.regular10style.copyWith(
                      fontSize: _subtitleSize.sp,
                      fontWeight: FontWeight.w400,
                      height: _lineHeight,
                      color: _subtitleColor,
                    ),
                  ),
                  if (item.buttonText != null)
                    Padding(
                      padding: EdgeInsets.only(top: 8.h),
                      child: InkWell(
                        onTap: () {},
                        borderRadius: BorderRadius.circular(_buttonRadius.r),
                        child: Container(
                          height: _buttonHeight.h,
                          padding: EdgeInsets.symmetric(horizontal: 10.w),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: _buttonBg,
                            borderRadius: BorderRadius.circular(_buttonRadius.r),
                          ),
                          child: Text(
                            item.buttonText!,
                            style: AppTextStyle.normal10style.copyWith(
                              color: _buttonText,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  item.time,
                  textAlign: TextAlign.center,
                  style: AppTextStyle.regular10style.copyWith(
                    fontSize: _timeSize.sp,
                    fontWeight: FontWeight.w300,
                    height: _lineHeight,
                    color: Colors.black,
                  ),
                ),
                // ✅ unread dot
                if (!item.isRead)
                  Padding(
                    padding: EdgeInsets.only(top: 6.h),
                    child: Container(
                      width: 8.w,
                      height: 8.w,
                      decoration: BoxDecoration(
                        color: AppColors.primaryAppColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

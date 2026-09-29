import 'package:clinician_app/controller/earnings_controller.dart';
import 'package:clinician_app/core/constant/constant_import.dart';
import 'package:clinician_app/core/ui/common_appbar.dart';
import 'package:clinician_app/pages/profile/widgets/earning_stat_tile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/profile_controller.dart';
import '../../model/profile/my_earning_model.dart';

/// Figma "My Earning": two four-up stat rows, a today summary bar and the
/// list of today's visits.
class MyEarningPage extends StatefulWidget {
  const MyEarningPage({super.key});

  @override
  State<MyEarningPage> createState() => _MyEarningPageState();
}

class _MyEarningPageState extends State<MyEarningPage> {
  EarningsController earningsController = Get.put(EarningsController());
  ProfileController controller = Get.put(ProfileController());

  static const double _sidePadding = 16;
  static const double _tileGap = 8;
  static const double _minutesPerHour = 60;

  // Figma tile accent colours, left to right.
  static const List<Color> _accents = [
    AppColors.primaryAppColor, // #50B5E5
    Color(0xffF7D342),
    Color(0xffF5AAA4),
    Color(0xff8C00FF),
  ];
  static const List<String> _earningIcons = [
    AppAsset.earningTotalSvgIcon,
    AppAsset.earningTodaySvgIcon,
    AppAsset.earningWeekSvgIcon,
    AppAsset.earningMonthSvgIcon,
  ];
  static const List<String> _visitIcons = [
    AppAsset.earningHoursSvgIcon,
    AppAsset.earningWeekSvgIcon,
    AppAsset.earningTodaySvgIcon,
    AppAsset.earningMonthSvgIcon,
  ];

  @override
  void initState() {
    earningsController.fetchMyTotalEarningData();
    earningsController.fetchMyTotalEarningTodayData();
    earningsController.fetchMyAllEarningData(
      clinitianId: controller.employeeIdByEmail.value.employeeId,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommonAppbar(
              label: "My Earning",
              padding: EdgeInsets.only(
                left: 20.w,
                right: 20.w,
                top: 15.h,
                bottom: 8.h,
              ),
            ),
            const Divider(),
            Obx(() {
              if (earningsController.isEarningLoading.value ||
                  earningsController.isAllEarningLoading.value) {
                return const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryAppColor,
                    ),
                  ),
                );
              }
              return Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: _sidePadding.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      customHeight(16.h),
                      _statRow(_earningTiles(), _earningIcons),
                      customHeight(24.h),
                      Text(
                        "Total Visits",
                        style: AppTextStyle.normal14style.copyWith(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.defaultTxtGrey,
                        ),
                      ),
                      customHeight(12.h),
                      _statRow(_visitTiles(), _visitIcons),
                      customHeight(28.h),
                      Text(
                        "Today's Hours",
                        style: AppTextStyle.normal14style.copyWith(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.defaultTxtGrey,
                        ),
                      ),
                      customHeight(12.h),
                      _todaySection(),
                      customHeight(20.h),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // Built from the Rx models (the controller's plain lists are assigned after
  // the loading flag flips, so they're stale on the first rebuild).
  List<PriceDurationModel> _earningTiles() {
    final d = earningsController.myAllEarningData.value;
    return [
      PriceDurationModel(duration: "Total Earning", price: _money(d.total)),
      PriceDurationModel(duration: "Today", price: _money(d.today)),
      PriceDurationModel(duration: "This Week", price: _money(d.thisweek)),
      PriceDurationModel(duration: "This Month", price: _money(d.thismonth)),
    ];
  }

  List<PriceDurationModel> _visitTiles() {
    final d = earningsController.myTotalEarningModel.value;
    // The summary API has no "today" count — derive it from today's visits.
    final int today = earningsController.myEarningTodayVisitModel
        .where((v) => v.dayLabel.toLowerCase() == 'today')
        .length;
    return [
      PriceDurationModel(duration: "Total", price: '${d.total}'),
      PriceDurationModel(duration: "This Week", price: '${d.thisWeek}'),
      PriceDurationModel(duration: "Today", price: today.toString().padLeft(2, '0')),
      PriceDurationModel(duration: "This Month", price: '${d.thisMonth}'),
    ];
  }

  static String _money(double v) =>
      '\$${v.toStringAsFixed(v == v.roundToDouble() ? 0 : 2)}';

  Widget _statRow(List<PriceDurationModel> items, List<String> icons) {
    return SizedBox(
      height: EarningStatTile.height.h,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (int i = 0; i < items.length; i++) ...[
            if (i > 0) customWidth(_tileGap.w),
            Expanded(
              child: EarningStatTile(
                svg: icons[i % icons.length],
                label: items[i].duration,
                value: items[i].price,
                accent: _accents[i % _accents.length],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _todaySection() {
    return Obx(() {
      if (earningsController.isEarningLoadingList.value) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 60.h),
          child: const Center(
            child: CircularProgressIndicator(color: AppColors.primaryAppColor),
          ),
        );
      }
      final items = earningsController.myEarningTodayVisitModel;
      if (items.isEmpty) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 60.h),
          child: const Center(child: Text("No Records Found!")),
        );
      }

      final int minutes = items.fold(0, (sum, v) => sum + v.durationMinutes);
      final double total = items.fold(0.0, (sum, v) => sum + v.visit_charge);
      final int hours = (minutes / _minutesPerHour).round();

      return Column(
        children: [
          _TodaySummaryBar(hours: hours, total: total),
          for (final visit in items) ...[
            customHeight(12.h),
            _TodayVisitCard(visit: visit),
          ],
        ],
      );
    });
  }
}

/// Grey bar with "5 Hours" and the day's total.
class _TodaySummaryBar extends StatelessWidget {
  const _TodaySummaryBar({required this.hours, required this.total});

  final int hours;
  final double total;

  static const double _height = 50;
  static const double _fontSize = 14;
  static const Color _background = Color(0x0F989898); // #9898980F
  static const Color _hoursColor = Color(0xff898989);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _height.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: _background,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Text(
            '$hours Hours',
            // Figma: Fira Sans 400 / 14px / 100% #898989
            style: AppTextStyle.normal14style.copyWith(
              fontSize: _fontSize.sp,
              fontWeight: FontWeight.w400,
              height: 1,
              color: _hoursColor,
            ),
          ),
          const Spacer(),
          Text(
            '\$${total.toStringAsFixed(2)}',
            // Figma: Fira Sans 600 / 14px / 100% #1696C8
            style: AppTextStyle.normal14style.copyWith(
              fontSize: _fontSize.sp,
              fontWeight: FontWeight.w600,
              height: 1,
              color: AppColors.saveButtonBlue,
            ),
          ),
        ],
      ),
    );
  }
}

class _TodayVisitCard extends StatelessWidget {
  const _TodayVisitCard({required this.visit});

  final MyEarningTodayVisitModel visit;

  static const double _avatarRadius = 22;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            blurRadius: 6.r,
            offset: Offset(0, 2.h),
            color: Colors.black.withValues(alpha: 0.08),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: _avatarRadius.r,
            backgroundColor: Colors.transparent,
            backgroundImage:
                visit.patientAvatarUrl.isEmpty
                    ? AssetImage(AppAsset.profilePicImg) as ImageProvider
                    : NetworkImage(visit.patientAvatarUrl),
          ),
          customWidth(10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  visit.patientName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.bold12style.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 12.sp,
                    color: AppColors.defaultTxtGrey,
                  ),
                ),
                customHeight(4.h),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      color: AppColors.defaultTxtGrey,
                      size: 11.w,
                    ),
                    customWidth(5.w),
                    Text(
                      visit.dayLabel,
                      style: AppTextStyle.regular10style.copyWith(
                        color: AppColors.defaultTxtGrey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          customWidth(8.w),
          Text(
            "${visit.startTime}-${visit.endTime}",
            style: AppTextStyle.regular10style.copyWith(
              fontSize: 11.sp,
              color: AppColors.defaultTxtGrey,
            ),
          ),
          customWidth(12.w),
          Text(
            "\$${visit.visit_charge.toStringAsFixed(2)}",
            style: AppTextStyle.regular10style.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 18.sp,
              color: AppColors.mapMarkerLabel,
            ),
          ),
        ],
      ),
    );
  }
}

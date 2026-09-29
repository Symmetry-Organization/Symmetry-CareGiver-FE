import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

import 'package:clinician_app/controller/home_controller.dart';
import '../../controller/profile_controller.dart';
import 'package:clinician_app/core/constant/constant_import.dart';
import 'package:clinician_app/core/ui/primary_dropdown.dart';
import 'package:clinician_app/core/ui/primary_textfield.dart';
import 'package:clinician_app/pages/calender_section/widget/symmetry_top_bar.dart';
import 'package:clinician_app/pages/profile/notifcation_page.dart';
import 'package:clinician_app/pages/request/widget/request_info_widget.dart';
import 'package:intl/intl.dart';

import '../../controller/notification_controller.dart';

import '../../main.dart';
import '../../model/request/requestList_model.dart';

class RequestPage extends StatefulWidget {
  const RequestPage({super.key});

  @override
  State<RequestPage> createState() => _RequestPageState();
}

class _RequestPageState extends State<RequestPage> with RouteAware {
  final ProfileController profileController = Get.find<ProfileController>();
  final HomeController homeController = Get.find<HomeController>();
  final NotificationController notificationController =
      Get.put(NotificationController());

  final TextEditingController searchController = TextEditingController();

  static const double _searchRadius = 12;

  int get clinicianId => profileController.employeeId.value != 0
      ? profileController.employeeId.value
      : profileController.employeeIdByEmail.value.employeeId;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // ✅ First load (shows loader only first time via controller.showFirstLoader)
      await homeController.fetchListAllDetails(
        clinicianId: clinicianId,
        visitStatus: homeController.statusVal.value,
        patientName: 'all',
        isPollingCall: false,
      );
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    searchController.dispose();
    super.dispose();
  }

  @override
  void didPopNext() {
    // A screen pushed on top of this one (e.g. RequestDetailPage) was
    // popped — reload so the list reflects any accept/reject/status change.
    homeController.refreshRequestList();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Obx(
            () => SymmetryTopBar(
              showNotificationBadge:
                  notificationController.hasNewNotification.value,
              onNotificationTap: () => Get.to(() => NotificationPage()),
            ),
          ),
          customHeight(12.h),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.w),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 35.h,
                    child: PrimaryTextField(
                      controller: searchController,
                      // ✅ proper debounced search (and keeps polling)
                      onChanged: (v) {
                        homeController.debounceSearch(patientName: v);
                      },
                      hintText: 'Search',
                      filledColor: AppColors.searchFieldFill,
                      borderRadius: _searchRadius.r,
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(_searchRadius.r),
                        borderSide: const BorderSide(
                          color: AppColors.searchFieldBorder,
                        ),
                      ),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SvgPicture.asset(AppAsset.searchSvgIcon),
                      ),
                    ),
                  ),
                ),
                customWidth(15.w),

                SizedBox(
                  width: 120.w,
                  child: Obx(
                        () => PrimaryDropDown(
                      value: homeController.statusVal.value,
                      buttonStyleData: ButtonStyleData(width: 120.w),
                      filled: false,
                      iconStyleData: IconStyleData(
                        icon: SvgPicture.asset(AppAsset.downArrowFillSvgIcon),
                      ),
                      items: ['Pending', 'Accepted', 'Rejected', 'Rescheduled', 'Completed']
                          .map(
                            (s) => DropdownMenuItem(
                          value: s,
                          child: Text(
                            s,
                            style: AppTextStyle.normal12style.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.defaultTxtGrey,
                            ),
                          ),
                        ),
                      )
                          .toList(),
                      onChanged: (value) async {
                        if (value == null) return;

                        // ✅ update filter
                        homeController.statusVal.value = value;

                        // ✅ fetch immediately with new status + current search text
                        await homeController.fetchListAllDetails(
                          clinicianId: clinicianId,
                          visitStatus: value,
                          patientName: searchController.text.trim().isEmpty
                              ? 'all'
                              : searchController.text.trim(),
                          isPollingCall: false,
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          customHeight(12.h),

          /// ✅ tiny indicator (doesn't block UI)
          // Obx(() {
          //   return homeController.isSilentRefreshing.value
          //       ? const LinearProgressIndicator(minHeight: 2)
          //       : const SizedBox(height: 2);
          // }),

          Expanded(
            child: Obx(() {
              /// ✅ ONLY FIRST TIME loader
              if (homeController.showFirstLoader.value) {
                return Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryAppColor,
                  ),
                );
              }

              final items = homeController.todayVisitsModel.value.visits;
              if (items.isEmpty) {
                return const Center(child: Text("No Data Found!"));
              }
              final rows = _groupByDate(items);

              return RefreshIndicator(
                color: AppColors.primaryAppColor,
                onRefresh: () async {
                  await homeController.fetchListAllDetails(
                    clinicianId: clinicianId,
                    visitStatus: homeController.statusVal.value,
                    patientName: searchController.text.trim().isEmpty
                        ? 'all'
                        : searchController.text.trim(),
                    isPollingCall: false,
                  );
                },
                child: ListView.builder(
                  itemCount: rows.length,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  itemBuilder: (context, index) {
                    final row = rows[index];
                    if (row.header != null) {
                      return _DateHeader(label: row.header!);
                    }
                    return RequestInfoWidget(
                      filterStatus: homeController.statusVal.value.toLowerCase(),
                      data: row.visit!,
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

/// Flattened list row: either a date header or a visit card.
class _RequestRow {
  const _RequestRow.header(this.header) : visit = null;
  const _RequestRow.visit(this.visit) : header = null;

  final String? header;
  final PatientVisitModel? visit;
}

/// Groups visits under "Today , 25 December 2025" style headers, keeping
/// the API's order. `visitDateTime` arrives pre-formatted as "dd MMM yyyy".
List<_RequestRow> _groupByDate(List<PatientVisitModel> visits) {
  final rows = <_RequestRow>[];
  String? lastDate;
  for (final visit in visits) {
    if (visit.visitDateTime != lastDate) {
      lastDate = visit.visitDateTime;
      rows.add(_RequestRow.header(_dateHeaderLabel(visit.visitDateTime)));
    }
    rows.add(_RequestRow.visit(visit));
  }
  return rows;
}

String _dateHeaderLabel(String formatted) {
  DateTime? date;
  try {
    // month arrives lower-cased ("17 sep 2026"); intl needs "Sep".
    final parts = formatted.split(' ');
    if (parts.length == 3) {
      parts[1] = parts[1][0].toUpperCase() + parts[1].substring(1);
    }
    date = DateFormat('dd MMM yyyy').parse(parts.join(' '));
  } catch (_) {
    return formatted;
  }
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(date.year, date.month, date.day);
  final long = DateFormat('d MMMM yyyy').format(day);
  if (day == today) return 'Today , $long';
  if (day == today.subtract(const Duration(days: 1))) return 'Yesterday , $long';
  if (day == today.add(const Duration(days: 1))) return 'Tomorrow , $long';
  return long;
}

class _DateHeader extends StatelessWidget {
  const _DateHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 6.w, top: 6.h, bottom: 4.h),
      child: Text(
        label,
        style: AppTextStyle.normal14style.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.defaultTxtGrey,
        ),
      ),
    );
  }
}

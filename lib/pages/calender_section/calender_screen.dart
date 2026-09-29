import 'package:clinician_app/core/constant/constant_import.dart';
import 'package:clinician_app/pages/calender_section/appointment_list_widget.dart';
import 'package:clinician_app/pages/calender_section/widget/calendar_date_selector.dart';
import 'package:clinician_app/pages/calender_section/widget/calendar_day_timeline.dart';
import 'package:clinician_app/pages/calender_section/widget/calendar_filter_sheet.dart';
import 'package:clinician_app/pages/calender_section/widget/calendar_view_toggle.dart';
import 'package:clinician_app/pages/calender_section/widget/calendar_visit_tile.dart';
import 'package:clinician_app/pages/calender_section/widget/calender_date_pick_dialog_widget.dart';
import 'package:clinician_app/pages/calender_section/widget/symmetry_top_bar.dart';
import 'package:clinician_app/pages/home/widget/chat_fab_widget.dart';
import 'package:clinician_app/pages/profile/notifcation_page.dart';
import 'package:clinician_app/pages/request/visit_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../controller/calender_controller.dart';
import '../../controller/notification_controller.dart';
import '../../controller/profile_controller.dart';
import '../../main.dart';
import '../../model/calender/calender_model.dart';

class CalenderScreen extends StatefulWidget {
  const CalenderScreen({super.key});

  @override
  State<CalenderScreen> createState() => _CalenderScreenState();
}

class _CalenderScreenState extends State<CalenderScreen> with RouteAware {
  final CalenderListController controller = Get.put(CalenderListController());
  final ProfileController profileController = Get.put(ProfileController());
  final NotificationController notificationController = Get.put(
    NotificationController(),
  );

  String get _empId =>
      profileController.employeeIdByEmail.value.employeeId.toString();

  @override
  void initState() {
    super.initState();

    // ✅ keep calendar controller in sync with current date
    controller.calController.value.displayDate = controller.currentDate.value;

    // ✅ one-time initial load (no more continuous polling)
    controller.loadInitial(
      status: controller.statusFilter.value,
      empIds: _empId,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void dispose() {
    _timelineScroll.dispose();
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // A screen pushed on top of this one (e.g. VisitDetailPage) was
    // popped — reload so the list reflects any changes made there.
    _refreshNow();
  }

  DateTime? _parsePickedDate(dynamic result) {
    if (result == null) return null;
    if (result is DateTime) return result;
    if (result is String) {
      // Expecting "yyyy-MM-dd"
      return DateTime.tryParse(result);
    }
    // Range mode hands back [start, end]; the day view opens on the start.
    if (result is List<DateTime> && result.isNotEmpty) return result.first;
    return null;
  }

  void _refreshNow() {
    // ✅ instant refresh (no need to wait for next 2-second tick)
    controller.refreshNow(
      status: controller.statusFilter.value,
      empIds: _empId,
    );
  }

  // ------------------------------------------------------------ date strip
  static const int _stripLength = 5;

  /// Mon–Fri of the selected week (Figma shows a five-day strip). On a
  /// weekend the window slides so the selected day is still visible.
  List<DateTime> _stripDays(DateTime selected) {
    final DateTime day = DateTime(selected.year, selected.month, selected.day);
    final DateTime start =
        day.weekday <= _stripLength
            ? day.subtract(Duration(days: day.weekday - 1))
            : day.subtract(const Duration(days: _stripLength - 1));
    return List<DateTime>.generate(
      _stripLength,
      (i) => start.add(Duration(days: i)),
    );
  }

  /// The range picked from the calendar dialog, shown in the header pill. The
  /// list itself still works a day at a time, so it opens on the start date.
  DateTimeRange? _pickedRange;

  static final DateFormat _labelFormat = DateFormat('MMMM d, yyyy');

  /// The pill is narrow, so a navigated day gets the short form.
  static final DateFormat _pillDateFormat = DateFormat('MMM d, yyyy');

  /// True once a genuine two-ended range is picked; a single day is not one.
  bool get _hasRange {
    final DateTimeRange? range = _pickedRange;
    if (range == null) return false;
    return _labelFormat.format(range.start) != _labelFormat.format(range.end);
  }

  String? get _rangeLabel {
    final DateTimeRange? range = _pickedRange;
    if (range == null) return null;
    final String start = _labelFormat.format(range.start);
    // A range of one day reads as that day, not "the 19th to the 19th".
    return _hasRange ? '$start - ${_labelFormat.format(range.end)}' : start;
  }

  /// Label for the centre pill: "Today" only while today is selected, so
  /// stepping with the arrows is visible in both list and calendar mode. A
  /// picked range wins over it.
  String? get _pillLabel {
    final String? range = _rangeLabel;
    if (range != null) return range;
    final DateTime selected = controller.currentDate.value;
    return _isToday(selected) ? null : _pillDateFormat.format(selected);
  }

  bool _isToday(DateTime date) {
    final DateTime now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  void _selectDate(DateTime date) {
    setState(() => _pickedRange = null);
    final DateTime day = DateTime(date.year, date.month, date.day);
    controller.currentDate.value = day;
    controller.calController.value.displayDate = day;
    _refreshNow();
  }

  void _shiftDate(int days) {
    setState(() => _pickedRange = null);
    controller.changeDate(days);
    controller.calController.value.displayDate = controller.currentDate.value;
    _refreshNow();
  }

  void _openFilterSheet() {
    Get.bottomSheet(
      CalendarFilterSheet(controller: controller, onStatusChanged: _refreshNow),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  Future<void> _openDatePicker() async {
    final result = await Get.dialog(
      const CalenderDatePickDialogWidget(isRange: true),
    );
    final picked = _parsePickedDate(result);
    if (picked == null) return;

    _selectDate(picked);
    if (result is List<DateTime> && result.length > 1) {
      setState(() {
        _pickedRange = DateTimeRange(start: result.first, end: result.last);
      });
    }
  }

  static const double _headerIconSize = 14;
  static const double _listHorizontalPadding = 10;

  // -------------------------------------------------------------- timeline
  static const int _hoursInDay = 24;
  static const int _initialHour = 9;
  static const int _noonHour = 12;

  late final ScrollController _timelineScroll = ScrollController(
    initialScrollOffset: _initialHour * CalendarDayTimeline.rowExtent,
  );

  List<CalendarTimeSlot> _buildSlots(List<VisitModelData> visits) {
    final Map<int, List<CalendarVisit>> byHour = {};
    for (final visit in visits) {
      final DateTime start = _safeParse(visit.visiteDateTimeFrom);
      byHour.putIfAbsent(start.hour, () => []).add(_toCalendarVisit(visit));
    }

    return List<CalendarTimeSlot>.generate(_hoursInDay, (hour) {
      final int clock = hour % _noonHour == 0 ? _noonHour : hour % _noonHour;
      return CalendarTimeSlot(
        hour: clock.toString().padLeft(2, '0'),
        meridiem: hour < _noonHour ? 'AM' : 'PM',
        visits: byHour[hour] ?? const [],
      );
    });
  }

  CalendarVisit _toCalendarVisit(VisitModelData visit) {
    return CalendarVisit(
      title: '${visit.employee.firstName} ${visit.employee.lastName}',
      color: _hexToColor(visit.employeeType.color),
      isMoving: visit.onWay,
      trailing:
          visit.onWay
              ? SvgPicture.asset(
                AppAsset.calenderEventInfoSvgIcon,
                height: 10.h,
              )
              : null,
      onTap:
          () => Get.to(
            () => VisitDetailPage(
              visitId: visit.visitId,
              employeeTypeId: visit.employeeTypeId,
              visitStatus: 'accepted',
              isSecondLastEpisodeVisit: false,
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: ChatFABWidget(),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Obx(
              () => SymmetryTopBar(
                showNotificationBadge:
                    notificationController.hasNewNotification.value,
                onNotificationTap: () => Get.to(() => NotificationPage()),
              ),
            ),
            customHeight(9.h),
            Obx(
              () => CalendarViewToggle(
                mode:
                    controller.contentTypeInx.value == 0
                        ? CalendarViewMode.list
                        : CalendarViewMode.calendar,
                onChanged: (mode) {
                  controller.contentTypeInx.value =
                      mode == CalendarViewMode.list ? 0 : 1;
                  if (mode == CalendarViewMode.calendar) {
                    controller.calController.value.displayDate =
                        controller.currentDate.value;
                  }
                },
              ),
            ),
            customHeight(14.h),
            Obx(
              () => CalendarDateSelector(
                days: _stripDays(controller.currentDate.value),
                selectedDay: controller.currentDate.value,
                onDaySelected: _selectDate,
                onPrevious: () => _shiftDate(-1),
                onNext: () => _shiftDate(1),
                onToday: () => _selectDate(DateTime.now()),
                onTodayLongPress: _openDatePicker,
                label: _pillLabel,
                isRangeLabel: _hasRange,
                showDayStrip: controller.contentTypeInx.value == 1,
                trailing:
                    controller.contentTypeInx.value == 0
                        ? [
                          // TODO(figma-asset): swap for the exact funnel icon
                          // once exported — Material placeholder for now.
                          _HeaderIconButton(
                            onTap: _openFilterSheet,
                            child: Icon(
                              Icons.filter_list_rounded,
                              size: _headerIconSize.w,
                              color: AppColors.defaultTxtGrey,
                            ),
                          ),
                          _HeaderIconButton(
                            onTap: _openDatePicker,
                            child: SvgPicture.asset(
                              AppAsset.pickScheduleSvgIcon,
                              width: _headerIconSize.w,
                              colorFilter: AppColors.defaultTxtGrey.getSvgColor,
                            ),
                          ),
                        ]
                        : const [],
              ),
            ),
            Expanded(child: Obx(_buildContent)),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (controller.isListLoading.value) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryAppColor),
      );
    }

    if (controller.contentTypeInx.value == 1) {
      return ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(overscroll: false),
        child: SingleChildScrollView(
          controller: _timelineScroll,
          padding: EdgeInsets.fromLTRB(16.w, 22.h, 16.w, 20.h),
          child: CalendarDayTimeline(slots: _buildSlots(controller.visitList)),
        ),
      );
    }

    final items = controller.filteredListVisits;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: _listHorizontalPadding.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          customHeight(14.h),
          Expanded(
            child:
                items.isEmpty
                    ? const Center(child: Text("No Records Found!"))
                    : ListView.builder(
                      itemCount: items.length,
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.only(bottom: 20.h),
                      itemBuilder: (context, index) {
                        final visitListData = items[index];
                        return InkWell(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          onTap: () {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              Get.to(
                                () => VisitDetailPage(
                                  visitId: visitListData.visitId,
                                  employeeTypeId: visitListData.employeeTypeId,
                                  visitStatus: 'accepted',
                                  isSecondLastEpisodeVisit:
                                      visitListData.isSecondLastEpisodeVisit,
                                ),
                              );
                            });
                          },
                          child: AppointmentListWidget(dataList: visitListData),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}

/// 28 × 28 bordered square holding the filter / date-picker glyph.
class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  static const double _size = 28;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: _size.w,
        height: _size.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6.r),
          border: Border.all(color: AppColors.borderGrey),
        ),
        child: child,
      ),
    );
  }
}

// ==========================
// helpers (unchanged)
// ==========================
DateTime _safeParse(String value) {
  try {
    if (value.trim().isEmpty) return DateTime.now();
    return DateTime.parse(value).toLocal();
  } catch (_) {
    return DateTime.now();
  }
}

Color _hexToColor(String hex) {
  hex = hex.replaceAll("#", "").trim();
  if (hex.length == 6) hex = "FF$hex";
  final int? value = int.tryParse(hex, radix: 16);
  return value == null ? AppColors.primaryAppColor : Color(value);
}

List<Appointment> getAppointments({required List<VisitModelData> dataList}) {
  debugPrint("✅ getAppointments called, length=${dataList.length}");

  return List<Appointment>.generate(dataList.length, (index) {
    final item = dataList[index];

    final start = _safeParse(item.visiteDateTimeFrom);
    final end = _safeParse(item.visitDateTimeTo);

    final fixedStart = start.isBefore(end) ? start : end;
    final fixedEnd =
        start.isBefore(end) ? end : start.add(const Duration(minutes: 30));

    return Appointment(
      startTime: fixedStart,
      endTime: fixedEnd,
      subject: '${item.employee.firstName} ${item.employee.lastName}',
      color: _hexToColor(item.employeeType.color),
    );
  });
}

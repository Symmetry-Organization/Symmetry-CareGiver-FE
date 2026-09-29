import 'package:clinician_app/core/constant/constant_import.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/calender_controller.dart';

/// Bottom sheet behind the list-mode filter button — a "Zone | Status" tab
/// bar and a check-list of options. Picking an option applies it at once.
class CalendarFilterSheet extends StatefulWidget {
  const CalendarFilterSheet({
    super.key,
    required this.controller,
    required this.onStatusChanged,
  });

  final CalenderListController controller;

  /// Status is server-side, so the screen re-fetches when it changes.
  final VoidCallback onStatusChanged;

  @override
  State<CalendarFilterSheet> createState() => _CalendarFilterSheetState();
}

class _CalendarFilterSheetState extends State<CalendarFilterSheet>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 2, vsync: this);

  static const double _tabHeight = 48;
  static const double _tabIndicatorWidth = 3;
  static const double _optionHeight = 36;
  static const double _checkSize = 20;

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: _tabHeight.h,
              child: TabBar(
                controller: _tabs,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.black,
                labelStyle: AppTextStyle.normal14style.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: AppTextStyle.normal14style,
                indicatorColor: Colors.black,
                indicatorWeight: _tabIndicatorWidth,
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: AppColors.borderGrey,
                tabs: const [Tab(text: 'Zone'), Tab(text: 'Status')],
              ),
            ),
            customHeight(12.h),
            AnimatedBuilder(
              animation: _tabs,
              builder: (context, _) =>
                  _tabs.index == 0 ? _zoneOptions() : _statusOptions(),
            ),
            customHeight(12.h),
          ],
        ),
      ),
    );
  }

  Widget _zoneOptions() {
    return Obx(() {
      final selected = widget.controller.zoneFilterInZone.value;
      return Column(
        children: [
          _FilterOption(
            label: 'Out of Zone',
            selected: selected == false,
            onTap: () => widget.controller.zoneFilterInZone.value = false,
          ),
          _FilterOption(
            label: 'In Zone',
            selected: selected == true,
            onTap: () => widget.controller.zoneFilterInZone.value = true,
          ),
        ],
      );
    });
  }

  Widget _statusOptions() {
    return Obx(() {
      final selected = widget.controller.statusFilter.value;
      return Column(
        children: [
          for (final status in CalendarStatusFilter.all)
            _FilterOption(
              label: '${status[0].toUpperCase()}${status.substring(1)}',
              selected: selected == status,
              onTap: () {
                if (widget.controller.statusFilter.value == status) return;
                widget.controller.statusFilter.value = status;
                widget.onStatusChanged();
              },
            ),
        ],
      );
    });
  }
}

class _FilterOption extends StatelessWidget {
  const _FilterOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: _CalendarFilterSheetState._optionHeight.h,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Row(
            children: [
              SizedBox(
                width: _CalendarFilterSheetState._checkSize.w,
                child: selected
                    ? Icon(
                        Icons.check_circle,
                        size: _CalendarFilterSheetState._checkSize.w,
                        color: AppColors.greenColor,
                      )
                    : null,
              ),
              customWidth(12.w),
              Text(
                label,
                style: AppTextStyle.normal14style.copyWith(
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  color: selected ? AppColors.greenColor : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

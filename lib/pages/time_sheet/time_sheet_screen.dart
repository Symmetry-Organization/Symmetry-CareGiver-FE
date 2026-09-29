// ignore_for_file: invalid_use_of_protected_member

import 'package:clinician_app/controller/home_controller.dart';
import 'package:clinician_app/controller/visit_controller.dart';
import 'package:clinician_app/core/constant/constant_import.dart';
import 'package:clinician_app/core/ui/buttons/primary_outlined_button.dart';
import 'package:clinician_app/core/ui/primary_textfield.dart';
import 'package:clinician_app/pages/home/widget/chat_fab_widget.dart';
import 'package:clinician_app/pages/home/widget/home_appbar_widget.dart';
import 'package:clinician_app/pages/time_sheet/add_visit_page.dart';
import 'package:clinician_app/pages/time_sheet/visit_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../controller/timesheet_controller.dart';
import '../../main.dart';

class TimeSheetPage extends StatefulWidget {
  const TimeSheetPage({super.key});

  @override
  State<TimeSheetPage> createState() => _TimeSheetPageState();
}

class _TimeSheetPageState extends State<TimeSheetPage>
    with SingleTickerProviderStateMixin, RouteAware {
  static const double _addVisitWidth = 110;
  static const double _addVisitIconSize = 16;
  static const double _addVisitLineHeight = 23;

  late TabController _tabController;
  VisitController visitController = Get.put(VisitController());
  TimeSheetController timeSheetController = Get.put(TimeSheetController());
  // final homeController = Get.find<HomeController>();
  RxInt selectedIndex = 0.obs;
  TextEditingController searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 3);
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    if (Get.isRegistered<TimeSheetController>()) {
      Get.delete<TimeSheetController>(); // triggers onClose()
    }
    super.dispose();
  }

  @override
  void didPopNext() {
    timeSheetController.refreshNow();
  }


  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        floatingActionButton: ChatFABWidget(),
        body: SafeArea(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Column(
              children: [
                // ------ header -------
                HomeAppbarWidget(),
                // --------- search and dropdown ----------
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 11.w),
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 35.h,
                          child: PrimaryTextField(
                            controller: searchController,
                            onChanged: (value){
                              if (value.trim().isEmpty) {
                                timeSheetController.searchText.value = 'all';
                              } else {
                                timeSheetController.searchText.value = value.trim();
                              }
                            },
                            hintText: 'Search',
                            filledColor: Color(0xffE9E9E9),
                            prefixIcon: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SvgPicture.asset(AppAsset.searchSvgIcon),
                            ),
                          ),
                        ),
                      ),
                      customWidth(15.w),
                      PrimaryOutlinedButton(
                        text: "Add Visit",
                        onPressed: () {
                          Get.to(
                            () => AddVisitPage(
                              visitStatus:
                                  timeSheetController.selectedTypeRecord.value,
                            ),
                            transition: Transition.rightToLeft,
                            duration: const Duration(milliseconds: 300),
                          );
                        },
                        // Figma: Fira Sans 700 / 12px / 23px line-height
                        textStyle: AppTextStyle.normal12style.copyWith(
                          fontWeight: FontWeight.w700,
                          height: _addVisitLineHeight / 12,
                          color: AppColors.primaryAppColor,
                        ),
                        width: _addVisitWidth.w,
                        radius: 6,
                        height: 35.h,
                        borderWidth: 1.w,
                        spaceBetweenIconText: 4,
                        icon: Icon(
                          Icons.add,
                          size: _addVisitIconSize.w,
                          color: AppColors.primaryAppColor,
                        ),
                      ),
                    ],
                  ),
                ),
                customHeight(17.h),
                // ------- request list ---------
                Obx(
                  () => TabBar(
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    controller: _tabController,
                    indicatorColor: Colors.transparent,
          
                    labelPadding: EdgeInsets.only(right: 11.w),
          
                    dividerHeight: 10,
                    dividerColor: Colors.transparent,
                    labelStyle: AppTextStyle.normal12style.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.calenderTxtBlack,
                    ),
                    indicatorPadding: EdgeInsets.zero,
                    padding: EdgeInsets.only(left: 10.w),
                    unselectedLabelStyle: AppTextStyle.normal12style.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.greyColor,
                    ),
          
                    tabs: [
                      PrimaryOutlinedButton(
                        text: "All",
                        onPressed: () {
                          selectedIndex.value = 0;
                          _tabController.index = 0;
                          timeSheetController.selectedTypeRecord.value = 'All';
                        },
                        fillColor:
                            selectedIndex.value == 0
                                ? AppColors.primaryAppColor
                                : Colors.white,
          
                        textStyle: AppTextStyle.normal10style.copyWith(
                          fontWeight: FontWeight.w700,
                          color:
                              selectedIndex.value == 0
                                  ? Colors.white
                                  : AppColors.primaryAppColor,
                        ),
                        borderWidth: 1.5,
                        width: 110.w,
                        radius: 6,
                        height: 24.h,
                      ),
                      // PrimaryOutlinedButton(
                      //   text: "Visit",
                      //   onPressed: () {
                      //     selectedIndex.value = 1;
                      //     _tabController.index = 1;
                      //     timeSheetController.selectedTypeRecord.value = 'Visit';
                      //   },
                      //   fillColor:
                      //       selectedIndex.value == 1
                      //           ? AppColors.primaryAppColor
                      //           : Colors.white,
                      //
                      //   textStyle: AppTextStyle.normal10style.copyWith(
                      //     fontWeight: FontWeight.w700,
                      //     color:
                      //         selectedIndex.value == 1
                      //             ? Colors.white
                      //             : AppColors.primaryAppColor,
                      //   ),
                      //   borderWidth: 1.5,
                      //   width: 110.w,
                      //   radius: 6,
                      //   height: 24.h,
                      // ),
                      PrimaryOutlinedButton(
                        text: "Case Conference",
                        onPressed: () {
                          _tabController.index = 1;
                          selectedIndex.value = 1;
                          timeSheetController.selectedTypeRecord.value = 'Case Conference';
                        },
                        fillColor:
                            selectedIndex.value == 1
                                ? AppColors.primaryAppColor
                                : Colors.white,
          
                        textStyle: AppTextStyle.normal10style.copyWith(
                          fontWeight: FontWeight.w700,
                          color:
                              selectedIndex.value == 1
                                  ? Colors.white
                                  : AppColors.primaryAppColor,
                        ),
                        width: 110.w,
                        radius: 6,
                        borderWidth: 1.5,
                        height: 24.h,
                      ),
          
                      PrimaryOutlinedButton(
                        text: "Miscellaneous ",
                        onPressed: () {
                          selectedIndex.value = 2;
                          _tabController.index = 2;
                          timeSheetController.selectedTypeRecord.value = 'Miscellaneous';
                        },
                        fillColor:
                            selectedIndex.value == 2
                                ? AppColors.primaryAppColor
                                : Colors.white,
          
                        textStyle: AppTextStyle.normal10style.copyWith(
                          fontWeight: FontWeight.w700,
                          color:
                              selectedIndex.value == 2
                                  ? Colors.white
                                  : AppColors.primaryAppColor,
                        ),
                        width: 110.w,
                        radius: 6,
                        borderWidth: 1.5,
                        height: 24.h,
                      ),
                    ],
                  ),
                ),
                customHeight(20.h),
                Expanded(
                  child: TabBarView(
                    physics: NeverScrollableScrollPhysics(),
                    controller: _tabController,
                    children: [VisitPage(), VisitPage(), VisitPage()],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}






/////////

///
///
import 'package:clinician_app/core/constant/constant_import.dart';
import 'package:clinician_app/pages/home/widget/chat_fab_widget.dart';
import 'package:clinician_app/pages/home/widget/clinician_info_dialog.dart';
import 'package:clinician_app/pages/home/widget/home_appbar_widget.dart';
import 'package:clinician_app/pages/home/widget/see_route_dialog.dart';
import 'package:clinician_app/pages/home/widget/visit_overlay_widget.dart';
import 'package:clinician_app/utils/global_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:image_stack/image_stack.dart';

import '../../controller/live_map_controller.dart';
import '../../main.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with RouteAware {
  static const double _mapOverlayHeight = 140;
  static const double _mapBottomOverlayHeight = 90;

  RxInt mapInx = 0.obs;
  final List<UserProgress> users = [
    UserProgress('Ralph Edwards', '\$55.00', true, true),
    UserProgress('Devon Lane', '\$55.00', true, true),
    UserProgress('Jerome Bell', '\$55.00', true, true),
    UserProgress('Eleanor Pena', '\$55.00', true, false, isCurrent: true),
    UserProgress('Wade Warren', '\$55.00', false, false),
    UserProgress('Bessie Cooper', '\$55.00', false, false),
  ];
  final LiveMapController liveMapController = Get.put(LiveMapController());
  @override
  void initState() {
    // ✅ one-time initial load (no more continuous polling)
    liveMapController.loadInitial();
    liveMapController.onPatientMarkerTap = _openVisitDialog;
    super.initState();
  }

  /// Opens the visit dialog for [visitId] — shared by the timeline cards and
  /// the map pins.
  Future<void> _openVisitDialog(int visitId) async {
    await liveMapController.fetchVisitMapDetails(visitId: visitId);
    Get.dialog(
      ClinicianInfoDialog(
        data: liveMapController.visitDashboardDetails.value,
        viditId: visitId,
      ),
      barrierColor: Colors.white38,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void dispose() {
    liveMapController.onPatientMarkerTap = null;
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // A screen/dialog opened from this page (e.g. ClinicianInfoDialog,
    // SeeRouteDialog) was closed — refresh so the map/list reflects changes.
    liveMapController.refreshNow();
  }
  Color hexToColor(String? hex) {
    if (hex == null || hex.trim().isEmpty) return AppColors.chatRedColor;

    String value = hex.trim();

    // Accept "#RRGGBB"
    if (value.startsWith("#")) {
      value = value.replaceFirst("#", "");
      return Color(int.parse("0xFF$value"));
    }

    // Accept "0xffRRGGBB" or "0xFFRRGGBB"
    if (value.startsWith("0x") || value.startsWith("0X")) {
      return Color(int.parse(value));
    }

    // fallback: raw "RRGGBB"
    if (value.length == 6) {
      return Color(int.parse("0xFF$value"));
    }

    return AppColors.chatRedColor;
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          HomeAppbarWidget(),
        Obx((){
          if (liveMapController.isLoading.value) {
            return Expanded(child: const Center(child: CircularProgressIndicator(color: AppColors.primaryAppColor,)));
          }
          // if (controller.error.value.isNotEmpty) {
          //   return Center(
          //     child: Text(
          //       controller.error.value,
          //       style: AppTextStyle.normal12style,
          //     ),
          //   );
          // }

          if (liveMapController.clinicianStats.value.clinician == null) {
            return Expanded(child: const Center(child: Text("No data found")));
          }
          return Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: Obx(
                    () => Visibility(
                      visible: mapInx.value == 0,
                      // list view
                      replacement: SizedBox(
                        width: double.maxFinite,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            customHeight(140.h),
                            liveMapController.visitsMapModel.value.visits.isEmpty ?
                                Flexible(child: Center(child: Text('No data found!'),)):Flexible(
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: liveMapController.visitsMapModel.value.visits.length,
                                itemBuilder: (_, index) {
                                  final user = liveMapController.visitsMapModel.value.visits[index];
                                  return InkWell(
                                    splashColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    onTap: () => _openVisitDialog(user.visitId),
                                    child: CustomTimelineCard(
                                      name: user.patientName,
                                      time: '${user.visitDateTimeTo} ${user.visiteDateTimeFrom}',
                                      amount: '\$${user.visitCharge}',
                                      index: index,
                                      isDone: user.isVisitCompleted,
                                      isCurrent: user.onWay,
                                      imageUrl: user.patientImgUrl,
                                      length: liveMapController.visitsMapModel.value.visits.length,
                                    ),
                                  );
                                },
                              ),
                            ),
                            customHeight(15.h),
                            // Flexible(
                            //   child: Timeline.tileBuilder(
                            //     builder: TimelineTileBuilder(
                            //       itemCount: 6,
                            //       itemExtent: 60.h,
                            //       startConnectorBuilder:
                            //           (context, index) =>
                            //               index > 0
                            //                   ? DashedLineConnector(
                            //                     thickness: 2.w,
                            //                     dash: 4,
                            //                     color: Colors.black,
                            //                     gap: 2,
                            //                   )
                            //                   : null,
                            //       endConnectorBuilder:
                            //           (context, index) =>
                            //               index < 5
                            //                   ? DashedLineConnector(
                            //                     thickness: 2.w,
                            //                     dash: 4,
                            //                     color: Colors.black,
                            //                     gap: 2,
                            //                   )
                            //                   : null,
                            //       indicatorBuilder: (_, index) {
                            //         final user = users[index];
                            //         if (user.isCurrent) {
                            //           return DotIndicator(
                            //             color: Colors.transparent,
                            //             child: SvgPicture.asset(
                            //               AppAsset.locationPinSvgIcon,
                            //               width: 13.w,
                            //             ),
                            //           );
                            //         } else if (user.isDone) {
                            //           return DotIndicator(
                            //             // color: Colors.green,
                            //             color: Colors.transparent,
                            //             child: SizedBox(
                            //               width: 18.w,
                            //               height: 18.h,
                            //               child: Radio(
                            //                 value: true,
                            //                 groupValue: true,
                            //                 onChanged: (value) {},
                            //                 fillColor: WidgetStatePropertyAll(
                            //                   Colors.green,
                            //                 ),
                            //                 activeColor: Colors.green,
                            //               ),
                            //             ),
                            //           );
                            //         } else {
                            //           return OutlinedDotIndicator(
                            //             borderWidth: 2,
                            //             color: Colors.black,
                            //             backgroundColor: Colors.white,
                            //           );
                            //         }
                            //       },
                            //       contentsBuilder: (_, index) {
                            //         final user = users[index];
                            //         return Container(
                            //           width: double.maxFinite,
                            //           decoration: BoxDecoration(
                            //             color: Colors.amber,
                            //           ),
                            //           padding: const EdgeInsets.all(8.0),
                            //           child: ListTile(
                            //             tileColor:
                            //                 user.isCurrent
                            //                     ? Colors.blue.shade50
                            //                     : Colors.white,
                            //             title: Text(
                            //               user.name,
                            //               style: TextStyle(
                            //                 fontWeight: FontWeight.bold,
                            //                 color:
                            //                     user.isCurrent
                            //                         ? Colors.black
                            //                         : Colors.grey.shade800,
                            //               ),
                            //             ),
                            //             subtitle: Text('1:00 PM  1:34 PM'),
                            //             trailing: Text(
                            //               user.amount,
                            //               style: TextStyle(
                            //                 color:
                            //                     user.isCurrent
                            //                         ? Colors.blue
                            //                         : Colors.green,
                            //                 fontWeight: FontWeight.bold,
                            //                 fontSize: 16,
                            //               ),
                            //             ),
                            //           ),
                            //         );
                            //       },
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                      // Map view
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Obx(() => GoogleMap(
                              initialCameraPosition: const CameraPosition(
                                target: LatLng(19.0760, 72.8777),
                                zoom: 14,
                              ),
                              myLocationEnabled: true,
                              myLocationButtonEnabled: false,
                              zoomControlsEnabled: false,
                              mapToolbarEnabled: false,
                              // keeps fitted markers clear of the card + toggle overlay
                              padding: EdgeInsets.only(
                                top: _mapOverlayHeight.h,
                                bottom: _mapBottomOverlayHeight.h,
                              ),

                              // ✅ ADD THESE TWO
                              markers: liveMapController.markers.value,
                              polylines: liveMapController.polylines.value,

                              onMapCreated: liveMapController.onMapReady,
                            )),
                          ),
                          Positioned(
                            bottom: 110.h,
                            right: 16.w,
                            child: Obx(() {
                              if (liveMapController.polylines.value.isEmpty) {
                                return const SizedBox.shrink();
                              }

                              return InkWell(
                                onTap: () {
                                  liveMapController.openInGoogleMaps();
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryAppColor,
                                    borderRadius: BorderRadius.circular(30.r),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.25),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.navigation, color: Colors.white),
                                      customWidth(6.w),
                                      Text(
                                        'Open in Maps',
                                        style: AppTextStyle.normal12style.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ),
                          Positioned(
                            right: 0.w,
                            top: 150.h,
                            child: InkWell(
                              onTap: () {
                                GlobalOverlay().show(
                                  context: context,
                                  backgroundColor: Colors.white.withValues(alpha: 0.3),
                                  child: Positioned(
                                    right: 0,
                                    top: 200.h,
                                    child: VisitOverlayWidget(),
                                  ),
                                );
                              },
                              child: Container(
                                height: 100.h,
                                width: 8.w,
                                color: AppColors.primaryAppColor,
                              )
                            ),
                          ),
                        ],
                      )
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () {

                        },
                        child: Obx(() => Container(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          width: double.maxFinite,
                          margin: mapInx.value == 1
                              ? EdgeInsets.symmetric(horizontal: 16.w)
                              : EdgeInsets.zero,
                          decoration: BoxDecoration(
                            // List tab: floating card (Figma); Map tab: the
                            // original full-width band — unchanged.
                            color: mapInx.value == 1
                                ? AppColors.textFieldBackGColor
                                : Colors.white,
                            borderRadius: mapInx.value == 1
                                ? BorderRadius.circular(6.r)
                                : null,
                            boxShadow: [
                              BoxShadow(
                                offset: Offset(2.w, 2.h),
                                blurRadius: 4.r,
                                color: Colors.black.withValues(alpha: 0.16),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 51.h,
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Container(
                                      height: 46.h,
                                      width: 46.w,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        // border: GradientBoxBorder(
                                        //   width: 1.w,
                                        //   // gradient: LinearGradient(
                                        //   //   colors: [
                                        //   //     Colors.black,
                                        //   //     Color(0xffCE9E2F),
                                        //   //     Color(0xffE4AC31),
                                        //   //     Color(0xff9F7302),
                                        //   //     Color(0xffC08503),
                                        //   //     Color(
                                        //   //       0xffBB720A,
                                        //   //     ).withValues(alpha: 0.69),
                                        //   //     Color(0xffBE892F),
                                        //   //     Color(
                                        //   //       0xffC47B13,
                                        //   //     ).withValues(alpha: 0.69),
                                        //   //     Color(
                                        //   //       0xffC58413,
                                        //   //     ).withValues(alpha: 0.807),
                                        //   //     Color(0xffB8830F),
                                        //   //     Color(0xffDD9D34),
                                        //   //     Colors.black,
                                        //   //   ],
                                        //   // ),
                                        // ),
                                        boxShadow: [
                                          BoxShadow(
                                            offset: Offset(2.w, 2.h),
                                            blurRadius: 4.r,
                                            color: Colors.black.withValues(
                                              alpha: 0.16,
                                            ),
                                          ),
                                        ],
                                      ),
                                      clipBehavior: Clip.hardEdge,
                                      child: liveMapController.clinicianStats.value.clinician.imageUrl.isNotEmpty
                                          ? Image.network(
                                              liveMapController.clinicianStats.value.clinician.imageUrl,
                                              fit: BoxFit.cover,
                                            )
                                          :
                                      Image.asset(AppAsset.profilePicImg,),
                                    ),
                                    Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 2.5.w,
                                          vertical: 2.h,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            3.r,
                                          ),
                                          color: hexToColor(liveMapController.clinicianStats.value.clinician.employeeTypeColor),
                                        ),
                                        child: Text(
                                          liveMapController.clinicianStats.value.clinician.employeeTypeAbbreviation,
                                          style: AppTextStyle.normal10style
                                              .copyWith(
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              customWidth(10.w),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    liveMapController.clinicianStats.value.clinician.name,
                                    style: AppTextStyle.normal10style.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  customHeight(6.h),
                                  Text(
                                    'Potential Earning  -  \$${liveMapController.clinicianStats.value.potentialEarning}',
                                    style: AppTextStyle.normal10style.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              customWidth(30.w),
                              Column(
                                children: [
                                  ImageStack.providers(
                                    providers: liveMapController.clinicianStats.value.activePatients
                                        .take(3)
                                        .map<ImageProvider<Object>>((p) {
                                      if (p.imageUrl.isNotEmpty) {
                                        return NetworkImage(p.imageUrl) as ImageProvider<Object>;
                                      } else {
                                        return const AssetImage(AppAsset.profilePicImg) as ImageProvider<Object>;
                                      }
                                    }).toList(),


                                    extraCountBorderColor: Colors.transparent,
                                    extraCountTextStyle: AppTextStyle.normal10style
                                        .copyWith(fontWeight: FontWeight.w600),
                                    // imageBorderColor: AppColors.primaryAppColor,

                                    totalCount: liveMapController.clinicianStats.value.activePatients.length, // ✅ total active patients
                                    imageRadius: 20.r,
                                    imageCount: liveMapController.clinicianStats.value.activePatients.length > 3
                                        ? 3
                                        : liveMapController.clinicianStats.value.activePatients.length, // ✅ max 3 show
                                    imageBorderWidth: 0.5.w,
                                  ),

                                  customHeight(4.h),

                                  Text(
                                    'Active Patients (${liveMapController.clinicianStats.value.activePatients.length})', // ✅ show count
                                    style: AppTextStyle.normal10style.copyWith(
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                ],
                              )

                            ],
                          ),
                        )),
                      ),
                      customHeight(10.h),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          height: 27.w,
                          margin: EdgeInsets.only(right: 10.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6.r),
                            border: Border.all(
                              color: AppColors.primaryAppColor,
                              width: 1.w,
                            ),
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(
                              2,
                              (index) => InkWell(
                                onTap: () {
                                  mapInx.value = index;
                                },
                                child: Obx(
                                  () => Container(
                                    width: 45.w,
                                    height: 27.h,
                                    alignment: Alignment.center,

                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5.r),
                                      color:
                                          mapInx.value == index
                                              ? AppColors.primaryAppColor
                                              : Colors.white,
                                    ),
                                    child: Text(
                                      index == 0 ? 'Map' : 'List',
                                      style: AppTextStyle.normal14style.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color:
                                            mapInx.value == index
                                                ? Colors.white
                                                : AppColors.primaryAppColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                mapInx.value == 0 ? Positioned(
                  left: 0,
                  bottom: 68.h,
                  child: InkWell(
                    onTap: () {
                      Get.dialog(
                        SeeRouteDialog(),
                        barrierColor: const Color(0x4DDDDDDD),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 13.w,
                        vertical: 9.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryAppColor,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(6.r),
                          bottomRight: Radius.circular(6.r),
                        ),
                      ),
                      child: Text(
                        'See Route',
                        style: AppTextStyle.normal14style.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ) : Positioned(
                    left: 0,
                    bottom: 5.h,
                    child: SizedBox()),
                Positioned(
                    right: 25.w,
                    bottom: 5.h,
                    child: ChatFABWidget()),
              ],
            ),
          );}),
        ],
      ),
    );
  }
}

class UserProgress {
  final String name;
  final String amount;
  final bool isDone;
  final bool showCheck;
  final bool isCurrent;

  UserProgress(
    this.name,
    this.amount,
    this.isDone,
    this.showCheck, {
    this.isCurrent = false,
  });
}

class User {
  final String name;
  final String imageUrl;

  User({required this.name, required this.imageUrl});
}

final List<User> userList = [
  User(name: 'Ralph Edwards', imageUrl: 'https://i.pravatar.cc/100?img=1'),
  User(name: 'Devon Lane', imageUrl: 'https://i.pravatar.cc/100?img=2'),
  User(name: 'Jerome Bell', imageUrl: 'https://i.pravatar.cc/100?img=3'),
  User(name: 'Eleanor Pena', imageUrl: 'https://i.pravatar.cc/100?img=4'),
  User(name: 'Wade Warren', imageUrl: 'https://i.pravatar.cc/100?img=5'),
  User(name: 'Bessie Cooper', imageUrl: 'https://i.pravatar.cc/100?img=6'),
];

/// Dotted connector between timeline indicators. Sized by its parent, so it
/// never overflows the row like a fixed-length dash did.
class _TimelineConnector extends StatelessWidget {
  const _TimelineConnector({required this.visible});

  final bool visible;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => Dash(
        dashColor: visible ? Colors.black : Colors.transparent,
        direction: Axis.vertical,
        dashThickness: 2.w,
        dashLength: 5,
        dashGap: 2,
        dashBorderRadius: 2.r,
        length: constraints.maxHeight,
      ),
    );
  }
}

class CustomTimelineCard extends StatelessWidget {
  final String name;
  final String time;
  final String amount;
  final int index;
  final bool isDone;
  final bool isCurrent;
  final String imageUrl;
  final int length;

  const CustomTimelineCard({
    super.key,
    required this.name,
    required this.time,
    required this.amount,
    required this.index,
    required this.isDone,
    required this.isCurrent,
    required this.imageUrl,
    required this.length,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background Container with decoration
        Container(
          margin: EdgeInsets.symmetric(vertical: 5.h, horizontal: 18.w),
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          width: double.maxFinite,
          decoration: BoxDecoration(
            color:
                isCurrent
                    ? Colors.white
                    : isDone
                    ? Color(0xffF3F3F3)
                    : Color(0xffE8F7FE),
            border: Border.all(
              color: isCurrent ? Colors.blue : Colors.transparent,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            children: [
              customWidth(35.w),
              Text(
                (index + 1).toString().padLeft(2, '0'),
                style: AppTextStyle.normal12style.copyWith(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 12),
              CircleAvatar(
                  backgroundImage: imageUrl.isEmpty ? AssetImage(AppAsset.profilePicImg) : NetworkImage(imageUrl)
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTextStyle.normal12style.copyWith(
                      fontWeight: FontWeight.w700,
                      color:
                          isCurrent
                              ? Colors.black
                              : isDone
                              ? AppColors.textGreyColor
                              : AppColors.iconGreyColor,
                    ),
                  ),
                  customHeight(4.h),
                  Text(
                    time,
                    style: AppTextStyle.normal10style.copyWith(
                      fontWeight: FontWeight.w300,
                      color:
                          isCurrent
                              ? Colors.black
                              : isDone
                              ? AppColors.textGreyColor
                              : AppColors.iconGreyColor,
                    ),
                  ),
                ],
              ),
              Spacer(),
              Text(
                amount,
                style: AppTextStyle.normal12style.copyWith(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                  color:
                      isCurrent
                          ? AppColors.primaryAppColor
                          : isDone
                          ? Color(0xff008000)
                          : Colors.black,
                ),
              ),
              customWidth(10.w),
            ],
          ),
        ),

        // Timeline Circle and Line
        Positioned(
          left: 28,
          top: 0,
          bottom: 0,
          child: Column(
            children: [
              // Top dotted line
              // if (index > 0)
              Expanded(
                child: _TimelineConnector(visible: index > 0),
              ),
              // Circle or pin icon
              Container(
                width: 22.w,
                margin: EdgeInsets.only(bottom: 2.h),
                child:
                    isCurrent
                        ? SvgPicture.asset(
                          AppAsset.locationPinSvgIcon,
                          width: 13.w,
                        )
                        : isDone
                        ? SizedBox(
                          width: 18.w,
                          height: 18.h,
                          child: Radio(
                            value: true,
                            groupValue: true,
                            onChanged: (value) {},
                            fillColor: WidgetStatePropertyAll(
                              Color(0xff3A9A40),
                            ),
                            activeColor: Color(0xff3A9A40),
                          ),
                        )
                        : Container(
                          width: 18.w,
                          height: 18.h,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(width: 2.w, color: Colors.black),
                            color: Colors.white,
                          ),
                        ),
              ),
              // Bottom line
              Expanded(
                child: _TimelineConnector(visible: index < length - 1),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

import 'package:clinician_app/core/constant/constant_import.dart';
import 'package:clinician_app/core/ui/common_appbar.dart';
import 'package:clinician_app/pages/profile/availability_page.dart';
import 'package:clinician_app/pages/profile/document.dart';
import 'package:clinician_app/pages/profile/edit_profile.dart';
import 'package:clinician_app/pages/profile/my_earnings_page.dart';
import 'package:clinician_app/pages/profile/pending_page.dart';
import 'package:clinician_app/pages/profile/time_off_page.dart';
import 'package:clinician_app/pages/profile/widgets/logout_dailog.dart';
import 'package:clinician_app/pages/profile/widgets/profile_menu_tile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/profile_controller.dart';
import '../../core/common/hex_color_decoder.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Figma: 2-column grid, 17 px side inset, tiles 168 × 128 with 15 px radius
  static const double _gridSidePadding = 17;
  static const double _gridGap = 16;
  static const double _tileWidth = 168;
  static const double _tileHeight = 128;

  ProfileController controller = Get.put(ProfileController());
  @override
  void initState() {
    // TODO: implement initState
    controller.fetchClinitionLoginDetails();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    FocusScope.of(context).unfocus();
    // controller.fetchClinitionLoginDetails();
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            CommonAppbar(
              isBackButton: false,
              label: "My Profile",
              trailing: InkWell(
                onTap: () {
                  controller.fetchRecordType();
                  Get.to(() => EditProfilePage(employeeId: controller.employeeId.value,));
                },
                child: Text(
                  "Edit Profile",
                  style: TextStyle(color: AppColors.defaultTxtGrey),
                ),
              ),
              padding: EdgeInsets.only(
                left: 20.w,
                right: 20.w,
                top: 15.h,
                bottom: 8.h,
              ),
            ),
            Divider(),
            customHeight(30.h),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                  Obx(()=>
                      Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
            
                    child: Row(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.white,
                              backgroundImage: controller.clinitinaLoginDataModel.value.imageUrl.isEmpty ?
                              AssetImage(AppAsset.profilePicImg) : NetworkImage(controller.clinitinaLoginDataModel.value.imageUrl),
                              radius: 40,
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 50.h, left: 50.w),
                              child: Container(
                                height: 20.h,
            
                                padding: EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: hexToColor(controller.clinitinaLoginDataModel.value.color),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Center(
                                  child: Text(
                                    controller.clinitinaLoginDataModel.value.abbreviation,
                                    style: AppTextStyle.normal10style
                                        .copyWith(color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        customWidth(20.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              controller.clinitinaLoginDataModel.value.clinicianFullName,
                              style: AppTextStyle.regular16style.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.defaultTxtGrey,
                              ),
                            ),
                            Text(
                              "${controller.clinitinaLoginDataModel.value.gender} | ${controller.clinitinaLoginDataModel.value.age}y",
                              style: AppTextStyle.regular16style.copyWith(
                                fontWeight: FontWeight.w300,
                                color: AppColors.defaultTxtGrey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),) ,
                    customHeight(24.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: _gridSidePadding.w),
                      child: GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: _gridGap.h,
                        crossAxisSpacing: _gridGap.w,
                        childAspectRatio: _tileWidth / _tileHeight,
                        children: [
                          ProfileMenuTile(
                            title: "Document Update",
                            image: AppAsset.document,
                            onTap: () => Get.to(
                              () => DocumnetPage(empId: controller.employeeId.value),
                              transition: Transition.cupertino,
                              duration: const Duration(milliseconds: 350),
                            ),
                          ),
                          ProfileMenuTile(
                            title: "Time Off",
                            image: AppAsset.timer,
                            onTap: () => Get.to(
                              () => TimeOffPage(employeeId: controller.employeeId.value),
                              transition: Transition.cupertino,
                              duration: const Duration(milliseconds: 350),
                            ),
                          ),
                          ProfileMenuTile(
                            title: "Pending Visit Notes/ Oasis",
                            image: AppAsset.pending,
                            onTap: () => Get.to(
                              () => PendingVisits(),
                              transition: Transition.cupertino,
                              duration: const Duration(milliseconds: 350),
                            ),
                          ),
                          ProfileMenuTile(
                            title: "My Earning",
                            image: AppAsset.earning,
                            onTap: () => Get.to(
                              () => MyEarningPage(),
                              transition: Transition.cupertino,
                              duration: const Duration(milliseconds: 350),
                            ),
                          ),
                          ProfileMenuTile(
                            title: "Availability",
                            svg: AppAsset.availabilitySvgIcon,
                            onTap: () => Get.to(
                              () => AvailabilityPage(),
                              transition: Transition.cupertino,
                              duration: const Duration(milliseconds: 350),
                            ),
                          ),
                          ProfileMenuTile(
                            title: "Logout",
                            image: AppAsset.logout,
                            isDestructive: true,
                            onTap: () => showLogoutConfirmationDialog(context),
                          ),
                        ],
                      ),
                    ),
                    customHeight(24.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:clinician_app/core/constant/constant_import.dart';
import 'package:clinician_app/core/ui/buttons/primary_button.dart';
import 'package:clinician_app/core/ui/buttons/primary_outlined_button.dart';
import 'package:clinician_app/pages/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/auth_controller.dart';
import '../../../controller/calling_controller.dart';
import '../../../controller/home_controller.dart';
import '../../../controller/profile_controller.dart';
import '../../../services/token_manager/token_manager_service.dart';

const double _logoutDialogRadius = 12;
const double _logoutButtonHeight = 35;
const double _logoutBorderWidth = 0.5;
const Color _logoutSubtitleColor = Color(0xff848484);

void showLogoutConfirmationDialog(BuildContext context) {
  final callController = Get.put(CallingController());
  final authController = Get.put(AuthController());
  // final homeController = Get.put(HomeController());

  ProfileController profileController = Get.put(ProfileController());
  showDialog(
    context: context,
    barrierDismissible: true,
    builder:
        (_) => Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Container(
            padding: EdgeInsets.fromLTRB(20.w, 44.h, 20.w, 28.h),
            // Figma: #F9FAFB surface, 0 4 4 #00000040 shadow
            decoration: BoxDecoration(
              color: AppColors.textFieldBackGColor,
              borderRadius: BorderRadius.circular(_logoutDialogRadius),
              boxShadow: const [
                BoxShadow(
                  offset: Offset(0, 4),
                  blurRadius: 4,
                  color: Color(0x40000000),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Yellow icon or SVG
                Image.asset(AppAsset.logOut, height: 35.h),
                SizedBox(height: 14.h),

                // Title
                Text(
                  "Are you Sure?",
                  // Figma: Fira Sans 600 / 18px / 100% #000
                  style: AppTextStyle.normal12style.copyWith(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    height: 1,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 10),

                // Subtitle
                Text(
                  "Are you sure you really want to logout from your account?",
                  // Figma: Fira Sans 400 / 12px / 18px #848484
                  style: AppTextStyle.normal12style.copyWith(
                    fontSize: 12.sp,
                    height: 18 / 12,
                    color: _logoutSubtitleColor,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 31.h),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: DecoratedBox(
                        // Figma: 0 4 201 #0000000D
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(6)),
                          boxShadow: [
                            BoxShadow(
                              offset: Offset(0, 4),
                              blurRadius: 201,
                              color: Color(0x0D000000),
                            ),
                          ],
                        ),
                        child: PrimaryOutlinedButton(
                          width: double.infinity,
                          height: _logoutButtonHeight,
                          text: "Log Out",
                          // Figma: 0.5px #FF0000 border, Fira Sans 300 / 14px
                          borderWidth: _logoutBorderWidth,
                          radius: 6,
                          fillColor: Colors.white,
                          textStyle: AppTextStyle.normal12style.copyWith(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w300,
                            height: 1,
                            color: Colors.red,
                          ),
                          buttonColor: Colors.red,
                          onPressed: () async {
                            final fcmToken =
                                await TokenManager.getFcmTokenRegister();
                            final refreshToken =
                                await TokenManager.getRefreshAccessToken();
                            if (fcmToken.isEmpty) {
                              var refreshResponse = await authController
                                  .logoutCurrentuser(
                                    refreshToken: refreshToken,
                                  );
                              if (refreshResponse.statusCode == 200 ||
                                  refreshResponse.statusCode == 204) {
                                profileController.clearEmpId();
                                print('User logged out successfully');
                                // TokenManager.removeAccessToken();
                                // Navigator.pushNamedAndRemoveUntil(
                                //     buildContext, LoginScreen.routeName, (route) => false);
                              } else {
                                print('Failed to log out user');
                                profileController.clearEmpId();
                                // homeController.clearAllData();
                                TokenManager.removeAccessToken();
                                Get.offAll(() => LoginScreen());
                              }
                            } else {
                              var response = await callController
                                  .unRegisterDevice(
                                    context: context,
                                    fcmToken: fcmToken,
                                  );
                              if (response.statusCode == 201 ||
                                  response.statusCode == 200) {
                                var refreshResponse = await authController
                                    .logoutCurrentuser(
                                      refreshToken: refreshToken,
                                    );
                                if (refreshResponse.statusCode == 200 ||
                                    refreshResponse.statusCode == 204) {
                                  profileController.clearEmpId();
                                  TokenManager.removeFCMToken();
                                  print('User logged out successfully');
                                  // TokenManager.removeAccessToken();
                                  // Navigator.pushNamedAndRemoveUntil(
                                  //     buildContext, LoginScreen.routeName, (route) => false);
                                } else {
                                  print('Failed to log out user');
                                  profileController.clearEmpId();
                                  // homeController.clearAllData();
                                  TokenManager.removeFCMToken();
                                  TokenManager.removeAccessToken();
                                  Get.offAll(() => LoginScreen());
                                }
                              }
                            }

                            // TokenManager.removeAccessToken();
                          },
                        ),
                      ),
                    ),
                    customWidth(12.w),
                    Expanded(
                      child: DecoratedBox(
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(6)),
                          boxShadow: [
                            BoxShadow(
                              offset: Offset(0, 4),
                              blurRadius: 201,
                              color: Color(0x0D000000),
                            ),
                          ],
                        ),
                        child: PrimaryButton(
                          onTap: () {
                            Get.back();
                          },
                          width: double.infinity,
                          height: _logoutButtonHeight,
                          padding: EdgeInsets.zero,
                          borderRadius: 6,
                          label: "Cancel",
                          // Figma: #1696C8, Fira Sans 600 / 14px / 100%
                          buttonColor: AppColors.saveButtonBlue,
                          labelStyle: AppTextStyle.normal12style.copyWith(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            height: 1,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
  );
}

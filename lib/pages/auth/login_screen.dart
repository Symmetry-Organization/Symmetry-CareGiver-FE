import 'package:clinician_app/controller/profile_controller.dart';
import 'package:clinician_app/core/constant/constant_import.dart';
import 'package:clinician_app/core/ui/buttons/primary_button.dart';
import 'package:clinician_app/core/ui/buttons/primary_outlined_button.dart';
import 'package:clinician_app/core/ui/primary_textfield.dart';
import 'package:clinician_app/pages/auth/forgot_pass_screen.dart';
import 'package:clinician_app/pages/auth/widget/error_dailog.dart';
import 'package:clinician_app/pages/home/home_screen.dart';
import 'package:clinician_app/utils/validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../controller/auth_controller.dart';
import '../../core/constant/api_app_constant.dart';
import '../../services/token_manager/token_manager_service.dart';
import 'company_list_screen.dart';

/// Single-step login — email + password on one screen. The company lookup
/// that used to gate a separate password screen now runs inside [_login];
/// only the multi-company case still detours through [CompanyListScreen].
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final auth = Get.put(AuthController());
  final profileController = Get.put(ProfileController());
  bool _obscurePassword = true;

  static const double _fieldIconSize = 20;
  static const double _faceIdIconSize = 20;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _login() async {
    if (auth.isLoading.value) return;

    final email = emailController.text.trim();
    if (email.isEmpty) {
      _showErrorSnackBar('Email is required');
      return;
    }
    final emailError = Validators.validateEmail(email);
    if (emailError != null) {
      _showErrorSnackBar(emailError);
      return;
    }
    final passwordError = Validators.validatePassword(passwordController.text);
    if (passwordError != null) {
      _showErrorSnackBar(passwordError);
      return;
    }

    final companies = await auth.getCompanyList(email);
    if (!companies.success) {
      if (!mounted) return;
      showErrorDialog(
        context: context,
        title: "Invalid credentials!",
        subtitle: "Unable to retrieve credentials for authorizing user.",
      );
      return;
    }

    if (companies.companies.length != 1) {
      Get.to(
        () => CompanyListScreen(
          isForgotPasswordScreen: false,
          email: email,
          companyList: companies.companies,
        ),
      );
      return;
    }

    final companyAlias = companies.companies.first.companyAlias;
    await TokenManager.setCompanyAlias(companyAlias: companyAlias);
    ApiAppConstant.endPointByAlias(3, companyAlias);

    final response = await auth.signInAuth(
      email: email,
      password: passwordController.text,
    );
    if (!mounted) return;

    if (!response.success) {
      showErrorDialog(
        context: context,
        title: "Invalid credentials!",
        subtitle: response.message,
      );
      return;
    }

    if (response.roleName == "Clinical" && response.userStatus == "Completed") {
      await profileController.fetchRecordType();
      await profileController.fetchClinitionLoginDetails();
      await Get.offAll(
        () => HomeScreen(),
        transition: Transition.rightToLeftWithFade,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
      return;
    }

    _showErrorSnackBar(
      response.userStatus == "Onboarding"
          ? (response.roleName != "Clinical"
              ? "Only Clinical users are allowed to log in."
              : "Only Onboarded users are allowed to log in.")
          : "Only Clinical users are allowed to log in.",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                customHeight(10.h),
                Image.asset(AppAsset.loginDoctorImg, height: 243.h),
                customHeight(46.h),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Login',
                    style: AppTextStyle.normal14style.copyWith(
                      color: AppColors.defaultTxtGrey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                customHeight(3.h),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Using credentials from Pro Health',
                    style: AppTextStyle.normal12style.copyWith(
                      color: AppColors.defaultTxtGrey,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
                customHeight(24.h),
                PrimaryTextField(
                  controller: emailController,
                  hintText: 'Your Email',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  prefixIcon: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15.w),
                    child: SvgPicture.asset(
                      AppAsset.emailSvgIcon,
                      width: _fieldIconSize,
                      height: _fieldIconSize,
                      fit: BoxFit.scaleDown,
                    ),
                  ),
                ),
                customHeight(20.h),
                PrimaryTextField(
                  controller: passwordController,
                  hintText: 'Password',
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: _obscurePassword,
                  prefixIcon: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15.w),
                    child: SvgPicture.asset(
                      AppAsset.passwordSvgIcon,
                      width: _fieldIconSize,
                      height: _fieldIconSize,
                      fit: BoxFit.scaleDown,
                    ),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                ),
                customHeight(10.h),
                Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    onTap: () => Get.to(() => ForgotPassScreen()),
                    child: Text(
                      'Forgot password?',
                      style: AppTextStyle.normal10style.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppColors.primaryAppColor,
                      ),
                    ),
                  ),
                ),
                customHeight(64.h),
                Obx(
                  () => auth.isLoading.value
                      ? Padding(
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          child: const CircularProgressIndicator(
                            color: AppColors.primaryAppColor,
                          ),
                        )
                      : PrimaryButton(onTap: _login, label: 'Login'),
                ),
                customHeight(20.h),
                PrimaryOutlinedButton(
                  text: 'Login with Face ID',
                  icon: SvgPicture.asset(
                    AppAsset.faceIdSvgIcon,
                    width: _faceIdIconSize.w,
                    height: _faceIdIconSize.w,
                  ),
                  textStyle: AppTextStyle.normal16style.copyWith(
                    color: AppColors.primaryAppColor,
                    fontWeight: FontWeight.w500,
                  ),
                  // TODO(biometrics): needs a local_auth integration — wire
                  // up once the dependency is approved.
                  onPressed: () {},
                ),
                customHeight(20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

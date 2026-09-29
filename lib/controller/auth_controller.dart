import 'package:clinician_app/core/constant/app_string.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../model/request/request_data_model.dart';
import '../pages/auth/login_screen.dart';
import '../services/auth_api_services/auth_services.dart';
import '../services/token_manager/token_manager_service.dart';
import 'calling_controller.dart';
import 'package:clinician_app/services/mock/mock_data_service.dart';

class AuthController extends GetxController {
  final ApiService _api = Get.put(ApiService());
  final ApiAuthService  _authApi = Get.put(ApiAuthService());
  final callController = Get.put(CallingController());
  final isLoading = false.obs;
  final error = ''.obs;
 final RxString _otpError = ''.obs;
  String get otpError => _otpError.value;
  set otpError(String value) => _otpError.value = value;


  Future<ApiData> signInAuth({
    required String email,
    required String password,
  }) async {
    String? _extractMessage(dynamic data) {
      if (data == null) return null;
      if (data is String && data.isNotEmpty) return data;
      if (data is Map) {
        final msg = data['message'] ?? data['error'] ?? data['msg'];
        if (msg is String && msg.isNotEmpty) return msg;
        if (msg is List && msg.isNotEmpty) return msg.first.toString();
      }
      return null;
    }
    try {
      isLoading.value = true;
      error.value = '';

      // final res = await _api.post('/auth/signIn', {
      //   "email": email,
      //   "password": password,
      // });  // MOCKED for local UI testing
      final res = mockResponse(MockData.get('auth.signIn'));

      if (res.statusCode == 200 || res.statusCode == 201) {
        // Persist the session for any successful Clinical login, not just
        // status == "Onboarding" — the app only lets status == "Completed"
        // users into HomeScreen (see password_screen.dart), so gating the
        // token save on "Onboarding" alone meant a normal, fully-onboarded
        // login never got a token: every request after login then went out
        // with companyId=0/empty email/no token (404 on
        // GetEmployeeIdByEmail/0/, then 401s, then a forced logout).
        if (res.data['user']['role'] == "Clinical") {
          print("accessToken ${res.data["accessToken"]}");
          String token = res.data["accessToken"] ?? "";
          String username =
              "${res.data['user']['firstName']} ${res.data['user']['lastName']}";
          int departmentId = res.data['user']["departmentId"] ?? 0;
          int companyId = res.data['user']["company_id"] ?? 0;
          int userId = res.data['user']["userId"] ?? 0;
          String refreshToken = res.data['refreshToken'] ?? "";
          String userStatus = res.data['user']["status"] ?? "";
          String userEmail = res.data['user']["email"] ?? email;

          callController.initFCM(deviceName: 'MOBILE');

          TokenManager.setAccessToken(
            token: token,
            refreshToken: refreshToken,
            username: username,
            departmentId: departmentId,
            companyId: companyId,
            userID: userId,
            email: userEmail,
            userStatus: userStatus,
          );
        }

        return ApiData(
          success: true,
          message: res.statusMessage ?? 'Success',
          statusCode: res.statusCode ?? 200,
          roleName: res.data['user']["role"] ?? '',
          userStatus: res.data['user']["status"] ?? '',
        );
      } else {
        // Non-2xx response that did NOT throw (only reached if
        // validateStatus allows it in your Dio config).
        final backendMsg = _extractMessage(res.data) ?? "Login failed";
        error.value = backendMsg;
        return ApiData(
          success: false,
          message: backendMsg,
          statusCode: res.statusCode ?? 0,
        );
      }
    } on DioException catch (e) {
      // Backend errors (400, 401, 403, 500...) land here.
      // The real backend message lives in e.response?.data
      final backendMsg =
          _extractMessage(e.response?.data) ?? AppString.somethingWentWrong;
      error.value = backendMsg;
      return ApiData(
        success: false,
        message: backendMsg,
        statusCode: e.response?.statusCode ?? 0,
      );
    } catch (e) {
      // Anything else (parsing errors, null issues, etc.)
      error.value = AppString.somethingWentWrong;
      return ApiData(
        success: false,
        message: AppString.somethingWentWrong,
        statusCode: 0,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// forgot password
  Future<ApiData> forgetPasswordAuth({
    required String email,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';

      // final res = await _api.post('/auth/ForgotPassword', {
      //   "email": email,
      // });  // MOCKED for local UI testing
      final res = mockResponse(MockData.get('auth.forgotPassword'));

      if (res.statusCode == 200 || res.statusCode == 201) {
        // final data = res.data as Map<String, dynamic>;
         print("Auth OTP ::::: ${res.data}");
        return ApiData(
            success: true,
            message: res.statusMessage!,
            statusCode: res.statusCode!
        );
      }else{
        error.value = res.statusMessage!;
        return ApiData(
            success: false,
            message: res.statusMessage!,
            statusCode: res.statusCode!
        );
      }
    } catch (e) {
      error.value = e.toString();
      return ApiData(
          success: false,
          message:AppString.somethingWentWrong,
          statusCode: 404
      );
    } finally {
      isLoading.value = false;
    }
  }
  Future<ApiData> verifyOTPAuth({
    required String email,
    required String otp,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';

      // final res = await _api.post('/auth/verifyOtp', {
      //   "email": email,
      //   "otp": int.parse(otp),
      // });  // MOCKED for local UI testing
      final res = mockResponse(MockData.get('auth.verifyOtp'));

      if (res.statusCode == 200 || res.statusCode == 201) {
        // final data = res.data as Map<String, dynamic>;
        if(res.data['user']['role'] == "Clinical" && res.data['user']["status"] == "Onboarding"){
          print("accessToken ${res.data["accessToken"]}");
          String token = res.data["accessToken"] ?? "";
          String username = "${res.data['user']['firstName']} ${res.data['user']['lastName']}";
          int departmentId = res.data['user']["departmentId"] ?? 0;
          int companyId = res.data['user']["company_id"] ?? 0;
          int userId = res.data['user']["userId"] ?? 0;
          String userStatus = res.data['user']["status"] ?? "";
          String refreshToken = res.data['refreshToken'] ?? "";
          String userEmail = res.data['user']["email"] ?? email;

          TokenManager.setAccessToken(
              token: token,
              refreshToken: refreshToken,
              username: username,
              departmentId: departmentId,
              companyId: companyId,
              userID: userId,
              email: userEmail,
              userStatus: userStatus
          );
        }


        return ApiData(
            success: true,
            message: res.statusMessage!,
            statusCode: res.statusCode!,
            userStatus: res.data['user']["status"] ?? ""
        );
      }else{
        error.value = "Verify failed";
        _otpError.value = res.statusMessage!;
        return ApiData(
        success: false,
            message: res.statusMessage!,
            statusCode: res.statusCode!
        );
      }
    } catch (e) {
      error.value = e.toString();
      _otpError.value = 'Invalid OTP';
      return ApiData(
          success: false,
          message:"Invalid OTP",
          statusCode: 404
      );
    } finally {
      isLoading.value = false;
    }
  }
  Future<ApiData> changePasswordAuth({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';

      // final res = await _api.post('/auth/ResetPassword', {
      //   "email": email,
      //   "otp": int.parse(otp),
      //   "password": newPassword
      // });  // MOCKED for local UI testing
      final res = mockResponse(MockData.get('auth.resetPassword'));

      if (res.statusCode == 200 || res.statusCode == 201) {
        // final data = res.data as Map<String, dynamic>;
        return ApiData(
            success: true,
            message: res.statusMessage!,
            statusCode: res.statusCode!
        );
      }else{
        error.value = res.statusMessage!;
        return ApiData(
            success: false,
            message: res.statusMessage!,
            statusCode: res.statusCode!
        );
      }
    } catch (e) {
      error.value = e.toString();
      return ApiData(
          success: false,
          message:AppString.somethingWentWrong,
          statusCode: 404
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Future<void> updatePassword(String email, String otp) async {
  //   String newPassword = newPasswordController.text;
  //   try {
  //     var headers = {'Content-Type': 'application/json'};
  //     var data = json.encode({
  //       "email": email,
  //       "verificationCode": otp,
  //       "newPassword": newPassword
  //     });
  //
  //     var response = await Dio().post(
  //       '${AppConfig.baseUrl}/auth/ResetPassword',
  //       // http://54.245.136.133:3000/auth/ResetPassword
  //       data: data,
  //       options: Options(headers: headers),
  //     );
  //     if (response.statusCode == 200) {
  //       print(AppString.resetsuccessfully);
  //       print(json.encode(response.data));
  //       Navigator.pop(context as BuildContext);
  //     } else {
  //       print('Failed to change password: ${response.statusMessage}');
  //       print(json.encode(response.data));
  //     }
  //   } catch (e) {
  //     print('Error occurred: $e');
  //   }
  // }

  // int _toInt(dynamic v) {
  //   if (v == null) return 0;
  //   if (v is int) return v;
  //   return int.tryParse(v.toString()) ?? 0;
  // }

  Future<ApiData> refreshAccessToken({
    required String refreshToken,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';

      // final res = await _api.post('/auth/refresh', {
      //   "refreshToken":refreshToken
      // });  // MOCKED for local UI testing
      final res = mockResponse(MockData.get('auth.refresh'));

      if (res.statusCode == 200 || res.statusCode == 201) {
        // final data = res.data as Map<String, dynamic>;
        print("New refresh accessToken ${res.data["accessToken"]}");
        String token = res.data["accessToken"] ?? "";
        String username = "${res.data['user']['firstName']} ${res.data['user']['lastName']}";
        int departmentId = res.data['user']["departmentId"] ?? 0;
        int companyId = res.data['user']["company_id"] ?? 0;
        int userId = res.data['user']["userId"] ?? 0;
        String refreshToken = res.data['refreshToken'] ?? "";
        String userStatus = res.data['user']["status"] ?? "";
        String userEmail = res.data['user']["email"] ?? '';
        callController.initFCM(deviceName: 'MOBILE',);
        TokenManager.setAccessToken(
          token: token,
          refreshToken: refreshToken,
          username: username,
          departmentId: departmentId,
          companyId: companyId,
          userID: userId,
          email: userEmail,
          userStatus: userStatus
        );

        return ApiData(
            success: true,
            message: res.statusMessage!,
            statusCode: res.statusCode!,
            userStatus: res.data['user']["status"] ?? ""
        );
      }else{
        error.value = "Login failed";
        return ApiData(
            success: false,
            message: res.statusMessage!,
            statusCode: res.statusCode!
        );
      }
    } catch (e) {
      error.value = e.toString();
      return ApiData(
          success: false,
          message:AppString.somethingWentWrong,
          statusCode: 404
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<ApiData> logoutCurrentuser({
    required String refreshToken,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';

      // final res = await _api.post('/auth/logout', {
      //   "refreshToken":refreshToken
      // });  // MOCKED for local UI testing
      final res = mockResponse(MockData.get('auth.logout'));

      if (res.statusCode == 200 || res.statusCode == 201) {
        // final data = res.data as Map<String, dynamic>;
        TokenManager.removeAccessToken();
        Get.offAll(()=>LoginScreen());

        return ApiData(
            success: true,
            message: res.statusMessage!,
            statusCode: res.statusCode!
        );
      }else{
        error.value = "Login failed";
        return ApiData(
            success: false,
            message: res.statusMessage!,
            statusCode: res.statusCode!
        );
      }
    } catch (e) {
      error.value = e.toString();
      return ApiData(
          success: false,
          message:AppString.somethingWentWrong,
          statusCode: 404
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Get company list auth
   Future<CompanyListResponse> getCompanyList(String email) async {
    try {
      isLoading.value = true;
      error.value = '';
      print("$email");
      // final response = await _authApi.post('/auth/check-user-companies', {
      //   "email": email,
      // });  // MOCKED for local UI testing
      final response = mockResponse(MockData.get('auth.companies'));

      print("<<<>>>${response.statusCode}");

      if (response.statusCode == 201 || response.statusCode == 200) {
        final List companiesJson = response.data['companies'] ?? [];  // 👈 parse list
        final List<Company> companies = companiesJson
            .map((e) => Company(
          companyId: e['company_id'] ?? 0,
          name: e['name'] ?? "",
          companyAlias: e['company_alias'] ?? "",
        ))
            .toList();

        return CompanyListResponse(
            statusCode: response.statusCode!,
            companies: companies,
            message: "Success",
            success: true);  // 👈 pass parsed companies
      } else {
        error.value = "Company failed";
        return CompanyListResponse(
            statusCode: response.statusCode!,
            companies: [],
            message: response.data["message"] ?? "Failed",
            success: false);
      }
    } catch (e) {
      error.value = e.toString();
      return CompanyListResponse(
          statusCode: 404,
          companies: [],
          message: "Something went wrong",
          success: false);
    }finally{
      isLoading.value = false;
    }
    }
}

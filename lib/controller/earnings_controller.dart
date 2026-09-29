import 'package:clinician_app/controller/repository/profile_repo.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../model/profile/my_earning_model.dart';
import '../services/auth_api_services/auth_services.dart';
import 'package:clinician_app/services/mock/mock_data_service.dart';

class EarningsController extends GetxController {
  final ApiService _api = Get.put(ApiService());
  final isAllEarningLoading = false.obs;
  final isEarningLoading = false.obs;
  final isEarningLoadingList = false.obs;
  final isTimeOffSaveLoading = false.obs;
  final error = ''.obs;
  final myTotalEarningModel = MyTotalEarningModel(
      total: 0, thisWeek: 0, thisMonth: 0).obs;
  final myAllEarningData = MyAllEarningData(
      total: 0, thisweek: 0, thismonth: 0, clinicianId: 0, today: 0).obs;
  final myEarningTodayVisitModel = <MyEarningTodayVisitModel>[].obs;
  List<PriceDurationModel> earningsList = [

  ];
  List<PriceDurationModel> visitsList = [

  ];

  RxInt selectedVisit = 0.obs;

  Future<void> fetchMyTotalEarningData() async {
    myTotalEarningModel.value = await getMyTotalEarningData();
    visitsList = [
      PriceDurationModel(duration: "Total", price: "\$${myTotalEarningModel.value.total}"),
      PriceDurationModel(duration: "This Week", price: "\$${myTotalEarningModel.value.thisWeek}"),
      PriceDurationModel(duration: "This Month", price: "\$${myTotalEarningModel.value.thisMonth}"),
    ];
  }
  Future<void> fetchMyAllEarningData({required int clinitianId}) async {
    myAllEarningData.value = await getMyAllEarningData(clinitianId: clinitianId);
    earningsList = [
      PriceDurationModel(duration: "Total", price: "\$${myAllEarningData.value.total}"),
      PriceDurationModel(duration: "Today", price: "\$${myAllEarningData.value.today}"),
      PriceDurationModel(duration: "This Week", price: "\$${myAllEarningData.value.thisweek}"),
      PriceDurationModel(duration: "This Month", price: "\$${myAllEarningData.value.thismonth}"),
    ];
  }
  Future<void> fetchMyTotalEarningTodayData() async {
    myEarningTodayVisitModel.value = await getMyTotalEarningTodayData();
  }


  Future<MyTotalEarningModel> getMyTotalEarningData() async {
    MyTotalEarningModel? itemData ;
    try {
      isEarningLoading.value = true;
      error.value = '';

      // final res = await _api.get(ProfileRepository.getMyEarning());  // MOCKED for local UI testing
      final res = mockResponse(MockData.get('earnings.summary'));

      if (res.statusCode == 200 || res.statusCode == 201) {
        itemData = MyTotalEarningModel(
            total: res.data['total'] ?? 0,
            thisWeek: res.data['thisWeek'] ?? 0,
            thisMonth: res.data['thisMonth'] ?? 0

        );
      } else {
        error.value = "failed to load data";
      }
    } catch (e) {
      error.value = e.toString();
    } finally {
      isEarningLoading.value = false;
    }

    // ✅ return ONLY here
    return itemData ?? MyTotalEarningModel(total: 0, thisWeek: 0, thisMonth: 0);
  }
  Future<List<MyEarningTodayVisitModel>> getMyTotalEarningTodayData() async {
    List<MyEarningTodayVisitModel> itemData = [] ;
    String formatTimeToAMPM(String? dateTimeString) {
      if (dateTimeString == null || dateTimeString.isEmpty) return '';

      try {
        final DateTime dateTime = DateTime.parse(dateTimeString).toLocal();
        return DateFormat('h.mm a').format(dateTime).replaceAll(' ', '');
      } catch (e) {
        return '';
      }
    }
    try {
      isEarningLoadingList.value = true;
      error.value = '';

      // final res = await _api.get(ProfileRepository.getMyEarningTodayVisit());  // MOCKED for local UI testing
      final res = mockResponse(MockData.get('earnings.todayVisits'));

      if (res.statusCode == 200 || res.statusCode == 201) {
        for(var items in res.data){
          itemData.add(MyEarningTodayVisitModel(
              visitId: items['visitId'] ?? 0,
              patientId: items['patientId'] ?? 0,
              patientName: items['patientName'] ?? '',
              patientAvatarUrl: items['patientAvatarUrl'] ?? '',
              startTime: items['startTime'] != null ? formatTimeToAMPM(items['startTime']) : '',
              endTime: items['endTime'] != null ? formatTimeToAMPM(items['endTime']) : '',
              dayLabel: items['dayLabel'] ?? '',
              durationMinutes: _minutesBetween(items['startTime'], items['endTime']),
              visit_charge: double.parse(
                (((items['visit_charge'] as num?)?.toDouble() ?? 0.0)
                    .toStringAsFixed(2)),
              )
              ));
        }

      } else {
        error.value = "failed to load data";
      }
    } catch (e) {
      error.value = e.toString();
    } finally {
      isEarningLoadingList.value = false;
    }

    // ✅ return ONLY here
    return itemData ;
  }
  Future<MyAllEarningData> getMyAllEarningData(
  {required int clinitianId}
      ) async {
    MyAllEarningData? itemData ;
    try {
      isAllEarningLoading.value = true;
      error.value = '';

      // final res = await _api.get(ProfileRepository.getMyAllEarning(clinicianId: clinitianId));  // MOCKED for local UI testing
      final res = mockResponse(MockData.get('earnings.allEarning'));

      if (res.statusCode == 200 || res.statusCode == 201) {
        itemData = MyAllEarningData(
            total: double.parse(((res.data['total'] as num?)?.toDouble() ?? 0.0).toStringAsFixed(2)),
            thisweek:double.parse(((res.data['thisweek'] as num?)?.toDouble() ?? 0.0).toStringAsFixed(2)),
            thismonth: double.parse(((res.data['thismonth'] as num?)?.toDouble() ?? 0.0).toStringAsFixed(2)),
            clinicianId: res.data['clinicianId'] ?? 0,
          today: double.parse(((res.data['today'] as num?)?.toDouble() ?? 0.0).toStringAsFixed(2)),

        );
      } else {
        error.value = "failed to load data";
      }
    } catch (e) {
      error.value = e.toString();
    } finally {
      isAllEarningLoading.value = false;
    }

    // ✅ return ONLY here
    return itemData ?? MyAllEarningData(
        total: 0,
        thisweek: 0,
        thismonth: 0,
        clinicianId: 0,
        today: 0);
  }

}

int _minutesBetween(dynamic start, dynamic end) {
  final s = DateTime.tryParse(start?.toString() ?? '');
  final e = DateTime.tryParse(end?.toString() ?? '');
  if (s == null || e == null) return 0;
  final m = e.difference(s).inMinutes;
  return m < 0 ? 0 : m;
}

class PriceDurationModel {
  final String price;
  final String duration;

  PriceDurationModel({required this.price, required this.duration});
}

class MyTotalEarningModel{
  final int total;
  final int thisWeek;
  final int thisMonth;
  MyTotalEarningModel({
    required this.total,
    required this.thisWeek,
    required this.thisMonth,
  });
}

class MyEarningTodayVisitModel{
  final int visitId;
  final int patientId;
  final String patientName;
  final String patientAvatarUrl;
  final String startTime;
  final String endTime;
  final String dayLabel;
  final double visit_charge;

  /// Minutes between start and end — summed for the "Today's Hours" bar.
  final int durationMinutes;
  MyEarningTodayVisitModel({
    required this.visitId,
    required this.patientId,
    required this.patientName,
    required this.patientAvatarUrl,
    required this.startTime,
    required this.endTime,
    required this.dayLabel,
    required this.visit_charge,
    this.durationMinutes = 0,
  });

}

class MyAllEarningData{
  final int clinicianId;
  final double total;
  final double thismonth;
  final double thisweek;
  final double today;
  MyAllEarningData({
    required this.clinicianId,
    required this.total,
    required this.thismonth,
    required this.thisweek,
    required this.today,
  });
}
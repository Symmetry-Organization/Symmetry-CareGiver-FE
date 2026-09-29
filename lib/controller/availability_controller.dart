import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

/// One saved availability window: the weekdays it applies to and the hours.
class AvailabilitySlot {
  AvailabilitySlot({
    required this.weekdays,
    required this.from,
    required this.to,
  });

  /// `DateTime.monday`..`DateTime.sunday`, ascending.
  final List<int> weekdays;
  final TimeOfDay from;
  final TimeOfDay to;

  /// "Wed", "Mon to Fri" for a consecutive run, else "Mon, Wed, Fri".
  String get weekdaysLabel {
    if (weekdays.isEmpty) return '';
    final List<String> names =
        weekdays.map(AvailabilityController.weekdayName).toList();
    if (names.length == 1) return names.first;
    final bool isConsecutive = weekdays.last - weekdays.first == names.length - 1;
    return isConsecutive ? '${names.first} to ${names.last}' : names.join(', ');
  }

  String get hoursLabel =>
      '${AvailabilityController.formatTime(from)} to '
      '${AvailabilityController.formatTime(to)}';
}

class AvailabilityController extends GetxController {
  /// Any date inside the week the strip is showing.
  final Rx<DateTime> focusedDate = DateTime.now().obs;
  final RxSet<int> selectedWeekdays = <int>{}.obs;
  final Rxn<TimeOfDay> fromTime = Rxn<TimeOfDay>();
  final Rxn<TimeOfDay> toTime = Rxn<TimeOfDay>();
  final RxList<AvailabilitySlot> slots = <AvailabilitySlot>[].obs;
  final RxString formError = ''.obs;

  /// Set while an existing slot is being edited, so saving replaces it
  /// instead of appending a duplicate.
  final Rxn<AvailabilitySlot> editingSlot = Rxn<AvailabilitySlot>();

  @override
  void onInit() {
    super.onInit();
    selectedWeekdays.add(focusedDate.value.weekday);
  }

  static String weekdayName(int weekday) =>
      DateFormat('EEE').format(DateTime(2024, 1, weekday));

  static String formatTime(TimeOfDay time) {
    final DateTime asDate = DateTime(2024, 1, 1, time.hour, time.minute);
    return DateFormat('h:mm a').format(asDate).toLowerCase();
  }

  /// Monday-to-Sunday dates of the focused week.
  List<DateTime> get weekDates {
    final DateTime monday = focusedDate.value
        .subtract(Duration(days: focusedDate.value.weekday - DateTime.monday));
    return List<DateTime>.generate(
      7,
      (index) => DateTime(monday.year, monday.month, monday.day + index),
    );
  }

  String get monthLabel => DateFormat('MMMM - yyyy').format(focusedDate.value);

  void toggleWeekday(int weekday) {
    if (!selectedWeekdays.remove(weekday)) {
      selectedWeekdays.add(weekday);
    }
    formError.value = '';
  }

  bool isWeekdaySelected(int weekday) => selectedWeekdays.contains(weekday);

  void saveSlot() {
    if (selectedWeekdays.isEmpty) {
      formError.value = 'Select at least one day';
      return;
    }
    final TimeOfDay? from = fromTime.value;
    final TimeOfDay? to = toTime.value;
    if (from == null || to == null) {
      formError.value = 'Select both a from and a to time';
      return;
    }

    final AvailabilitySlot slot = AvailabilitySlot(
      weekdays: selectedWeekdays.toList()..sort(),
      from: from,
      to: to,
    );
    final AvailabilitySlot? editing = editingSlot.value;
    final int existing = editing == null ? -1 : slots.indexOf(editing);
    if (existing >= 0) {
      slots[existing] = slot;
    } else {
      slots.add(slot);
    }
    clearForm();
  }

  void startEditing(AvailabilitySlot slot) {
    editingSlot.value = slot;
    selectedWeekdays
      ..clear()
      ..addAll(slot.weekdays);
    fromTime.value = slot.from;
    toTime.value = slot.to;
    formError.value = '';
  }

  void deleteSlot(AvailabilitySlot slot) {
    slots.remove(slot);
    if (editingSlot.value == slot) clearForm();
  }

  void clearForm() {
    editingSlot.value = null;
    fromTime.value = null;
    toTime.value = null;
    formError.value = '';
    selectedWeekdays
      ..clear()
      ..add(focusedDate.value.weekday);
  }
}

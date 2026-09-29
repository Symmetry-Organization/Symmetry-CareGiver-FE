

import 'package:clinician_app/controller/repository/live_repo.dart';
import 'package:clinician_app/core/constant/app_colors.dart';
import 'package:clinician_app/utils/map_marker_factory.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/constant/api_app_constant.dart';
import '../model/liveMap/live_data_model.dart';
import '../model/liveMap/see_route_model.dart';
import '../model/liveMap/visit_data_model.dart';
import '../services/auth_api_services/auth_services.dart';
import 'package:clinician_app/services/mock/mock_data_service.dart';

class LiveMapController extends GetxController{
  final ApiService _api = Get.put(ApiService());
  final isDashboardLoading = false.obs;
  final isDetailsLoading = false.obs;
  final isMapListLoading = false.obs;
  final isSeeRouteLoading = false.obs;
  final error = ''.obs;

  final RxBool isLoading = false.obs;
  bool _isFirstLoad = true;
  final selectedPatientId = 0.obs;
  final selectedPatientName = ''.obs;
  final visitsMapModel = VisitsMapModel(visits: []).obs;
  final mapVisitDataModel = MapVisitDataModel(
      visitDone: 0,
      visitsRemaining: 0,
      earned: 0,
      visitExpected: 0).obs;
  final visitDashboardDetails = VisitDashboardDetailsModel(
    visit: VisitDashData(
      visitType: '',
      timeRange: '',
      visitCount: '',
      distanceKm: '',
      visitCharge: 0,
      timeToReach: '',
      distanceInMiles: '',
    ),
    patient: PatientDash(
      name: '',
      imageUrl: '',
      gender: '',
      age: 0,
      primaryDiagnosis: '',
      about: '',
      address: '',
    ),
    planOfCare: [],
  ).obs;
  final viewRouteModelData = ViewRouteModelData(
      sourceLatitude: 0.0,
      sourceLongitude: 0.0,
      destinyLatitude: 0.0,
      destinyLongitude: 0.0,
      distance: ''
  ).obs;
  final clinicianStats = ClinicianStats(
    clinician: ClinicianDashboardData(
      clinicianId: 0,
      name: '',
      imageUrl: '',
      employeeTypeAbbreviation: '',
      employeeTypeColor: '',
    ),
    activePatientCount: 0,
    potentialEarning: 0,
    activePatients: [],
  ).obs;
  /// One-time initial load (shows the full loader).
  void loadInitial() {
    fetchClinicianDashoardDetails(showLoader: true)
        .then((_) => _loadVisitsAndMarkers());
  }

  /// Re-fetch on user interaction (e.g. returning to this screen) — no loader.
  void refreshNow() {
    fetchClinicianDashoardDetails().then((_) => _loadVisitsAndMarkers());
  }
  Future<void> fetchViewRoutetMap({required int clinitianId,required int patientId}) async {
    viewRouteModelData.value = await getViewRouteData(clinitianId: clinitianId, patientId: patientId);
  }
  Future<void> fetchListOfVisitMap() async {
visitsMapModel.value = await getMapListVisit();
  }

  // Runs after the dashboard fetch: the route lookups need the clinician id.
  Future<void> _loadVisitsAndMarkers() async {
    await fetchListOfVisitMap();
    await loadPatientMarkers();
  }

  Future<void> fetchVisitMapDetails({required int visitId}) async {
    visitDashboardDetails.value = await getVisitDetailsDashboardData(visitId: visitId);
  }

  Future<void> fetchClinicianDashoardDetails({bool showLoader = false}) async {
    try {
      if (showLoader) isLoading.value = true;

      clinicianStats.value = await getLiveMapDashboardData();
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      if (showLoader) isLoading.value = false;
    }
  }


  Future<void> fetchVisitData({required int clinitianId}) async {
    mapVisitDataModel.value = await getVisitData(clinicianId: clinitianId);
  }


  Future<ClinicianStats> getLiveMapDashboardData() async {
    var itemData;
    try {
      isDashboardLoading.value = true;
      error.value = '';

      // final res = await _api.get(LiveMapRepo.getLiveMapDashboart()); // MOCKED for local UI testing
      final res = mockResponse(MockData.get('liveMap.dashboard'));

      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = res.data;

        // ✅ Clinician object
        final clinicianData = data['clinician'] ?? {};
        final clinician = ClinicianDashboardData(
          clinicianId: clinicianData[ "clinicianId"] ?? 0,
          name: clinicianData['name'] ?? '',
          imageUrl: clinicianData['imageUrl'] ?? '',
          employeeTypeAbbreviation:
          clinicianData['employeeTypeAbbreviation'] ?? '',
          employeeTypeColor: clinicianData['employeeTypeColor'] ?? '',
        );

        // ✅ ActivePatients list
        final List<ActivePatient> activePatients = [];
        if (data['activePatients'] != null) {
          for (var p in data['activePatients']) {
            activePatients.add(
              ActivePatient(
                ptId: p['pt_id'] ?? 0,
                imageUrl: p['imageUrl'] ?? '',
              ),
            );
          }
        }

        // ✅ Final ClinicianStats object
        itemData = ClinicianStats(
          clinician: clinician,
          activePatientCount: data['activePatientCount'] ?? 0,
          potentialEarning: data['potentialEarning'] ?? 0,
          activePatients: activePatients,
        );

      } else {
        error.value = "failed to load data";
      }
    } catch (e) {
      error.value = e.toString();
      debugPrint('error live map dashboard: $e');
    } finally {
      isDashboardLoading.value = false;
    }

    return itemData ?? ClinicianStats(
      clinician: ClinicianDashboardData(
        clinicianId: 0,
        name: '',
        imageUrl: '',
        employeeTypeAbbreviation: '',
        employeeTypeColor: '',
      ),
      activePatientCount: 0,
      potentialEarning: 0,
      activePatients: [],
    );
  }

  Future<VisitDashboardDetailsModel> getVisitDetailsDashboardData({
    required int visitId,
  }) async {
    VisitDashboardDetailsModel? itemData;

    try {
      isDetailsLoading.value = true;
      error.value = '';

      // final res = await _api.get(LiveMapRepo.getLiveMapDetails(visitId: visitId)); // MOCKED for local UI testing
      final res = mockResponse(MockData.get('liveMap.visitDetails'));

      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = res.data;

        // ✅ Visit object
        final visitData = data['visit'] ?? {};
        final visit = VisitDashData(
          visitType: visitData['visitType'] ?? '',
          timeRange: visitData['timeRange'] ?? '',
          visitCount: visitData['visitCount'] ?? '',
            distanceKm: visitData['distanceKm'] ?? '',
          distanceInMiles: visitData['distanceMiles'] ?? '',
          timeToReach: visitData['timeToReach'] ?? '',
          visitCharge: double.parse(((visitData['visit_charge'] as num?)?.toDouble() ?? 0.0).toStringAsFixed(2)),
        );

        // ✅ Patient object
        final patientData = data['patient'] ?? {};
        final patient = PatientDash(
          name: patientData['name'] ?? '',
          imageUrl: patientData['imageUrl'] ?? '',
          gender: patientData['gender'] ?? '',
          age: patientData['age'] ?? 0,
          primaryDiagnosis: patientData['primaryDiagnosis'] ?? '',
          about: patientData['about'] ?? '',
          address: patientData['address'] ?? '',
        );

        // ✅ PlanOfCare list
        final List<PlanOfCareLive> planOfCareList = [];
        if (data['planOfCare'] != null) {
          for (var p in data['planOfCare']) {
            planOfCareList.add(
              PlanOfCareLive(
                abbreviation: p['abbreviation'] ?? '',
                color: p['color'] ?? '',
              ),
            );
          }
        }

        // ✅ Final Model
        itemData = VisitDashboardDetailsModel(
          visit: visit,
          patient: patient,
          planOfCare: planOfCareList,
        );
      } else {
        error.value = "failed to load data";
      }
    } catch (e) {
      error.value = e.toString();
      debugPrint('error live map dashboard: $e');
    } finally {
      isDetailsLoading.value = false;
    }

    return itemData ?? VisitDashboardDetailsModel(
      visit: VisitDashData(
        visitType: '',
        timeRange: '',
        visitCount: '',
        distanceKm: '',
        visitCharge: 0,
        timeToReach: '',
        distanceInMiles: '',
      ),
      patient: PatientDash(
        name: '',
        imageUrl: '',
        gender: '',
        age: 0,
        primaryDiagnosis: '',
        about: '',
        address: '',
      ),
      planOfCare: [],
    );
  }

  Future<VisitsMapModel> getMapListVisit() async {
    VisitsMapModel? itemData;
    String formatTimeToAMPM(String? dateTimeString) {
      if (dateTimeString == null || dateTimeString.isEmpty) return '';

      try {
        final DateTime dateTime = DateTime.parse(dateTimeString).toLocal();
        return DateFormat('h.mm a').format(dateTime);
      } catch (e) {
        return '';
      }
    }
    try {
      isMapListLoading.value = true;
      error.value = '';

      // final res = await _api.get(
      //   LiveMapRepo.getLiveMapTodayList(),
      // ); // MOCKED for local UI testing
      final res = mockResponse(MockData.get('liveMap.mapListVisit'));

      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = res.data;

        // ✅ Visits list
        final List<VisitMapItem> visitsList = [];

        if (data['visits'] != null) {
          for (var v in data['visits']) {
            visitsList.add(
              VisitMapItem(
                visitId: v['visitId'] ?? 0,
                patientId: v['patientId'] ?? 0,
                patientName: v['patientName'] ?? '',
                patientImgUrl: v['patientImgUrl'] ?? '',
                visiteDateTimeFrom: v['visiteDateTimeFrom'] != null ?formatTimeToAMPM(v['visiteDateTimeFrom']) : '',
                visitDateTimeTo: v['visitDateTimeTo'] != null ?formatTimeToAMPM(v['visitDateTimeTo']) : '',
                isVisitCompleted: v['isVisitCompleted'] ?? false,
                isVisitMissed: v['isVisitMissed'] ?? false,
                onWay: v['onWay'] ?? false,
                visitCharge: double.parse(((v['visit_charge'] as num?)?.toDouble() ?? 0.0).toStringAsFixed(2)),
              ),
            );
          }
        }

        // ✅ Final Model
        itemData = VisitsMapModel(visits: visitsList);
      } else {
        error.value = "failed to load data";
      }
    } catch (e) {
      error.value = e.toString();
      debugPrint('error live map details: $e');
    } finally {
      isMapListLoading.value = false;
    }

    return itemData ?? VisitsMapModel(visits: []);
  }

  Future<MapVisitDataModel> getVisitData({required int clinicianId}) async {
    MapVisitDataModel? itemData;
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
      isMapListLoading.value = true;
      error.value = '';

      // final res = await _api.get(
      //   LiveMapRepo.getVisitData(clinicianId: clinicianId),
      // ); // MOCKED for local UI testing
      final res = mockResponse(MockData.get('liveMap.visitData'));

      if (res.statusCode == 200 || res.statusCode == 201) {


        // ✅ Final Model
        itemData = MapVisitDataModel(
            visitDone: res.data['visitsDone'] ?? 0,
            visitsRemaining: res.data['visitsRemaining'] ?? 0,
            earned: res.data['earned'] ?? 0,
            visitExpected: res.data['visitExpected'] ?? 0);
      } else {
        error.value = "failed to load data";
      }
    } catch (e) {
      error.value = e.toString();
      debugPrint('error live map details: $e');
    } finally {
      isMapListLoading.value = false;
    }

    return itemData ?? MapVisitDataModel(
        visitDone: 0,
        visitsRemaining: 0,
        earned: 0,
        visitExpected: 0);
  }



  Future<ViewRouteModelData> getViewRouteData({
    required int clinitianId,
    required int patientId,
  }) async {
    var itemData;

    try {
      isSeeRouteLoading.value = true;
      error.value = '';

      // final res = await _api.get(LiveMapRepo.getViewRoute(
      //     clinicianId: clinitianId, patientId: patientId)); // MOCKED for local UI testing
      final res = mockResponse(
        MockData.get('liveMap.viewRoute.byPatient.$patientId') ??
            MockData.get('liveMap.viewRoute'),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        // ✅ Final Model
      return  itemData = ViewRouteModelData(
            sourceLatitude: res.data['sourceLatitude']?.toDouble() ?? 0.0,
            sourceLongitude: res.data['sourceLongitude']?.toDouble() ?? 0.0,
            destinyLatitude: res.data['destinyLatitude']?.toDouble() ?? 0.0,
            destinyLongitude: res.data['destinyLongitude']?.toDouble() ?? 0.0,
            distance: res.data['distance'] ?? '0.0 miles'
        );
      } else {
        error.value = "failed to load data";
      }
    } catch (e) {
      error.value = e.toString();
      debugPrint('error live map view route: $e');
    } finally {
      isSeeRouteLoading.value = false;
    }
    return  itemData ?? ViewRouteModelData(
        sourceLatitude: 0.0,
        sourceLongitude: 0.0,
        destinyLatitude: 0.0,
        destinyLongitude: 0.0,
        distance: ''
    );
  }



  /// Google map route polyline points fetching can be added here



  GoogleMapController? mapController;

  final RxSet<Polyline> polylines = <Polyline>{}.obs;
  final RxSet<Marker> markers = <Marker>{}.obs;

  /// Set by the map screen so tapping a patient pin opens the same visit
  /// dialog the timeline list opens.
  void Function(int visitId)? onPatientMarkerTap;

  /// One numbered pin per active visit; kept separately so a drawn route can
  /// add the clinician's pin without dropping these.
  final List<Marker> _patientMarkers = [];
  Marker? _clinicianMarker;

  static const double _markerBoundsPadding = 60;
  static const int _routeWidth = 6;

  double get _devicePixelRatio =>
      WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;

  /// With a route drawn only its two ends are shown (original behaviour);
  /// otherwise every patient pin.
  void _publishMarkers() {
    if (_clinicianMarker != null) {
      markers.value = {
        _clinicianMarker!,
        ..._patientMarkers.where(
          (m) => m.markerId.value == _patientMarkerId(selectedPatientId.value),
        ),
      };
      return;
    }
    markers.value = {..._patientMarkers};
  }

  static String _patientMarkerId(int patientId) => 'patient_$patientId';

  /// Resolves each active visit's location through the route endpoint (the
  /// visit list itself carries no coordinates) and drops a "1, 2, 3…" pin
  /// labelled with the patient's name, then fits the camera around them.
  Future<void> loadPatientMarkers() async {
    final visits = visitsMapModel.value.visits;
    final int clinicianId = clinicianStats.value.clinician.clinicianId;
    final List<Marker> built = [];

    for (int i = 0; i < visits.length; i++) {
      final visit = visits[i];
      final route = await getViewRouteData(
        clinitianId: clinicianId,
        patientId: visit.patientId,
      );
      if (route.destinyLatitude == 0.0 && route.destinyLongitude == 0.0) {
        continue;
      }
      final pin = await MapMarkerFactory.build(
        label: visit.patientName,
        number: '${i + 1}',
        devicePixelRatio: _devicePixelRatio,
      );
      built.add(
        Marker(
          markerId: MarkerId(_patientMarkerId(visit.patientId)),
          position: LatLng(route.destinyLatitude, route.destinyLongitude),
          icon: pin.descriptor,
          anchor: pin.anchor,
          onTap: () => onPatientMarkerTap?.call(visit.visitId),
        ),
      );
    }

    _patientMarkers
      ..clear()
      ..addAll(built);
    _clinicianMarker = null;
    polylines.clear();
    _publishMarkers();
    _fitMarkers();
  }

  void _fitMarkers() {
    final controller = mapController;
    if (controller == null || markers.isEmpty) return;

    final positions = markers.map((m) => m.position).toList();
    if (positions.length == 1) {
      controller.animateCamera(CameraUpdate.newLatLng(positions.first));
      return;
    }
    double minLat = positions.first.latitude, maxLat = minLat;
    double minLng = positions.first.longitude, maxLng = minLng;
    for (final p in positions) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }
    controller.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        _markerBoundsPadding,
      ),
    );
  }

  /// Called from the screen once the GoogleMap is created — markers may have
  /// loaded before the controller existed.
  void onMapReady(GoogleMapController controller) {
    mapController = controller;
    _fitMarkers();
  }

  // Put your Google Directions key here
  final String googleApiKey = "YOUR_GOOGLE_MAPS_API_KEY";

  Future<void> drawRoute() async {
    // ✅ your fields
    final sLat = viewRouteModelData.value.sourceLatitude;
    final sLng = viewRouteModelData.value.sourceLongitude ;
    final dLat = viewRouteModelData.value.destinyLatitude;
    final dLng = viewRouteModelData.value.destinyLongitude;

    if (sLat == null || sLng == null || dLat == null || dLng == null) return;

    final source = LatLng(sLat, sLng);
    final dest = LatLng(dLat, dLng);

    // ✅ markers — the clinician's (unnumbered) pin joins the patient pins
    final MapMarkerBitmap sourcePin = await MapMarkerFactory.build(
      label: clinicianStats.value.clinician.name,
      devicePixelRatio: _devicePixelRatio,
    );
    _clinicianMarker = Marker(
      markerId: const MarkerId("source"),
      position: source,
      icon: sourcePin.descriptor,
      anchor: sourcePin.anchor,
    );
    _publishMarkers();

    // ✅ route points from Google Directions
    final polylinePoints = PolylinePoints(apiKey: ApiAppConstant.googleApiKey);
    final result = await polylinePoints.getRouteBetweenCoordinates(
      // googleApiKey: googleApiKey,
      request: PolylineRequest(
        origin: PointLatLng(source.latitude, source.longitude),
        destination: PointLatLng(dest.latitude, dest.longitude),
        mode: TravelMode.driving,
      ),
    );

    if (result.points.isEmpty) return;

    final routePoints = result.points
        .map((p) => LatLng(p.latitude, p.longitude))
        .toList();

    polylines.value = {
      Polyline(
        polylineId: const PolylineId("route"),
        points: routePoints,
        width: _routeWidth,
        color: AppColors.secondaryAppColor,
      ),
    };

    // ✅ fit camera around every pin, not just the route ends
    _fitMarkers();
  }

  Future<void> openInGoogleMaps() async {
    final sLat = viewRouteModelData.value.sourceLatitude;
    final sLng = viewRouteModelData.value.sourceLongitude;
    final dLat = viewRouteModelData.value.destinyLatitude;
    final dLng = viewRouteModelData.value.destinyLongitude;

    if (sLat == null || sLng == null || dLat == null || dLng == null) return;

    final url = Uri.parse(
      "https://www.google.com/maps/dir/?api=1"
          "&origin=$sLat,$sLng"
          "&destination=$dLat,$dLng"
          "&travelmode=driving",
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication, // ✅ opens Google Maps app
      );
    }
  }

}
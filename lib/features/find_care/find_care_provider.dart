import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shuchona/core/seed_data/upazila_clinics_seed.dart';
import 'package:url_launcher/url_launcher.dart';

class FacilityWithDistance {
  const FacilityWithDistance({
    required this.facility,
    required this.distanceKm,
  });

  final CareFacility facility;
  final double distanceKm;
}

class FindCareState {
  const FindCareState({
    required this.selectedUpazila,
    required this.onlyFreeBloodTest,
    required this.facilities,
    this.isLocating = false,
    this.usedLiveGps = false,
    this.locationStatus,
  });

  final String selectedUpazila; // 'All' or exact Upazila name
  final bool onlyFreeBloodTest;
  final List<FacilityWithDistance> facilities;
  final bool isLocating;
  final bool usedLiveGps;
  final String? locationStatus;

  FindCareState copyWith({
    String? selectedUpazila,
    bool? onlyFreeBloodTest,
    List<FacilityWithDistance>? facilities,
    bool? isLocating,
    bool? usedLiveGps,
    String? locationStatus,
  }) {
    return FindCareState(
      selectedUpazila: selectedUpazila ?? this.selectedUpazila,
      onlyFreeBloodTest: onlyFreeBloodTest ?? this.onlyFreeBloodTest,
      facilities: facilities ?? this.facilities,
      isLocating: isLocating ?? this.isLocating,
      usedLiveGps: usedLiveGps ?? this.usedLiveGps,
      locationStatus: locationStatus ?? this.locationStatus,
    );
  }
}

class FindCareNotifier extends StateNotifier<FindCareState> {
  FindCareNotifier()
      : super(
          FindCareState(
            selectedUpazila: 'All',
            onlyFreeBloodTest: false,
            facilities: UpazilaClinicsSeed.facilities
                .map(
                  (f) => FacilityWithDistance(
                    facility: f,
                    distanceKm: f.defaultDistanceKm,
                  ),
                )
                .toList(),
          ),
        );

  void selectUpazila(String upazila) {
    state = state.copyWith(selectedUpazila: upazila);
  }

  void toggleFreeBloodTestFilter(bool value) {
    state = state.copyWith(onlyFreeBloodTest: value);
  }

  /// Uses `geolocator` to compute live Upazila clinic proximity with safe offline fallback.
  Future<void> refreshGpsProximity() async {
    state = state.copyWith(isLocating: true);
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        state = state.copyWith(
          isLocating: false,
          usedLiveGps: false,
          locationStatus: 'Using offline Upazila distance estimates',
        );
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        state = state.copyWith(
          isLocating: false,
          usedLiveGps: false,
          locationStatus: 'Using offline Upazila distance estimates',
        );
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 6),
        ),
      );

      final updated = UpazilaClinicsSeed.facilities.map((f) {
        if (f.type == CareFacilityType.nationalHelpline) {
          return FacilityWithDistance(facility: f, distanceKm: 0.0);
        }
        final meters = Geolocator.distanceBetween(
          pos.latitude,
          pos.longitude,
          f.latitude,
          f.longitude,
        );
        return FacilityWithDistance(
          facility: f,
          distanceKm: double.parse((meters / 1000).toStringAsFixed(1)),
        );
      }).toList()
        ..sort((a, b) => a.distanceKm.compareTo(b.distanceKm));

      state = state.copyWith(
        facilities: updated,
        isLocating: false,
        usedLiveGps: true,
        locationStatus: 'Sorted by live GPS proximity',
      );
    } catch (e) {
      debugPrint('Geolocator fallback: $e');
      state = state.copyWith(
        isLocating: false,
        usedLiveGps: false,
        locationStatus: 'Offline Upazila estimates active',
      );
    }
  }

  /// One-tap helpline & clinic phone dialer using `url_launcher`.
  static Future<bool> dialPhoneNumber(String number) async {
    final cleaned = number.replaceAll(RegExp(r'[^0-9+*#]'), '');
    final uri = Uri(scheme: 'tel', path: cleaned);
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (launched) return true;
      if (await canLaunchUrl(uri)) {
        return launchUrl(uri);
      }
    } catch (e) {
      debugPrint('Dialer launch note: $e');
    }
    return false;
  }
}

final findCareProvider =
    StateNotifierProvider<FindCareNotifier, FindCareState>((ref) {
  return FindCareNotifier();
});


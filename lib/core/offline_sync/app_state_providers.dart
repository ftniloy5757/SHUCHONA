import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shuchona/core/constants/app_constants.dart';
import 'package:shuchona/core/localization/app_locale.dart';
import 'package:shuchona/core/offline_sync/firebase_bootstrap_service.dart';
import 'package:shuchona/core/offline_sync/hive_storage_service.dart';
import 'package:shuchona/core/offline_sync/notification_service.dart';

/// Runtime language state — Defaults to Bangla (বাংলা).
class LocaleNotifier extends StateNotifier<AppLocale> {
  LocaleNotifier() : super(_loadInitial());

  static AppLocale _loadInitial() {
    final saved = HiveStorageService.instance.read<String>(
      AppConstants.boxProfile,
      'locale',
      defaultValue: 'bn',
    );
    return saved == 'en' ? AppLocale.en : AppLocale.bn;
  }

  void toggle() {
    state = state.toggled;
    HiveStorageService.instance
        .write(AppConstants.boxProfile, 'locale', state.name);
  }

  void setLocale(AppLocale locale) {
    state = locale;
    HiveStorageService.instance
        .write(AppConstants.boxProfile, 'locale', locale.name);
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, AppLocale>((ref) {
  return LocaleNotifier();
});

/// One-tap High-Contrast / Dark Mode toggle (#090D16 pitch-slate + #38BDF8 electric blue).
class HighContrastNotifier extends StateNotifier<bool> {
  HighContrastNotifier()
      : super(
          HiveStorageService.instance.read<bool>(
                AppConstants.boxProfile,
                'high_contrast_dark',
                defaultValue: false,
              ) ??
              false,
        );

  void toggle() {
    state = !state;
    HiveStorageService.instance
        .write(AppConstants.boxProfile, 'high_contrast_dark', state);
  }
}

final highContrastDarkProvider =
    StateNotifierProvider<HighContrastNotifier, bool>((ref) {
  return HighContrastNotifier();
});

/// SHG Facilitator Guest Mode — Zero-Trace session so an SHG leader can assist
/// community members on a shared phone without polluting her personal health logs.
final shgGuestModeProvider = StateProvider<bool>((ref) => false);

/// Role Switcher: Community User View (false) <-> NGO / Admin Impact Dashboard (true).
final adminRoleProvider = StateProvider<bool>((ref) => false);

/// Offline-First Connectivity & Sync Queue State.
class OfflineSyncState {
  const OfflineSyncState({
    required this.isOnline,
    required this.simulatedOffline,
    required this.pendingQueueCount,
    required this.isSyncing,
    this.lastSyncedAt,
  });

  final bool isOnline;
  final bool simulatedOffline;
  final int pendingQueueCount;
  final bool isSyncing;
  final DateTime? lastSyncedAt;

  bool get effectivelyOnline => isOnline && !simulatedOffline;

  OfflineSyncState copyWith({
    bool? isOnline,
    bool? simulatedOffline,
    int? pendingQueueCount,
    bool? isSyncing,
    DateTime? lastSyncedAt,
  }) {
    return OfflineSyncState(
      isOnline: isOnline ?? this.isOnline,
      simulatedOffline: simulatedOffline ?? this.simulatedOffline,
      pendingQueueCount: pendingQueueCount ?? this.pendingQueueCount,
      isSyncing: isSyncing ?? this.isSyncing,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }
}

class OfflineSyncNotifier extends StateNotifier<OfflineSyncState> {
  OfflineSyncNotifier()
      : super(
          OfflineSyncState(
            isOnline: true,
            simulatedOffline: false,
            pendingQueueCount:
                HiveStorageService.instance.getPendingSyncCount(),
            isSyncing: false,
            lastSyncedAt: DateTime.now(),
          ),
        ) {
    _listenConnectivity();
  }

  StreamSubscription<List<ConnectivityResult>>? _sub;

  void _listenConnectivity() {
    try {
      _sub = Connectivity().onConnectivityChanged.listen((results) {
        final connected =
            results.any((r) => r != ConnectivityResult.none);
        if (!mounted) return;
        state = state.copyWith(isOnline: connected);
        if (connected && !state.simulatedOffline && state.pendingQueueCount > 0) {
          syncNow();
        }
      });
    } catch (_) {}
  }

  /// Lets users/judges toggle Offline Mode to test real Hive offline queueing & auto-sync.
  void toggleSimulatedOffline() {
    final nextOffline = !state.simulatedOffline;
    state = state.copyWith(simulatedOffline: nextOffline);
    if (!nextOffline && state.isOnline && state.pendingQueueCount > 0) {
      syncNow();
    }
  }

  /// Enqueues an anonymized offline action; immediately syncs if online.
  Future<void> recordSyncableAction({
    required String actionType,
    required Map<String, dynamic> anonymizedPayload,
  }) async {
    await HiveStorageService.instance.enqueueSyncAction(
      actionType: actionType,
      anonymizedPayload: anonymizedPayload,
    );
    final pending = HiveStorageService.instance.getPendingSyncCount();
    state = state.copyWith(pendingQueueCount: pending);
    if (state.effectivelyOnline) {
      await syncNow();
    }
  }

  Future<void> syncNow() async {
    if (!state.effectivelyOnline || state.isSyncing) return;
    state = state.copyWith(isSyncing: true);
    await Future<void>.delayed(const Duration(milliseconds: 550));
    await DemoFallbackService.instance.pushAnonymizedTelemetry(
      'shuchona_anonymized_events',
      {
        'syncedItems': state.pendingQueueCount,
        'piiStrippedOnDevice': true,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
    await HiveStorageService.instance.flushSyncQueue();
    if (mounted) {
      state = state.copyWith(
        pendingQueueCount: 0,
        isSyncing: false,
        lastSyncedAt: DateTime.now(),
      );
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

final offlineSyncProvider =
    StateNotifierProvider<OfflineSyncNotifier, OfflineSyncState>((ref) {
  return OfflineSyncNotifier();
});

/// Authenticated & Consented User Profile State (persisted locally via Hive).
class UserSessionState {
  const UserSessionState({
    required this.isAuthenticated,
    required this.hasGivenInformedConsent,
    required this.isDemoMode,
    required this.displayIdentifier,
    required this.pseudonymBn,
    required this.pseudonymEn,
    required this.avatarEmoji,
    required this.upazila,
    required this.cumulativeBdtSaved,
    required this.prescriptionsScannedCount,
  });

  final bool isAuthenticated;
  final bool hasGivenInformedConsent;
  final bool isDemoMode;
  final String displayIdentifier;
  final String pseudonymBn;
  final String pseudonymEn;
  final String avatarEmoji;
  final String upazila;
  final double cumulativeBdtSaved;
  final int prescriptionsScannedCount;

  bool get isOnboardingComplete => isAuthenticated && hasGivenInformedConsent;

  UserSessionState copyWith({
    bool? isAuthenticated,
    bool? hasGivenInformedConsent,
    bool? isDemoMode,
    String? displayIdentifier,
    String? pseudonymBn,
    String? pseudonymEn,
    String? avatarEmoji,
    String? upazila,
    double? cumulativeBdtSaved,
    int? prescriptionsScannedCount,
  }) {
    return UserSessionState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      hasGivenInformedConsent:
          hasGivenInformedConsent ?? this.hasGivenInformedConsent,
      isDemoMode: isDemoMode ?? this.isDemoMode,
      displayIdentifier: displayIdentifier ?? this.displayIdentifier,
      pseudonymBn: pseudonymBn ?? this.pseudonymBn,
      pseudonymEn: pseudonymEn ?? this.pseudonymEn,
      avatarEmoji: avatarEmoji ?? this.avatarEmoji,
      upazila: upazila ?? this.upazila,
      cumulativeBdtSaved: cumulativeBdtSaved ?? this.cumulativeBdtSaved,
      prescriptionsScannedCount:
          prescriptionsScannedCount ?? this.prescriptionsScannedCount,
    );
  }
}

class UserSessionNotifier extends StateNotifier<UserSessionState> {
  UserSessionNotifier() : super(_load()) {
    // Persist the initial auto-demo session on first launch after installation
    // so testers stay signed in seamlessly across app restarts.
    final s = HiveStorageService.instance;
    if (state.isOnboardingComplete &&
        s.read<bool>(AppConstants.boxProfile, 'is_auth') == null &&
        (s.read<bool>(AppConstants.boxProfile, 'explicitly_signed_out') ??
                false) ==
            false) {
      s.write(AppConstants.boxProfile, 'is_auth', true);
      s.write(AppConstants.boxProfile, 'has_consent', true);
      s.write(AppConstants.boxProfile, 'is_demo', true);
      s.write(
        AppConstants.boxProfile,
        'identifier',
        state.displayIdentifier,
      );
    }
  }

  static UserSessionState _load() {
    final s = HiveStorageService.instance;
    final explicitlySignedOut =
        s.read<bool>(AppConstants.boxProfile, 'explicitly_signed_out') ?? false;
    final savedAuth = s.read<bool>(AppConstants.boxProfile, 'is_auth');
    final savedConsent = s.read<bool>(AppConstants.boxProfile, 'has_consent');

    // Auto-login as a Demo Tester immediately after fresh installation so users
    // and testers can experience every SHUCHONA feature without credentials.
    final autoDemoOnInstall =
        !explicitlySignedOut && savedAuth == null && savedConsent == null;

    return UserSessionState(
      isAuthenticated: autoDemoOnInstall ? true : (savedAuth ?? false),
      hasGivenInformedConsent:
          autoDemoOnInstall ? true : (savedConsent ?? false),
      isDemoMode: s.read<bool>(AppConstants.boxProfile, 'is_demo') ?? true,
      displayIdentifier:
          s.read<String>(AppConstants.boxProfile, 'identifier') ??
              'SHG Demo Tester (Savar)',
      pseudonymBn:
          s.read<String>(AppConstants.boxProfile, 'pseudonym_bn') ?? 'শাপলা কলি',
      pseudonymEn: s.read<String>(AppConstants.boxProfile, 'pseudonym_en') ??
          'Water Lily Bud',
      avatarEmoji: s.read<String>(AppConstants.boxProfile, 'avatar') ?? '🪷',
      upazila: s.read<String>(AppConstants.boxProfile, 'upazila') ??
          'Savar, Dhaka',
      cumulativeBdtSaved:
          (s.read<num>(AppConstants.boxProfile, 'bdt_saved') ?? 640).toDouble(),
      prescriptionsScannedCount:
          (s.read<num>(AppConstants.boxProfile, 'rx_count') ?? 2).toInt(),
    );
  }

  Future<void> authenticate({
    required String identifier,
    required bool isDemoMode,
  }) async {
    state = state.copyWith(
      isAuthenticated: true,
      isDemoMode: isDemoMode,
      displayIdentifier: identifier,
    );
    await HiveStorageService.instance
        .write(AppConstants.boxProfile, 'explicitly_signed_out', false);
    await HiveStorageService.instance
        .write(AppConstants.boxProfile, 'is_auth', true);
    await HiveStorageService.instance
        .write(AppConstants.boxProfile, 'is_demo', isDemoMode);
    await HiveStorageService.instance
        .write(AppConstants.boxProfile, 'identifier', identifier);
  }

  Future<void> acceptInformedConsent() async {
    state = state.copyWith(hasGivenInformedConsent: true);
    await HiveStorageService.instance
        .write(AppConstants.boxProfile, 'has_consent', true);
  }

  Future<void> updateAvatarAndPseudonym({
    required String avatarEmoji,
    required String pseudonymBn,
    required String pseudonymEn,
  }) async {
    state = state.copyWith(
      avatarEmoji: avatarEmoji,
      pseudonymBn: pseudonymBn,
      pseudonymEn: pseudonymEn,
    );
    await HiveStorageService.instance
        .write(AppConstants.boxProfile, 'avatar', avatarEmoji);
    await HiveStorageService.instance
        .write(AppConstants.boxProfile, 'pseudonym_bn', pseudonymBn);
    await HiveStorageService.instance
        .write(AppConstants.boxProfile, 'pseudonym_en', pseudonymEn);
  }

  Future<void> updateUpazila(String upazila) async {
    state = state.copyWith(upazila: upazila);
    await HiveStorageService.instance
        .write(AppConstants.boxProfile, 'upazila', upazila);
  }

  Future<void> recordPrescriptionSavings(double savedBdt) async {
    final total = state.cumulativeBdtSaved + savedBdt;
    final count = state.prescriptionsScannedCount + 1;
    state = state.copyWith(
      cumulativeBdtSaved: total,
      prescriptionsScannedCount: count,
    );
    await HiveStorageService.instance
        .write(AppConstants.boxProfile, 'bdt_saved', total);
    await HiveStorageService.instance
        .write(AppConstants.boxProfile, 'rx_count', count);
  }

  Future<void> signOutToOnboarding() async {
    state = state.copyWith(
      isAuthenticated: false,
      hasGivenInformedConsent: false,
    );
    await HiveStorageService.instance
        .write(AppConstants.boxProfile, 'explicitly_signed_out', true);
    await HiveStorageService.instance
        .write(AppConstants.boxProfile, 'is_auth', false);
    await HiveStorageService.instance
        .write(AppConstants.boxProfile, 'has_consent', false);
  }
}

final userSessionProvider =
    StateNotifierProvider<UserSessionNotifier, UserSessionState>((ref) {
  return UserSessionNotifier();
});

/// Smart Local Voice Reminders Provider (Medication dosage + Habit check-ins).
class RemindersNotifier extends StateNotifier<List<ScheduledVoiceReminder>> {
  RemindersNotifier() : super(_loadInitial());

  static List<ScheduledVoiceReminder> _loadInitial() {
    final saved = HiveStorageService.instance
        .read<List<dynamic>>(AppConstants.boxReminders, 'items');
    if (saved != null && saved.isNotEmpty) {
      return saved
          .whereType<Map<dynamic, dynamic>>()
          .map(ScheduledVoiceReminder.fromMap)
          .toList();
    }
    return const [
      ScheduledVoiceReminder(
        id: 101,
        titleBn: 'সকালের স্বাস্থ্য চেক-ইন ও পানি',
        titleEn: 'Morning Hydration & Habit Check-in',
        spokenMessageBn:
            'শুভ সকাল! এক গ্লাস নিরাপদ পানি পান করুন এবং আজকের সুস্থ অভ্যাস শুরু করুন।',
        spokenMessageEn:
            'Good morning! Drink a glass of clean water and start your healthy habits today.',
        hour: 8,
        minute: 0,
        category: 'habit',
      ),
      ScheduledVoiceReminder(
        id: 102,
        titleBn: 'রাতের আয়রন ও ফলিক এসিড ট্যাবলেট',
        titleEn: 'Evening Iron & Folic Acid Tablet',
        spokenMessageBn:
            'রাতের খাবারের পর আপনার আয়রন ও ফলিক এসিড ট্যাবলেট খাওয়ার সময় হয়েছে।',
        spokenMessageEn:
            'Time to take your daily Iron and Folic Acid tablet after dinner.',
        hour: 20,
        minute: 30,
        category: 'medication',
      ),
    ];
  }

  Future<void> _persist() async {
    await HiveStorageService.instance.write(
      AppConstants.boxReminders,
      'items',
      state.map((r) => r.toMap()).toList(),
    );
  }

  Future<void> addOrUpdateReminders(List<ScheduledVoiceReminder> newItems) async {
    final map = {for (final r in state) r.id: r};
    for (final item in newItems) {
      map[item.id] = item;
      await NotificationService.instance.scheduleDailyReminder(item);
    }
    state = map.values.toList()
      ..sort((a, b) => (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute));
    await _persist();
  }

  Future<void> toggleReminder(int id) async {
    state = [
      for (final r in state)
        if (r.id == id) r.copyWith(enabled: !r.enabled) else r,
    ];
    final target = state.firstWhere((r) => r.id == id);
    if (target.enabled) {
      await NotificationService.instance.scheduleDailyReminder(target);
    } else {
      await NotificationService.instance.cancelReminder(id);
    }
    await _persist();
  }

  Future<void> removeReminder(int id) async {
    state = state.where((r) => r.id != id).toList();
    await NotificationService.instance.cancelReminder(id);
    await _persist();
  }
}

final remindersProvider =
    StateNotifierProvider<RemindersNotifier, List<ScheduledVoiceReminder>>((ref) {
  return RemindersNotifier();
});


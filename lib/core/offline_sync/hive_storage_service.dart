import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shuchona/core/constants/app_constants.dart';

/// Fast local offline-first persistence layer built on Hive.
/// Stores user preferences, habit logs, mood trends, active medication alarms,
/// blood donor profile, and a pending sync queue that flushes when online.
class HiveStorageService {
  HiveStorageService._();

  static final HiveStorageService instance = HiveStorageService._();

  bool _initialized = false;
  final Map<String, Map<String, dynamic>> _memoryFallback = {};

  Future<void> init() async {
    if (_initialized) return;
    try {
      await Hive.initFlutter();
      await Future.wait([
        Hive.openBox<dynamic>(AppConstants.boxProfile),
        Hive.openBox<dynamic>(AppConstants.boxHabits),
        Hive.openBox<dynamic>(AppConstants.boxMoods),
        Hive.openBox<dynamic>(AppConstants.boxSyncQueue),
        Hive.openBox<dynamic>(AppConstants.boxBlood),
        Hive.openBox<dynamic>(AppConstants.boxPrescriptions),
        Hive.openBox<dynamic>(AppConstants.boxReminders),
      ]);
      _initialized = true;
    } catch (e) {
      debugPrint('SHUCHONA Hive fallback to in-memory storage: $e');
      _initialized = false;
    }
  }

  T? read<T>(String boxName, String key, {T? defaultValue}) {
    try {
      if (_initialized && Hive.isBoxOpen(boxName)) {
        final val = Hive.box<dynamic>(boxName).get(key, defaultValue: defaultValue);
        return val as T?;
      }
    } catch (_) {}
    final mem = _memoryFallback[boxName]?[key];
    return (mem as T?) ?? defaultValue;
  }

  Future<void> write(String boxName, String key, dynamic value) async {
    try {
      if (_initialized && Hive.isBoxOpen(boxName)) {
        await Hive.box<dynamic>(boxName).put(key, value);
        return;
      }
    } catch (e) {
      debugPrint('Hive write fallback ($boxName/$key): $e');
    }
    _memoryFallback.putIfAbsent(boxName, () => {})[key] = value;
  }

  /// Appends an offline action to the background sync queue (PII-stripped payload).
  Future<void> enqueueSyncAction({
    required String actionType,
    required Map<String, dynamic> anonymizedPayload,
  }) async {
    final existing = read<List<dynamic>>(
          AppConstants.boxSyncQueue,
          'pending_items',
          defaultValue: <dynamic>[],
        ) ??
        <dynamic>[];
    final updated = List<dynamic>.from(existing)
      ..add({
        'type': actionType,
        'timestamp': DateTime.now().toIso8601String(),
        'payload': anonymizedPayload,
      });
    await write(AppConstants.boxSyncQueue, 'pending_items', updated);
  }

  int getPendingSyncCount() {
    final existing = read<List<dynamic>>(
          AppConstants.boxSyncQueue,
          'pending_items',
          defaultValue: <dynamic>[],
        ) ??
        <dynamic>[];
    return existing.length;
  }

  Future<int> flushSyncQueue() async {
    final count = getPendingSyncCount();
    await write(AppConstants.boxSyncQueue, 'pending_items', <dynamic>[]);
    await write(
      AppConstants.boxSyncQueue,
      'last_synced_at',
      DateTime.now().toIso8601String(),
    );
    return count;
  }
}


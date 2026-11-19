import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shuchona/app.dart';
import 'package:shuchona/core/offline_sync/firebase_bootstrap_service.dart';
import 'package:shuchona/core/offline_sync/hive_storage_service.dart';
import 'package:shuchona/core/offline_sync/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Offline-first Hive local cache (habits, moods, alarms, sync queue)
  await HiveStorageService.instance.init();

  // 2. Graceful Firebase Core + Offline Firestore init with DemoFallbackService
  await DemoFallbackService.instance.initialize();

  // 3. Local voice-assisted notification engine (Asia/Dhaka timezone)
  await NotificationService.instance.init();

  runApp(const ProviderScope(child: ShuchonaApp()));
}

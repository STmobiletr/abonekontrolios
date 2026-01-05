import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart'; // Import for kDebugMode
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../../features/subscriptions/models/subscription_model.dart';

/// Service for handling backups
class BackupService {
  final Box<SubscriptionModel> _subscriptionBox = Hive.box<SubscriptionModel>(
    'subscriptions',
  );
  final Box _settingsBox = Hive.box('settings');

  /// Creates a backup file
  Future<bool> createBackup() async {
    try {
      // Gather Data
      final subscriptions = _subscriptionBox.values
          .map(
            (e) => {
              'id': e.id,
              'name': e.name,
              'price': e.price,
              'currency': e.currency,
              'billingCycle': e.billingCycle,
              'nextBillingDate': e.nextBillingDate.toIso8601String(),
              'cancellationUrl': e.cancellationUrl,
              'colorHex': e.colorHex,
              'category': e.category,
            },
          )
          .toList();

      final settings = {
        'isDarkMode': _settingsBox.get('isDarkMode'),
        'currency': _settingsBox.get('currency'),
        'notificationsEnabled': _settingsBox.get('notificationsEnabled'),
        'onboarding_complete': _settingsBox.get('onboarding_complete'),
        'language': _settingsBox.get('language'),
      };

      final backupData = {
        'version': 1,
        'timestamp': DateTime.now().toIso8601String(),
        'subscriptions': subscriptions,
        'settings': settings,
      };

      final jsonString = jsonEncode(backupData);
      final fileName =
          'subzero_backup_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.json';

      // Save File
      if (Platform.isAndroid || Platform.isIOS) {
        String? outputFile = await FilePicker.platform.saveFile(
          dialogTitle: 'Save Backup File',
          fileName: fileName,
          bytes: utf8.encode(jsonString),
          type: FileType.custom,
          allowedExtensions: ['json'],
        );

        return outputFile != null;
      } else {
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint("Backup Error: $e");
      }
      return false;
    }
  }

  /// Restores data from a backup file
  Future<bool> restoreBackup() async {
    try {
      // Pick File
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
      );

      if (result != null && result.files.single.path != null) {
        final path = result.files.single.path!;

        if (!path.toLowerCase().endsWith('.json')) {
          if (kDebugMode) {
            debugPrint("Invalid file type selected");
          }
          return false;
        }

        final file = File(path);
        final jsonString = await file.readAsString();
        final Map<String, dynamic> data = jsonDecode(jsonString);

        // Validate Data
        if (!data.containsKey('subscriptions') ||
            !data.containsKey('settings')) {
          return false;
        }

        // Restore Settings
        final settings = data['settings'] as Map<String, dynamic>;
        await _settingsBox.put('isDarkMode', settings['isDarkMode']);
        await _settingsBox.put('currency', settings['currency']);
        await _settingsBox.put(
          'notificationsEnabled',
          settings['notificationsEnabled'],
        );
        await _settingsBox.put(
          'onboarding_complete',
          settings['onboarding_complete'],
        );
        await _settingsBox.put('language', settings['language']);

        // Restore Subscriptions
        await _subscriptionBox.clear();
        final List<dynamic> subs = data['subscriptions'];
        for (var subData in subs) {
          final sub = SubscriptionModel(
            id: subData['id'],
            name: subData['name'],
            price: (subData['price'] as num).toDouble(),
            currency: subData['currency'],
            billingCycle: subData['billingCycle'],
            nextBillingDate: DateTime.parse(subData['nextBillingDate']),
            cancellationUrl: subData['cancellationUrl'],
            colorHex: subData['colorHex'],
            category: subData['category'] ?? 'Entertainment',
          );
          await _subscriptionBox.add(sub);
        }

        return true;
      } else {
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint("Restore Error: $e");
      }
      return false;
    }
  }
}

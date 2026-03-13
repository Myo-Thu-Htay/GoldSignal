import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/setting_state.dart';

final settingsProvider =
    AsyncNotifierProvider<SettingsNotifier, SettingState>(SettingsNotifier.new);

class SettingsNotifier extends AsyncNotifier<SettingState> {
  @override
  Future<SettingState> build() async {
    final prefs = await SharedPreferences.getInstance();
    return SettingState(
      isDarkMode: prefs.getBool('isDarkMode') ?? false,
      languageCode: prefs.getString('language') ?? 'en',
      notificationsEnabled: prefs.getBool('notificationsEnabled') ?? true,
    );
  }

  Future<void> toggleDarkMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark);
    state = AsyncData(state.value!.copyWith(isDarkMode: isDark));
  }

  Future<void> changeLanguage(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', code);
    state = AsyncData(state.value!.copyWith(languageCode: code));
  }

  Future<void> toggleNotifications(BuildContext context, bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    bool currentStatus = state.value!.notificationsEnabled;
    if (enabled && !currentStatus) {
      PermissionStatus status = await Permission.notification.request();
      if (!status.isGranted) {
        enabled = false; // Revert to disabled if permission not granted
      }
    }
    if (enabled == false) {
      openAppSettings();
    }
    await prefs.setBool('notificationsEnabled', enabled);
    state = AsyncData(state.value!.copyWith(notificationsEnabled: enabled));
  }

  // Future<void> openNotificationSettings(
  //   BuildContext context,
  // ) async {
  //   PermissionStatus status = await Permission.notification.status;
  //   if (status.isGranted) {
  //     openAppSettings();
  //   } else if (status.isDenied) {
  //     showDialog(
  //       context: context,
  //       builder: (context) => AlertDialog(
  //         title: const Text('Permission Required'),
  //         content:
  //             const Text('Please enable notification permissions in settings.'),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.of(context).pop(),
  //             child: const Text('Cancel'),
  //           ),
  //           TextButton(
  //             onPressed: () {
  //               openAppSettings();
  //               Navigator.of(context).pop();
  //             },
  //             child: const Text('Open Settings'),
  //           ),
  //         ],
  //       ),
  //     );
  //   }
  // }
}

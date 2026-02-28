import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/setting_state.dart';

final settingsProvider = AsyncNotifierProvider<SettingsNotifier, SettingState> (SettingsNotifier.new);

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

  Future<void> changeLanguage(String code) async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', code);
    state = AsyncData(state.value!.copyWith(languageCode: code));
  }

  Future<void> toggleNotifications(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', enabled);
    state = AsyncData(state.value!.copyWith(notificationsEnabled: enabled));
  }
}
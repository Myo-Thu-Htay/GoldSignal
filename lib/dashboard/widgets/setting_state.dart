class SettingState {
  final bool isDarkMode;
  final String languageCode;
  final bool notificationsEnabled;

  SettingState({
    required this.isDarkMode,
    required this.languageCode,
    required this.notificationsEnabled,
  });

  SettingState copyWith({
    bool? isDarkMode,
    String? languageCode,
    bool? notificationsEnabled,
  }) {
    return SettingState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      languageCode: languageCode ?? this.languageCode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}
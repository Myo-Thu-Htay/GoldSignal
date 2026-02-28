class AppStrings {
  static final Map<String, Map<String, String>> _localized = {
    'en': {
      'settings': 'Settings',
      'darkMode': 'Dark Mode',
      'lightMode': 'Light Mode',
      'language': 'Language',
      'notifications': 'Notifications',
      'dashboard': 'Dashboard',
      'balance': 'Balance',
      'account': 'Account',
      'portfolio': 'Portfolio',
    },
    'my': {
      'settings': 'ဆက်တင်များ',
      'darkMode': 'အမှောင်မုဒ်',
      'lightMode': 'အလင်းမုဒ်',
      'language': 'ဘာသာစကား',
      'notifications': 'အသိပေးချက်များ',
      'dashboard': 'ဒက်ရှ်ဘုတ်',
      'balance': 'လက်ကျန်',
      'account': 'အကောင့်',
      'portfolio': 'Portfolio',
    },
  };

  static String text(String key, String languageCode) {
    if (languageCode == 'my') {
      return _localized['my']?[key] ?? key;
    } else {
      return _localized['en']?[key] ?? key;
    }
  }
}

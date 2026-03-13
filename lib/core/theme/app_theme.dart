import 'package:flutter/material.dart';

class AppTheme {
  static final darkTheme = ThemeData.dark().copyWith(
    brightness: Brightness.dark,
    primaryColor: Colors.blueGrey,
    scaffoldBackgroundColor: Colors.grey[700],
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey[800],
      elevation: 0,
    ),
    dropdownMenuTheme: DropdownMenuThemeData(
      textStyle: const TextStyle(color: Colors.white),
      menuStyle: MenuStyle(
        backgroundColor: WidgetStateProperty.all(Colors.black12),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.grey[800],
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white54,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white, fontSize: 18),
      bodyMedium: TextStyle(color: Colors.white70, fontSize: 16),
      bodySmall: TextStyle(color: Colors.white54, fontSize: 14),
    ),
  );

  static final lightTheme = ThemeData.light().copyWith(
    brightness: Brightness.light,
    primaryColor: Colors.blueGrey,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.blueGrey,
      elevation: 0,
    ),
    dropdownMenuTheme: DropdownMenuThemeData(
      textStyle: const TextStyle(color: Colors.white),
      menuStyle: MenuStyle(
        backgroundColor: WidgetStateProperty.all(Colors.black12),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.blueGrey,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.blueGrey[300],
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black87, fontSize: 18),
      bodyMedium: TextStyle(color: Colors.black54, fontSize: 16),
      bodySmall: TextStyle(color: Colors.black45, fontSize: 14),
    ),
  );
}

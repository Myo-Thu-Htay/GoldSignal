import 'package:flutter/material.dart';

class AppTheme {
  static final darkTheme = ThemeData.dark().copyWith(
    brightness: Brightness.dark,
    primaryColor: Colors.blueGrey,
    scaffoldBackgroundColor: const Color(0xFF0D1117),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF161B22),
      elevation: 0,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(
          color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      bodyMedium: TextStyle(color: Colors.white70, fontSize: 16),
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
    textTheme: const TextTheme(
      bodyLarge: TextStyle(
          color: Colors.black87, fontSize: 20, fontWeight: FontWeight.bold),
      bodyMedium: TextStyle(color: Colors.black54, fontSize: 16),
    ),
  );
}

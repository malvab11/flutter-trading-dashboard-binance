import 'package:flutter/material.dart';

class AppColors {
  static const Color precioSubida = Colors.greenAccent;
  static const Color precioBajada = Colors.redAccent;
  static const Color precioNeutro = Colors.blueAccent;
}

class AppTheme {
  static ThemeData get darkTheme => ThemeData.dark().copyWith(
    colorScheme: const ColorScheme.dark(
      primary: Colors.amber,
      secondary: Colors.deepOrange,
    ),
    scaffoldBackgroundColor: Colors.black,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.black,
      elevation: 0,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Colors.white),
      bodySmall: TextStyle(color: Colors.white70),
      titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      labelLarge: TextStyle(color: Colors.white, fontSize: 16),
    ),
  );
}

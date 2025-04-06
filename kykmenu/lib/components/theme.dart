import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    primary: Colors.green,
    secondary: Colors.grey.shade300,
    background: Colors.white,
    surface: Colors.white,
    error: Colors.red,
    onPrimary: Colors.white,
    onSecondary: Colors.black,
    onBackground: Colors.black,
    onSurface: Colors.black,
    onError: Colors.white,
  ),
  scaffoldBackgroundColor: const Color.fromARGB(254, 247, 255, 255),

  textTheme: GoogleFonts.poppinsTextTheme(),
);

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    primary: const Color.fromARGB(255, 117, 133, 117),
    secondary: Colors.grey.shade800,
    background: const Color.fromARGB(255, 30, 30, 30),
    error: Colors.red,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onBackground: Colors.white,
    onSurface: Colors.white,
    onError: Colors.black,
  ),
  scaffoldBackgroundColor: Colors.black,
  textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
);

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData darkTheme = ThemeData(
  colorScheme: ColorScheme(
    brightness: Brightness.dark,
    primary: const Color.fromARGB(255, 44, 171, 193),
    onPrimary: Colors.white,
    secondary: const Color.fromARGB(255, 70, 178, 217),
    onSecondary: Colors.white,
    error: Colors.red,
    onError: Colors.black,
    background: Colors.grey[850]!,
    onBackground: Colors.white,
    surface: Colors.transparent,
    onSurface: Colors.white,
  ),
  textTheme: GoogleFonts.poppinsTextTheme(),
);

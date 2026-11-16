
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  // Font untuk judul
  static TextStyle heading = GoogleFonts.playfairDisplay(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  // Font untuk subjudul
  static TextStyle subtitle = GoogleFonts.lato(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: Colors.black,
  );

  // Font untuk teks biasa
  static TextStyle body = GoogleFonts.lato(
    fontSize: 14,
    color: Colors.black,
  );

  // Font untuk label input
  static TextStyle label = GoogleFonts.lato(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: Colors.black,
  );

  // Font untuk tombol
  static TextStyle button = GoogleFonts.playfairDisplay(
    fontSize: 15,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  static TextStyle display = GoogleFonts.poppins(
    fontSize: 30, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
  );
  static TextStyle h1 = GoogleFonts.poppins(
    fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
  );
  static TextStyle h2 = GoogleFonts.poppins(
    fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary,
  );
  static TextStyle h3 = GoogleFonts.poppins(
    fontSize: 18, fontWeight: FontWeight.w500, color: AppColors.textPrimary,
  );
  static TextStyle body = GoogleFonts.inter(
    fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.textPrimary,
  );
  static TextStyle caption = GoogleFonts.inter(
    fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.textSecondary,
  );
  static TextStyle small = GoogleFonts.inter(
    fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textSecondary,
  );
}
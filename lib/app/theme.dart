import 'dart:ui' show FontFeature;
import 'package:flutter/material.dart';

abstract final class AppColors {
  static const canvasBase = Color(0xfffaf7f5);
  static const auraPeachLight = Color(0xfffbd1be);
  static const auraCoralWarm = Color(0xfff4977a);
  static const auraCoralDeep = Color(0xffe86a42);
  static const inkPrimary = Color(0xff1f1d1b);
  static const inkSecondary = Color(0xff6e6863);
  static const inkMuted = Color(0xff9e9791);
  static const badgePeachBg = Color(0xfffde5da);
  static const starGold = Color(0xfff5a623);
}

abstract final class AppTypography {
  static const numberFeatures = [FontFeature.tabularFigures()];
  static const number = TextStyle(fontFeatures: numberFeatures);
  static const caption = TextStyle(fontSize: 12, color: AppColors.inkSecondary);
  static const title = TextStyle(
    fontSize: 19,
    fontWeight: FontWeight.w600,
    letterSpacing: -.5,
  );
  static const label = TextStyle(fontSize: 14, fontWeight: FontWeight.w600);
}

final appTheme = ThemeData(
  useMaterial3: true,
  fontFamily: 'Inter',
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.auraCoralDeep,
    surface: AppColors.canvasBase,
    onSurface: AppColors.inkPrimary,
  ),
  scaffoldBackgroundColor: AppColors.canvasBase,
  inputDecorationTheme: const InputDecorationTheme(
    border: InputBorder.none,
    isDense: true,
    hintStyle: TextStyle(color: AppColors.inkSecondary, fontSize: 13),
  ),
);

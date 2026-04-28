import 'package:flutter/cupertino.dart';

class AppTheme {
  static const background = Color(0xFFFAF9FE);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceContainer = Color(0xFFEEEDF3);
  static const surfaceContainerLow = Color(0xFFF4F3F8);
  static const surfaceContainerHigh = Color(0xFFE9E7ED);
  static const outline = Color(0xFF717786);
  static const outlineVariant = Color(0xFFC1C6D7);
  static const primary = Color(0xFF007AFF);
  static const primaryContainer = Color(0xFF0070EB);
  static const primaryFixed = Color(0xFFD8E2FF);
  static const secondary = Color(0xFF006E28);
  static const secondaryContainer = Color(0xFF6FFB85);
  static const tertiaryFixed = Color(0xFFFFDAD5);
  static const onSurface = Color(0xFF1A1B1F);
  static const onSurfaceVariant = Color(0xFF414755);
  static const onPrimary = Color(0xFFFFFFFF);
  static const onPrimaryContainer = Color(0xFFFEFCFF);
  static const onSecondary = Color(0xFFFFFFFF);
  static const onSecondaryContainer = Color(0xFF00732A);
  static const error = Color(0xFFBA1A1A);

  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const stackGap = 12.0;
  static const containerPadding = 20.0;

  static const cardShadow = [
    BoxShadow(
      color: Color(0x0D000000),
      offset: Offset(0, 4),
      blurRadius: 12,
    ),
  ];

  static const h1 = TextStyle(
    fontFamily: 'Inter',
    fontSize: 28,
    height: 34 / 28,
    letterSpacing: -0.4,
    fontWeight: FontWeight.w700,
    color: onSurface,
  );

  static const h2 = TextStyle(
    fontFamily: 'Inter',
    fontSize: 22,
    height: 28 / 22,
    letterSpacing: -0.4,
    fontWeight: FontWeight.w600,
    color: onSurface,
  );

  static const body = TextStyle(
    fontFamily: 'Inter',
    fontSize: 17,
    height: 22 / 17,
    letterSpacing: -0.4,
    fontWeight: FontWeight.w400,
    color: onSurfaceVariant,
  );

  static const labelBold = TextStyle(
    fontFamily: 'Inter',
    fontSize: 15,
    height: 20 / 15,
    letterSpacing: -0.2,
    fontWeight: FontWeight.w600,
    color: onSurface,
  );

  static const labelSmall = TextStyle(
    fontFamily: 'Inter',
    fontSize: 13,
    height: 18 / 13,
    letterSpacing: -0.1,
    fontWeight: FontWeight.w400,
    color: onSurfaceVariant,
  );

  static const caption = TextStyle(
    fontFamily: 'Inter',
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w500,
    color: onSurfaceVariant,
  );
}

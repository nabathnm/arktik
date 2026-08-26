import 'package:flutter/material.dart';

class AppColors {
  // Aliases for compatibility
  static const Color primary = primaryNormal;
  static const Color background = baseBackground;
  static const Color secondary = blueNormal;
  static const Color error = redNormal;

  // Primary Colors (Violet from Palette)
  static const Color primaryLight = Color(0xffeae9f1); // V50
  static const Color primaryLightHover = Color(0xffaaa5c8); // V75
  static const Color primaryLightActive = Color(0xff867fae); // V100
  static const Color primaryNormal = Color(0xff2f2373); // V300
  static const Color primaryNormalHover = Color(0xff52488b); // V200
  static const Color primaryNormalActive = Color(0xff211951); // V400
  static const Color primaryDark = Color(0xff1d1546); // V500
  static const Color primaryDarkHover = Color(0xff1d1546); // V500
  static const Color primaryDarkActive = Color(0xff1d1546); // V500
  static const Color primaryDarker = Color(0xff1d1546); // V500

  // Base Colors
  static const Color baseWhite = Colors.white;
  static const Color baseBlack = Colors.black;
  static const Color baseBackground = Color(0xffffffff); // W50

  // Text Colors
  static const Color textHeading = primaryDark;
  static const Color textPrimary = Color(0xff1A1A1A);
  static const Color textSecondary = Color(0xff707070); // Slightly darker than W500 for better readability
  static const Color textWhite = Colors.white;

  // Neutral (White from Palette)
  static const Color neutralLight = Color(0xffffffff); // W50
  static const Color neutralLightHover = Color(0xffffffff); // W75
  static const Color neutralLightActive = Color(0xffffffff); // W100
  static const Color neutralNormal = Color(0xffffffff); // W200
  static const Color neutralNormalHover = Color(0xffffffff); // W300
  static const Color neutralNormalActive = Color(0xffb3b3b3); // W400
  static const Color neutralDark = Color(0xff9c9c9c); // W500
  static const Color neutralDarkHover = Color(0xff9c9c9c);
  static const Color neutralDarkActive = Color(0xff9c9c9c);
  static const Color neutralDarker = Color(0xff9c9c9c);

  // Blue (From Palette)
  static const Color blueLight = Color(0xffedeef6); // B50
  static const Color blueLightHover = Color(0xffb8b7c9); // B75
  static const Color blueLightActive = Color(0xff808ac9); // B100
  static const Color blueNormal = Color(0xff4d50a2); // B300
  static const Color blueNormalHover = Color(0xff6b6eb2); // B200
  static const Color blueNormalActive = Color(0xff363871); // B400
  static const Color blueDark = Color(0xff2f3163); // B500

  // Yellow (From Palette)
  static const Color yellowLight = Color(0xfffefcf1); // Y50
  static const Color yellowLightHover = Color(0xfffdf2c7); // Y75
  static const Color yellowLightActive = Color(0xfffcecb0); // Y100
  static const Color yellowNormal = Color(0xfff9df77); // Y300
  static const Color yellowNormalHover = Color(0xfffae48e); // Y200
  static const Color yellowNormalActive = Color(0xffaebc53); // Y400
  static const Color yellowDark = Color(0xff988849); // Y500
  static const Color yellowDarkHover = Color(0xff988849);
  static const Color yellowDarkActive = Color(0xff988849);
  static const Color yellowDarker = Color(0xff988849);

  // Keep Green & Red for existing UI elements like errors/success
  static const Color greenLight = Color(0xffeaf2ef);
  static const Color greenLightHover = Color(0xffe0ece6);
  static const Color greenLightActive = Color(0xffbed7cc);
  static const Color greenNormal = Color(0xff2e7d5b);
  static const Color greenNormalHover = Color(0xff297152);
  static const Color greenNormalActive = Color(0xff256449);
  static const Color greenDark = Color(0xff235e44);
  static const Color greenDarkHover = Color(0xff1c4b37);
  static const Color greenDarkActive = Color(0xff153829);
  static const Color greenDarker = Color(0xff102c20);

  static const Color redLight = Color(0xfffaecec);
  static const Color redLightHover = Color(0xfff7e3e3);
  static const Color redLightActive = Color(0xffeec5c5);
  static const Color redNormal = Color(0xffc84545);
  static const Color redNormalHover = Color(0xffb43e3e);
  static const Color redNormalActive = Color(0xffa03737);
  static const Color redDark = Color(0xff963434);
  static const Color redDarkHover = Color(0xff782929);
  static const Color redDarkActive = Color(0xff5a1f1f);
  static const Color redDarker = Color(0xff461818);
}

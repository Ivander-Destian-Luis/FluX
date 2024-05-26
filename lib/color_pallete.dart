import 'package:flutter/material.dart';

class ColorPallete {
  late AssetImage logo;
  late Color backgroundColor;
  late Color fontColor;
  late Color textFieldBackgroundColor;
  late Color textFieldTextColor;
  late Color buttonColor;
  late Color postBackgroundColor;
  late Color borderColor;
  Color textLinkColor = const Color(0xFF4F75FB);
}

class DarkModeColorPallete extends ColorPallete {
  DarkModeColorPallete() {
    super.logo = const AssetImage('assets/images/logo-terang.png');
    super.backgroundColor = const Color(0xFF272727);
    super.fontColor = const Color(0xFFFFFFFF);
    super.textFieldBackgroundColor = const Color(0xFF5F6363);
    super.textFieldTextColor = const Color(0xFF8C8A8A);
    super.buttonColor = const Color(0xFF333232);
    super.postBackgroundColor = const Color(0xFF000000);
    super.borderColor = const Color(0xFFFFFFFF);
  }
}

class LightModeColorPallete extends ColorPallete {
  LightModeColorPallete() {
    super.logo = const AssetImage('assets/images/logo-gelap.png');
    super.backgroundColor = const Color(0xFFF3F3F3);
    super.fontColor = const Color(0xFF000000);
    super.textFieldBackgroundColor = const Color(0xFFBEBEBE);
    super.textFieldTextColor = const Color(0xFF626262);
    super.buttonColor = const Color(0xFFB2B2B2);
    super.postBackgroundColor = const Color(0xFFFFFFFF);
    super.borderColor = const Color(0xFF000000);
  }
}

import 'package:flutter/material.dart';
import '/utils/theme/custom_theme/color_theme.dart';

import 'custom_theme/appbar_theme.dart';
import 'custom_theme/bottom_sheet_theme.dart';
import 'custom_theme/checkbox_theme.dart';
import 'custom_theme/drawer_theme.dart';
import 'custom_theme/dropdown_theme.dart';
import 'custom_theme/elevated_button_theme.dart';
import 'custom_theme/outline_button_theme.dart';
import 'custom_theme/text_field_theme.dart';
import 'custom_theme/text_theme.dart';

class TAppTheme {
  TAppTheme._();

  static ThemeData lightTheme = ThemeData(
      useMaterial3: true,
      fontFamily: "Poppins",
      brightness: Brightness.light,
      primaryColor: Colors.blue,
      scaffoldBackgroundColor: Colors.white,
      textTheme: TTextTheme.lightTextTheme,
      elevatedButtonTheme: TElevatedButtonTheme.lightElevatedButtonTheme,
      appBarTheme: TAppBarTheme.lightAppBarTheme,
      checkboxTheme: TCheckboxTheme.lightCheckboxTheme,
      bottomSheetTheme: TBottonSheetTheme.lightBottomSheetThemeData,
      outlinedButtonTheme: TOutlineButtonTheme.lightOutlineButtonTheme,
      inputDecorationTheme: TTextFormFieldTheme.lightInputDecorationTheme,
      splashColor: Colors.grey.withOpacity(0.5),
      shadowColor: const Color(0xffff1f5f9),
      iconTheme: const IconThemeData(
        color: Colors.black,
      ),
      //  colorScheme: TColorScheme.lightColorScheme,
      dropdownMenuTheme: TDropdownMenuTheme.lightDropdownMenuTheme,
      drawerTheme: TDrawerTheme.lightDrawerTheme);

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: "Poppins",
    brightness: Brightness.dark,
    primaryColor: Colors.blue,
    scaffoldBackgroundColor: Colors.black,
    textTheme: TTextTheme.darkTextTheme,
    elevatedButtonTheme: TElevatedButtonTheme.darkElevatedButtonTheme,
    appBarTheme: TAppBarTheme.darkAppBarTheme,
    checkboxTheme: TCheckboxTheme.darkCheckboxTheme,
    bottomSheetTheme: TBottonSheetTheme.lightBottomSheetThemeData,
    outlinedButtonTheme: TOutlineButtonTheme.darkOutlineButtonTheme,
    inputDecorationTheme: TTextFormFieldTheme.darkInputDecorationTheme,
    splashColor: const Color(0xFF111111),
    shadowColor: const Color(0xFF111111),
    iconTheme: const IconThemeData(
      color: Colors.white,
    ),
    dropdownMenuTheme: TDropdownMenuTheme.lightDropdownMenuTheme,
    // colorScheme: TColorScheme.darkColorScheme,
    drawerTheme: TDrawerTheme.darkDrawerTheme,
  );
}

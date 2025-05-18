import 'package:flutter/material.dart';

class Tformatter {
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }
}

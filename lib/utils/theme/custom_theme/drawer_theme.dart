import 'package:flutter/material.dart';

class TDrawerTheme {
  TDrawerTheme._();

  static final lightDrawerTheme = DrawerThemeData(
    backgroundColor: Colors.white,
    scrimColor: Colors.black.withOpacity(0.2),
    elevation: 0,
    surfaceTintColor: Colors.black,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(25),
        bottomRight: Radius.circular(25),
      ),
    ),
  );

  static final darkDrawerTheme = DrawerThemeData(
    backgroundColor: Colors.grey[900],
    scrimColor: Colors.white.withOpacity(0.2),
    elevation: 0,
    surfaceTintColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(25),
        bottomRight: Radius.circular(25),
      ),
    ),
  );
}

import 'package:flutter/material.dart';

final ThemeData _androidTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.indigo,
    accentColor: Colors.indigoAccent,
    primaryColor: Color(0xFFDE143D),
    buttonColor: Color(0xFFDE143D)
);

final ThemeData _iosTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.indigo,
    accentColor: Colors.indigoAccent,
    primaryColor: Color(0xFFDE143D),
    buttonColor: Color(0xFFDE143D)
);

ThemeData getAdaptiveThemeData(BuildContext context){
  return Theme.of(context).platform == TargetPlatform.android ? _androidTheme : _iosTheme;
}

import 'package:flutter/material.dart';

const List<Color> listColors = [
  Colors.pink,
  Colors.blue,
  Colors.red,
  Colors.grey,
  Colors.brown,
  Colors.yellow,
  Colors.green,
];

class AppTheme {
  final int selectedColor;
  final bool isDarkMode;

  AppTheme({this.selectedColor=0, this.isDarkMode=false});

  ThemeData getColor() => ThemeData(
    brightness: isDarkMode? Brightness.dark: Brightness.light,
    colorSchemeSeed: listColors[selectedColor],
    appBarTheme: const AppBarTheme(centerTitle: false)
  );

  AppTheme copyWidht({
    bool? isDarkMode, 
    int? selectedColor}
    ) => AppTheme( 
      isDarkMode: isDarkMode?? this.isDarkMode,
      selectedColor: selectedColor?? this.selectedColor
    );


}
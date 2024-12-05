
import 'package:flutter/material.dart';
final List<Color> listColors = [
  // Tonos cálidos (rojos, naranjas y rosas)
  Color(0xFFE74C3C), // Rojo cereza

  // Tonos amarillos y beige
  Color(0xFFF7D794), // Beige

  // Tonos verdes
  Color(0xFF55E6C1), // Verde lima

  // Tonos azules y aguamarina
  Color(0xFF00CEC9), // Aguamarina
  Color(0xFFADD8E6), // Azul claro

  // Tonos púrpuras
  Color(0xFFAF52DE), // Púrpura
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
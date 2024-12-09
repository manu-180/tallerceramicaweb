
import 'package:flutter/material.dart';
import 'package:taller_ceramica/supabase/functions/cambiar_tema.dart';
import 'package:taller_ceramica/supabase/supabase_barril.dart';


const List<Color> listColors = [
  Color(0xFFE74C3C), 
  Color(0xFFF7D794), 
  Color(0xFF55E6C1), 
  Color(0xFF00CEC9), 
  Color(0xFFADD8E6), 
  Color(0xFFAF52DE), 
];


class AppTheme {
  final int selectedColor;
  final bool isDarkMode;
  final usuarioActivo = Supabase.instance.client.auth.currentUser;


  AppTheme({this.selectedColor=0, this.isDarkMode=false});

  Future<ThemeData> getColor() async {
  int colorIndex = selectedColor; // Usa el valor actual mientras esperas
  try {
    colorIndex = await CambiarTema().obtenerColor(usuarioActivo?.userMetadata?['fullname']);
  } catch (e) {
    debugPrint('Error obteniendo el color: $e');
  }
  return ThemeData(
    brightness: isDarkMode ? Brightness.dark : Brightness.light,
    colorSchemeSeed: listColors[colorIndex],
    appBarTheme: const AppBarTheme(centerTitle: false),
  );
}


  AppTheme copyWidht({
    bool? isDarkMode, 
    int? selectedColor}
    ) => AppTheme( 
      isDarkMode: isDarkMode?? this.isDarkMode,
      selectedColor: selectedColor?? this.selectedColor
    );


}


import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taller_ceramica/config/theme/app_theme.dart';
import 'package:taller_ceramica/supabase/functions/cambiar_tema.dart';
import 'package:taller_ceramica/supabase/supabase_barril.dart';



final listTheColors = Provider((ref) => listColors);

final themeNotifyProvider = StateNotifierProvider<ThemeNotify, AppTheme>((ref) => ThemeNotify());
final usuarioActivo = Supabase.instance.client.auth.currentUser;



class ThemeNotify extends StateNotifier<AppTheme>{

  ThemeNotify() : super(AppTheme());

  void toggleDarkMode () {
    state = state.copyWidht(isDarkMode: !state.isDarkMode);
  }

  void  changeColor(int index){
    CambiarTema().obtenerColor(usuarioActivo?.userMetadata?['fullname']).then((color) {
      state = state.copyWidht(selectedColor: color);
    });
  }


} 


import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taller_ceramica/config/theme/app_theme.dart';



final listTheColors = Provider((ref) => listColors);

final themeNotifyProvider = StateNotifierProvider<ThemeNotify, AppTheme>((ref) => ThemeNotify());


class ThemeNotify extends StateNotifier<AppTheme>{

  ThemeNotify() : super(AppTheme());

  void toggleDarkMode () {
    state = state.copyWidht(isDarkMode: !state.isDarkMode);
  }

  void  changeColor(int index){
    state = state.copyWidht(selectedColor:index);
  }


} 
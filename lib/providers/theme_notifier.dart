import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier extends StateNotifier<ThemeState> {
  ThemeNotifier() : super(ThemeState());

  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    state = ThemeState(
      selectedColor: prefs.getInt('selectedColor') ?? 0,
      isDarkMode: prefs.getBool('isDarkMode') ?? false,
    );
  }

  void changeColor(int index) async {
    state = state.copyWith(selectedColor: index);
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('selectedColor', index);
  }

  void toggleDarkMode() async {
    state = state.copyWith(isDarkMode: !state.isDarkMode);
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', state.isDarkMode);
  }
}


class ThemeState {
  final int selectedColor;
  final bool isDarkMode;

  ThemeState({this.selectedColor = 0, this.isDarkMode = false});

  ThemeState copyWith({int? selectedColor, bool? isDarkMode}) {
    return ThemeState(
      selectedColor: selectedColor ?? this.selectedColor,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }
}

final themeNotifyProvider =
    StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  return ThemeNotifier();
});

import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemeNotifier extends StateNotifier<bool> {
  ThemeNotifier() : super(false); // false significa Modo Claro

  // Función para cambiar entre modo claro/oscuro
  void toggleTheme() {
    state = !state;
  }
}

// Definir el provider de estado
final themeNotifyProvider = StateNotifierProvider<ThemeNotifier, bool>((ref) {
  return ThemeNotifier();
});

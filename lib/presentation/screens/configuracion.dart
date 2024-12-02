import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:taller_ceramica/providers/theme_provider.dart';
import 'package:taller_ceramica/widgets/custom_appbar.dart';

class Configuracion extends ConsumerWidget {
  const Configuracion({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final bool isDark = ref.watch(themeNotifyProvider).isDarkMode;
    final List<Color> colors = ref.watch(listTheColors);
    final int selectedColor = ref.watch(themeNotifyProvider).selectedColor;

    return Scaffold(
      appBar: const CustomAppBar(),
      body: ListView(
        children: [
          // ExpansionTile que envolverá el ListView.builder
          ExpansionTile(
            title: const Text('Elige un color'),
            children: [
              ListView.builder(
                shrinkWrap: true, // Importante para evitar que se expanda y cause problemas de scroll
                physics: const NeverScrollableScrollPhysics(), // Desactiva el scroll del ListView dentro del ExpansionTile
                itemCount: colors.length,
                itemBuilder: (context, index) {
                  final color = colors[index];
                  return RadioListTile(
                    title: Text(
                      "El color es este",
                      style: TextStyle(color: color),
                    ),
                    activeColor: color,
                    value: index,
                    groupValue: selectedColor,
                    onChanged: (value) {
                      ref.read(themeNotifyProvider.notifier).changeColor(index);
                    },
                  ); // Asegúrate de cerrar el RadioListTile correctamente aquí
                },
              ),
              ListTile(
                title: Text(isDark ? 'Modo claro' : 'Modo oscuro'),
                onTap: () {
                  ref.read(themeNotifyProvider.notifier).toggleDarkMode();
                },
                leading: isDark? const Icon(Icons.light_mode_outlined) : const Icon(Icons.dark_mode_outlined),
              ),
              ElevatedButton(
              onPressed: () {
                final user = Supabase.instance.client.auth.currentUser;
                final userId = user!.userMetadata?["fullname"];
                print('Usuario autenticado: $userId');
              },
              child: const Text('Mostrar User ID'),
            ),

            ],
          ),
        ],
      ),
    );
  }
}

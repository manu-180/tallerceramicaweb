// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:taller_ceramica/providers/auth_notifier.dart';
import 'package:taller_ceramica/providers/theme_provider.dart';
import 'package:taller_ceramica/supabase/functions/cambiar_tema.dart';
import 'package:taller_ceramica/widgets/custom_appbar.dart';

class Configuracion extends ConsumerStatefulWidget {
  const Configuracion({super.key});

  @override
  _ConfiguracionState createState() => _ConfiguracionState();
}

class _ConfiguracionState extends ConsumerState<Configuracion> {
  User? user;

  

  @override
  void initState() {
    super.initState();
    // Establece el usuario actual cuando la pantalla se inicializa
    user = ref.read(authProvider); 

  
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    final bool isDark = ref.watch(themeNotifyProvider).isDarkMode;
    final List<Color> colors = ref.watch(listTheColors);
    final int selectedColor = ref.watch(themeNotifyProvider).selectedColor;
    final color = Theme.of(context).colorScheme;
    final usuarioActivo = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      appBar: const CustomAppBar(),
      body: user == null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock_outline, size: 80, color: Colors.grey),
                  const SizedBox(height: 20),
                  Text(
                    'Para cambiar la configuración debes iniciar sesión!',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: color.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 150),
                ],
              ),
            )
          : ListView(
              children: [
                // ExpansionTile que envolverá el ListView.builder
                ExpansionTile(
                  title: const Text('Elige un color'),
                  children: [
                    ListView.builder(
                      shrinkWrap: true, // Evita problemas de scroll
                      physics: const NeverScrollableScrollPhysics(), // Desactiva el scroll dentro del ExpansionTile
                      itemCount: colors.length,
                      itemBuilder: (context, index) {
                        final color = colors[index];
                        return RadioListTile(
                          title: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.palette_outlined,
                                color: color,
                                size: 35,
                              ),
                              const SizedBox(width: 15,),
                              Icon(
                                Icons.palette_outlined,
                                color: color,
                                size: 35,
                              ),
                              const SizedBox(width: 15,),
                              Icon(
                                Icons.palette_outlined,
                                color: color,
                                size: 35,
                              ),
                              const SizedBox(width: 15,),
                              
                            ],
                          ),
                          activeColor: color,
                          value: index,
                          groupValue: selectedColor,
                          onChanged: (value) {
                            CambiarTema().cambiarTema(usuarioActivo?.userMetadata?['fullname'], index);
                            ref.read(themeNotifyProvider.notifier).changeColor(index);
                        },
                        );
                      },
                    ),
                    ListTile(
                      title: Text(isDark ? 'Modo claro' : 'Modo oscuro'),
                      onTap: () {
                        ref.read(themeNotifyProvider.notifier).toggleDarkMode();
                      },
                      leading: isDark
                          ? const Icon(Icons.light_mode_outlined)
                          : const Icon(Icons.dark_mode_outlined),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}

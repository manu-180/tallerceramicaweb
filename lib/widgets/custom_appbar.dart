import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:taller_ceramica/main.dart'; // Asegúrate de tener esta importación


class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  @override
  final Size preferredSize; // Tamaño del AppBar

  const CustomAppBar({super.key}) : preferredSize = const Size.fromHeight(70.0);

  @override
  // ignore: library_private_types_in_public_api
  _CustomAppBarState createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  var user = Supabase.instance.client.auth.currentUser;
  bool _isMenuOpen = false; 

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return AppBar(
      backgroundColor: color.primary, 
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              context.go("/"); 
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Taller de',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color.surface,
                  ),
                ),
                Text(
                  'Cerámica',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color.surface,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16), 
          PopupMenuButton<String>(
            onSelected: (value) {
              
              if (value == '/turnos') {
                context.go('/turnos');
              } else if (value == '/misclases') {
                context.go('/misclases');
              } else if (value == '/gestionhorarios') {
                context.go('/gestionhorarios');
              } else if (value == '/Alumnos/as') {
                context.go('/Alumnos/as');
              } else if (value == '/configuracion') {
                context.go('/configuracion');
              } else if (value == '/usuarios') {
                context.go('/usuarios');
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: '/turnos',
                child: Text('Clases'),
              ),
              const PopupMenuItem(
                value: '/misclases',
                child: Text('Mis clases'),
              ),
              const PopupMenuItem(
                value: '/gestionhorarios',
                child: Text('Gestión horarios'),
              ),
              const PopupMenuItem(
                value: '/usuarios',
                child: Text('Usuarios'),
              ),
              const PopupMenuItem(
                value: '/configuracion',
                child: Text('Configuración'),
              ),
            ],
            icon: AnimatedRotation(
              turns: _isMenuOpen ? 0.5 : 0.0, 
              duration: const Duration(milliseconds: 200),
              child: Icon(Icons.arrow_drop_down, color: color.surface),
            ),
            onOpened: () {
              setState(() {
                _isMenuOpen = true; 
              });
            },
            onCanceled: () {
              setState(() {
                _isMenuOpen = false;
              });
            },
            offset: const Offset(0, 45),
          ),
        ],
      ),
      actions: [
        user == null
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        context.go('/crear-usuario');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color.primaryContainer,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      ),
                      child: const Text(
                        'Crear usuario',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        context.go('/iniciar-sesion');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color.primaryContainer,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      ),
                      child: const Text(
                        'Iniciar sesion',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        await supabase.auth.signOut();
                        setState(() {
                      
                          final nuevoUsuario = Supabase.instance.client.auth.currentUser;
                          user = nuevoUsuario; 
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color.primaryContainer,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      ),
                      child: const Text(
                        'Cerrar Sesión',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 10,)
      ],
    );
  }
}






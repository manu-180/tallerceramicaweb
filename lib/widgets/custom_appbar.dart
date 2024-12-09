import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  @override
  final Size preferredSize; // Tamaño del AppBar

  const CustomAppBar({super.key}) : preferredSize = const Size.fromHeight(70.0);

  @override
  _CustomAppBarState createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  bool _isMenuOpen = false;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return StreamBuilder<User?>(
      stream: Supabase.instance.client.auth.onAuthStateChange.map((event) => event.session?.user),
      builder: (context, snapshot) {
        final user = snapshot.data;
        final userId = user?.id; // Obtiene el id del usuario actual

        // Lista de botones visibles para usuarios con id == 14 o 31
        final adminRoutes = [
          {'value': '/turnos', 'label': 'Clases'},
          {'value': '/misclases', 'label': 'Mis clases'},
          {'value': '/configuracion', 'label': 'Configuración'},
          {'value': '/gestionhorarios', 'label': 'Gestión de horarios'},
          {'value': '/gestionclases', 'label': 'Gestión de clases'},
          {'value': '/usuarios', 'label': 'Usuarios'},
        ];

        // Lista de botones visibles para otros usuarios
        final userRoutes = [
          {'value': '/turnos', 'label': 'Clases'},
          {'value': '/misclases', 'label': 'Mis clases'},
          {'value': '/configuracion', 'label': 'Configuración'},
        ];

        // Determina qué lista de botones mostrar
        final menuItems = (userId == "c1b53dba-88d6-4aea-bede-603e3d9d7ff8" || userId == "939d2e1a-13b3-4af0-be54-1a0205581f3b")
            ? adminRoutes
            : userRoutes;

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
                  context.go(value); // Navega a la ruta seleccionada
                },
                itemBuilder: (BuildContext context) => menuItems
                    .map((route) => PopupMenuItem(
                          value: route['value'] as String,
                          child: Text(route['label'] as String),
                        ))
                    .toList(),
                icon: AnimatedRotation(
                  turns: _isMenuOpen ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(Icons.keyboard_arrow_down_outlined, color: color.surface),
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
                          'Iniciar sesión',
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
                          await Supabase.instance.client.auth.signOut();

                          final prefs = await SharedPreferences.getInstance();
                          await prefs.remove('session');

                          context.go('/');
                        },
                        child: const Text('Cerrar sesión'),
                      ),
                    ],
                  ),
            const SizedBox(width: 10),
          ],
        );
      },
    );
  }
}

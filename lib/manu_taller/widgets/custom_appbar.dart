import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CustomAppBarManu extends StatefulWidget implements PreferredSizeWidget {
  @override
  final Size preferredSize; // Tamaño del AppBar

  const CustomAppBarManu({super.key})
      : preferredSize = const Size.fromHeight(70.0);

  @override
  _CustomAppBarState createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBarManu> {
  bool _isMenuOpen = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final color = Theme.of(context).colorScheme;

    return StreamBuilder<User?>(
      stream: Supabase.instance.client.auth.onAuthStateChange
          .map((event) => event.session?.user),
      builder: (context, snapshot) {
        final user = snapshot.data;
        final userId = user?.id; // Obtiene el id del usuario actual

        // Lista de botones visibles para usuarios con id == 14 o 31
        final adminRoutes = [
          {'value': '/turnosmanu', 'label': 'Clases'},
          {'value': '/misclasesmanu', 'label': 'Mis clases'},
          {'value': '/gestionhorariosmanu', 'label': 'Gestión de horarios'},
          {'value': '/gestionclasesmanu', 'label': 'Gestión de clases'},
          {'value': '/usuariosmanu', 'label': 'Usuarios'},
          {'value': '/configuracionmanu', 'label': 'Configuración'},
          {'value': '/pruebamanu', 'label': 'prueba'},
        ];

        // Lista de botones visibles para otros usuarios
        final userRoutes = [
          {'value': '/turnosmanu', 'label': 'Clases'},
          {'value': '/misclasesmanu', 'label': 'Mis clases'},
          {'value': '/configuracionmanu', 'label': 'Configuración'},
        ];

        // Determina qué lista de botones mostrar
        final menuItems = (userId == "c1b53dba-88d6-4aea-bede-603e3d9d7ff8" ||
                userId == "939d2e1a-13b3-4af0-be54-1a0205581f3b")
            ? adminRoutes
            : userRoutes;

        return AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: color.primary,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  context.push("/homemanu");
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
                      'Manu',
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
                  context.push(value);
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
                  child: Icon(Icons.keyboard_arrow_down_outlined,
                      color: color.surface),
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
                offset: const Offset(-20, 50),
              ),
            ],
          ),
          actions: [
            user == null
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: size.width * 0.25,
                        height: size.height * 0.05,
                        child: ElevatedButton(
                          onPressed: () {
                            context.push('/crear-usuariomanu');
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(3.0),
                            child: Text(
                              'Crear usuario',
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: size.width * 0.25,
                        height: size.height * 0.05,
                        child: ElevatedButton(
                          onPressed: () {
                            context.push('/iniciar-sesionmanu');
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(3.0),
                            child: Text(
                              'Iniciar sesión',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: size.width * 0.35,
                        height: size.height * 0.05,
                        child: ElevatedButton(
                          onPressed: () async {
                            await Supabase.instance.client.auth.signOut();

                            final prefs = await SharedPreferences.getInstance();
                            await prefs.remove('session');

                            context.push('/');
                          },
                          child: const Text('Cerrar sesión'),
                        ),
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

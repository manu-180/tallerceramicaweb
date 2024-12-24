import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:taller_ceramica/config/router/barril_screens.dart';
import 'package:taller_ceramica/ivanna_taller/presentation/screens/cambiar_password.dart';
import 'package:taller_ceramica/ivanna_taller/presentation/screens/configuracion.dart';
import 'package:taller_ceramica/ivanna_taller/presentation/screens/gestion_clases_screen.dart';
import 'package:taller_ceramica/ivanna_taller/presentation/screens/prueba.dart';
import 'package:taller_ceramica/ivanna_taller/presentation/screens/responsive_turnos_screens/resposive_clases_screen.dart';
import 'package:taller_ceramica/ivanna_taller/presentation/screens/update_name_screen.dart';

final appRouter = GoRouter(initialLocation: "/homeivanna", routes: [
  GoRoute(path: "/homeivanna", builder: (context, state) => const HomeScreen()),
  GoRoute(
      path: "/turnosivanna",
      builder: (context, state) {
        final isTablet = MediaQuery.of(context).size.width > 600;
        return ResposiveClasesScreen(isTablet: isTablet);
      },
    ),
  GoRoute(
      path: "/misclasesivanna",
      // name: "misclases",
      builder: (context, state) => const MisClasesScreen()),
  GoRoute(
      path: "/gestionhorariosivanna",
      // name: "gestionhorarios",
      builder: (context, state) => const GestionHorariosScreen()),
  GoRoute(
      path: "/usuariosivanna",
      // name: "usuarios",
      builder: (context, state) => const UsuariosScreen()),
  GoRoute(
      path: "/configuracionivanna",
      // name: "configuracion",
      builder: (context, state) => const Configuracion()),
  GoRoute(
      path: "/iniciar-sesionivanna",
      // name: "iniciar sesion",
      builder: (context, state) => const LoginScreen()),
  GoRoute(
      path: "/crear-usuarioivanna",
      // name: "crear usuario",
      builder: (context, state) => const SignUpScreen()),
  GoRoute(path: "/pruebaivanna", builder: (context, state) => const Prueba()),
  GoRoute(
      path: "/gestionclasesivanna",
      builder: (context, state) => const GestionDeClasesScreen()),
  GoRoute(
      path: "/cambiarpassword",
      builder: (context, state) => const CambiarPassword()),
  GoRoute(
      path: "/cambiarfullname",
      builder: (context, state) => const UpdateNameScreen()),
]);

import 'package:go_router/go_router.dart';
import 'package:taller_ceramica/config/router/barril_screens.dart';
import 'package:taller_ceramica/presentation/screens/configuracion.dart';
import 'package:taller_ceramica/presentation/screens/gestion_clases_screen.dart';
import 'package:taller_ceramica/presentation/screens/prueba.dart';

final appRouter = GoRouter(initialLocation: "/", routes: [
  GoRoute(
      path: "/", name: "home", builder: (context, state) => const HomeScreen()),
  GoRoute(
      path: "/turnos",
      name: "turnos",
      builder: (context, state) => const TurnosScreen()),
  GoRoute(
      path: "/misclases",
      name: "misclases",
      builder: (context, state) => const MisClasesScreen()),
  GoRoute(
      path: "/gestionhorarios",
      name: "gestionhorarios",
      builder: (context, state) => const GestionHorariosScreen()),
  GoRoute(
      path: "/usuarios",
      name: "usuarios",
      builder: (context, state) => const UsuariosScreen()),
  GoRoute(
      path: "/configuracion",
      name: "configuracion",
      builder: (context, state) => const Configuracion()),
  GoRoute(
      path: "/iniciar-sesion",
      name: "iniciar sesion",
      builder: (context, state) => LoginScreen()),
  GoRoute(
      path: "/crear-usuario",
      name: "crear usuario",
      builder: (context, state) => const SignUpScreen()),
  GoRoute(
      path: "/prueba",
      name: "prueba",
      builder: (context, state) => const Prueba()),
  GoRoute(
      path: "/gestionclases",
      name: "gestionclases",
      builder: (context, state) => const GestionDeClasesScreen()),
]);

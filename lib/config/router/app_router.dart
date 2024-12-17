import 'package:go_router/go_router.dart';
import 'package:taller_ceramica/config/router/barril_screens.dart';
import 'package:taller_ceramica/ivanna_taller/presentation/screens/cambiar_password.dart';
import 'package:taller_ceramica/ivanna_taller/presentation/screens/configuracion.dart';
import 'package:taller_ceramica/ivanna_taller/presentation/screens/gestion_clases_screen.dart';
import 'package:taller_ceramica/ivanna_taller/presentation/screens/prueba.dart';
import 'package:taller_ceramica/ivanna_taller/presentation/screens/update_name_screen.dart';
import 'package:taller_ceramica/manu_taller/presentation/screens/configuracion.dart';
import 'package:taller_ceramica/manu_taller/presentation/screens/gestion_clases_screen.dart';
import 'package:taller_ceramica/manu_taller/presentation/screens/gestion_horarios_screen.dart';
import 'package:taller_ceramica/manu_taller/presentation/screens/home_screen.dart';
import 'package:taller_ceramica/manu_taller/presentation/screens/login_screen.dart';
import 'package:taller_ceramica/manu_taller/presentation/screens/mis_clases_screens.dart';
import 'package:taller_ceramica/manu_taller/presentation/screens/prueba.dart';
import 'package:taller_ceramica/manu_taller/presentation/screens/sign_up_screen.dart';
import 'package:taller_ceramica/manu_taller/presentation/screens/turnos_screen.dart';
import 'package:taller_ceramica/manu_taller/presentation/screens/usuarios_screen.dart';

final appRouter = GoRouter(initialLocation: "/homeivanna", routes: [
  GoRoute(path: "/homeivanna", builder: (context, state) => const HomeScreen()),
  GoRoute(
      path: "/turnosivanna",
      // name: "turnos",
      builder: (context, state) => const TurnosScreen()),
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
  GoRoute(
      path: "/pruebaivanna",
      builder: (context, state) => const Prueba()),
  GoRoute(
      path: "/gestionclasesivanna",
      builder: (context, state) => const GestionDeClasesScreen()),
  GoRoute(
    path: "/cambiarpassword",
    builder: (context, state) => const CambiarPassword()),
  GoRoute(
    path: "/cambiarfullname",
    builder: (context, state) => const UpdateNameScreen()),
  
      
  GoRoute(
      path: "/homemanu", builder: (context, state) => const HomeScreenManu()),

  GoRoute(
      path: "/turnosmanu",
      // name: "turnos",
      builder: (context, state) => const TurnosScreenManu()),
  GoRoute(
      path: "/misclasesmanu",
      // name: "misclases",
      builder: (context, state) => const MisClasesScreenManu()),
  GoRoute(
      path: "/gestionhorariosmanu",
      // name: "gestionhorarios",
      builder: (context, state) => const GestionHorariosScreenManu()),
  GoRoute(
      path: "/usuariosmanu",
      // name: "usuarios",
      builder: (context, state) => const UsuariosScreenManu()),
  GoRoute(
      path: "/configuracionmanu",
      // name: "configuracion",
      builder: (context, state) => const ConfiguracionManu()),
  GoRoute(
      path: "/iniciar-sesionmanu",
      // name: "iniciar sesion",
      builder: (context, state) => const LoginScreenManu()),
  GoRoute(
      path: "/crear-usuariomanu",
      // name: "crear usuario",
      builder: (context, state) => const SignUpScreenManu()),
  GoRoute(
      path: "/pruebamanu",
      // name: "prueba",
      builder: (context, state) => const PruebaManu()),
  GoRoute(
      path: "/gestionclasesmanu",
      // name: "gestionclases",
      builder: (context, state) => const GestionDeClasesScreenManu()),
]);

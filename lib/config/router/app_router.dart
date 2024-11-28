
import 'package:go_router/go_router.dart';
import 'package:taller_ceramica/config/router/barril_screens.dart';
import 'package:taller_ceramica/presentation/screens/gestion_horarios_screen.dart';

final appRouter = GoRouter(
  initialLocation: "/",
  routes: [
    GoRoute(
      path: "/",
      name: "home",
      builder: (context, state) => const HomeScreen()
      ),
    GoRoute(
      path: "/turnos",
      name: "turnos",
      builder: (context, state) => const TurnosScreen()
      ),
    GoRoute(
      path: "/misclases",
      name: "misclases",
      builder: (context, state) => const MisClasesScreen()
      ),
    GoRoute(
      path: "/gestionhorarios",
      name: "gestionhorarios",
      builder: (context, state) => const GestionHorariosScreen()
      ),
    
    
      
  ]);
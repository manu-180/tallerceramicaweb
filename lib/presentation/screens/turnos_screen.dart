import 'package:flutter/material.dart';
import 'package:taller_ceramica/main.dart';
import 'package:taller_ceramica/models/clase_models.dart';
import 'package:taller_ceramica/supabase/functions/modificar_alert_trigger.dart';
import 'package:taller_ceramica/supabase/functions/obtener_alert_trigger.dart';
import 'package:taller_ceramica/supabase/supabase_barril.dart';
import 'package:taller_ceramica/widgets/custom_appbar.dart';

class TurnosScreen extends StatefulWidget {
  const TurnosScreen({super.key});

  @override
  State<TurnosScreen> createState() => _TurnosScreenState();
}

class _TurnosScreenState extends State<TurnosScreen> {
  String semanaSeleccionada = 'semana1'; 
  String? diaSeleccionado; 
  final List<String> semanas = ['semana1', 'semana2', 'semana3', 'semana4', 'semana5'];
  bool isLoading = true; 

  List<ClaseModels> todasLasClases = [];
  List<ClaseModels> diasUnicos = [];
  Map<String, List<ClaseModels>> horariosPorDia = {};

  Future<void> cargarDatos() async {
    setState(() {
      isLoading = true; // Indicamos que se está cargando
    });

    final datos = await ObtenerTotalInfo().obtenerInfo();
    final datosSemana = datos.where((clase) => clase.semana == semanaSeleccionada).toList();
    datosSemana.sort((a, b) => a.id.compareTo(b.id));

    final diasSet = <String>{};
    diasUnicos = datosSemana.where((clase) {
      final diaFecha = '${clase.dia} - ${clase.fecha}';
      if (diasSet.contains(diaFecha)) {
        return false;
      } else {
        diasSet.add(diaFecha);
        return true;
      }
    }).toList();

    horariosPorDia = {};
    for (var clase in datosSemana) {
      final diaFecha = '${clase.dia} - ${clase.fecha}';
      horariosPorDia.putIfAbsent(diaFecha, () => []).add(clase);
    }

    if (mounted) {
      setState(() {
        isLoading = false; // Desactivamos el indicador de carga
      });
    }
  }

  void mostrarConfirmacion(BuildContext context, ClaseModels clase) async {
  final user = Supabase.instance.client.auth.currentUser;

  // Obtener mensaje dinámico y condición del botón
  String mensaje;
  bool mostrarBotonAceptar = false;

  if (user == null) {
    mensaje = "Debes iniciar sesión para inscribirte a una clase";
  } else if (clase.mails.contains(user.userMetadata?["fullname"])) {
    mensaje = 'Revisa en "mis clases"';
  } else {
    final clasesDisponibles = await ObtenerClasesDisponibles().clasesDisponibles(user.userMetadata?["fullname"]);
    if (clasesDisponibles == 0) {
      mensaje = "No tienes créditos disponibles para inscribirte a esta clase";
    } 
    final triggerAlert = await ObtenerAlertTrigger().alertTrigger(user.userMetadata?["fullname"]);
    if (triggerAlert > 0 && clasesDisponibles == 0) {
      mensaje = 'No puedes recuperar una clase si cancelaste con menos de 24hs de anticipación';
    } 
    if (Calcular24hs().esMenorA0Horas(clase.fecha, clase.hora)) {
      mensaje = 'No puedes inscribirte a esta clase';
    } 
    else {
      mensaje = '¿Deseas inscribirte a la clase el ${clase.dia} a las ${clase.hora}?';
      mostrarBotonAceptar = true; 
    }
  }

  // Mostrar el diálogo
  showDialog(
    // ignore: use_build_context_synchronously
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          user == null
              ? "Inicia sesión"
              : clase.mails.contains(user.userMetadata?["fullname"])
                  ? "Ya estás inscripto en esta clase"
                  : mensaje == "No tienes créditos disponibles para inscribirte a esta clase" ? "No puedes inscribirte a esta clase" 
                  : mensaje == "No puedes recuperar una clase si cancelaste con menos de 24hs de anticipación" ? "No puedes inscribirte a esta clase" 
                  : mensaje == 'No puedes inscribirte a esta clase' ? "Esta clase ya paso"
                  : 'Confirmar Inscripción' 
        ),
        content: Text(
          mensaje,
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Cerrar el diálogo
            },
            child: const Text('Cancelar'),
          ),
          if (mostrarBotonAceptar)
            ElevatedButton(
              onPressed: () {
                // Ejecuta la función para inscribir al usuario
                manejarSeleccionClase(clase.id, user?.userMetadata?["fullname"] ?? '');
                ModificarAlertTrigger().resetearAlertTrigger(user?.userMetadata?["fullname"] ?? '');
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
              child: const Text('Aceptar'),
            ),
        ],
      );
    },
  );
}


  void manejarSeleccionClase(int id, String user) async {
    await AgregarUsuario(supabase).agregarUsuarioAClase(id, user, false);

    setState(() {
      cargarDatos(); // Esto actualiza los horarios y el estado de los botones.
    });
  }

  void cambiarSemanaAdelante() {
    final indiceActual = semanas.indexOf(semanaSeleccionada);
    final nuevoIndice = (indiceActual + 1) % semanas.length;
    semanaSeleccionada = semanas[nuevoIndice];
    cargarDatos();
  }

  void cambiarSemanaAtras() {
    final indiceActual = semanas.indexOf(semanaSeleccionada);
    final nuevoIndice = (indiceActual - 1 + semanas.length) % semanas.length;
    semanaSeleccionada = semanas[nuevoIndice];
    cargarDatos();
  }

  void seleccionarDia(String dia) {
    setState(() {
      diaSeleccionado = dia;
    });
  }

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  List<String> obtenerDiasConClasesDisponibles() {
    final diasConClases = <String>{};

    horariosPorDia.forEach((dia, clases) {
      if (clases.any((clase) => clase.mails.length < 5)) {
        final diaSolo = dia.split(' - ')[0]; // Extraer solo el día (ej: "Lunes")
        diasConClases.add(diaSolo);
      }
    });

    return diasConClases.toList();
  }

  @override
  Widget build(BuildContext context) {

    final color = Theme.of(context).primaryColor;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: const CustomAppBar(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 20, 10,0),
            child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "En esta sesión podrás ver los horarios disponibles para las clases de cerámica. ¡Reserva tu lugar ahora!",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
          ),
          const SizedBox(height: 30),
          _SemanaNavigation(
            semanaSeleccionada: semanaSeleccionada,
            cambiarSemanaAdelante: cambiarSemanaAdelante,
            cambiarSemanaAtras: cambiarSemanaAtras,
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _DiaSelection(
                          diasUnicos: diasUnicos,
                          seleccionarDia: seleccionarDia,
                        ),
                ),
                                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 40, right: 10),
                    child: diaSeleccionado != null
                        ? isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : ListView.builder(
                                itemCount: horariosPorDia[diaSeleccionado]?.length ?? 0,
                                itemBuilder: (context, index) {
                                  final clase = horariosPorDia[diaSeleccionado]![index];
                                  return construirBotonHorario(clase);
                                },
                              )
                        : const SizedBox(),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            child: Builder(
              builder: (context) {
                final diasConClases = obtenerDiasConClasesDisponibles();
                if (isLoading) {
                  return const SizedBox(); 
                } else if (diasConClases.isEmpty) {
                  return _AvisoDeClasesDisponibles(colors: colors, color: color, diasConClases: diasConClases, text: "No hay clases disponibles esta semana.",);
                } else {
                  return _AvisoDeClasesDisponibles(colors: colors, color: color, diasConClases: diasConClases, text: "Hay clases disponibles el ${diasConClases.join(', ')}.",);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget construirBotonHorario(ClaseModels clase) {
    final diaYHora = '${clase.dia} ${clase.fecha} ${clase.hora}';
    final estaLlena = clase.mails.length >= 5;

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 10, 10),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.7,
        child: ElevatedButton(
          onPressed: estaLlena 
              ? null 
              : () => mostrarConfirmacion(context, clase),
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(
              estaLlena ? Colors.grey : Colors.green,
            ),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text(diaYHora, style: const TextStyle(fontSize: 11, color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}

class _AvisoDeClasesDisponibles extends StatelessWidget {
  const _AvisoDeClasesDisponibles({
    required this.text,
    required this.colors,
    required this.color,
    required this.diasConClases,
  });

  final ColorScheme colors;
  final Color color;
  final List<String> diasConClases;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colors.secondaryContainer, colors.primary.withOpacity(0.6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withOpacity(0.55),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.info,
            color: color,
            size: 32,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


// Widget para la navegación de semanas
class _SemanaNavigation extends StatelessWidget {
  final String semanaSeleccionada;
  final VoidCallback cambiarSemanaAdelante;
  final VoidCallback cambiarSemanaAtras;

  const _SemanaNavigation({
    required this.semanaSeleccionada,
    required this.cambiarSemanaAdelante,
    required this.cambiarSemanaAtras,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          IconButton(
            onPressed: cambiarSemanaAtras,
            icon: const Icon(Icons.arrow_left, size: 28),
          ),
          const SizedBox(width: 40),
          IconButton(
            onPressed: cambiarSemanaAdelante,
            icon: const Icon(Icons.arrow_right, size: 28),
          ),
        ],
      ),
    );
  }
}

// Widget para la selección de días
class _DiaSelection extends StatelessWidget {

  

  final List<ClaseModels> diasUnicos;
  final Function(String) seleccionarDia;

  const _DiaSelection({
    required this.diasUnicos,
    required this.seleccionarDia,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: diasUnicos.length,
      itemBuilder: (context, index) {
        final clase = diasUnicos[index];
        final diaFecha = '${clase.dia} - ${clase.fecha}';
        return Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 0, 10),
          child: ElevatedButton(
            onPressed: () => seleccionarDia(diaFecha),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(diaFecha, style: const TextStyle(fontSize: 11)),
          ),
        );
      },
    );
  }
}
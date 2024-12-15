// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:taller_ceramica/ivanna_taller/supabase/functions/agregar_usuario.dart';
import 'package:taller_ceramica/ivanna_taller/supabase/functions/calcular_24hs.dart';
import 'package:taller_ceramica/ivanna_taller/supabase/functions/obtener_clases_disponibles.dart';
import 'package:taller_ceramica/ivanna_taller/supabase/functions/obtener_total_info.dart';
import 'package:taller_ceramica/main.dart';
import 'package:taller_ceramica/ivanna_taller/models/clase_models.dart';
import 'package:taller_ceramica/ivanna_taller/supabase/functions/modificar_alert_trigger.dart';
import 'package:taller_ceramica/ivanna_taller/supabase/functions/obtener_alert_trigger.dart';
import 'package:taller_ceramica/ivanna_taller/supabase/supabase_barril.dart';
import 'package:taller_ceramica/ivanna_taller/utils/generar_fechas_del_mes.dart';
import 'package:taller_ceramica/ivanna_taller/widgets/custom_appbar.dart';

class TurnosScreen extends StatefulWidget {
  const TurnosScreen({super.key});

  @override
  State<TurnosScreen> createState() => _TurnosScreenState();
}

class _TurnosScreenState extends State<TurnosScreen> {
  List<String> fechasDisponibles = [];
  String semanaSeleccionada = 'semana1';
  String? diaSeleccionado;
  final List<String> semanas = [
    'semana1',
    'semana2',
    'semana3',
    'semana4',
    'semana5'
  ];
  bool isLoading = true;

  List<ClaseModels> todasLasClases = [];
  List<ClaseModels> diasUnicos = [];
  Map<String, List<ClaseModels>> horariosPorDia = {};

  Future<void> cargarDatos() async {
    setState(() {
      isLoading = true; // Indicamos que se está cargando
    });

    final datos = await ObtenerTotalInfo().obtenerInfo();

    // Filtramos las clases por la semana seleccionada
    final datosSemana =
        datos.where((clase) => clase.semana == semanaSeleccionada).toList();

    // Crea un objeto DateFormat para el formato "dd/MM/yyyy HH:mm"
    final dateFormat = DateFormat("dd/MM/yyyy HH:mm");

    // Ordenamos primero por la fecha (ascendente) y luego por la hora (ascendente)
    datosSemana.sort((a, b) {
      // Concatenamos la hora al dato de fecha ya existente
      String fechaA = '${a.fecha} ${a.hora}';
      String fechaB = '${b.fecha} ${b.hora}';

      // Convierte las fechas y horas a DateTime usando DateFormat
      DateTime parsedFechaA = dateFormat.parse(fechaA);
      DateTime parsedFechaB = dateFormat.parse(fechaB);

      return parsedFechaA.compareTo(parsedFechaB);
    });

    // Extraemos días únicos basados en la fecha y día
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

    // Inicializar variables para el mensaje y el botón
    String mensaje;
    bool mostrarBotonAceptar = false;

    // Verificar si el usuario está autenticado
    if (user == null) {
      mensaje = "Debes iniciar sesión para inscribirte a una clase";
    } else if (clase.mails.contains(user.userMetadata?['fullname'])) {
      mensaje = 'Revisa en "mis clases"';
    } else {
      // Verificar clases disponibles
      // Verificar restricciones adicionales
      final triggerAlert = await ObtenerAlertTrigger()
          .alertTrigger(user.userMetadata?['fullname']);
      final clasesDisponibles = await ObtenerClasesDisponibles()
          .clasesDisponibles(user.userMetadata?['fullname']);

      if (triggerAlert > 0 && clasesDisponibles == 0) {
        mensaje =
            'No puedes recuperar una clase si cancelaste con menos de 24hs de anticipación';
        _mostrarDialogo(context, mensaje, mostrarBotonAceptar);
        return;
      }

      if (clasesDisponibles == 0) {
        mensaje =
            "No tienes créditos disponibles para inscribirte a esta clase";
        _mostrarDialogo(context, mensaje, mostrarBotonAceptar);
        return;
      }

      // Verificar si la clase está dentro del plazo permitido
      if (Calcular24hs().esMenorA0Horas(clase.fecha, clase.hora)) {
        mensaje = 'No puedes inscribirte a esta clase';
        _mostrarDialogo(context, mensaje, mostrarBotonAceptar);
        return;
      }

      // Si no hay restricciones, configurar el mensaje de confirmación
      mensaje =
          '¿Deseas inscribirte a la clase el ${clase.dia} a las ${clase.hora}?';
      mostrarBotonAceptar = true;
    }

    // Mostrar el diálogo final
    _mostrarDialogo(context, mensaje, mostrarBotonAceptar, clase, user);
  }

  void _mostrarDialogo(
      BuildContext context, String mensaje, bool mostrarBotonAceptar,
      [ClaseModels? clase, dynamic user]) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            _obtenerTituloDialogo(mensaje),
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
                  if (clase != null && user != null) {
                    manejarSeleccionClase(
                        clase, user.userMetadata?['fullname'] ?? '');
                    ModificarAlertTrigger().resetearAlertTrigger(
                        user.userMetadata?['fullname'] ?? '');
                  }
                  Navigator.of(context).pop(); // Cerrar el diálogo
                },
                child: const Text('Aceptar'),
              ),
          ],
        );
      },
    );
  }

  String _obtenerTituloDialogo(String mensaje) {
    if (mensaje == "Debes iniciar sesión para inscribirte a una clase") {
      return "Inicia sesión";
    } else if (mensaje == 'Revisa en "mis clases"') {
      return "Ya estás inscrito en esta clase";
    } else if (mensaje ==
            "No tienes créditos disponibles para inscribirte a esta clase" ||
        mensaje ==
            'No puedes recuperar una clase si cancelaste con menos de 24hs de anticipación' ||
        mensaje == 'No puedes inscribirte a esta clase') {
      return "No puedes inscribirte a esta clase";
    } else {
      return "Confirmar Inscripción";
    }
  }

  void manejarSeleccionClase(ClaseModels clase, String user) async {
    await AgregarUsuario(supabase)
        .agregarUsuarioAClase(clase.id, user, false, clase);

    setState(() {
      cargarDatos();
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
    fechasDisponibles = GenerarFechasDelMes().generarFechasLunesAViernes();
    cargarDatos();
  }

  List<String> obtenerDiasConClasesDisponibles() {
    final diasConClases = <String>{};
    horariosPorDia.forEach((dia, clases) {
      if (clases.any((clase) =>
          clase.mails.length < 5 &&
          !Calcular24hs().esMenorA0Horas(clase.fecha, clase.hora))) {
        final diaSolo =
            dia.split(' - ')[0]; // Extraer solo el día (ej: "Lunes")
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
            padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
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
          const SizedBox(height: 15),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: isLoading
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Column(
                            children: [
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Center(
                                    child: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 3,
                                        ))),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Center(
                                    child: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 3,
                                        ))),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Center(
                                    child: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 3,
                                        ))),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Center(
                                    child: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 3,
                                        ))),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Center(
                                    child: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 3,
                                        ))),
                              ),
                            ],
                          ),
                        )
                      : _DiaSelection(
                          diasUnicos: diasUnicos,
                          seleccionarDia: seleccionarDia,
                          fechasDisponibles: fechasDisponibles,
                        ),
                ),
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 40, right: 10),
                    child: diaSeleccionado != null
                        ? isLoading
                            ? const SizedBox()
                            : ListView.builder(
                                itemCount:
                                    horariosPorDia[diaSeleccionado]?.length ??
                                        0,
                                itemBuilder: (context, index) {
                                  final clase =
                                      horariosPorDia[diaSeleccionado]![index];
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
                  return _AvisoDeClasesDisponibles(
                    colors: colors,
                    color: color,
                    text: "No hay clases disponibles esta semana.",
                  );
                } else {
                  return _AvisoDeClasesDisponibles(
                    colors: colors,
                    color: color,
                    text:
                        "Hay clases disponibles el ${diasConClases.join(', ')}.",
                  );
                }
              },
            ),
          ),
          const SizedBox(
            height: 30,
          )
        ],
      ),
    );
  }

  Widget construirBotonHorario(ClaseModels clase) {
    final partesFecha = clase.fecha.split('/');
    final diaMes = '${partesFecha[0]}/${partesFecha[1]}';
    final diaYHora = '${clase.dia} $diaMes - ${clase.hora}';
    final estaLlena = clase.mails.length >= 5;

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 10, 10),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.7,
        child: ElevatedButton(
          onPressed: (estaLlena ||
                  Calcular24hs().esMenorA0Horas(clase.fecha, clase.hora) ||
                  clase.lugaresDisponibles == 0)
              ? null
              : () => mostrarConfirmacion(context, clase),
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(
              estaLlena ||
                      Calcular24hs().esMenorA0Horas(clase.fecha, clase.hora) ||
                      clase.lugaresDisponibles == 0
                  ? Colors.grey
                  : Colors.green,
            ),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text(
                diaYHora,
                style: const TextStyle(fontSize: 11, color: Colors.white),
              ),
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
  });

  final ColorScheme colors;
  final Color color;
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
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade200,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 1,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: cambiarSemanaAtras,
                icon: const Icon(Icons.arrow_left, size: 28),
                color: Colors.black,
              ),
            ),
            const SizedBox(width: 45),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade200,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 1,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: cambiarSemanaAdelante,
                icon: const Icon(Icons.arrow_right, size: 28),
                color: Colors.black, // Color del ícono (puedes personalizarlo)
              ),
            ),
          ],
        ));
  }
}

// Widget para la selección de días
class _DiaSelection extends StatelessWidget {
  final List<ClaseModels> diasUnicos;
  final Function(String) seleccionarDia;
  final List<String> fechasDisponibles;

  const _DiaSelection({
    required this.diasUnicos,
    required this.seleccionarDia,
    required this.fechasDisponibles,
  });

  @override
  Widget build(BuildContext context) {
    final currentMonth = DateTime.now().month;

    return ListView.builder(
      itemCount: diasUnicos.length,
      itemBuilder: (context, index) {
        final clase = diasUnicos[index];

        // Procesar clase.fecha para mostrar solo día y mes
        final partesFecha = clase.fecha.split('/');
        final diaMes = '${partesFecha[0]}/${partesFecha[1]}';
        final diaMesAnio = '${clase.dia} - ${clase.fecha}';

        final diaFecha = '${clase.dia} - $diaMes';

        // Filtrar fechasDisponibles para mostrar solo las fechas del mes actual
        final filteredFechas = fechasDisponibles.where((dateString) {
          final partes = dateString.split('/');
          final fecha = DateTime(
            int.parse(partes[2]), // Año
            int.parse(partes[1]), // Mes
            int.parse(partes[0]), // Día
          );

          // Compara solo el mes
          return fecha.month == currentMonth;
        }).toList();

        // Si la fecha está en el mes actual, mostrar el botón
        if (filteredFechas.contains(clase.fecha)) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 0, 10),
            child: SizedBox(
              child: ElevatedButton(
                onPressed: () => seleccionarDia(diaMesAnio),
                style: ElevatedButton.styleFrom(
                  // backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(diaFecha, style: const TextStyle(fontSize: 10)),
              ),
            ),
          );
        } else {
          return const SizedBox
              .shrink(); // Si no está en el mes actual, no mostrar nada
        }
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:taller_ceramica/ivanna_taller/widgets/responsive_appbar.dart';
import 'package:taller_ceramica/main.dart';
import 'package:taller_ceramica/ivanna_taller/models/clase_models.dart';
import 'package:taller_ceramica/ivanna_taller/supabase/supabase_barril.dart';
import 'package:taller_ceramica/ivanna_taller/utils/generar_fechas_del_mes.dart';

class ClasesTabletScreen extends StatefulWidget {
  const ClasesTabletScreen({super.key});

  @override
  State<ClasesTabletScreen> createState() => _ClasesScreenState();
}

class _ClasesScreenState extends State<ClasesTabletScreen> {
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
      if (context.mounted) {
        _mostrarDialogo(context, mensaje, mostrarBotonAceptar);
      }
      return;
    }

    if (clase.mails.contains(user.userMetadata?['fullname'])) {
      mensaje = 'Revisa en "mis clases"';
      if (context.mounted) {
        _mostrarDialogo(context, mensaje, mostrarBotonAceptar);
      }
      return;
    }

    // Operaciones asincrónicas
    final triggerAlert = await ObtenerAlertTrigger()
        .alertTrigger(user.userMetadata?['fullname']);
    final clasesDisponibles = await ObtenerClasesDisponibles()
        .clasesDisponibles(user.userMetadata?['fullname']);

    if (!context.mounted) return; // Verificar si el widget sigue montado

    if (triggerAlert > 0 && clasesDisponibles == 0) {
      mensaje =
          'No puedes recuperar una clase si cancelaste con menos de 24hs de anticipación';
      if (context.mounted) {
        _mostrarDialogo(context, mensaje, mostrarBotonAceptar);
      }
      return;
    }

    if (clasesDisponibles == 0) {
      mensaje = "No tienes créditos disponibles para inscribirte a esta clase";
      if (context.mounted) {
        _mostrarDialogo(context, mensaje, mostrarBotonAceptar);
      }
      return;
    }

    if (Calcular24hs().esMenorA0Horas(clase.fecha, clase.hora)) {
      mensaje = 'No puedes inscribirte a esta clase';
      if (context.mounted) {
        _mostrarDialogo(context, mensaje, mostrarBotonAceptar);
      }
      return;
    }
    mensaje =
        '¿Deseas inscribirte a la clase el ${clase.dia} a las ${clase.hora}?';
    mostrarBotonAceptar = true;

    if (context.mounted) {
      _mostrarDialogo(context, mensaje, mostrarBotonAceptar, clase, user);
    }
  }

  void _mostrarDialogo(
      BuildContext context, String mensaje, bool mostrarBotonAceptar,
      [ClaseModels? clase, dynamic user]) {
    // Verificar si el widget sigue montado antes de usar el contexto
    if (!context.mounted) return;

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
    final currentMonth = DateTime.now().month;

    horariosPorDia.forEach((dia, clases) {
      if (clases.any((clase) =>
          clase.mails.length < 5 &&
          !Calcular24hs().esMenorA0Horas(clase.fecha, clase.hora) &&
          clase.lugaresDisponibles > 0)) {
        final partesFecha = dia.split(' - ')[1].split('/');
        final diaMes = int.parse(partesFecha[1]);
        if (diaMes == currentMonth) {
          final diaSolo =
              dia.split(' - ')[0]; // Extraer solo el día (ej: "Lunes")
          diasConClases.add(diaSolo);
        }
      }
    });

    return diasConClases.toList();
  }

  @override
Widget build(BuildContext context) {
  final color = Theme.of(context).primaryColor;
  final colors = Theme.of(context).colorScheme;
  final size = MediaQuery.of(context).size;
  final user = Supabase.instance.client.auth.currentUser;


  return Scaffold(
    appBar: ResponsiveAppBar(isTablet: size.width > 600),
    body: user == null ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock_outline, size: 80, color: Colors.grey),
                  const SizedBox(height: 20),
                  Text(
                    'Para inscribirte a una clase debes iniciar sesión!',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ) : Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600), 
        child: Column(
          children: [
            _SemanaNavigation(
              semanaSeleccionada: semanaSeleccionada,
              cambiarSemanaAdelante: cambiarSemanaAdelante,
              cambiarSemanaAtras: cambiarSemanaAtras,
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
  flex: 2,
  child: isLoading
      ? const Center(
          child: SizedBox(
            width: 50,
            height: 50,
            child: CircularProgressIndicator(),
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
                ],
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 20),
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
          ],
        ),
      ),
    ),
  );
}


  Widget construirBotonHorario(ClaseModels clase) {
    final partesFecha = clase.fecha.split('/');
    final diaMes = '${partesFecha[0]}/${partesFecha[1]}';
    final diaYHora = '${clase.dia} $diaMes - ${clase.hora}';
    final estaLlena = clase.mails.length >= 5;
    final screenWidth = MediaQuery.of(context).size.width;
    final user = Supabase.instance.client.auth.currentUser;

    return Column(
      children: [
        SizedBox(
          width: screenWidth * 0.15,
          height: screenWidth * 0.035,
          child: ElevatedButton(
            onPressed: ((estaLlena ||
                        Calcular24hs()
                            .esMenorA0Horas(clase.fecha, clase.hora) ||
                        clase.lugaresDisponibles == 0) &&
                    user?.id != "939d2e1a-13b3-4af0-be54-1a0205581f3b")
                ? null
                : () {
                    if (user?.id != "939d2e1a-13b3-4af0-be54-1a0205581f3b") {
                      mostrarConfirmacion(context, clase);
                    } else {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Los alumnos de esta clase son: ${clase.mails.join(', ')}",
                          ),
                          duration: const Duration(seconds: 5),
                          behavior: SnackBarBehavior.floating,
                          margin: const EdgeInsets.all(10),
                        ),
                      );
                    }
                  },
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(
                estaLlena ||
                        Calcular24hs()
                            .esMenorA0Horas(clase.fecha, clase.hora) ||
                        clase.lugaresDisponibles == 0
                    ? Colors.grey.shade400
                    : Colors.green,
              ),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(screenWidth * 0.05)),
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
        const SizedBox(height: 18),
      ],
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
    // Obtener dimensiones de la pantalla
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.12, // 10% del alto de la pantalla
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.secondaryContainer,
            colors.primary.withAlpha(70),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(
            screenWidth * 0.03), // 3% del ancho para el borde redondeado
      
      ),
      child: Row(
        children: [
          SizedBox(width: screenWidth * 0.02), // 5% del ancho para el espaciado
          Icon(
            Icons.info,
            color: color,
            size: screenWidth * 0.03, // 8% del ancho para el tamaño del ícono
          ),
          SizedBox(width: screenWidth * 0.02), // 3% del ancho para el espaciado
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize:
                    screenWidth * 0.015, // 4% del ancho para el tamaño de fuente
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
    // Dimensiones de la pantalla
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04, vertical: screenHeight * 0.02,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: screenWidth * 0.03, // 12% del ancho de la pantalla
            height: screenWidth * 0.03, // 12% del ancho para que sea circular
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade200,
            ),
            child: IconButton(
              onPressed: cambiarSemanaAtras,
              icon: const Icon(
                Icons.arrow_left,
              ),
              color: Colors.black,
            ),
          ),
          SizedBox(width: screenWidth * 0.06), // Espaciado entre los botones
          Container(
            width: screenWidth * 0.03,
            height: screenWidth * 0.03,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade200,
            ),
            child: IconButton(
              onPressed: cambiarSemanaAdelante,
              icon: const Icon(
                Icons.arrow_right,
              ),
              color: Colors.black,
            ),
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
  final List<String> fechasDisponibles;

  const _DiaSelection({
    required this.diasUnicos,
    required this.seleccionarDia,
    required this.fechasDisponibles,
  });

  @override
Widget build(BuildContext context) {
  final currentMonth = 5;
  final screenWidth = MediaQuery.of(context).size.width;
  final screenHeight = MediaQuery.of(context).size.height;

  return ListView.builder(
    itemCount: diasUnicos.length,
    itemBuilder: (context, index) {
      final clase = diasUnicos[index];
      final partesFecha = clase.fecha.split('/');

      final dia = int.parse(partesFecha[0]);
      final mes = int.parse(partesFecha[1]);
      final anio = int.parse(partesFecha[2]);

      final fechaClase = DateTime(anio, mes, dia);

      // Mostramos el botón solo si la clase es del mes actual (abril)
      if (fechaClase.month == currentMonth) {
        final diaMes = '${partesFecha[0]}/${partesFecha[1]}';
        final diaMesAnio = '${clase.dia} - ${clase.fecha}';
        final diaFecha = '${clase.dia} - $diaMes';

        return Column(
          children: [
            SizedBox(
              width: screenWidth * 0.15,
              height: screenHeight * 0.075,
              child: ElevatedButton(
                onPressed: () => seleccionarDia(diaMesAnio),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(screenWidth * 0.03),
                  ),
                ),
                child: Text(
                  diaFecha,
                  style: TextStyle(fontSize: screenWidth * 0.012),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        );
      } else {
        return const SizedBox.shrink();
      }
    },
  );
}

}

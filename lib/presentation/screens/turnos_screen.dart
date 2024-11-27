import 'package:flutter/material.dart';
import 'package:taller_ceramica/main.dart';
import 'package:taller_ceramica/supabase/functions/agregar_usuario.dart';
import 'package:taller_ceramica/supabase/functions/obtener_total_info.dart';

class TurnosScreen extends StatefulWidget {
  const TurnosScreen({super.key});

  @override
  State<TurnosScreen> createState() => _TurnosScreenState();
}

class _TurnosScreenState extends State<TurnosScreen> {
  String semanaSeleccionada = 'semana1'; // Semana inicial
  String? diaSeleccionado; // Día seleccionado (para mostrar horarios)
  final List<String> semanas = ['semana1', 'semana2', 'semana3', 'semana4', 'semana5'];

  List<Map<String, dynamic>> diasUnicos = [];
  Map<String, List<Map<String, dynamic>>> horariosPorDia = {};

  Future<void> cargarDatos() async {
    final datos = await ObtenerTotalInfo().obtenerInfo();

    // Filtrar los datos según la semana seleccionada
    final datosSemana = List<Map<String, dynamic>>.from(
      datos.where((elemento) => elemento['semana'] == semanaSeleccionada),
    );

    // Ordenar por ID
    datosSemana.sort((a, b) => a['id'].compareTo(b['id']));

    // Filtrar días únicos
    final diasSet = <String>{};
    diasUnicos = datosSemana.where((turno) {
      final diaFecha = '${turno['dia']} - ${turno['fecha']}';
      if (diasSet.contains(diaFecha)) {
        return false;
      } else {
        diasSet.add(diaFecha);
        return true;
      }
    }).toList();

    // Mapear horarios por día
    horariosPorDia = {};
    for (var turno in datosSemana) {
      final diaFecha = '${turno['dia']} - ${turno['fecha']}';
      if (!horariosPorDia.containsKey(diaFecha)) {
        horariosPorDia[diaFecha] = [];
      }
      horariosPorDia[diaFecha]!.add(turno);
    }

    // Limpiar selección al cambiar semana
    diaSeleccionado = null;

    setState(() {});
  }

  void manejarSeleccionClase(int id, String user) {
    AgregarUsuario(supabase).agregarUsuarioAClase(id, user);
  }

  void cambiarSemanaAdelante() {
    final indiceActual = semanas.indexOf(semanaSeleccionada);
    final nuevoIndice = (indiceActual + 1) % semanas.length; // Ciclo circular hacia adelante
    semanaSeleccionada = semanas[nuevoIndice];
    cargarDatos(); // Recargar datos con la nueva semana
  }

  void cambiarSemanaAtras() {
    final indiceActual = semanas.indexOf(semanaSeleccionada);
    final nuevoIndice = (indiceActual - 1 + semanas.length) % semanas.length; // Ciclo circular hacia atrás
    semanaSeleccionada = semanas[nuevoIndice];
    cargarDatos(); // Recargar datos con la nueva semana
  }

  void seleccionarDia(String dia) {
    setState(() {
      diaSeleccionado = dia;
    });
  }

  @override
  void initState() {
    super.initState();
    cargarDatos(); // Cargar datos iniciales
  }

@override
Widget build(BuildContext context) {
  // Obtener el ancho de la pantalla
  final double screenWidth = MediaQuery.of(context).size.width;

  return Scaffold(
    appBar: AppBar(
      title: const Text('Turnos'),
    ),
    body: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: cambiarSemanaAtras,
              icon: const Icon(Icons.arrow_left, size: 28),
            ),
            const SizedBox(width: 40), // Espaciado entre las flechas
            IconButton(
              onPressed: cambiarSemanaAdelante,
              icon: const Icon(Icons.arrow_right, size: 28),
            ),
          ],
        ),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start, // Alinea arriba
            children: [
              // Sección izquierda: Botones de días
              Expanded(
                flex: 2,
                child: ListView.builder(
                  itemCount: diasUnicos.length,
                  itemBuilder: (context, index) {
                    final turno = diasUnicos[index];
                    final diaFecha = '${turno['dia']} - ${turno['fecha']}';
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(10, 10, 0, 10),
                      child: Align(
                        alignment: Alignment.topLeft, // Alinear a la izquierda
                        child: SizedBox(
                          width: screenWidth * 0.65, // 65% del ancho de la pantalla
                          child: ElevatedButton(
                              onPressed: () => seleccionarDia(diaFecha),
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            child: Text(
                              diaFecha,
                              style: const TextStyle(fontSize: 11),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Sección derecha: Botones de horarios
              Expanded(
                flex: 3,
                child: diaSeleccionado != null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min, // Mantén el tamaño mínimo
                        children: [
                          horariosPorDia[diaSeleccionado] != null &&
                                  horariosPorDia[diaSeleccionado]!.isNotEmpty
                              ? ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: horariosPorDia[diaSeleccionado]!.length,
                                  itemBuilder: (context, index) {
                                    final horario = horariosPorDia[diaSeleccionado]![index];
                                    final diaYHora =
                                        '${horario['dia']} ${horario['fecha']} ${horario['hora']}';
                                    final idClase = horario['id'];
                                    return Padding(
                                      padding: const EdgeInsets.fromLTRB(0, 10, 10, 10),
                                      child: Align(
                                        alignment: Alignment.topCenter, // Alinear arriba y centro
                                        child: SizedBox(
                                          width: screenWidth * 0.50, // Ajustar ancho
                                          child: FilledButton(
                                            onPressed: () {
                                              manejarSeleccionClase(
                                                idClase,
                                                "manunv97@gmail.com",
                                              );
                                            },
                                            style: ButtonStyle(
                                              backgroundColor: MaterialStateProperty.all(
                                                  Colors.green),
                                              shape: MaterialStateProperty.all(
                                                RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                              ),
                                            ),
                                            child: Text(
                                              diaYHora,
                                              style: const TextStyle(fontSize: 11),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                )
                              : const Text('No hay clases disponibles para este día.'),
                        ],
                      )
                    : const Center(
                        child: Text('Seleccione un día para ver las clases'),
                      ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
}
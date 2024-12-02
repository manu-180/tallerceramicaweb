import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:taller_ceramica/main.dart';
import 'package:taller_ceramica/supabase/functions/agregar_usuario.dart';
import 'package:taller_ceramica/supabase/functions/obtener_total_info.dart';
import 'package:taller_ceramica/models/clase_models.dart';
import 'package:taller_ceramica/widgets/custom_appbar.dart';

class TurnosScreen extends StatefulWidget {
  const TurnosScreen({super.key});

  @override
  State<TurnosScreen> createState() => _TurnosScreenState();
}

class _TurnosScreenState extends State<TurnosScreen> {
  String semanaSeleccionada = 'semana1'; // Semana inicial
  String? diaSeleccionado; // Día seleccionado
  final List<String> semanas = ['semana1', 'semana2', 'semana3', 'semana4', 'semana5'];
  bool isLoading = true; // Indicador de carga

  List<ClaseModels> todasLasClases = [];
  List<ClaseModels> diasUnicos = [];
  Map<String, List<ClaseModels>> horariosPorDia = {};

  Future<void> cargarDatos() async {
    setState(() {
      isLoading = true;
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
        isLoading = false;
      });
    }
  }

  void manejarSeleccionClase(int id, String user) async {
    await AgregarUsuario(supabase).agregarUsuarioAClase(id, user);

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

  Widget construirBotonHorario(ClaseModels clase) {
    final user = Supabase.instance.client.auth.currentUser;
    
    final diaYHora = '${clase.dia} ${clase.fecha} ${clase.hora}';
    final estaLlena = clase.mails.length >= 5; // Verifica si la clase está llena

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 10, 10),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.7,
        child: FilledButton(
          onPressed: (estaLlena) 
              ? null  // Solo deshabilita el botón si la clase tiene 5 personas
              : () => manejarSeleccionClase(clase.id, user?.userMetadata?["fullname"]),
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(
              (estaLlena) ? Colors.grey : Colors.green, // Cambia el color si está llena
            ),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          child: Text(diaYHora, style: const TextStyle(fontSize: 11)),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Column(
        children: [
          _SemanaNavigation(
            semanaSeleccionada: semanaSeleccionada,
            cambiarSemanaAdelante: cambiarSemanaAdelante,
            cambiarSemanaAtras: cambiarSemanaAtras,
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sección de días
                Expanded(
                  flex: 2,
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _DiaSelection(
                          diasUnicos: diasUnicos,
                          seleccionarDia: seleccionarDia,
                        ),
                ),
                // Sección de horarios
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
                        : null,
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
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
